# **Layer Decoder**
https://www.notion.so/chengchihyu/Controller-1fee7b34229480aba160fa920b14aaa0?pvs=4
## 功能概覽
接收來自 Testbench 的每層 Layer 訊息（Layer Descriptor，uLD），**將原始資訊緩存**，並根據硬體資源（GLB 容量、bitwidth 設定）**計算出各項 tile 切分與輸出特徵圖參數**，供下游模組（Tile Scheduler、DMA Controller、Token Engine）使用。
## Input

| 200bits | width | 來源 | 功能說明 | 需要思考的點 |
| --- | --- | --- | --- | --- |
| **`layer_id`** | 6 bits | Testbench | 用於 Log、Debug 與多層切換 |  |
| **`layer_type`** | 2 bits | Testbench | 決定這一層是 Pointwise / Depthwise / Linear 哪種?  |  |
| **`in_R`, `in_C`** | 7 bits | Testbench | 輸入特徵圖 Height／Width | max=112 |
| **`in_D`** | 11 bits | Testbench | 輸入通道數 | max=1280 |
| **`out_K`** | 11 bits | Testbench | 輸出通道數 | max=1280 |
| **`stride`** | 2 bits | Testbench | stride | DepthWise 需要考慮 |
| **`pad_H,pad_B,pad_R,pad_L`** | 2 bits | Testbench | 4 個方向的 padding | padding 可能都一樣 |
| **`base_ifmap`** | 32bits | Testbench | ifmap 在 DRAM 的起始位址 |  |
| **`base_weight`** | 32bits | Testbench | weight 在 DRAM 的起始位址 |  |
| **`base_bias`** | 32bits | Testbench | bias 在 DRAM 的起始位址（若無可填 0） |  |
| **`base_ofmap`** | 32bits | Testbench | ofmap 在 DRAM 的起始位址 |  |
| **`Flag`** | 4 bits | Testbench | 功能開關（**bit0=ReLU, bit1=Linear, bit2=Skip, bit3=Bias**） | 可能會需要考慮其他 |
| **`quant_sclae`** | 8 bits | Testbench | 如同 eyeriss ，每一層都會輸入自己的 scale |  |

## Output

除了 **Decode** 出的資訊，**Layer Descriptor** 會額外計算以下參數輸出

| 欄位 | width | 下游目標 | 功能說明 | 需要思考的點 |
| --- | --- | --- | --- | --- |
| **`tile_R`** | 7 bits | Tile Scheduler | 透過公式計算 | max 先設跟 ifmap max size 一樣 |
| **`tile_D`** | 7 bits | Tile Scheduler | pointwise 固定 32；depthwise 固定 1 |  |
| **`tile_K`** | 7 bits | Tile Scheduler | pointwise 固定 32；depthwise 固定 10 |  |
| **`out_tile_R`**  | 7 bits |  | Depthwise Convolution 會因為 stride/pad 導致 out_tile_R 與 tile_R 不一樣  |  |
| **`num_tile_R`** | 7 bits | Tile Scheduler | R 方向切塊數 = ⌈(in_R + 2·padding) / tile_R⌉ |  |
| **`num_tile_D`** | 7 bits | Tile Scheduler | 通道 D 切塊數 = ⌈in_D / tile_D⌉ |  |
| **`num_tile_K`** | 7 bits | Tile Scheduler | 通道 K 切塊數 = ⌈out_K / tile_K⌉ |  |
| **`out_R`** | 7 bits | Tile Scheduler | ofmap 的 Height |  |
| **`out_C`** | 7 bits | Tile Scheduler | ofmap 的 Weight |  |

---



### 輸入資訊（由 Testbench 提供）

這些資訊皆可由 ONNX 模型自動提取，不包含 tile 相關參數 **⇒ General Propose DSE Accelerator**

| **欄位名稱** | **說明** |
| --- | --- |
| **`layer_id_i`** | layer 編號，用於 Debug 與多層管理 |
| **`layer_type_i`** | layer 類型（0=Pointwise, 1=Depthwise, 2=Standard, 3=Linear） |
| **`in_R_i`, `in_C_i`** | 輸入特徵圖尺寸（高與寬） |
| **`in_D_i`, `out_K_i`** | 輸入／輸出通道數 |
| **`stride_i`** | 空間 stride 值（DW/STD 會用到） |
| **`pad_T/B/L/R_i`** | 上下左右 padding 數值 |
| **`base_*_i`** | DRAM 中 ifmap / weight / bias / ofmap 的起始位址 |
| **`flags_i`** | Flag（bit0=ReLU、1=Linear、2=Skip、3=Bias） |
| **`quant_scale_i`** | 每層量化比例值（對應 eyeriss scale） |
| **`uLD_en_i`** | Descriptor 有效旗標 |

### 輸出資訊

1. 緩存原始輸入資訊（全部轉出 `_o`）
    
    `layer_id_o`, `layer_type_o`, `in_D_o`, `out_K_o`, `stride_o`, `pad_*_o`, `base_*_o`, `flags_o`, `quant_scale_o`
    
2. 計算空間尺寸與 padding 結果
    - `padded_R_o`, `padded_C_o`：原始輸入加上 padding
    - `out_R_o`, `out_C_o`：輸出特徵圖的高度與寬度
        
        $\text{out\_R} = \left\lfloor \frac{in\_R + pad\_T + pad\_B - kH}{stride} \right\rfloor + 1$
        

### 計算 tile 切分與參數

| **參數名稱** | **說明** |
| --- | --- |
| **`tile_R_o`** | 一次處理的輸出行數（根據 GLB 推導） |
| **`tile_D_o`** | 一次載入的輸入通道數（PW=32，DW=1） |
| **`tile_K_o`** | 一次產生的輸出通道數（PW=32，DW=10） |
| **`out_tile_R_o`** | tile_R 所對應產出的實際 output rows |
| **`num_tiles_R_o`** |  |
| **`num_tiles_D_o`** |  |
| **`num_tiles_K_o`** |  |

---

## 0. Summary

### 0.1 ofmap width/height (**`out_R`、**`out_C`)

1. Pointwise 相同
2. Depthwise 需要使用以下公式計算輸出的 Size
        $\text{out\_R} = \left\lfloor \frac{in\_R + pad\_T + pad\_B - kH}{stride} \right\rfloor + 1$

### 0.2 Tile 參數計算

| 參數 | 含義 | Pointwise 建議值 | Depthwise 建議值 |
| --- | --- | --- | --- |
| **tile_R** | 每次在 GLB 中同時儲存的 **ifmap row** 數量 | 由 Layer Decoder 計算
（依 GLB 容量公式求得） | 由 Layer Decoder 計算
（依 GLB 容量公式求得） |
| **tile_D** | 每次在 GLB 中同時儲存的 **ifmap channel** 數量 | 固定 = 32
（對應 32 列 MUL 陣列） | 固定 = 1
（Depthwise 不跨通道累加） |
| **tile_K** | 每次在 GLB 中同時儲存的 **ofmap channel** 數量 | 固定 = 32
（對應 32 行 MUL 陣列） | 固定 = 10
（可同時對 10 個 channel 做 3×3 DW） |

| out_tile_R | Depthwise Convolution 會因為 stride/pad 導致 out_tile_R 與 tile_R 不一樣  |
| --- | --- |

可以用先前的公式從 tile_R 計算



**tile_R 計算公式**

```python

# GLB Size: 64 KB
padded_C = C + pad_R + pad_L
out_C = ((padded_C - kernel_size) / stride) + 1
tile_R =  tile_R_max - ( ( tile_R_max - 3 ) % stride )
out_tile_R = ((tile_R - kernel_size) / stride) + 1

ifmap GLB usage = tile_R_max * padded_C * tile_D * 1 byte
filter GLB usage = tile_D * tile_K * kernel size * kernel size * 1 byte
bias GLB usage = tile_K * 1 byte
ofmap GLB usage = out_tile_R * tile_K * out_C * 2 byte
```

```python
tile_R_max * padded_C * tile_D + tile_D * tile_K * kernel size * kernel size + tile_K + out_tile_R * tile_K * out_C * 2
```

</aside>

```nasm
輸入 kernel_size、stride、padded_C、tile_D、tile_K、out_C
求 tile_R_max

out_tile_R = ((**tile_R_max** - kernel_size) / stride) + 1

64 * 1024 = (tile_R_max * padded_C * tile_D + tile_D * tile_K * kernel size * kernel size + tile_K + out_tile_R * tile_K * out_C * 2 ) 
```

Depthwise 需要考慮 padding 與 stride


**num_tile_R、num_tile_D、num_tile_K**

```python
# 記得考慮 padding
num_tiles_R = ceil((Padded_R / tile_R)
num_tiles_D = ceil(in_D / tile_D)
num_tiles_K = ceil(out_K / tile_K)
```

</aside>

### 0.3 Flag

**Pointwise** 卷積分成兩種情境

1. **Expansion conv（t×1×1 + ReLU6）**
2. **Projection conv（1×1 + Linear）**
    
    此外，在部分 Bottleneck block 還有 **Residual Skip-Add**。
    

**Depthwise** 卷積可能需要考慮

1. padding 是否啟用 ⇒ 會在 DRAM 讀進 GLB 時先 padding 好，不用考慮
2. bias 是否啟用

綜上所想，Flag Signal 需要以下資訊

| Flag[3:0] Bit | 名稱 | 功能說明 |
| --- | --- | --- |
| 0 | `relu_en` | 計算完畢後對 ofmap 執行 ReLU6（Expansion） |
| 1 | `linear_en` | 計算完畢後跳過 activation（Projection） |
| 2 | `skip_en` | 如果本層有殘差連接，完成 ofmap 後執行 `ofmap += skip_input` |
| 3 | `bias_en` | 是否在每個輸出 channel 前加上 bias |

## 1. Pointwise

### 1.1 Pointwise 的 Tile 參數

- **tile_R**：GLB 儲存的 **ifmap row** **數量**；需要計算
- **tile_D**：GLB 儲存的 **ifmap channel** **數量**；固定 =32
- **tile_K**：GLB 儲存的 **ofmap channel 數量**；固定 =32
1. 計算 tile_R
    
    **硬體實作**
    
    在 Layer Decoder 裡會根據每層的 in_C 和 GLB 容量，透過先前 Python 公式算出最合適的 tile_R
    
2. 計算 num_tile_R、num_tile_D、num_tile_K
    
    **硬體實作**
    
    ```nasm
    num_tiles_R = ceil((in_R + 2*pad) / tile_R)
    num_tiles_D = ceil(in_D / tile_D)
    num_tiles_K = ceil(out_K / tile_K)
    ```
    

### 1.2 DMA Controller 參數

> **Tile Scheduler 使用**
> 

Layer Decoder 從 uLD 解碼後傳遞至 Tile Scheduler

這些參數會在 後續計算 DMA Control Signal 時用到

- **base_ifmap** ：**ifmap** 在 **DRAM** 的起始位址
- **base_weight**： **weight** 在 **DRAM** 的起始位址
- **base_bias** ：**bias** 在 **DRAM** 的起始位址（若無可填 0）
- **base_ofmap** ：**ofmap** 在 **DRAM** 的起始位址
- **in_R, in_C, in_D, out_K**
- **tile_R**, **tile_D**, **tile_K**

### 1.3 Stride/Padding

- Pointwise 層通常 `stride=1`、`padding=0`（1×1 卷積不改空間大小），因此我們暫不考慮。
- Depthwise/Standard 才用到 `stride` 與 `padding`，那時再把這兩個欄位拉進 uLD 解碼。

### 1.4 Flag 設計（MobileNetV2 Pointwise 層）

> **Token engine 使用**
> 

在 MobileNetV2 裡，Pointwise 卷積分成兩種情境：

1. **Expansion conv（t×1×1 + ReLU6）**
2. **Projection conv（1×1 + Linear）**
    
    此外，在部分 Bottleneck block 還有 **Residual Skip-Add**。
    

| Bit | 名稱 | 功能說明 |
| --- | --- | --- |
| 0 | `relu_en` | 計算完畢後對 ofmap 執行 ReLU6（Expansion） |
| 1 | `linear_en` | 計算完畢後跳過 activation（Projection） |
| 2 | `skip_en` | 如果本層有殘差連接，完成 ofmap 後執行 `ofmap += skip_input` |
| 3 | `bias_en` | 是否在每個輸出 channel 前加上 bias |

BN 已經融合進入 Bias，這邊不考慮

- **Expansion conv**：通常 `relu_en=1, linear_en=0, skip_en=0, bias_en=1`
- **Projection conv**：`relu_en=0, linear_en=1, skip_en=1 (if stride=1 & in_D=out_K), bias_en=0`

---

## 2. Depthwise

### 2.1 Depthwise 的 Tile 參數

- **tile_R**：GLB 儲存的 **ifmap row** **數量**；需要計算
- **tile_D**：GLB 儲存的 **ifmap channel** **數量**；固定 =1 (Depth wise 不需要在 D 方向進行累加)
- **tile_K**：GLB 儲存的 **ofmap channel 數量**；固定 = 10 (MUL array 最多可以同時計算 10 張 ofmap)
1. 計算 tile_R
    
    **硬體實作**
    
    在 Layer Decoder 裡會根據每層的 in_C 和 GLB 容量，透過先前 Python 公式算出最合適的 tile_R
    
2. 計算 num_tile_R、num_tile_D、num_tile_K
    
    **硬體實作**
    
    ```nasm
    num_tiles_R = ceil((in_R + 2*pad) / tile_R)
    num_tiles_D = ceil(in_D / tile_D)
    num_tiles_K = ceil(out_K / tile_K)
    ```
    

### 2.2 DMA controller 參數

> **Tile Scheduler 使用**
> 

與 pointwise 相同

### 2.3 Stride/Padding

> **用於計算 Tile 參數**
> 

### 2.4 Flag 設計

> **Token engine 使用**
> 

與 pointwise 相同

| Bit | 名稱 | 功能說明 |
| --- | --- | --- |
| 0 | `relu_en` | 計算完畢後對 ofmap 執行 ReLU6（Expansion） |
| 1 | `linear_en` | 計算完畢後跳過 activation（Projection） |
| 2 | `skip_en` | 如果本層有殘差連接，完成 ofmap 後執行 `ofmap += skip_input` |
| 3 | `bias_en` | 是否在每個輸出 channel 前加上 bias |



**備註**

1. 一般 `padding` 直接在 DMA preload 進 GLB 就處理好
2. Fuse 過後**不用特別考慮 BatchNorm ，已經融入 Bias**

---