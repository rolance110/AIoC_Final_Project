import torch
import torch.nn as nn
import torch.quantization as tq
import torch.nn.functional as F

# ─── ① 手动实现 Conv+BN 参数折叠 ───────────────────────────────────────
def fuse_conv_bn(conv: nn.Conv2d, bn: nn.BatchNorm2d) -> nn.Conv2d:
    """返回一个新的 Conv2d，其 weight/bias 已经把 bn 参数 fold 进去了，带 bias=True。"""
    fused_conv = nn.Conv2d(
        conv.in_channels, conv.out_channels,
        conv.kernel_size, conv.stride, conv.padding,
        conv.dilation, conv.groups,
        bias=True
    )

    # 拷贝原 conv weight
    W = conv.weight.detach().clone()
    # 原 bias（如果没有就用 0）
    if conv.bias is not None:
        b = conv.bias.detach().clone()
    else:
        b = torch.zeros(conv.out_channels, device=W.device)

    # BN 参数
    gamma = bn.weight.detach().clone()
    beta  = bn.bias.detach().clone()
    mu    = bn.running_mean
    var   = bn.running_var
    eps   = bn.eps

    # fold 公式
    denom = torch.sqrt(var + eps)
    W_fold = W * (gamma / denom).reshape(-1, 1, 1, 1)
    b_fold = beta + (b - mu) * (gamma / denom)

    fused_conv.weight.data.copy_(W_fold)
    fused_conv.bias.data.copy_(b_fold)

    return fused_conv

# ─── ② 把一个 nn.Sequential 中的 Conv→BN→ReLU6 或 Conv→BN 序列替换成 fold 后的模块 ──
def fuse_sequential_conv_bn_relu6(seq: nn.Sequential) -> nn.Sequential:
    modules = []
    i = 0
    while i < len(seq):
        m1 = seq[i]
        # 检测 Conv→BN→ReLU6
        if (i + 2 < len(seq)
            and isinstance(m1, nn.Conv2d)
            and isinstance(seq[i+1], nn.BatchNorm2d)
            and isinstance(seq[i+2], nn.ReLU6)):
            # fold Conv+BN
            fused = fuse_conv_bn(m1, seq[i+1])
            # 保留原生 ReLU6
            modules.append(nn.Sequential(fused, seq[i+2]))
            i += 3
        # 检测仅 Conv→BN（如 bottleneck 最后一段 project）
        elif (i + 1 < len(seq)
              and isinstance(m1, nn.Conv2d)
              and isinstance(seq[i+1], nn.BatchNorm2d)):
            fused = fuse_conv_bn(m1, seq[i+1])
            modules.append(fused)
            i += 2
        else:
            modules.append(m1)
            i += 1
    return nn.Sequential(*modules)

# ─── ③ 给整个模型做一次遍历，把 features 以及每个 InvertedResidual.conv 都 fuse 掉 ───
def fuse_model(model: nn.Module) -> nn.Module:
    # 先 fuse 主干 features
    model.features = fuse_sequential_conv_bn_relu6(model.features)
    # 再 fuse 每个倒残差块里面的 conv
    for m in model.features:
        if isinstance(m, InvertedResidual):
            m.conv = fuse_sequential_conv_bn_relu6(m.conv)
    return model


#---------------------------------------------------------------------------#
# 1) 定义 Inverted Residual Block（倒残差块）
#---------------------------------------------------------------------------#
class InvertedResidual(nn.Module):
    def __init__(self, inp, oup, stride, expand_ratio):
        super().__init__()
        self.stride = stride
        hidden_dim = int(inp * expand_ratio)
        self.use_res_connect = (self.stride == 1 and inp == oup)

        layers = []
        # 1x1 expand
        if expand_ratio != 1:
            layers += [
                nn.Conv2d(inp, hidden_dim, 1, 1, 0, bias=False),
                nn.BatchNorm2d(hidden_dim),
                nn.ReLU6(inplace=True)
            ]
        # 3x3 depthwise
        layers += [
            nn.Conv2d(hidden_dim, hidden_dim, 3, stride, 1, groups=hidden_dim, bias=False),
            nn.BatchNorm2d(hidden_dim),
            nn.ReLU6(inplace=True),
        ]
        # 1x1 project
        layers += [
            nn.Conv2d(hidden_dim, oup, 1, 1, 0, bias=False),
            nn.BatchNorm2d(oup),
        ]
        self.conv = nn.Sequential(*layers)

    def forward(self, x):
        if self.use_res_connect:
            return x + self.conv(x)
        else:
            return self.conv(x)

#---------------------------------------------------------------------------#
# 2) 定义 MobileNetV2 主干
#---------------------------------------------------------------------------#
class MobileNetV2(nn.Module):
    def __init__(self, num_classes=10, width_mult=1.0):
        super().__init__()
        # 配置表：[t, c, n, s]
        inverted_residual_setting = [
            # t,   c,   n,  s
            [1,    16,  1,  1],
            [6,    24,  2,  2],
            [6,    32,  3,  2],
            [6,    64,  4,  2],
            [6,    96,  3,  1],
            [6,   160,  3,  2],
            [6,   320,  1,  1],
        ]

        # 首层 conv2d 3x3，输出 32 channel
        input_channel = int(32 * width_mult)
        layers = [
            nn.Conv2d(3, input_channel, 3, stride=2, padding=1, bias=False),
            nn.BatchNorm2d(input_channel),
            nn.ReLU6(inplace=True)
        ]

        # 构建一系列倒残差块
        for t, c, n, s in inverted_residual_setting:
            output_channel = int(c * width_mult)
            for i in range(n):
                stride = s if i == 0 else 1
                layers.append(InvertedResidual(input_channel, output_channel, stride, expand_ratio=t))
                input_channel = output_channel

        # 收尾：1x1 conv to 1280 -> avgpool -> fc
        last_channel = int(1280 * width_mult) if width_mult > 1.0 else 1280
        layers += [
            nn.Conv2d(input_channel, last_channel, 1, 1, 0, bias=False),
            nn.BatchNorm2d(last_channel),
            nn.ReLU6(inplace=True),
        ]
        self.features = nn.Sequential(*layers)

        self.pool = nn.AdaptiveAvgPool2d(1)
        self.classifier = nn.Sequential(
            nn.Dropout(0.2),
            nn.Linear(last_channel, num_classes)
        )

        # 权重初始化
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode='fan_out')
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.ones_(m.weight)
                nn.init.zeros_(m.bias)
            elif isinstance(m, nn.Linear):
                nn.init.normal_(m.weight, 0, 0.01)
                nn.init.zeros_(m.bias)

    def forward(self, x):
        x = self.features(x)
        x = self.pool(x).view(x.size(0), -1)
        x = self.classifier(x)
        return x







if __name__ == "__main__":
    model = MobileNetV2()
    inputs = torch.randn(1, 3, 32, 32)
    print(model)

    from torchsummary import summary

    summary(model, (3, 32, 32), device="cpu")
