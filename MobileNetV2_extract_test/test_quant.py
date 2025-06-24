import os
import numpy as np
import torch
from torch.ao.quantization.quantize_fx import prepare_fx, convert_fx
from model.MobileNetV2_ReLU import MobileNetV2   
from custom_qconfig import CustomQConfig     

def load_scalar_from_txt(filepath: str, dtype=np.float32):
    """讀取單一 scalar 值，忽略第一行 shape（例如 '1'）"""
    with open(filepath, 'r') as f:
        lines = f.readlines()
        if len(lines) < 2:
            raise ValueError(f"File {filepath} does not contain scalar data.")
        return dtype(lines[1].strip())

def load_array_txt(filepath: str, dtype=np.float32) -> np.ndarray:
    """讀入 save_array_txt 格式：第一行 dims，後面 flatten data。"""
    with open(filepath, 'r') as f:
        dims = list(map(int, f.readline().split()))
        data = np.loadtxt(f, dtype=dtype)
    return data.reshape(dims)

def build_and_reload_from_txt(txt_dir: str, calibrate_loader=None):
    # 1) 構建量化模型
    model_fp32 = MobileNetV2().eval()
    model_fp32.fuse_modules()

    qcfg = CustomQConfig.POWER2.value
    example_inputs = (torch.randn(1,3,224,224),)
    model_prepared = prepare_fx(model_fp32, {"": qcfg}, example_inputs=example_inputs)

    if calibrate_loader is not None:
        with torch.no_grad():
            for i,(imgs,_) in enumerate(calibrate_loader):
                model_prepared(imgs)
                if i >= 20: break

    qmodel = convert_fx(model_prepared)

    # 2) 讀 txt，重建 state_dict
    orig_sd = qmodel.state_dict()
    new_sd  = {k:v for k,v in orig_sd.items()}

    # 先列出你 txt_dir 底下有哪些 prefix
    # e.g. ["features_0_conv_0_weight.txt", ...] → prefix="features_0_conv_0"
    files = os.listdir(txt_dir)
    txt_prefixes = set(f.rsplit('_', 1)[0] for f in files)

    for prefix in txt_prefixes:
        # 尝试对应 state_dict 中的 key
        # weight
        wt = os.path.join(txt_dir, f"{prefix}_weight.txt")
        if os.path.isfile(wt):
            iarr = load_array_txt(wt, dtype=np.int8)
            # 找到对应的 state_dict key
            key_w = prefix.replace('_', '.').replace('.weight', '') + ".weight"
            # 实际上 prefix 已经不带 .weight，所以：
            key_w = prefix.replace('_', '.') + ".weight"
            # 读出模块的原 qparam
            mod = qmodel.get_submodule(prefix.replace('_', '.'))
            wq  = mod.weight()
            scale_w = wq.q_scale(); zp_w = wq.q_zero_point()
            deq = (iarr.astype(np.float32) - zp_w) * scale_w
            new_sd[key_w] = torch.quantize_per_tensor(
                                torch.from_numpy(deq),
                                scale=scale_w,
                                zero_point=zp_w,
                                dtype=torch.qint8
                            )

        # bias
        bt = os.path.join(txt_dir, f"{prefix}_bias.txt")
        if os.path.isfile(bt):
            barr = load_array_txt(bt, dtype=np.float32)
            key_b = prefix.replace('_', '.') + ".bias"
            new_sd[key_b] = torch.tensor(barr, dtype=torch.float32)

        # scale
        st = os.path.join(txt_dir, f"{prefix}_scale.txt")
        if os.path.isfile(st):
            s = load_scalar_from_txt(st, dtype=np.float32)
            key_s = prefix.replace('_', '.') + ".scale"
            new_sd[key_s] = torch.tensor(s, dtype=orig_sd[key_s].dtype)

        # zero_point
        zpt = os.path.join(txt_dir, f"{prefix}_zero_point.txt")
        if os.path.isfile(zpt):
            z = load_scalar_from_txt(zpt, dtype=np.int64)
            key_z = prefix.replace('_', '.') + ".zero_point"
            new_sd[key_z] = torch.tensor(z, dtype=orig_sd[key_z].dtype)

    # 3) Load 並檢查
    missing, unexpected = qmodel.load_state_dict(new_sd, strict=False)
    print("Missing keys:", missing)
    print("Unexpected keys:", unexpected)

    return qmodel

if __name__ == "__main__":
    txt_dir = "/home2/aoc2025/n26131520/params_quant_linear/"  
    # 如果你要再跑一次 calibrate 以收 activation qparams，可傳 calibrate_loader
    qmodel = build_and_reload_from_txt(txt_dir, calibrate_loader=None)

   
    # 2) 或者逐層列出 name & module
    for name, module in qmodel.named_children():
        if not isinstance(module, torch.nn.Identity):
            print(f"{name}: {module}")


    # 最後測試輸出 shape
    x = torch.randn(1,3,224,224)
    y = qmodel(x)
    print("Quantized model output shape:", y.shape)
