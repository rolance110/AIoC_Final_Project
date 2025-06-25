import os
import sys
import torch
import re
import numpy as np

# Append project root so we can import model package
top_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if top_dir not in sys.path:
    sys.path.insert(0, top_dir)

from model.MobileNetV2_ReLU import MobileNetV2, InvertedResidual
from custom_qconfig import CustomQConfig
from torch.ao.quantization.quantize_fx import prepare_fx, convert_fx, QConfigMapping
from torch.nn.quantized import Linear as QuantizedLinear



def save_array_txt(arr: np.ndarray, filepath: str):
    """
    Save numpy array to a text file without limiting precision.
    First line: dimensions separated by spaces.
    Following lines: flattened data values in full precision.
    """
    with open(filepath, 'w') as f:
        # write shape
        shape_str = ' '.join(str(d) for d in arr.shape)
        f.write(shape_str + '\n')
        # write data flattened
        flat = arr.flatten()
        for val in flat:
            # use default string conversion for full precision
            f.write(str(val) + '\n')


def extract_float_model(state_dict, out_dir="params_float"):
    os.makedirs(out_dir, exist_ok=True)
    for name, param in state_dict.items():
        arr = param.detach().cpu().numpy()
        fname = name.replace('.', '_') + '.txt'
        save_array_txt(arr, os.path.join(out_dir, fname))
    print(f"[+] Saved float parameters to '{out_dir}'")


def extract_quant_from_module(model, out_dir="params_quant_linear"):
    os.makedirs(out_dir, exist_ok=True)
    for name, module in model.named_modules():
        prefix = name.replace('.', '_')

        # 1) weight (int8)
        if hasattr(module, 'weight') and callable(module.weight):
            try:
                w_q    = module.weight()            # QuantizedTensor
                w_int8 = w_q.int_repr().cpu().numpy()
                save_array_txt(w_int8,
                    os.path.join(out_dir, f"{prefix}_weight.txt"))
                
            except Exception:
                pass

        # 2) Bias (float32)
        if hasattr(module, 'bias') and callable(module.bias):
            try:
                b_q = module.bias()                   
                b_arr = b_q.detach().cpu().numpy()
                save_array_txt(b_arr, os.path.join(out_dir, f"{prefix}_bias.txt"))
            except Exception:
                pass
        elif hasattr(module, 'bias') and isinstance(module.bias, torch.Tensor):
            try:
                b_arr = module.bias.detach().cpu().numpy()
                save_array_txt(b_arr, os.path.join(out_dir, f"{prefix}_bias.txt"))
            except Exception:
                pass

        if hasattr(module, 'scale') and hasattr(module, 'zero_point'):
            try:
                s = float(module.scale)
                z = int(module.zero_point)
                save_array_txt(np.array([s],dtype=np.float32),
                    os.path.join(out_dir, f"{prefix}_scale.txt"))
                save_array_txt(np.array([z],dtype=np.int64),
                    os.path.join(out_dir, f"{prefix}_zero_point.txt"))
            except Exception:
                pass

        # —— 從state_dict 裡提取 features_i_scale_0 —— #
        sd = model.state_dict()
        for key, val in sd.items():
        #  features_#_scale_0
            m = re.match(r'features_(\d+)_scale_0', key)
            if not m:
                continue
            arr = val.detach().cpu().numpy()         # 0-dim tensor → scalar array
            prefix = key.replace('.', '_')           # e.g. "features_10_scale_0"
            save_array_txt(arr, os.path.join(out_dir, f"{prefix}.txt"))
            print(f"Extracted {prefix}.txt")

        # ——  input scale/zero_point —— #
        sd = model.state_dict()
        for key in ("features_0_input_scale_0", "features_0_input_zero_point_0"):
            if key in sd:
                val = sd[key]
                arr = val.detach().cpu().numpy() if isinstance(val, torch.Tensor) else np.array([val])
                save_array_txt(arr, os.path.join(out_dir, f"{key}.txt"))
                print(f"Extracted {key}.txt")
        print(f"[+] All parameters saved to '{out_dir}'")

    print(f"[+] Saved quantized parameters from Module to '{out_dir}'")



def extract_quant_from_state_dict(sd, out_dir="params_quant"):
    os.makedirs(out_dir, exist_ok=True)

    for key, val in sd.items():
        if isinstance(val, torch.Tensor):
            prefix = key.replace('.', '_')
            if val.is_quantized:
                arr = val.int_repr().detach().cpu().numpy()
            else:
                arr = val.detach().cpu().numpy()
            save_array_txt(arr, os.path.join(out_dir, f"{prefix}.txt"))
    print(f"[+] Saved quantized parameters from state_dict to '{out_dir}'")


if __name__ == '__main__':
    base = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    float_pt = os.path.join(base, 'MobileNetV2_test', 'weights', 'mobilenetv2.pt')
    quant_pt = os.path.join(base, 'MobileNetV2_test', 'weights', 'mobilenetv2-power2.pt')

    # 1) Extract float parameters
    raw_f = torch.load(float_pt, map_location='cpu')
    fsd   = raw_f.state_dict() if isinstance(raw_f, torch.nn.Module) else raw_f
    base = os.path.dirname(os.path.abspath(__file__))
    extract_float_model(fsd, out_dir=os.path.join(base, 'params_float'))

    # 載入 state_dict
    sd = torch.load(quant_pt, map_location='cpu')

    # 1)  FP32 模型
    fp_model = MobileNetV2(num_classes=10).eval()

    # 2)  QConfigMapping
    qconfig_mapping = QConfigMapping()
    # 量化POWER2
    qconfig_mapping.set_global(CustomQConfig.POWER2.value)

    # 3) 提供 example_inputs
    example_inputs = torch.randn(1, 3, 224, 224)

    # 4) FX 準備 & 轉換
    prepared = prepare_fx(
        fp_model,
        example_inputs=example_inputs,
        qconfig_mapping=qconfig_mapping
    )
    qmodel = convert_fx(
        prepared,
        qconfig_mapping=qconfig_mapping
    ).eval()

    # 5) 把量化好的 state_dict 加載進來
    qmodel.load_state_dict(sd, strict=False)

    # 6) 儲存的資料夾
    base = os.path.dirname(os.path.abspath(__file__))
    extract_quant_from_module(qmodel, out_dir=os.path.join(base, 'params_quant_linear'))