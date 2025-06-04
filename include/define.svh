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
`define FLAG_RELU 0 // ReLU activation
`define FLAG_ADD 1  // residual
`define FLAG_SKIP 2 // Skip connection
`define FLAG_BIAS 3 // Bias addition


//quantization scale
`define QUANT_SCALE 8 // Bit width for quantization scale
`define ZERO_POINT 128 // Zero point for quantization

`endif // DEFINE_LD
