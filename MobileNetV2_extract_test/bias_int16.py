import os
import re
import numpy as np

def load_array_skip_header(txt_path):
    """Load float values from txt, skipping the first line as header."""
    values = []
    with open(txt_path, 'r') as f:
        lines = f.readlines()[1:]  # skip first line
    for line in lines:
        line = line.strip()
        if not line:
            continue
        try:
            values.append(float(line))
        except ValueError:
            continue
    return np.array(values, dtype=np.float32)

def load_single_value(txt_path):
    """Load a single numeric value (float/int) from txt."""
    with open(txt_path, 'r') as f:
        for line in f:
            line = line.strip()
            if re.match(r'^-?\d+(\.\d+)?([eE][-+]?\d+)?$', line):
                return float(line)
    raise FileNotFoundError(f"No numeric value found in {txt_path}")

def find_input_scale(layer, folder):
    """
    For layer 'features.X.conv.Y', look for 'features_X_scale_0.txt' first,
    fallback to earlier indices, then to 'features_0_input_scale_0.txt'.
    """
    m = re.match(r'features_(\d+)', layer)
    if m:
        idx = int(m.group(1))
        for i in range(idx, -1, -1):
            
            for nm in (
                f"features_{i}_scale_0.txt",
                f"features_{i}_scale.txt",
            ):
                path = os.path.join(folder, nm)
                if os.path.isfile(path):
                    return load_array_skip_header(path)

    # 如果是 classifier 系列
    if layer.startswith("classifier"):
        # 在同一資料夾內找出所有 'features_{i}_scale_0.txt'
        cand = []
        for fn in os.listdir(folder):
            # 只匹配這種檔名
            m = re.fullmatch(r'features_(\d+)_scale_0\.txt', fn)
            if m:
                cand.append(int(m.group(1)))

        if cand:
            N = max(cand)        # 找最大的 block 編號
            # 跳過第一行 header，讀第二行起的數值陣列
            arr = load_array_skip_header(os.path.join(folder, f"features_{N}_scale_0.txt"))
            if arr.size == 0:
                raise RuntimeError(f"No scale value found in features_{N}_scale_0.txt")
            return float(arr[0])  # 回傳第一個值作為 x_scale
       

    # 最后兜底
    return load_single_value(os.path.join(folder, "features_0_input_scale_0.txt"))

def quantize_bias_folder(folder):
    """
    Convert all 'features.X.conv.Y.bias.txt' to int32 hex,
    using 'features.X.conv.Y.scale.txt' and input scales.
    """
    print("→ Enter quantize_bias_folder, scanning:", folder)
    files = os.listdir(folder)
    print("→ Files found:", files)
    for fname in files:
        if not fname.endswith("_bias.txt"):
            continue
        print("  - Processing bias file:", fname)
    for fname in os.listdir(folder):
        if not fname.endswith("_bias.txt"):
            continue
        # derive layer name: features.X.conv.Y
        layer = fname[:-9]   # 去掉 "_bias.txt" 9 個字符，layer 就是 "features_7_conv_0"
        bias_path = os.path.join(folder, fname)
        # derive weight scale filename: features.X.conv.Y.scale.txt
        wscale_fname = f"{layer}_scale.txt"
        wscale_path = os.path.join(folder, wscale_fname)
        if not os.path.isfile(wscale_path):
            print(f"skip {layer}_bias: no weight scale file '{wscale_fname}'")
            continue
        # load data
        bias_fp32 = load_array_skip_header(bias_path)
        w_scale = load_array_skip_header(wscale_path)
        x_scale = find_input_scale(layer, folder)
        # quantize to int32
        real_scale = x_scale * w_scale
        b_int32 = np.round(bias_fp32 / real_scale).astype(np.int32)
        # to int16
        b_int16 = np.clip(b_int32, -32768, 32767).astype(np.int16)
        # write hex
        out_fname = f"{layer}_bias_int16.hex"
        out_path = os.path.join(folder, out_fname)
        with open(out_path, 'w') as outf:
            for v in b_int16:
                iv = int(v)              #  Python int
                ui = iv & 0xFFFF     
                outf.write(f"{ui:04x}\n")

        print(f"Converted {fname} -> {out_fname} ({len(b_int16)} entries)")
        print("x_scale, w_scale =", x_scale, w_scale)

if __name__ == "__main__":
    quantized_folder = "/home2/aoc2025/n26131520/params_quant_linear/"
    quantize_bias_folder(quantized_folder)
