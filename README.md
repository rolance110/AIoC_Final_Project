# AIoC_Final_Project
## MobileNeV2
training_and_quantization資料夾內包含AOC_final_MobileNetV2_ReLU_imagenette.ipynb及模型的權重檔，AOC_final_MobileNetV2_ReLU_imagenette.ipynb含有模型訓練和量化流程，可在colab上執行。
## MobileNeV2_extract_test
### 所需環境
執行MobileNeV2_extract_test夾內的python檔是在下列環境下執行:

_libgcc_mutex             0.1           
_openmp_mutex             5.1           
bzip2                     1.0.8         
ca-certificates           2025.2.25     
coloredlogs               15.0.1        
contourpy                 1.3.1         
cycler                    0.12.1        
filelock                  3.18.0        
flatbuffers               25.2.10       
fonttools                 4.56.0        
fsspec                    2025.3.0  
fastdownload              0.0.7 \
fastcore                  1.8.4 \
fastprogress              1.0.3 \
humanfriendly             10.0          
jinja2                    3.1.6         
kiwisolver                1.4.8         
ld_impl_linux-64          2.40          
libffi                    3.4.4         
libgcc-ng                 11.2.0        
libgomp                   11.2.0        
libstdcxx-ng              11.2.0        
libuuid                   1.41.5        
markupsafe                3.0.2         
matplotlib                3.10.1        
mpmath                    1.3.0         
ncurses                   6.4           
networkx                  3.4.2         
numpy                     2.2.4         
onnx                      1.17.0        
onnxruntime               1.21.0        
openssl                   3.0.16        
packaging                 24.2          
pandas                    2.2.3         
pillow                    11.1.0        
pip                       25.0          
protobuf                  6.30.1        
pyparsing                 3.2.1         
python                    3.10.16       
python-dateutil           2.9.0.post0   
pytz                      2025.1        
readline                  8.2           
setuptools                75.8.0        
six                       1.17.0        
sqlite                    3.45.3        
sympy                     1.13.1        
tabulate                  0.9.0         
tk                        8.6.14        
torch                     2.6.0+cpu     
torchvision               0.21.0+cpu    
tqdm                      4.67.1        
typing-extensions         4.12.2        
tzdata                    2025.1        
wheel                     0.45.1        
xz                        5.6.4         
zlib                      1.2.13 

### 檔案與模組結構
```
MobileNeV2_extract_test/
│
├── model/
│   ├── MobileNetV2_ReLU.py
│   └── __init__.py         
├── weights/
│   ├── mobilenetv2.pt              
│   └── mobilenetv2-power2.pt       
├── params_float/              # 儲存浮點模型參數
├── params_quant_linear/       # 儲存量化後模型參數 
├── custom_qconfig.py 
├── extract_params.py 
├── convert_int8_to_hex.py 
├── scaling_factor.py 
├── bias_int16.py
└── test_quant.py
```

**python檔內讀取params_quant_linear資料夾內參數的路徑需要調整**

### extract_params.py
從一個 float32 或經過 FX 流程量化（Post-Training Quantization）的 MobileNetV2 模型中提取參數，並儲存為可讀的 .txt 格式，目的是提供給下游的硬體加速器使用(將參數讀進 DRAM);提取的參數例如weight、bias、scale、zero point儲存在params_quant_linear資料夾中。
### convert_int8_to_hex.py
將含有 shape 資訊與 int8 權重值的 weight.txt 檔案轉換為 .hex 檔案格式，讓模型參數格式更接近記憶體初始化格式，供硬體端的verilog使用。
### bias_int16.py
從 `bias.txt` 檔案bias 參數，根據量化規則轉換為硬體設計的int16 格式，然後儲存為十六進位字串（`.hex` 檔），以便部署至硬體加速器。

在量化模型部署時，`bias` 需要轉換為整數型別。其轉換公式為：

![alt text](/docs/images/bias.png)


其中：

* `x_scale`：輸入特徵圖的scale
* `w_scale`：該層權重的scale
* `bias_int`：最終以 `int16` 表示並輸出為 hex 格式
### scaling_factor.py
為 MobileNetV2 的每一層計算 scaling exponent n，並將結果輸出成兩種格式：

- 純文字格式 .txt：每行列出 layer 名稱與 exponent n
- 十六進位格式 .hex：只輸出 n 的正整數值（以 00～ff 表示）

這在將模型部署至硬體時非常實用，因為乘法可以轉換為：

$$
x \cdot w \approx y \ll n \quad \text{or} \quad y \gg n
$$

根據

![alt text](/docs/images/quant.png)

使用

![alt text](/docs/images/scaling_factor.png)

求出n值，讓硬體加速器能使用整數位移近似浮點運算，達到減法與乘法的能耗與延遲優化。
### test_quant.py
從 .txt 檔案（包含 weight、bias、scale、zero_point 參數）還原出一個已量化的 MobileNetV2 模型，並將其正確套用到 FX Graph Mode Quantization 的 PyTorch 模型上，以進行部署或測試。因為模型的所有參數可由事前量化導出的 .txt 檔案還原，不必依賴原始 .pt 權重，所以可驗證從 extract_params.py提取的參數正確性。
## model_load

使用VCS版本:VCS Q-2020.03_Full64

### 檔案與模組結構
```
model_load/
  ├── layer_info/ #params_quant_linear中的hex檔
  ├── sim/ 
  │    └── read_weight_bias.sv 
  └── Makefile
```
### read_weight_bias.sv
因為我們目前沒辦法將提取的參數放入我們硬體DRAM，還要考慮要跟tiling順序一致，及運算問題，所以這邊模擬一個記憶體並將每層的weight、bias依序放入，並顯示存放的位置。

**執行指令:make vcs WV=2**，可在終端看到每一層的存放位址，並可使用**make wave**在nWave看到每一筆的儲存結果。











