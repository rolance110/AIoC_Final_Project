import torch
import torch.nn as nn
import torch.quantization as tq
import torch.nn.functional as F



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
                nn.ReLU(inplace=True)
            ]
        # 3x3 depthwise
        layers += [
            nn.Conv2d(hidden_dim, hidden_dim, 3, stride, 1, groups=hidden_dim, bias=False),
            nn.BatchNorm2d(hidden_dim),
            nn.ReLU(inplace=True),
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
            nn.ReLU(inplace=True)
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
            nn.ReLU(inplace=True),
        ]
        self.features = nn.Sequential(*layers)

        self.pool = nn.AdaptiveAvgPool2d(1)
        self.classifier = nn.Sequential(
            
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

    def fuse_modules(self):
        # 1) fuse 首层 conv-bn-relu
        tq.fuse_modules(self.features, ['0', '1', '2'], inplace=True)

        # 2) fuse 所有 InvertedResidual 块内部
        for m in self.features:
            if isinstance(m, InvertedResidual):
                # layers 顺序：
                # 如果 expand_ratio != 1: [0:Conv,1:BN,2:ReLU] 扩展；
                # 然后 [3:Conv_dw,4:BN,5:ReLU]；
                # 最后 [6:Conv_pw,7:BN]
                if len(m.conv) == 8:
                    tq.fuse_modules(m.conv, ['0','1','2'], inplace=True)
                    tq.fuse_modules(m.conv, ['3','4','5'], inplace=True)
                    tq.fuse_modules(m.conv, ['6','7'], inplace=True)
                else:
                    # 当 expand_ratio==1 时，直接从 depthwise 开始
                    tq.fuse_modules(m.conv, ['0','1','2'], inplace=True)
                    tq.fuse_modules(m.conv, ['3','4'], inplace=True)

        # 3) fuse 最后一个 1×1 conv-bn-relu
        # features 中最后三个层的索引是 -3,-2,-1
        N = len(self.features)
        tq.fuse_modules(self.features, [str(N-3), str(N-2), str(N-1)], inplace=True)









if __name__ == "__main__":
    model = MobileNetV2()
    inputs = torch.randn(1, 3, 224, 224)
    print(model)

    from torchsummary import summary

    summary(model, (3, 224, 224), device="cpu")
