/*===========================================================================
    Module: L2C_init_fifo_pe
    Description: 初始化所有 FIFO 與 PE 狀態，設定 base_addr 與 reset FIFO
        1. [31:0] fifo_reset_o: 給 96 個 FIFO 的 reset 訊號
        2. 設置 96 個 FIFO 的 base address    
            * [31:0] ifmap_fifo_base_addr_o [31:0]
            * [31:0] ipsum_fifo_base_addr_o [31:0]
            * [31:0] opsum_fifo_base_addr_o [31:0]
===========================================================================*/
module L2C_init_fifo_pe #(
    parameter int NUM_FIFO = 96
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic         init_fifo_pe_state_i,           // 啟動初始化
    input  logic [31:0]  ifmap_glb_base_addr_i, // 各 FIFO base address 由上層配置
    input  logic [31:0]  ipsum_glb_base_addr_i, // 各 FIFO base address 由上層配置
    input  logic [31:0]  opsum_glb_base_addr_i, // 各 FIFO base address 由上層配置
    input  logic [31:0]  bias_glb_base_addr_i, 
    input logic is_bias, // 判斷現在 ipsum_fifo 是要輸入 bias or ipsum 
    
    //* Form Tile_Scheduler
    // require by every module
    input logic [1:0] layer_type_i,
    // ifmap base addr require
    input logic [31:0] tile_n_i,
    input logic [8:0] in_C_i,
    input logic [1:0] pad_R_i,
    input logic [1:0] pad_L_i,
    // ofmap base addr require
    input logic [31:0] On_real_i,
    input logic [8:0] out_C_i,


    output logic [31:0] ifmap_fifo_base_addr_o [31:0],
    output logic [31:0] ipsum_fifo_base_addr_o [31:0],
    output logic [31:0] opsum_fifo_base_addr_o [31:0],
);

// ifmap_glb_base_addr_i
integer i, j, k, r, t;
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i=0; i<32; i++)begin
            ifmap_glb_base_addr_i[i] <= 32'd0;
        end
    end
    else if(layer_type_i == `POINTWISE && init_fifo_pe_state_i)begin
    // input channel 0
        ifmap_fifo_base_addr_o[0] <= ifmap_glb_base_addr_i;
    // input channel 1
        ifmap_fifo_base_addr_o[1] <= ifmap_glb_base_addr_i + tile_n_i;
    // input channel 2
        ifmap_fifo_base_addr_o[2] <= ifmap_glb_base_addr_i + 2*tile_n_i;
    // input channel 3
        ifmap_fifo_base_addr_o[3] <= ifmap_glb_base_addr_i + 3*tile_n_i;
    // input channel 4
        ifmap_fifo_base_addr_o[4] <= ifmap_glb_base_addr_i + 4*tile_n_i;
    // input channel 31
        ifmap_fifo_base_addr_o[31] <= ifmap_glb_base_addr_i + 31*tile_n_i;
    end
    else if(layer_type_i == `DEPTHWISE && init_fifo_pe_state_i)begin
    // input channel 0
        ifmap_fifo_base_addr_o[0] <= ifmap_glb_base_addr_i; // row1
        ifmap_fifo_base_addr_o[1] <= ifmap_glb_base_addr_i + (in_R+pad_R+pad_L); // row2
        ifmap_fifo_base_addr_o[2] <= ifmap_glb_base_addr_i + 2*(in_R+pad_R+pad_L); // row3
    // input channel 1
        ifmap_fifo_base_addr_o[3] <= ifmap_glb_base_addr_i + tile_n_i*(in_R+pad_R+pad_L); // row1
        ifmap_fifo_base_addr_o[4] <= ifmap_glb_base_addr_i + tile_n_i*(in_R+pad_R+pad_L) + (in_R+pad_R+pad_L); // row2
        ifmap_fifo_base_addr_o[5] <= ifmap_glb_base_addr_i + tile_n_i*(in_R+pad_R+pad_L) + 2*(in_R+pad_R+pad_L); // row3
    // input channel 2
        ifmap_fifo_base_addr_o[6] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_R+pad_R+pad_L);
        ifmap_fifo_base_addr_o[7] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_R+pad_R+pad_L) + (in_R+pad_R+pad_L);
        ifmap_fifo_base_addr_o[8] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_R+pad_R+pad_L) + 2*(in_R+pad_R+pad_L);
    // input channel 3
        ifmap_fifo_base_addr_o[9]  <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_R+pad_R+pad_L);
        ifmap_fifo_base_addr_o[10] <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_R+pad_R+pad_L) + (in_R+pad_R+pad_L);
        ifmap_fifo_base_addr_o[11] <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_R+pad_R+pad_L) + 2*(in_R+pad_R+pad_L); 
    // input channel 9
        ifmap_fifo_base_addr_o[27] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_R+pad_R+pad_L);
        ifmap_fifo_base_addr_o[28] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_R+pad_R+pad_L) + (in_R+pad_R+pad_L);
        ifmap_fifo_base_addr_o[29] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_R+pad_R+pad_L) + 2*(in_R+pad_R+pad_L);       
    end
    else begin
        for(j=0; j<32; j++)begin
            ifmap_glb_base_addr_i[j] <= 32'd0;
        end
    end
end

// ipsum_glb_base_addr_i
logic [31:0] ipsum_glb_base_addr_i_sel;
assign ipsum_glb_base_addr_i_sel = is_bias ? bias_glb_base_addr_i : ipsum_glb_base_addr_i;
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i=0; i<32; i++)begin
            ipsum_glb_base_addr_i[i] <= 32'd0;
        end
    end
    else if(layer_type_i == `POINTWISE && init_fifo_pe_state_i)begin
    // output channel 0
        ipsum_fifo_base_addr_o[0] <= ipsum_glb_base_addr_i;
    // output channel 1
        ipsum_fifo_base_addr_o[1] <= ipsum_glb_base_addr_i + tile_n_i;
    // output channel 2
        ipsum_fifo_base_addr_o[2] <= ipsum_glb_base_addr_i + 2*tile_n_i;
    // output channel 3
        ipsum_fifo_base_addr_o[3] <= ipsum_glb_base_addr_i + 3*tile_n_i;
    // output channel 4
        ipsum_fifo_base_addr_o[4] <= ipsum_glb_base_addr_i + 4*tile_n_i;
    // output channel 31
        ipsum_fifo_base_addr_o[31] <= ipsum_glb_base_addr_i + 31*tile_n_i;
    end
    else if(layer_type_i == `DEPTHWISE && init_fifo_pe_state_i)begin
    // output channel 0
        ipsum_fifo_base_addr_o[0] <= ipsum_glb_base_addr_i; // row1
        ipsum_fifo_base_addr_o[1] <= ipsum_glb_base_addr_i + in_R; // row2
        ipsum_fifo_base_addr_o[2] <= ipsum_glb_base_addr_i + 2*in_R; // row3
    // output channel 1
        ipsum_fifo_base_addr_o[3] <= ipsum_glb_base_addr_i + tile_n_i*in_R; // row1
        ipsum_fifo_base_addr_o[4] <= ipsum_glb_base_addr_i + tile_n_i*in_R + in_R; // row2
        ipsum_fifo_base_addr_o[5] <= ipsum_glb_base_addr_i + tile_n_i*in_R + 2*in_R; // row3
    // output channel 2
        ipsum_fifo_base_addr_o[6] <= ipsum_glb_base_addr_i + 2*tile_n_i*in_R;
        ipsum_fifo_base_addr_o[7] <= ipsum_glb_base_addr_i + 2*tile_n_i*in_R + in_R;
        ipsum_fifo_base_addr_o[8] <= ipsum_glb_base_addr_i + 2*tile_n_i*in_R + 2*in_R;
    // output channel 3
        ipsum_fifo_base_addr_o[9]  <= ipsum_glb_base_addr_i + 3*tile_n_i*in_R;
        ipsum_fifo_base_addr_o[10] <= ipsum_glb_base_addr_i + 3*tile_n_i*in_R + in_R;
        ipsum_fifo_base_addr_o[11] <= ipsum_glb_base_addr_i + 3*tile_n_i*in_R + 2*in_R; 
    // output channel 9
        ipsum_fifo_base_addr_o[27]  <= ipsum_glb_base_addr_i + 9*tile_n_i*in_R;
        ipsum_fifo_base_addr_o[28] <= ipsum_glb_base_addr_i + 9*tile_n_i*in_R + in_R;
        ipsum_fifo_base_addr_o[29] <= ipsum_glb_base_addr_i + 9*tile_n_i*in_R + 2*in_R;       
    end
    else begin
        for(j=0; j<32; j++)begin
            ipsum_fifo_base_addr_o[j] <= 32'd0;
        end
    end
end

// opsum_glb_base_addr_i
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i=0; i<32; i++)begin
            opsum_glb_base_addr_i[i] <= 32'd0;
        end
    end
    else if(layer_type_i == `POINTWISE && init_fifo_pe_state_i)begin
    // output channel 0
        opsum_fifo_base_addr_o[0] <= opsum_glb_base_addr_i;
    // output channel 1
        opsum_fifo_base_addr_o[1] <= opsum_glb_base_addr_i + On_real_i;
    // output channel 2
        opsum_fifo_base_addr_o[2] <= opsum_glb_base_addr_i + 2*On_real_i;
    // output channel 3
        opsum_fifo_base_addr_o[3] <= opsum_glb_base_addr_i + 3*On_real_i;
    // output channel 4
        opsum_fifo_base_addr_o[4] <= opsum_glb_base_addr_i + 4*On_real_i;
    // output channel 31
        opsum_fifo_base_addr_o[31] <= opsum_glb_base_addr_i + 31*On_real_i;
    end
    else if(layer_type_i == `DEPTHWISE && init_fifo_pe_state_i)begin
    // output channel 0
        opsum_fifo_base_addr_o[0] <= opsum_glb_base_addr_i; // row1
        opsum_fifo_base_addr_o[1] <= opsum_glb_base_addr_i + in_R; // row2
        opsum_fifo_base_addr_o[2] <= opsum_glb_base_addr_i + 2*in_R; // row3
    // output channel 1
        opsum_fifo_base_addr_o[3] <= opsum_glb_base_addr_i + On_real_i*in_R; // row1
        opsum_fifo_base_addr_o[4] <= opsum_glb_base_addr_i + On_real_i*in_R + in_R; // row2
        opsum_fifo_base_addr_o[5] <= opsum_glb_base_addr_i + On_real_i*in_R + 2*in_R; // row3
    // output channel 2
        opsum_fifo_base_addr_o[6] <= opsum_glb_base_addr_i + 2*On_real_i*in_R;
        opsum_fifo_base_addr_o[7] <= opsum_glb_base_addr_i + 2*On_real_i*in_R + in_R;
        opsum_fifo_base_addr_o[8] <= opsum_glb_base_addr_i + 2*On_real_i*in_R + 2*in_R;
    // output channel 3
        opsum_fifo_base_addr_o[9]  <= opsum_glb_base_addr_i + 3*On_real_i*in_R;
        opsum_fifo_base_addr_o[10] <= opsum_glb_base_addr_i + 3*On_real_i*in_R + in_R;
        opsum_fifo_base_addr_o[11] <= opsum_glb_base_addr_i + 3*On_real_i*in_R + 2*in_R; 
    // output channel 9
        opsum_fifo_base_addr_o[27]  <= opsum_glb_base_addr_i + 9*On_real_i*in_R;
        opsum_fifo_base_addr_o[28] <= opsum_glb_base_addr_i + 9*On_real_i*in_R + in_R;
        opsum_fifo_base_addr_o[29] <= opsum_glb_base_addr_i + 9*On_real_i*in_R + 2*in_R;       
    end
    else begin
        for(j=0; j<32; j++)begin
            opsum_fifo_base_addr_o[j] <= 32'd0;
        end
    end
end





endmodule
