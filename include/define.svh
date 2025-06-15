// this is a define file for the include directory :define.svh
`ifndef DEFINE_LD
`define DEFINE_LD


// Layer Decoder defines
`define GLB_MAX_BYTES 64*1024 // Maximum number of bytes
`define BYTES_I 1 // Input feature map bytes
`define BYTES_W 1 // Weight bytes
`define BYTES_P 2 // Partial sum bytes

// convolution layer types
`define POINTWISE 0 // Bit width for activation
`define DEPTHWISE 1 // Bit width for activation
`define STANDARD 2 // Bit width for activation
`define LINEAR 3 // Bit width for activation

// Layer Descriptor flags
`define RELU_EN 1 // ReLU activation
`define ADD_EN 1  // residual addition
`define BIAS_EN 1 // Bias addition


//quantization scale
`define QUANT_SCALE 8 // Bit width for quantization scale
`define ZERO_POINT 128 // Zero point for quantization


// DMA address
`define DMA_BASE_ADDR 32'h3000_0000 // Base address for DMA transfers
// DMA offset
`define DMA_SOURCE_OFFSET 32'h0000_0100 // Offset for input feature map
`define DMA_DEST_OFFSET 32'h0000_0200 // Offset for output feature map
`define DMA_LEN_OFFSET 32'h0000_0300 // Offset for weights
`define DMA_EN_OFFSET 32'h0000_0400 // Offset for bias

`define DMA_SRC_ADDR 32'h3000_0100 // Source address for DMA transfers
`define DMA_DEST_ADDR 32'h3000_0200 // Destination address for DMA transfers
`define DMA_LEN_ADDR 32'h3000_0300 // Length of transfer for DMA
`define DMA_EN_ADDR 32'h3000_0400 // Enable signal for DMA transfers




// AXI define
`define DATA_BITS 32
`define DATA_WIDTH     32
`define ADDR_WIDTH     32
`define ID_WIDTH       4
`define IDS_WIDTH      8
`define LEN_WIDTH      4
`define MAXLEN         1
// fixed AXI parameters
`define STRB_WIDTH     4
`define SIZE_WIDTH     3
`define BURST_WIDTH    2  
`define CACHE_WIDTH    4  
`define PROT_WIDTH     3  
`define BRESP_WIDTH     2
`define RRESP_WIDTH     2
`define AWUSER_WIDTH   32 // Size of AWUser field
`define WUSER_WIDTH    32 // Size of WUser field
`define BUSER_WIDTH    32 // Size of BUser field
`define ARUSER_WIDTH   32 // Size of ARUser field
`define RUSER_WIDTH    32 // Size of RUser field
`define QOS_WIDTH      4  // Size of QOS field
`define REGION_WIDTH   4  // Size of Region field




`endif // DEFINE_LD