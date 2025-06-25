import os
import re
import math
import numpy as np

def load_array_skip_header(txt_path):
    """跳過文件第一行，讀取后面所有數字並返回 numpy.float32 。"""
    vals = []
    with open(txt_path, 'r') as f:
        lines = f.readlines()[1:]   # 跳過第一行
    for line in lines:
        line = line.strip()
        if not line:
            continue
        try:
            vals.append(float(line))
        except:
            continue
    return np.array(vals, dtype=np.float32)

def load_single_value(txt_path):
    with open(txt_path) as f:
        for line in f:
            line = line.strip()
            if re.match(r'^-?\d+(\.\d+)?([eE][-+]?\d+)?$', line):
                return float(line)
    raise FileNotFoundError(txt_path)

def find_input_scale(layer, folder):
    # 同之前，匹配 features_X_scale_0.txt 或 features_X_scale.txt
    m = re.match(r'features_(\d+)', layer)
    if m:
        idx = int(m.group(1))
        for i in range(idx, -1, -1):
            for nm in (f"features_{i}_scale_0.txt",
                       f"features_{i}_scale.txt"):
                p = os.path.join(folder, nm)
                if os.path.isfile(p):
                    arr = load_array_skip_header(p)
                    return float(arr[0])
    # classifier
    if layer.startswith("classifier"):
        for nm in ("classifier_0_scale_0.txt","classifier_0_scale.txt"):
            p = os.path.join(folder, nm)
            if os.path.isfile(p):
                arr = load_array_skip_header(p)
                return float(arr[0])
    # fallback
    arr = load_array_skip_header(os.path.join(folder,"features_0_input_scale_0.txt"))
    return float(arr[0])

def find_output_scale(layer, folder):
    """
    輸出的 scale 就是下一個 block 的輸入 scale。
    例如 layer="features_9_conv_3" → 輸出 scale 從
               features_10_scale_0.txt 或 features_10_scale.txt 讀。
    最后一層 classifier 的輸出則用 classifier_0_scale*.txt。
    """
    # 如果是 features_N_conv_M 
    m = re.match(r'features_(\d+)_conv_\d+', layer)
    if m:
        next_idx = int(m.group(1)) + 1
        # 下一層 block 的輸入 scale
        for nm in (f"features_{next_idx}_scale_0.txt", f"features_{next_idx}_scale.txt"):
            p = os.path.join(folder, nm)
            if os.path.isfile(p):
                arr = load_array_skip_header(p)
                return float(arr[0])
            
    # 如果恰好到了最后 classifier
    arr = load_array_skip_header(os.path.join(folder,"classifier_0_scale.txt"))
    return float(arr[0])

def compute_scaling_exponents(folder, out_txt="scaling_exponents.txt",  out_hex="scaling_factors.hex"):
    """
    遍歷所有 features_X_conv_Y.weight.hex，同步讀取各自的 weight scale (.scale.txt)
    以及對應的 input_scale、output_scale，計算 n=round(log2((x*w)/y))
    並寫入 out_file，每行格式：layer_name n
    """
    exps = []
    for fname in os.listdir(folder):
        # 找到所有權重 scale 文件
        m = re.match(r'(features_\d+_conv_\d+)_scale\.txt', fname)
        if not m:
            continue
        layer = m.group(1)           # e.g. "features_10_conv_3"
        w_arr   = load_array_skip_header(os.path.join(folder, fname))
        w_scale = float(w_arr[0])
        x_scale = find_input_scale(layer, folder)
        y_scale = find_output_scale(layer, folder)
        real_scale = (x_scale * w_scale) / y_scale
        n = int(round(math.log2(real_scale)))
        exps.append((layer, n))

    with open(os.path.join(folder, out_txt), 'w') as f:
        for layer, n in exps:
            f.write(f"{layer} {n}\n")
    print("x_scale, w_scale,y_scale =", x_scale, w_scale,y_scale)
    print(f"Wrote {len(exps)} exponents to {out_txt}")

    # 2) 排序：先按 block，再按 conv
    def sort_key(item):
        layer, n = item
        # layer 格式 "features_X_conv_Y"
        parts = layer.split('_')
        block = int(parts[1])
        conv  = int(parts[3])
        return (block, conv)
    
    exps_sorted = sorted(exps, key=sort_key)

    # 3) 輸出 hex 文件
    with open(os.path.join(folder, out_hex), 'w') as f:
        for layer, n in exps_sorted:
            pos_n = abs(n)
            # 限定 0~255 範圍
            if pos_n < 0 or pos_n > 0xFF:
                raise ValueError(f"Exponent {pos_n} out of byte range for {layer}")
            f.write(f"{pos_n:02x}\n")
   
    print(f"Wrote {len(exps)} entries to {out_txt} and {out_hex}")


if __name__ == "__main__":
    folder = "/home2/aoc2025/n26131520/params_quant_linear/"
    compute_scaling_exponents(folder)
