import numpy as np
import os

def read_int8_and_shape_from_txt(txt_path):
    """
    讀取 txt 文件：
      - 第一行是形狀信息（例如 "512 320 3 3"），將其解析為整數列表 shape_list。
      - 后續每行解析為 int，並檢查是否都在 int8 取值範圍 [-128, 127] 之内。
    返回：
      shape_list (List[int])  # 例如 [512, 320, 3, 3]
      arr (np.ndarray)        # 後續所有行的 Int8 
    """
    with open(txt_path, 'r') as f:
        lines = f.readlines()

    # 1) 解析第一行：形狀信息
    first_line = lines[0].strip()
    try:
        shape_list = [int(x) for x in first_line.split()]
    except ValueError:
        raise ValueError(f"Cannot parse shape info from first line of {txt_path}: '{first_line}'")

    # 2) 後續權重信息
    ints = []
    for line in lines[1:]:
        line = line.strip()
        if not line:
            continue
        try:
            val = int(line)
        except ValueError:
            continue
        if val < -128 or val > 127:
            raise ValueError(f"Value {val} out of Int8 range in file {txt_path}")
        ints.append(val)

    arr = np.array(ints, dtype=np.int8)
    return shape_list, arr

def int8_to_hex_array(int8_array):
    """
    輸入一個 numpy.int8 陣列，回傳對應的兩位小寫十六進位字串列表。
    負值會先轉換成無符號的 0～255 範圍再格式化。
    例如：-1 -> 0xff -> "ff"，127 -> "7f"，-128 -> "80"。
    """
    hex_list = []
    for v in int8_array:
        unsigned = np.uint8(v).item()
        hex_str = f"{unsigned:02x}"
        hex_list.append(hex_str)
    return hex_list

def dims_to_unbounded_hex_array(dims):
    """
    將任意大小的整數列表 dims 轉換為帶有 '0x' 前綴的十六進位字串列表。
    例如 dims = [512, 3, 3, 3] -> ['0x200', '0x3', '0x3', '0x3']。
    不對整數大小設限，只要是 Python 的 int 型別即可處理。
    """
    hex_list = []
    for d in dims:
        if d < 0:
            raise ValueError(f"Dimension value {d} is negative; cannot represent as unsigned hex.")
        hex_str = f"{d:x}"   
        hex_list.append(hex_str)
    return hex_list

def convert_int8_txt_to_hex_with_shape_one_line(txt_path, hex_out_path):
    """
    從 txt_path 讀取：
      1) 第一行為 shape_list（例如 [512, 320, 3, 3]），將其轉換為帶有 '0x' 前綴的十六進位字串，
         並將這些十六進位字串以空格串接成一行。
      2) 後續行是 Int8 的權重值，將其轉換為兩位數的小寫十六進位，每個十六進位值獨立一行。
    最終寫入 hex_out_path：
      - 第一行為形狀的十六進位字串（以空格分隔），例如 "0x200 0x140 0x3 0x3"
      - 後續每行為一個權重的兩位十六進位，例如 "80"、"7f"、"05"……
    回傳：
      shape_list (List[int])
      arr (np.ndarray)
    """
    shape_list, arr = read_int8_and_shape_from_txt(txt_path)
    # 1) 形狀轉成 hex 列表
    shape_hex = dims_to_unbounded_hex_array(shape_list)  # e.g. ['0x200','0x140','0x3','0x3']
    # 2) 把 Int8 轉成兩位十六進制
    data_hex = int8_to_hex_array(arr)

    with open(hex_out_path, 'w') as f:
        # 第 1 行：把所有維度的 hex 串成一行
        f.write(' '.join(shape_hex) + '\n')
        # 後續行：每個權重一個兩位 hex
        for hx in data_hex:
            f.write(hx + '\n')

    return shape_list, arr

def batch_convert_int8_with_shape_one_line(folder):
    """
    批量轉換：遍歷 folder 目錄下所有文件名包含 "weight" 且后綴為 .txt 的文件，
    對每個文件：
      - 讀取第一行形狀並直接轉成 '0x...' 格式
      - 將後續 Int8 權重轉為兩位 hex
      - 把形狀和權重寫到同名 .hex 文件：第一行是形狀（空格分隔的 '0x...'），
        後續每行一個兩位 hex
    """
    for filename in os.listdir(folder):
        if filename.endswith('.txt') and 'weight' in filename:
            txt_path = os.path.join(folder, filename)
            hex_name = filename.replace('.txt', '.hex')
            hex_path = os.path.join(folder, hex_name)
            try:
                shape, arr = convert_int8_txt_to_hex_with_shape_one_line(txt_path, hex_path)
                print(f"Converted {filename}: shape={shape}, {len(arr)} int8 values → {hex_name}")
            except Exception as e:
                print(f"Error processing {filename}: {e}")

if __name__ == "__main__":
    # 路徑
    weights_folder = "/home2/aoc2025/n26131520/params_quant_linear/"
    batch_convert_int8_with_shape_one_line(weights_folder)
