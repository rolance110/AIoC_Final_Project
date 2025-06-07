//------------------------------------------------------------------------------
// dma_addr_generator.sv
//------------------------------------------------------------------------------
// [R][C][D] 內存排列 → 支援 Pointwise / Depthwise
//------------------------------------------------------------------------------ 
module dma_address_generator #(
    parameter int BYTES_I   = `BYTES_I,    // Input feature map bytes
    parameter int BYTES_W   = `BYTES_W,    // Weight bytes
    parameter int BYTES_P   = `BYTES_P,    // Partial sum bytes
    parameter int GLB_BYTES = `GLB_MAX_BYTES // Global SRAM capacity in bytes
) (
    input  logic clk,
    input  logic rst_n,
    
    // Inputs from layer_decoder
    input  logic [31:0]     base_ifmap_i,
    input  logic [31:0]     base_weight_i,
    input  logic [31:0]     base_bias_i,
    input  logic [31:0]     base_ofmap_i,
    input  logic [6:0]      k_idx,
    input  logic [6:0]      d_idx,
    input  logic [6:0]      r_idx,
    input  logic [6:0]      in_R_i,           // ifmap/ofmap height
    input  logic [9:0]      in_C_i,           // ifmap/ofmap width
    input  logic [9:0]      in_D_i,           // input channel total
    input  logic [9:0]      out_K_i,          // ifmap/ofmap height
    input  logic [9:0]      out_R_i,          // ofmap height
    input  logic [9:0]      out_C_i,          // ofmap width
    input  logic [6:0]      tile_D_i,         //!ic_real 才是真的這一次的channel 數  
    input  logic [6:0]      tile_K_i,
    input  logic [31:0]     tile_n_i,         //!in_real ?
    input  logic            dma_interrupt_i,  //! new:控制tile中channel方向
    input  logic [1:0]      layer_type_i,     // 0=PW, 1=DW, 2=STD, 3=LIN
    input  logic [1:0]      input_type;       // 0=filter, 1=ifmap, 2=bias, 3=opsum
    
    //! input  logic        tile運算完的訊號 (DMA_opsum_finish) ?
    // Output DMA control signals
    output logic [31:0]     dma_addr_ifmap_o,
    output logic [31:0]     dma_addr_weight_o,
    output logic [31:0]     dma_addr_bias_o,
    output logic [31:0]     dma_addr_opsum_o,

    // Output size of data to transfer
    output logic [31:0]     dma_size_ifmap_o,
    output logic [31:0]     dma_size_weight_o,
    output logic [31:0]     dma_size_bias_o,
    output logic [31:0]     dma_size_opsum_o,

    output logic            DMA_filter_finish, //!new
    output logic            DMA_ifmap_finish,  //!new
    output logic            DMA_bias_finish    //!new

);

    logic [31:0] offset,ifmap_offset,weight_offset,bias_offset,opsum_offset;
    logic [31:0] data_length,dma_base_addr;
    logic [6:0]  ifmap_tile_cnt,ofmap_tile_cnt;   //計算同一張ifmap的第幾次tile_n_i
    logic [6:0]  ifmap_channel_cnt,ofmap_channel_cnt;
    logic [13:0] bias_offset_tmp;
    //!預設input的base address 不會自動更新

    //d_idx:which channel ifmap_tile_cnt=  第幾次
    always_comb begin
        dma_base_addr    = 32'd0;
        dma_burst_len    = 32'd0;
        unique case (layer_type)
            2'd0: begin
                
                weight_offset = (k_idx * tile_D_i * tile_K_i) + (d_idx * tile_D_i *in_K);  
                
                                    // 同一tile 更新channel              下一次tile的讀取                      channel tile if in_D_i> 32
                ifmap_offset  = ( ifmap_channel_cnt * in_R_i *in_C_i) + ifmap_tile_cnt * tile_n_i +  (d_idx * in_R_i * in_C_i * tile_D_i)
    
                bias_offset_tmp = k_idx * tile_K_i;
                bias_offset   =  bias_offset_tmp + bias_offset_tmp // 2byte

                opsum_offset  = ( ofmap_channel_cnt * out_R_i *out_C_i) + ofmap_tile_cnt * tile_n_i +  (d_idx * in_R_i * in_C_i * tile_K_i )
    
 
                case(input_type)
                    2'd0: dma_base_addr = base_weight_i + weight_offset;
                    2'd1: dma_base_addr = base_ifmap_i  + ifmap_offset;
                    2'd2: dma_base_addr = base_bias_i   + bias_offset_tmp ;
                    2'd3: dma_base_addr = base_ofmap_i  + opsum_offset;
                endcase

                case(input_type)
                    2'd0: data_length = tile_D_i * tile_K_i;tile_n_i;   //! last round may not be tile_n_i
                    2'd1: data_length = tile_n_i;                       //! last round may not be tile_D_i
                    2'd2: data_length = tile_K_i + tile_K_i;  //2byte
                    2'd3: data_length = tile_n_i;                       //! 不確定 n是怎麼給在opsum時
                endcase
            end

            2'd1: begin // Depthwise 
                weight_offset = (k_idx * tile_K_i * 9 ) 
                
                                    // 同一tile 更新channel              下一次tile的讀取               channel tile if in_D_i> 32
                ifmap_offset  = ( ifmap_channel_cnt * in_R_i *in_C_i) + ifmap_tile_cnt * tile_n_i +  (d_idx * in_R_i * in_C_i * tile_D_i)
    
                bias_offset_tmp = k_idx * tile_K_i;
                bias_offset   =  bias_offset_tmp + bias_offset_tmp // 2byte

                opsum_offset  = ( ofmap_channel_cnt * out_R_i *out_C_i) + ofmap_tile_cnt * tile_n_i +  (d_idx * in_R_i * in_C_i * tile_K_i )
    
 
                case(input_type)
                    2'd0: dma_base_addr = base_weight_i + weight_offset;
                    2'd1: dma_base_addr = base_ifmap_i  + ifmap_offset;
                    2'd2: dma_base_addr = base_bias_i   + bias_offset_tmp;
                    2'd3: dma_base_addr = base_ofmap_i  + opsum_offset;
                endcase

                case(input_type)
                    2'd0: data_length = tile_D_i * 9;             //! last round may not be tile_n_i
                    2'd1: data_length = tile_n_i;                        //! last round may not be tile_D_i
                    2'd2: data_length = tile_K_i + tile_K_i;  //2byte
                    2'd3: data_length = tile_n_i;
                endcase
            end

            2'd2: begin //CONV

            end
            default: begin
                
            end
        endcase
    end

    always_ff(posedge clk) begin
        if(!rst_n)begin
            ifmap_tile_cnt <= 0;
            ifmap_channel_cnt <=0;
        end
        else if
        else begin
            case(input_type)
                2'd1:begin // PW || DW 
                    if(dma_interrupt_i)
                        ifmap_channel_cnt <= ifmap_channel_cnt + 1; //單次tile channel cnt
                    else if(ifmap_channel_cnt == tile_D_i -1)
                        ifmap_channel_cnt <= 0;

                    if(ifmap_channel_cnt_cnt == tile_D_i - 1) 
                        ifmap_tile_cnt <= ifmap_tile_cnt + 1;
                    else if(pass_done_i) // tile_D個且完整的ifmap算完
                        ifmap_tile_cnt <= 0;
                end
            endcase
        end
    end

    always_ff(posedge clk) begin
        if(!rst_n)begin
            ofmap_tile_cnt <= 0;
            ofmap_channel_cnt <=0;
        end
        else if
        else begin
            case(input_type)
                2'd1:begin // PW || DW 
                    if(dma_interrupt_i)
                        ofmap_channel_cnt <= ofmap_channel_cnt + 1; //單次tile channel cnt
                    else if(ofmap_channel_cnt == tile_K_i -1)
                        ofmap_channel_cnt <= 0;

                    if(ofmap_channel_cnt_cnt == tile_K_i - 1) 
                        ofmap_tile_cnt <= ofmap_tile_cnt + 1;
                    else if(pass_done_i) // tile_D個且完整的ifmap算完
                        ofmap_tile_cnt <= 0;
                end
            endcase
        end
    end
endmodule
