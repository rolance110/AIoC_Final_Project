import numpy as np
import os

def read_int8_and_shape_from_txt(txt_path):
    """
    读取 txt 文件：
      - 第一行假定是形状信息（例如 "512 320 3 3"），将其解析为整数列表 shape_list。
      - 后续每行解析为 int，并检查是否都在 int8 取值范围 [-128, 127] 之内。
    返回：
      shape_list (List[int])  # 形状信息，例如 [512, 320, 3, 3]
      arr (np.ndarray)        # 后续所有行的 Int8 数组
    """
    with open(txt_path, 'r') as f:
        lines = f.readlines()

    # 1) 解析第一行：形状信息
    first_line = lines[0].strip()
    try:
        shape_list = [int(x) for x in first_line.split()]
    except ValueError:
        raise ValueError(f"Cannot parse shape info from first line of {txt_path}: '{first_line}'")

    # 2) 解析后续行：权重信息
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
    输入一个 numpy.int8 数组，返回对应的两位小写十六进制字符串列表。
    负值会先转换成无符号 0~255 再格式化。
    例如：-1 -> 0xff -> "ff"， 127 -> "7f"， -128 -> "80"。
    """
    hex_list = []
    for v in int8_array:
        unsigned = np.uint8(v).item()
        hex_str = f"{unsigned:02x}"
        hex_list.append(hex_str)
    return hex_list

def dims_to_unbounded_hex_array(dims):
    """
    将任意大小的整数列表 dims 转换为带 '0x' 前缀的十六进制字符串列表。
    例如 dims=[512,3,3,3] -> ['0x200','0x3','0x3','0x3']。
    不对整数大小作上限限制，只要是 Python int 就能处理。
    """
    hex_list = []
    for d in dims:
        if d < 0:
            raise ValueError(f"Dimension value {d} is negative; cannot represent as unsigned hex.")
        hex_str = f"{d:x}"   # 小写十六进制，不补零
        hex_list.append(hex_str)
    return hex_list

def convert_int8_txt_to_hex_with_shape_one_line(txt_path, hex_out_path):
    """
    从 txt_path 读取：
      1) 第一行 shape_list（例如 [512, 320, 3, 3]），将其转换为带 '0x' 的十六进制字符串，
         并把这几条 hex 串联成一行，用空格隔开。
      2) 后续行的 Int8 权重值，将其转换为两位小写 hex，每个 hex 单独一行。
    最终写入 hex_out_path：
      - 第一行是形状的 hex 字符串（空格分隔），例如 "0x200 0x140 0x3 0x3"
      - 后续每行是一个权重的两位 hex，例如 "80"、"7f"、"05"……
    返回：
      shape_list (List[int])
      arr (np.ndarray)
    """
    shape_list, arr = read_int8_and_shape_from_txt(txt_path)
    # 1) 形状转换成带 '0x' 前缀的 hex 列表
    shape_hex = dims_to_unbounded_hex_array(shape_list)  # e.g. ['0x200','0x140','0x3','0x3']
    # 2) 把 Int8 数组转换成两位十六进制列表
    data_hex = int8_to_hex_array(arr)

    with open(hex_out_path, 'w') as f:
        # 第 1 行：把所有维度的 hex 串联成一行
        f.write(' '.join(shape_hex) + '\n')
        # 后续行：每个权重一个两位 hex
        for hx in data_hex:
            f.write(hx + '\n')

    return shape_list, arr

def batch_convert_int8_with_shape_one_line(folder):
    """
    批量转换：遍历 folder 目录下所有文件名包含 "weight" 且后缀为 .txt 的文件，
    对每个文件：
      - 读取第一行形状（任意大小的整数）并直接转成 '0x...' 格式
      - 将后续 Int8 权重转为两位 hex
      - 把形状和权重写到同名 .hex 文件：第一行是形状（空格分隔的 '0x...'），
        后续每行一个两位 hex
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
    # 把下面路径改成你存放权重 txt 文件的目录
    weights_folder = "/home2/aoc2025/n26131520/params_quant_linear/"
    batch_convert_int8_with_shape_one_line(weights_folder)
