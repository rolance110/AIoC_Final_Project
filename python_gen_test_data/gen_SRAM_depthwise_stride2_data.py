# -*- coding: utf-8 -*-
import random, math, numpy as np

# ────────────────────────────────────────────────────────────
# ❶ PPU 參數（同一套寫死就好，改這裡就行）
SCALING_FACTOR = 3     # 右移位數
RELU_ENABLE    = False  # 啟用 ReLU
ZERO_POINT     = 128   # +128 偏移
# ────────────────────────────────────────────────────────────

# 固定隨機種子
random.seed(42); np.random.seed(42)

# TODO: CONFIG
COMPUTE_ROW = 5

# 卷積 & stride=2
IMG_H, IMG_W = 114, 114
C, KERNEL_SIZE, STRIDE = 10, 3, 2
PAD_T, PAD_B, PAD_L, PAD_R = 1, 1, 1, 1

OUTPUT_ROW = math.floor((COMPUTE_ROW - KERNEL_SIZE)/STRIDE) + 1
OUTPUT_W   = math.floor((IMG_W - KERNEL_SIZE + PAD_L + PAD_R)/STRIDE) + 1

EFFECTIVE_H, EFFECTIVE_W = COMPUTE_ROW, IMG_W
IS_TOP_TILE, is_bias = True, False      # 和舊檔一致

# SRAM CONFIG
TOTAL_SRAM = 64*1024; WORD = 4
WBASE_W, FBASE_W, BBASE_W, IBASE_W, OBASE_W = 0x0, 0x1000, 0x2900, 0x2000, 0x3000
WBASE = WBASE_W*WORD; FBASE = FBASE_W*WORD; BBASE = BBASE_W*WORD
IBASE = IBASE_W*WORD; OBASE = OBASE_W*WORD

# ─── 初始化資料 ───
sram = np.zeros(TOTAL_SRAM, np.uint8)
weight = np.random.randint(0,6,(C,KERNEL_SIZE,KERNEL_SIZE),np.uint8)
ifmap  = np.random.randint(0,6,(C,EFFECTIVE_H,EFFECTIVE_W),np.uint8)
ipsum  = np.random.randint(5,10,(C,OUTPUT_ROW,OUTPUT_W),np.uint16)
bias   = np.random.randint(0,10,(C,),np.uint16)

# ─── Weight 寫 SRAM (小端、靠右) ───
wflat = weight.flatten()
for i in range(0,len(wflat),4):
    grp, addr = wflat[i:i+4], WBASE+i
    pad = np.zeros(4,np.uint8); pad[:len(grp)] = grp
    sram[addr:addr+4] = pad  # pad 本身就是 LSB->MSB

# ─── Ifmap 寫 SRAM ───
fflat = ifmap.flatten()
for i in range(0,len(fflat),4):
    grp = fflat[i:i+4]; addr = FBASE+i
    pad = np.zeros(4,np.uint8); pad[:len(grp)] = grp
    sram[addr:addr+4] = pad

# ─── Ipsum 寫 SRAM (每2筆 u16 → u32) ───
pflat = ipsum.flatten()
for i in range(0,len(pflat),2):
    v0 = int(pflat[i]) & 0xFFFF
    v1 = int(pflat[i+1]) & 0xFFFF if i+1<len(pflat) else 0
    addr = IBASE + i*2
    sram[addr+0] =  v0 & 0xFF
    sram[addr+1] = (v0>>8)&0xFF
    sram[addr+2] =  v1 & 0xFF
    sram[addr+3] = (v1>>8)&0xFF

# ─── Bias 寫 SRAM ───
for i,val in enumerate(bias):
    addr=BBASE+i*2; sram[addr]=val&0xFF; sram[addr+1]=(val>>8)&0xFF

# ─── (A) RAW Opsum ───
raw_ops = np.zeros((C,OUTPUT_ROW,OUTPUT_W),np.int32)
for c in range(C):
    for r in range(OUTPUT_ROW):
        for col in range(OUTPUT_W):
            ps = int(ipsum[c,r,col])
            for kr in range(KERNEL_SIZE):
                for kc in range(KERNEL_SIZE):
                    in_r = r*STRIDE + kr - (1 if IS_TOP_TILE else 0)
                    in_c = col*STRIDE + kc - PAD_L
                    a = 0
                    if 0<=in_r<EFFECTIVE_H and 0<=in_c<EFFECTIVE_W:
                        a = ifmap[c,in_r,in_c]
                    ps += int(a)*int(weight[c,kr,kc])
            raw_ops[c,r,col] = ps

# ─── (B) PPU 處理 ───
relu_out   = np.maximum(raw_ops,0) if RELU_ENABLE else raw_ops
shift_out  = np.right_shift(relu_out, SCALING_FACTOR).astype(np.int32)
offset_out = shift_out + ZERO_POINT
ppu_sat    = np.clip(offset_out, 0, 0xFFFF).astype(np.uint16)

# ─── 存檔：SRAM ───
with open('../sim/depthwise_stride2_memory.hex','w') as f:
    for i in range(0,len(sram),4):
        f.write(''.join(f'{b:02X}' for b in sram[i+3:i-1 if i else None:-1])+'\n')

# 封包 helper
def pack32(v1,v0):
    return [(v1>>8)&0xFF, v1&0xFF, (v0>>8)&0xFF, v0&0xFF]

# ─── 存檔：RAW golden ───
with open('../sim/depthwise_stride2_golden.hex','w') as f:
    flat=raw_ops.flatten()
    for i in range(0,len(flat),2):
        v0=int(flat[i]); v1=int(flat[i+1]) if i+1<len(flat) else 0
        f.write(''.join(f'{b:02X}' for b in pack32(v1&0xFFFF, v0&0xFFFF))+'\n')

# # ─── 存檔：PPU golden ───
# with open('../sim/depthwise_stride2_ppu_golden.hex','w') as f:
#     flat=ppu_sat.flatten()
#     for i in range(0,len(flat),2):
#         v0=int(flat[i]); v1=int(flat[i+1]) if i+1<len(flat) else 0
#         f.write(''.join(f'{b:02X}' for b in pack32(v1, v0))+'\n')

# ─── Log ───
print("✅ SRAM → depthwise_stride2_memory.hex")
# print("✅ RAW  → depthwise_stride2_golden_raw.hex")
print("✅ PPU  → depthwise_stride2_golden.hex")
print(f"   • SCALING_FACTOR={SCALING_FACTOR}, RELU={RELU_ENABLE}, ZP={ZERO_POINT}")
print(f"Opshape={raw_ops.shape},  SRAM used≈{len(sram)} B")
