# -*- coding: utf-8 -*-
import random
import numpy as np

# === 設定隨機種子 ===
random.seed(42)
np.random.seed(42)

# === SRAM 配置參數 ===
weight_base_word = 0x0000_0000 # word
ifmap_base_word  = 0x0000_1000 # word
ipsum_base_word  = 0x0000_2000 # word
bias_base_word   = 0x0000_2500 # word
opsum_base_word  = 0x0000_3000 # word

weight_base = weight_base_word << 2 # byte
ifmap_base  = ifmap_base_word << 2 # byte
ipsum_base  = ipsum_base_word << 2 # byte
bias_base   = bias_base_word << 2 # byte
opsum_base  = opsum_base_word << 2 # byte
total_sram_size = 64 * 1024  # 64KB

C_in = 32
C_out = 32
pix = 40

# === 初始化 SRAM ===
sram = np.zeros(total_sram_size, dtype=np.uint8)

# === 隨機資料產生 ===
weight = np.random.randint(0, 6, size=(C_out, C_in), dtype=np.uint8)
ifmap  = np.random.randint(0, 6, size=(C_in, pix), dtype=np.uint8)
ipsum  = np.random.randint(5, 11, size=(C_out, pix), dtype=np.uint16)
bias   = np.zeros(C_out, dtype=np.uint16)

# === 寫入 Weight（每 4 bytes 反向：小 index 放右邊）===
weight_flat = weight.flatten()
for i in range(0, len(weight_flat), 4):
    group = weight_flat[i:i+4]
    for j, val in enumerate(reversed(group)):
        addr = weight_base + i + j
        sram[addr] = val

# === 寫入 Ifmap（同樣 4 bytes 小端寫入）===
ifmap_flat = ifmap.flatten()
for i in range(0, len(ifmap_flat), 4):
    group = ifmap_flat[i:i+4]
    for j, val in enumerate(reversed(group)):
        addr = ifmap_base + i + j
        sram[addr] = val

# === 寫入 Ipsum（每兩筆 int16 小端合成 4-byte 小端）===
ipsum_flat = ipsum.flatten()
for i in range(0, len(ipsum_flat), 2):
    val0 = ipsum_flat[i] & 0xFFFF
    val1 = ipsum_flat[i + 1] & 0xFFFF if i + 1 < len(ipsum_flat) else 0

    # 小端序排列 val0（低位）在右、val1（高位）在左
    b0 = (val0 >> 0) & 0xFF
    b1 = (val0 >> 8) & 0xFF
    b2 = (val1 >> 0) & 0xFF
    b3 = (val1 >> 8) & 0xFF

    addr = ipsum_base + i * 2  # 每筆 2 bytes，因此第 i 筆位址為 i*2
    sram[addr + 0] = b3
    sram[addr + 1] = b2
    sram[addr + 2] = b1
    sram[addr + 3] = b0


# === 寫入 Bias（每個 int16 小端序）===
for i, val in enumerate(bias):
    addr = bias_base + i * 2
    sram[addr]     = val & 0xFF
    sram[addr + 1] = (val >> 8) & 0xFF


# === 計算 Golden Opsum（int32 計算，但最終輸出 16-bit）===
golden_opsum = np.zeros((C_out, pix), dtype=np.int32)
for oc in range(C_out):
    for p in range(pix):
        acc = int(bias[oc]) + int(ipsum[oc][p])
        for ic in range(C_in):
            acc += int(ifmap[ic][p]) * int(weight[oc][ic])
        golden_opsum[oc][p] = acc

        # ✅ 額外印出前幾筆 debug 計算過程
        if oc < 1 and p < 16:
            print(f"[DEBUG] oc={oc}, pix={p}, ipsum={ipsum[oc][p]}")
            term_str = []
            for ic in range(C_in):
                a = ifmap[ic][p]
                b = weight[oc][ic]
                term_str.append(f"{a}*{b}={a*b}")
            print("         Terms: " + ", ".join(term_str))
            print(f"         Final sum = {golden_opsum[oc][p]}\n")

# === 儲存 memory.hex 檔 ===
with open('../sim/pointwise_memory.hex', 'w') as f:
    for i in range(0, len(sram), 4):
        line = ''.join(f'{b:02X}' for b in sram[i:i+4])
        f.write(line + '\n')

# === 儲存 golden.hex 檔（每兩個 16-bit 值合併為 32-bit，小端序）===
with open('../sim/pointwise_golden.hex', 'w') as f:
    golden_flat = golden_opsum.flatten()
    for i in range(0, len(golden_flat), 2):  # 每兩個 16-bit 值一組
        val1 = golden_flat[i] & 0xFFFF  # 第一個 16-bit 值
        val2 = golden_flat[i + 1] & 0xFFFF if i + 1 < len(golden_flat) else 0  # 第二個 16-bit 值（若無則填 0）
        val_32bit = (val1 << 16) | val2  # 合併：val1 高位，val2 低位
        b1 = (val_32bit >> 0) & 0xFF
        b0 = (val_32bit >> 8) & 0xFF
        b3 = (val_32bit >> 16) & 0xFF
        b2 = (val_32bit >> 24) & 0xFF
        f.write(f'{b0:02X}{b1:02X}{b2:02X}{b3:02X}\n')

# === 結尾印出確認 ===
print("SRAM data generated and saved to ../sim/pointwise_memory.hex")
print("Golden data generated and saved to ../sim/pointwise_golden.hex")
print("Weight, Ifmap, Ipsum, Bias, and Opsum initialized successfully.")
print(f"Weight shape: {weight.shape}, Ifmap shape: {ifmap.shape}, Ipsum shape: {ipsum.shape}, Bias shape: {bias.shape}, Opsum shape: {golden_opsum.shape}")
print(f"Total SRAM size: {total_sram_size} bytes, used: {total_sram_size} bytes")
print(f"Weight base address: {weight_base:#010X}, Ifmap base address: {ifmap_base:#010X}, Ipsum base address: {ipsum_base:#010X}, Bias base address: {bias_base:#010X}, Opsum base address: {opsum_base:#010X}")
print("Data generation completed successfully.")