# -*- coding: utf-8 -*-
import random
import numpy as np

# ========= 可調式 PPU 參數 =========
SCALING_FACTOR = 1      # 0~15，右移位元數
RELU_ENABLE     = False  # True→啟用 ReLU；False→不啟用
ZERO_POINT = 128            # output zero-offset (+128)


# ========= 固定隨機種子 =========
random.seed(42)
np.random.seed(42)

# ========= SRAM 配置 =========
weight_base_word = 0x0000_0000
ifmap_base_word  = 0x0000_1000
ipsum_base_word  = 0x0000_2000
bias_base_word   = 0x0000_2500
opsum_base_word  = 0x0000_3000

weight_base = weight_base_word << 2
ifmap_base  = ifmap_base_word << 2
ipsum_base  = ipsum_base_word << 2
bias_base   = bias_base_word << 2
opsum_base  = opsum_base_word << 2
TOTAL_SRAM  = 64 * 1024  # 64 KiB

C_IN  = 32
C_OUT = 32
PIX   = 40

# ========= 初始化 SRAM =========
sram = np.zeros(TOTAL_SRAM, dtype=np.uint8)

# ========= 產生隨機資料 =========
weight = np.random.randint(-5, 5,  (C_OUT, C_IN),  dtype=np.int8)
ifmap  = np.random.randint(0, 6,  (C_IN,  PIX),   dtype=np.int8)
ipsum  = np.random.randint(5, 11, (C_OUT, PIX),   dtype=np.int16)
bias   = np.zeros(C_OUT,                    dtype=np.int16)   # 允許負數以測 ReLU

# ========= Weight 寫入 (4 byte group, little-endian) =========
w_flat = weight.flatten()
for i in range(0, len(w_flat), 4):
    grp = w_flat[i:i+4]
    for j, val in enumerate(reversed(grp)):
        sram[weight_base + i + j] = val

# ========= Ifmap 寫入 =========
f_flat = ifmap.flatten()
for i in range(0, len(f_flat), 4):
    grp = f_flat[i:i+4]
    for j, val in enumerate(reversed(grp)):
        sram[ifmap_base + i + j] = val

# ========= Ipsum 寫入 (兩筆 u16 → 一筆 u32, little-endian) =========
p_flat = ipsum.flatten()
for i in range(0, len(p_flat), 2):
    v0 = int(p_flat[i])          & 0xFFFF
    v1 = int(p_flat[i+1] if i+1 < len(p_flat) else 0) & 0xFFFF
    b0, b1 = v0 & 0xFF, (v0 >> 8) & 0xFF
    b2, b3 = v1 & 0xFF, (v1 >> 8) & 0xFF
    addr   = ipsum_base + i*2
    sram[addr + 0] = b3
    sram[addr + 1] = b2
    sram[addr + 2] = b1
    sram[addr + 3] = b0

# ========= Bias 寫入 (int16 little-endian) =========
for i, val in enumerate(bias.astype(np.int16)):
    addr = bias_base + i*2
    sram[addr]     =  val        & 0xFF
    sram[addr + 1] = (val >> 8)  & 0xFF

# ========= (1) RAW Opsum 計算 =========
raw_opsum = np.zeros((C_OUT, PIX), dtype=np.int32)
for oc in range(C_OUT):
    for p in range(PIX):
        acc = int(bias[oc]) + int(ipsum[oc, p])
        acc += np.dot(ifmap[:, p].astype(np.int32),
                      weight[oc, :].astype(np.int32))
        raw_opsum[oc, p] = acc

# ========= (2) PPU 處理 =========
# scaled   = np.right_shift(raw_opsum, SCALING_FACTOR).astype(np.int32)
ppu_out  = np.maximum(raw_opsum, 0) if RELU_ENABLE else raw_opsum
scaled   = np.right_shift(ppu_out, SCALING_FACTOR).astype(np.int32)
offset  = scaled + ZERO_POINT                                        # ③ +128

# 16-bit 飽和 (0 ~ 65535)
ppu_sat = np.clip(offset, 0, 0xFFFF).astype(np.uint16)  

# ========= 存檔：SRAM 影像 =========
with open('../sim/pointwise_ppu_memory.hex', 'w') as f:
    for i in range(0, len(sram), 4):
        f.write(''.join(f'{b:02X}' for b in sram[i:i+4]) + '\n')

# # ========= 存檔：未經 PPU 的 golden =========
# with open('../sim/pointwise_golden.hex', 'w') as f:
#     flat = raw_opsum.flatten()
#     for i in range(0, len(flat), 2):
#         v1 = flat[i]     & 0xFFFF
#         v2 = flat[i+1] & 0xFFFF if i+1 < len(flat) else 0
#         v32 = (v1 << 16) | v2
#         f.write(f'{(v32>>8)&0xFF:02X}{v32&0xFF:02X}{(v32>>24)&0xFF:02X}{(v32>>16)&0xFF:02X}\n')

# ========= 存檔：經過 PPU 的 golden =========
with open('../sim/pointwise_ppu_golden.hex', 'w') as f:
    flat = ppu_sat.flatten()
    for i in range(0, len(flat), 2):
        v1 = int(flat[i])
        v2 = int(flat[i+1]) if i+1 < len(flat) else 0
        v32 = (v1 << 16) | v2
        f.write(f'{(v32>>8)&0xFF:02X}{v32&0xFF:02X}{(v32>>24)&0xFF:02X}{(v32>>16)&0xFF:02X}\n')

# ========= 報告 =========
print("✅ SRAM 初始化完成 → ../sim/pointwise_ppu_memory.hex")
# print("✅ RAW Golden (無 PPU)  → ../sim/pointwise_golden.hex")
print("✅ PPU Golden          → ../sim/pointwise_ppu_golden.hex")
print(f"   • SCALING_FACTOR = {SCALING_FACTOR}")
print(f"   • RELU_ENABLE    = {RELU_ENABLE}")
print(f"Weight shape: {weight.shape}, Ifmap shape: {ifmap.shape}, "
      f"Ipsum shape: {ipsum.shape}, Bias shape: {bias.shape}")
