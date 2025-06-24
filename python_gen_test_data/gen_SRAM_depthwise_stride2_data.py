# -*- coding: utf-8 -*-
import random
import numpy as np
import math

# === 設定隨機種子 ===
random.seed(42)
np.random.seed(42)

#TODO: CONFIGURE SETTINGS
COMPUTE_ROW = 5

# === 卷積參數 ===
IMG_H, IMG_W = 114, 114  # 輸入圖像尺寸
C = 10                   # 通道數（輸入與輸出相同）
KERNEL_SIZE = 3          # 核大小 3x3
PAD_TOP, PAD_BOTTOM, PAD_LEFT, PAD_RIGHT = 1, 1, 1, 1  # 填充
STRIDE = 2               # 步幅

# 根據 stride 計算輸出維度
OUTPUT_ROW = math.floor((COMPUTE_ROW - KERNEL_SIZE) / STRIDE) + 1 if STRIDE > 0 else COMPUTE_ROW - KERNEL_SIZE + 1
OUTPUT_W = math.floor((IMG_W - KERNEL_SIZE + PAD_LEFT + PAD_RIGHT) / STRIDE) + 1 if STRIDE > 0 else IMG_W - KERNEL_SIZE + PAD_LEFT + PAD_RIGHT + 1


# TILE_H, TILE_W 是指包含 padding 的尺寸，但不寫入 padding 到 SRAM
EFFECTIVE_H = COMPUTE_ROW
EFFECTIVE_W = IMG_W

# === SRAM 配置參數 ===
TOTAL_SRAM_SIZE = 64 * 1024  # 64KB
WORD_SIZE = 4                # 每個字組 4 bytes

# 基址（字組單位，轉為位元組）
WEIGHT_BASE_WORD = 0x0000_0000
IFMAP_BASE_WORD  = 0x0000_1000
BIAS_BASE_WORD   = 0x0000_2900
IPSUM_BASE_WORD  = 0x0000_2000
OPSUM_BASE_WORD  = 0x0000_3000

WEIGHT_BASE = WEIGHT_BASE_WORD * WORD_SIZE
IFMAP_BASE  = IFMAP_BASE_WORD * WORD_SIZE
BIAS_BASE   = BIAS_BASE_WORD * WORD_SIZE
IPSUM_BASE  = IPSUM_BASE_WORD * WORD_SIZE
OPSUM_BASE  = OPSUM_BASE_WORD * WORD_SIZE


IS_TOP_TILE = True  # 是否為頂層 tile，若為 False 則不考慮 padding
is_bias = False     # 若要用 ipsum 當 base，改為 False

# === 初始化 SRAM ===
sram = np.zeros(TOTAL_SRAM_SIZE, dtype=np.uint8)

# === 初始化資料 ===
weight = np.random.randint(0, 6, size=(C, KERNEL_SIZE, KERNEL_SIZE), dtype=np.uint8)
ifmap = np.random.randint(0, 6, size=(C, EFFECTIVE_H, EFFECTIVE_W), dtype=np.uint8)  # SRAM 不儲存 padding
ipsum = np.random.randint(5, 10, size=(C, OUTPUT_ROW, OUTPUT_W), dtype=np.uint16)
bias = np.random.randint(0, 10, size=(C,), dtype=np.uint16)

# === 寫入 Weight（每 4 bytes 為一組，小端序靠右對齊寫入） ===
weight_flat = weight.flatten()
print(f"Weight shape: {weight.shape}, flat length: {len(weight_flat)}")
# print all values in weight_flat
print("Weight values:", weight_flat)
for i in range(0, len(weight_flat), 4):
    group = weight_flat[i:i+4]
    addr = WEIGHT_BASE + i

    # 準備一個 4-byte 的 word, 不足部分在結尾補 0 (高位元組)
    word_bytes = np.zeros(4, dtype=np.uint8)
    word_bytes[:len(group)] = group

    # 以小端序寫入 sram (sram[addr] = LSB)
    for j, val in enumerate(word_bytes):
        sram[addr + j] = val

# === 寫入 Ifmap（同樣 4 bytes 小端序靠右對齊寫入） ===
ifmap_flat = ifmap.flatten()
print(f"Ifmap shape: {ifmap.shape}, flat length: {len(ifmap_flat)}")
for i in range(0, len(ifmap_flat), 4):
    group = ifmap_flat[i:i+4]
    addr = IFMAP_BASE + i
    
    # 準備一個 4-byte 的 word, 不足部分在結尾補 0 (高位元組)
    word_bytes = np.zeros(4, dtype=np.uint8)
    word_bytes[:len(group)] = group

    # 以小端序寫入 sram
    for j, val in enumerate(word_bytes):
        sram[addr + j] = val

# === 寫入 Ipsum（每兩筆 int16 小端合成 4-byte 小端） ===
ipsum_flat = ipsum.flatten()
print(f"Ipsum shape: {ipsum.shape}, flat length: {len(ipsum_flat)}")
print("Ipsum values:", ipsum_flat)
# 每兩個 int16 值合併為 4-byte 小端序

# 每兩個 int16 值合併為 4-byte 小端序
for i in range(0, len(ipsum_flat), 2):
    val0 = ipsum_flat[i] & 0xFFFF
    val1 = ipsum_flat[i + 1] & 0xFFFF if i + 1 < len(ipsum_flat) else 0
    b0 = (val0 >> 0) & 0xFF
    b1 = (val0 >> 8) & 0xFF
    b2 = (val1 >> 0) & 0xFF
    b3 = (val1 >> 8) & 0xFF
    addr = IPSUM_BASE + i * 2
    sram[addr + 0] = b0
    sram[addr + 1] = b1
    sram[addr + 2] = b2
    sram[addr + 3] = b3


# === 計算 Golden Opsum ===
golden_opsum = np.zeros((C, OUTPUT_ROW, OUTPUT_W), dtype=np.int32)
for c in range(C):
    for r in range(OUTPUT_ROW):
        for col in range(OUTPUT_W):
            psum = int(ipsum[c][r][col])  # 從 ipsum 開始
            for kr in range(KERNEL_SIZE):
                for kc in range(KERNEL_SIZE):
                    # 根據 stride, padding 計算 ifmap 座標
                    ifmap_input_r = r * STRIDE
                    ifmap_input_col = col * STRIDE

                    # 動態計算 ifmap_r
                    if IS_TOP_TILE:
                        ifmap_r = ifmap_input_r + kr - PAD_TOP  # 頂層 tile 偏移
                        if ifmap_r < 0 or ifmap_r >= EFFECTIVE_H:
                            ifmap_val = 0  # 垂直方向 padding
                        else:
                            ifmap_col = ifmap_input_col + kc - PAD_LEFT
                            if 0 <= ifmap_col < EFFECTIVE_W:
                                ifmap_val = ifmap[c][ifmap_r][ifmap_col]
                            else:
                                ifmap_val = 0  # 水平方向 padding
                    else: # 非頂層 tile (不考慮上邊界的 padding)
                        ifmap_r = ifmap_input_r + kr  # 中間 tile 偏移
                        if 0 <= ifmap_r < EFFECTIVE_H:
                            ifmap_col = ifmap_input_col + kc - PAD_LEFT
                            if 0 <= ifmap_col < EFFECTIVE_W:
                                ifmap_val = ifmap[c][ifmap_r][ifmap_col]
                            else:
                                ifmap_val = 0  # 水平方向 padding
                        else:
                            ifmap_val = 0  # 垂直方向 padding (主要用於 tile 底部)
                    
                    psum += int(ifmap_val) * int(weight[c][kr][kc])
            golden_opsum[c][r][col] = psum

# === 輸出確認 ===
print(f"Golden opsum shape: {golden_opsum.shape}")

# === 儲存 memory.hex 檔 ===
with open('../sim/depthwise_stride2_memory.hex', 'w') as f:
    for i in range(0, len(sram), 4):
        # 將 4 個 byte 反轉順序以匹配小端序 32-bit 字
        group = sram[i:i+4]
        line = ''.join(f'{b:02X}' for b in reversed(group))
        f.write(line + '\n')

# === 儲存 golden.hex 檔（每兩個 16-bit 值合併為 32-bit，小端序） ===
with open('../sim/depthwise_stride2_golden.hex', 'w') as f:
    golden_flat = golden_opsum.flatten()
    for i in range(0, len(golden_flat), 2):
        val1 = golden_flat[i] & 0xFFFF
        val2 = golden_flat[i + 1] & 0xFFFF if i + 1 < len(golden_flat) else 0
        
        # 組合成 32-bit: val2 在高位, val1 在低位
        val_32bit = (val2 << 16) | val1
        
        # 以小端序寫入 (byte by byte)
        b0 = (val_32bit >> 0) & 0xFF
        b1 = (val_32bit >> 8) & 0xFF
        b2 = (val_32bit >> 16) & 0xFF
        b3 = (val_32bit >> 24) & 0xFF
        f.write(f'{b3:02X}{b2:02X}{b1:02X}{b0:02X}\n')

# === 顯示 Golden Opsum 的前幾個 channel 的前幾個 output pixel ===
print("\n=== Golden Opsum 前幾個通道的前幾個輸出像素 ===")
num_channels_to_show = min(3, C)  # 顯示前 3 個通道或所有通道（如果少於 3 個）
num_pixels_to_show = min(3, OUTPUT_W) # 顯示每個通道的前 3 個輸出像素或所有像素

# === 計算 Golden Opsum ===
golden_opsum = np.zeros((C, OUTPUT_ROW, OUTPUT_W), dtype=np.int32)

# ---
### Golden Opsum 詳細計算過程 (仿照指定模式)

for c_target in range(0, 1): # 僅顯示通道 0
    for r_target in range(0, 1): # 僅顯示行 0
        for col_target in range(0, 1): # 僅顯示列 0
            print("=" * 60)
            print(f"Channel: {c_target}, Row: {r_target}, Col: {col_target}")
            
            base_val = int(bias[c_target]) if is_bias else int(ipsum[c_target][r_target][col_target])
            print(f"{'Bias' if is_bias else 'Ipsum'}: {base_val}")
            psum = base_val

            for kr in range(KERNEL_SIZE):
                for kc in range(KERNEL_SIZE):
                    # 計算 ifmap 實際讀取位置，考慮 stride 和 padding
                    ifmap_input_r = r_target * STRIDE
                    ifmap_input_col = col_target * STRIDE
                    
                    ifmap_r_actual = ifmap_input_r + kr - PAD_TOP if IS_TOP_TILE else ifmap_input_r + kr
                    ifmap_col_actual = ifmap_input_col + kc - PAD_LEFT

                    # 檢查是否超出 ifmap 實際範圍（即是否為 padding 區域）
                    if (0 <= ifmap_r_actual < EFFECTIVE_H) and \
                       (0 <= ifmap_col_actual < EFFECTIVE_W):
                        a = ifmap[c_target][ifmap_r_actual][ifmap_col_actual]
                        src_str = f"ifmap[{ifmap_r_actual}][{ifmap_col_actual}]={a}"
                    else:
                        a = 0
                        # 顯示 ifmap 邏輯位置，即使是 padding
                        src_str = f"ifmap_logic[{ifmap_input_r + kr}][{ifmap_input_col + kc}] (PAD=0)"
                        
                    b = weight[c_target][kr][kc]
                    product = int(a) * int(b)
                    psum += product
                    print(f"{src_str:<35} * weight[{kr}][{kc}]={b:<2} => {product:<5} | Current psum: {psum}")

            print(f"Final Output: {psum}")
            print("=" * 60)


# === 結尾印出確認 ===
print("SRAM data generated and saved to ../sim/depthwise_stride2_memory.hex")
print("Golden data generated and saved to ../sim/depthwise_stride2_golden.hex")
print(f"Stride: {STRIDE}")
print(f"Weight shape: {weight.shape}, Ifmap shape: {ifmap.shape}, Ipsum shape: {ipsum.shape}, Bias shape: {bias.shape}, Opsum shape: {golden_opsum.shape}")
print(f"Total SRAM size: {TOTAL_SRAM_SIZE} bytes")
print(f"Weight base: {WEIGHT_BASE:#010X}, Ifmap base: {IFMAP_BASE:#010X}, Ipsum base: {IPSUM_BASE:#010X}, Bias base: {BIAS_BASE:#010X}, Opsum base: {OPSUM_BASE:#010X}")
print("Data generation completed successfully.")
