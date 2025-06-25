# -*- coding: utf-8 -*-
import random
import numpy as np

# ========== ❶ PPU 參數 ==========
SCALING_FACTOR = 3      # 右移位元數
RELU_ENABLE    = False   # 是否啟用 ReLU
ZERO_POINT     = 128    # +128 偏移

# ========== 固定隨機種子 ==========
random.seed(42)
np.random.seed(42)

# TODO: CONFIGURE SETTINGS ----------------------------------------------------
COMPUTE_ROW = 3            # 驗證用：這個 tile 含 3 列 ifmap

# ========== (以下內容與你原檔一致：卷積/記憶體設定) ==========
IMG_H, IMG_W = 224, 224
C                = 10
KERNEL_SIZE      = 3
PAD_TOP, PAD_BOTTOM, PAD_LEFT, PAD_RIGHT = 1, 1, 1, 1
OUTPUT_ROW       = COMPUTE_ROW - 2            # 1
EFFECTIVE_H      = COMPUTE_ROW
EFFECTIVE_W      = IMG_W

TOTAL_SRAM_SIZE  = 64 * 1024
WORD_SIZE        = 4

WEIGHT_BASE_WORD = 0x0000_0000
IFMAP_BASE_WORD  = 0x0000_1000
BIAS_BASE_WORD   = 0x0000_2900
IPSUM_BASE_WORD  = 0x0000_2000
OPSUM_BASE_WORD  = 0x0000_3000

WEIGHT_BASE = WEIGHT_BASE_WORD * WORD_SIZE
IFMAP_BASE  = IFMAP_BASE_WORD  * WORD_SIZE
BIAS_BASE   = BIAS_BASE_WORD   * WORD_SIZE
IPSUM_BASE  = IPSUM_BASE_WORD  * WORD_SIZE
OPSUM_BASE  = OPSUM_BASE_WORD  * WORD_SIZE

IS_TOP_TILE = True
is_bias     = False

# ---------- SRAM 初始化 ----------
sram = np.zeros(TOTAL_SRAM_SIZE, dtype=np.uint8)

# ---------- 隨機資料 ----------
weight = np.random.randint(0, 6,  (C, KERNEL_SIZE, KERNEL_SIZE), dtype=np.uint8)
ifmap  = np.random.randint(0, 6,  (C, EFFECTIVE_H, EFFECTIVE_W), dtype=np.uint8)
ipsum  = np.random.randint(5, 10, (C, OUTPUT_ROW, IMG_W),       dtype=np.uint16)
bias   = np.random.randint(0, 10, (C,),                         dtype=np.uint16)

# ---------- Weight 寫入 ----------
w_flat = weight.flatten()
for i in range(0, len(w_flat), 4):
    grp, addr = w_flat[i:i+4], WEIGHT_BASE + i
    if len(grp) < 4:
        pad = np.zeros(4, dtype=np.uint8)
        pad[-len(grp):] = grp[::-1]
        sram[addr:addr+4] = pad
    else:
        sram[addr:addr+4] = grp[::-1]

# ---------- Ifmap 寫入 ----------
f_flat = ifmap.flatten()
for i in range(0, len(f_flat), 4):
    grp = f_flat[i:i+4]
    sram[IFMAP_BASE+i : IFMAP_BASE+i+len(grp)] = grp[::-1]

# ---------- Ipsum 寫入 (u16 → u32) ----------
p_flat = ipsum.flatten()
for i in range(0, len(p_flat), 2):
    v0 = int(p_flat[i]) & 0xFFFF
    v1 = int(p_flat[i+1]) & 0xFFFF if i+1 < len(p_flat) else 0
    addr = IPSUM_BASE + i*2
    sram[addr+0] = (v1 >> 8) & 0xFF
    sram[addr+1] =  v1       & 0xFF
    sram[addr+2] = (v0 >> 8) & 0xFF
    sram[addr+3] =  v0       & 0xFF

# ---------- Bias 寫入 ----------
for i, val in enumerate(bias):
    addr = BIAS_BASE + i*2
    sram[addr]     =  val        & 0xFF
    sram[addr + 1] = (val >> 8)  & 0xFF

# ========== ❷ RAW Opsum ==========
raw_opsum = np.zeros((C, OUTPUT_ROW, IMG_W), dtype=np.int32)
for c in range(C):
    for r in range(OUTPUT_ROW):
        for col in range(IMG_W):
            psum = int(ipsum[c, r, col])
            for kr in range(KERNEL_SIZE):
                for kc in range(KERNEL_SIZE):
                    if IS_TOP_TILE:
                        ifmap_r = r + kr - 1
                    else:
                        ifmap_r = r + kr
                    if 0 <= ifmap_r < EFFECTIVE_H:
                        ifmap_c = col + kc - PAD_LEFT
                        if 0 <= ifmap_c < EFFECTIVE_W:
                            a = ifmap[c, ifmap_r, ifmap_c]
                        else:
                            a = 0
                    else:
                        a = 0
                    b = weight[c, kr, kc]
                    psum += int(a) * int(b)
            raw_opsum[c, r, col] = psum

# ========== ❸ PPU 後處理 (ReLU → >> → +128 → Clip16) ==========
relu_out  = np.maximum(raw_opsum, 0) if RELU_ENABLE else raw_opsum
shift_out = np.right_shift(relu_out, SCALING_FACTOR).astype(np.int32)
offset_out = shift_out + ZERO_POINT
ppu_sat   = np.clip(offset_out, 0, 0xFFFF).astype(np.uint16)

# ========== ❹ 存檔 ==========
# 4-byte 封包：高 16 bits = val1，低 16 bits = val0（與 SRAM 一致的小端）
def pack_u16_pair(v1, v0):
    return [(v1 >> 8) & 0xFF, v1 & 0xFF, (v0 >> 8) & 0xFF, v0 & 0xFF]

# ❹-1 SRAM 影像
with open('../sim/depthwise_ppu_memory.hex', 'w') as f:
    for i in range(0, len(sram), 4):
        f.write(''.join(f'{b:02X}' for b in sram[i:i+4]) + '\n')

# # ❹-2 RAW (無 PPU) golden
# with open('../sim/depthwise_golden_raw.hex', 'w') as f:
#     flat = raw_opsum.flatten()
#     for i in range(0, len(flat), 2):
#         v0 = int(flat[i])
#         v1 = int(flat[i+1]) if i+1 < len(flat) else 0
#         f.write(''.join(f'{b:02X}' for b in pack_u16_pair(v1 & 0xFFFF, v0 & 0xFFFF)) + '\n')

# ❹-3 PPU golden  (ReLU + Scale + 128)
with open('../sim/depthwise_ppu_golden.hex', 'w') as f:
    flat = ppu_sat.flatten()
    for i in range(0, len(flat), 2):
        v0 = int(flat[i])
        v1 = int(flat[i+1]) if i+1 < len(flat) else 0
        f.write(''.join(f'{b:02X}' for b in pack_u16_pair(v1, v0)) + '\n')

# ========== ❺ Log ==========
print("✅ SRAM → ../sim/depthwise_ppu_memory.hex")
# print("✅ RAW  → ../sim/depthwise_golden_raw.hex")
print("✅ PPU  → ../sim/depthwise_ppu_golden.hex")
print(f"   • SCALING_FACTOR = {SCALING_FACTOR}")
print(f"   • RELU_ENABLE    = {RELU_ENABLE}")
print(f"   • ZERO_POINT     = {ZERO_POINT}")
