# -*- coding: utf-8 -*-
import random

# Set file size to 64KB, 32 bits (4 bytes) per line, total 16384 lines (64KB / 4)
num_lines = 64 * 1024 // 4

# Open file for writing
with open('../sim/memory.hex', 'w') as f:
    for _ in range(num_lines):
        # Generate random 32-bit data (4 bytes, each byte 00-0F)
        byte1 = random.randint(0, 6)
        byte2 = random.randint(0, 6)
        byte3 = random.randint(0, 6)
        byte4 = random.randint(0, 6)
        # Format as 8-digit hexadecimal with zero-padding (e.g., 01020304)
        hex_line = f"{byte1:02X}{byte2:02X}{byte3:02X}{byte4:02X}"
        f.write(hex_line + '\n')