# -*- coding: utf-8 -*-
import random
import numpy as np

# === 設定隨機種子 ===
random.seed(42)
np.random.seed(42)

# TODO: 調整以下參數以符合實際需求
COMPUTE_ROW = 4 






# === 卷積參數 ===
IMG_H, IMG_W = 224, 224  # 輸入圖像尺寸
C = 10                    # 通道數（輸入與輸出相同）
KERNEL_SIZE = 3           # 核大小 3x3
PAD_TOP, PAD_BOTTOM, PAD_LEFT, PAD_RIGHT = 1, 1, 1, 1  # 填充
OUTPUT_ROW = COMPUTE_ROW - 2  # 輸出行數 = 1
# TILE_H, TILE_W 是指包含 padding 的尺寸，但不寫入 padding 到 SRAM
EFFECTIVE_H = COMPUTE_ROW
EFFECTIVE_W = IMG_W



# === SRAM 配置參數 ===
TOTAL_SRAM_SIZE = 64 * 1024  # 64KB
WORD_SIZE = 4                # 每個字組 4 bytes

# 基址（字組單位，轉為位元組）
WEIGHT_BASE_WORD = 0x0000_0000
IFMAP_BASE_WORD  = 0x0000_1000
BIAS_BASE_WORD   = 0x0000_2500
IPSUM_BASE_WORD  = 0x0000_2000
OPSUM_BASE_WORD  = 0x0000_3000

WEIGHT_BASE = WEIGHT_BASE_WORD * WORD_SIZE
IFMAP_BASE  = IFMAP_BASE_WORD * WORD_SIZE
BIAS_BASE   = BIAS_BASE_WORD * WORD_SIZE
IPSUM_BASE  = IPSUM_BASE_WORD * WORD_SIZE
OPSUM_BASE  = OPSUM_BASE_WORD * WORD_SIZE


IS_TOP_TILE = True  # 是否為頂層 tile，若為 False 則不考慮 padding
is_bias = False  # 若要用 ipsum 當 base，改為 False
# === 初始化 SRAM ===
sram = np.zeros(TOTAL_SRAM_SIZE, dtype=np.uint8)

# === 初始化資料 ===
weight = np.random.randint(0, 6, size=(C, KERNEL_SIZE, KERNEL_SIZE), dtype=np.uint8)
ifmap = np.random.randint(0, 6, size=(C, EFFECTIVE_H, EFFECTIVE_W), dtype=np.uint8)  # SRAM 不儲存 padding
ipsum = np.random.randint(5, 11, size=(C, OUTPUT_ROW, IMG_W), dtype=np.uint16)
bias = np.random.randint(0, 10, size=(C,), dtype=np.uint16)



# === 寫入 Weight（每 4 bytes 反向：小 index 放右邊） ===
weight_flat = weight.flatten()
print(f"Weight shape: {weight.shape}, flat length: {len(weight_flat)}")
print(f"Weight flat: {weight_flat}")
for i in range(0, len(weight_flat), 4):
    group = weight_flat[i:i+4]
    addr = WEIGHT_BASE + i
    if len(group) < 4:
        # 不足 4 byte 的組，先反轉再靠右對齊
        reversed_group = group[::-1]  # 反轉 group
        padded_group = np.zeros(4, dtype=np.uint8)
        padded_group[-len(reversed_group):] = reversed_group  # 靠右對齊
        for j, val in enumerate(padded_group):
            sram[addr + j] = val
    else:
        # 完整 4 byte 的組，反轉寫入
        for j, val in enumerate(reversed(group)):
            sram[addr + j] = val

# 驗證最後一組 (第 88~91 byte)
print([hex(sram[i])[2:].zfill(2) for i in range(88, 92)])  # 應顯示 ['00', '00', '01', '04'] 或類似

# === 寫入 Ifmap（同樣 4 bytes 小端寫入） ===
ifmap_flat = ifmap.flatten()
print(f"Ifmap shape: {ifmap.shape}, flat length: {len(ifmap_flat)}")
print(f"Ifmap flat: {ifmap_flat}")
for i in range(0, len(ifmap_flat), 4):
    group = ifmap_flat[i:i+4]
    for j, val in enumerate(reversed(group)):
        addr = IFMAP_BASE + i + j
        sram[addr] = val

# === 寫入 Ipsum（每兩筆 int16 小端合成 4-byte 小端） ===
ipsum_flat = ipsum.flatten()
print(f"Ipsum shape: {ipsum.shape}, flat length: {len(ipsum_flat)}")
print(f"Ipsum flat: {ipsum_flat}")
print("Ipsum flat (first 20 values):", ipsum_flat[:20])
# 每兩個 int16 值合併為 4-byte 小端序
for i in range(0, len(ipsum_flat), 2):
    val0 = ipsum_flat[i] & 0xFFFF
    val1 = ipsum_flat[i + 1] & 0xFFFF if i + 1 < len(ipsum_flat) else 0
    b0 = (val0 >> 0) & 0xFF
    b1 = (val0 >> 8) & 0xFF
    b2 = (val1 >> 0) & 0xFF
    b3 = (val1 >> 8) & 0xFF
    addr = IPSUM_BASE + i * 2
    sram[addr + 0] = b3
    sram[addr + 1] = b2
    sram[addr + 2] = b1
    sram[addr + 3] = b0

# === 寫入 Bias（每個 int16 小端序） ===
for i, val in enumerate(bias):
    addr = BIAS_BASE + i * 2
    sram[addr] = val & 0xFF
    sram[addr + 1] = (val >> 8) & 0xFF

# === 計算 Golden Opsum ===
golden_opsum = np.zeros((C, OUTPUT_ROW, IMG_W), dtype=np.int32)
for c in range(C):
    for r in range(OUTPUT_ROW):
        for col in range(IMG_W):
            psum = int(ipsum[c][r][col])  # 從 ipsum 開始
            for kr in range(KERNEL_SIZE):
                for kc in range(KERNEL_SIZE):
                    # 動態計算 ifmap_r
                    if IS_TOP_TILE:
                        ifmap_r = r + kr - 1  # 頂層 tile 偏移
                        if ifmap_r < 0 or ifmap_r >= EFFECTIVE_H:
                            ifmap_val = 0  # padding
                        else:
                            ifmap_col = col + kc - PAD_LEFT
                            if 0 <= ifmap_col < EFFECTIVE_W:
                                ifmap_val = ifmap[c][ifmap_r][ifmap_col]
                            else:
                                ifmap_val = 0  # 列方向 padding
                    else:
                        ifmap_r = r + kr  # 中間 tile 偏移
                        if 0 <= ifmap_r < EFFECTIVE_H:
                            ifmap_col = col + kc - PAD_LEFT
                            if 0 <= ifmap_col < EFFECTIVE_W:
                                ifmap_val = ifmap[c][ifmap_r][ifmap_col]
                            else:
                                ifmap_val = 0  # 列方向 padding
                        else:
                            ifmap_val = 0  # 行方向 padding
                    psum += int(ifmap_val) * int(weight[c][kr][kc])
            golden_opsum[c][r][col] = psum

# === 輸出確認 ===
print(f"Ifmap shape: {ifmap.shape}, Golden opsum shape: {golden_opsum.shape}")

# === 顯示 Golden Opsum 計算過程（不使用 pandas）===


for c in range(3):  # channel
    for r in range(1):  # row
        for col in range(221, 224):  # column
            print("=" * 60)
            print(f"Channel: {c}, Row: {r}, Col: {col}")
            base_val = int(bias[c]) if is_bias else int(ipsum[c][r][col])
            print(f"{'Bias' if is_bias else 'Ipsum'}: {base_val}")
            psum = base_val

            for kr in range(KERNEL_SIZE):
                for kc in range(KERNEL_SIZE):
                    ifmap_r = r + kr - PAD_TOP
                    ifmap_col = col + kc - PAD_LEFT
                    if 0 <= ifmap_r < EFFECTIVE_H and 0 <= ifmap_col < EFFECTIVE_W:
                        a = ifmap[c][ifmap_r][ifmap_col]
                        src = f"ifmap[{ifmap_r}][{ifmap_col}]={a}"
                    else:
                        a = 0
                        src = "PAD=0"
                    b = weight[c][kr][kc]
                    product = int(a) * int(b)
                    psum += product
                    print(f"{src:<20} * weight[{kr}][{kc}]={b:<2} => {product}")

            print(f"Final Output: {psum}")
            print()

# print(weight_flat)
# === 儲存 memory.hex 檔 ===
with open('../sim/depthwise_memory.hex', 'w') as f:
    for i in range(0, len(sram), 4):
        line = ''.join(f'{b:02X}' for b in sram[i:i+4])
        f.write(line + '\n')

# === 儲存 golden.hex 檔（每兩個 16-bit 值合併為 32-bit，小端序） ===
with open('../sim/depthwise_golden.hex', 'w') as f:
    golden_flat = golden_opsum.flatten()
    for i in range(0, len(golden_flat), 2):
        val1 = golden_flat[i] & 0xFFFF
        val2 = golden_flat[i + 1] & 0xFFFF if i + 1 < len(golden_flat) else 0
        val_32bit = (val1 << 16) | val2
        b1 = (val_32bit >> 0) & 0xFF
        b0 = (val_32bit >> 8) & 0xFF
        b3 = (val_32bit >> 16) & 0xFF
        b2 = (val_32bit >> 24) & 0xFF
        f.write(f'{b0:02X}{b1:02X}{b2:02X}{b3:02X}\n')

# === 結尾印出確認 ===
print("SRAM data generated and saved to ../sim/depthwise_memory.hex")
print("Golden data generated and saved to ../sim/depthwise_golden.hex")
print(f"Weight shape: {weight.shape}, Ifmap shape: {ifmap.shape}, Ipsum shape: {ipsum.shape}, Bias shape: {bias.shape}, Opsum shape: {golden_opsum.shape}")
print(f"Total SRAM size: {TOTAL_SRAM_SIZE} bytes")
print(f"Weight base: {WEIGHT_BASE:#010X}, Ifmap base: {IFMAP_BASE:#010X}, Ipsum base: {IPSUM_BASE:#010X}, Bias base: {BIAS_BASE:#010X}, Opsum base: {OPSUM_BASE:#010X}")
print("Data generation completed successfully.")