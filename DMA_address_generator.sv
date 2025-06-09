//------------------------------------------------------------------------------
// dma_addr_generator.sv
//------------------------------------------------------------------------------
// [R][C][D] 內存排列 → 支援 Pointwise / Depthwise
//------------------------------------------------------------------------------ 
module dma_address_generator (
    
    input  logic clk,
    input  logic rst_n,
    
    input  logic [6:0]      tile_D_i,         //!ic_real tile_scheduler 要記得改
    input  logic [6:0]      tile_K_i,
    input  logic [31:0]     tile_n_i,         //!in_real 
    input  logic [31:0]     tile_D_f_i,       // input channels per tile (filter)
    input  logic [31:0]     tile_K_f_i,       // output channels per tile (filter)

    // Inputs from layer_decoder
    input  logic [6:0]      in_R_i,           // ifmap/ofmap height
    input  logic [9:0]      in_C_i,           // ifmap/ofmap width
    input  logic [9:0]      in_D_i,           // input channel total
    input  logic [9:0]      out_K_i,          // ifmap/ofmap height
    input  logic [9:0]      out_R_i,          // ofmap height
    input  logic [9:0]      out_C_i,          // ofmap width
    input  logic [31:0]     base_ifmap_i,
    input  logic [31:0]     base_weight_i,
    input  logic [31:0]     base_bias_i,
    input  logic [31:0]     base_ofmap_i,

    input  logic [1:0]      layer_type_i,     // 0=PW, 1=DW, 2=STD, 3=LIN
    input  logic [2:0]      input_type,       // 0=filter, 1=ifmap, 2=bias, 3=opsum, 4=ipsum
    input  logic            dma_interrupt_i,  // from DMA
    input  logic [1:0]      stride_i,
   //from tile scheduler
    input  logic [6:0]      k_idx,      // output||filter 方向的tile數
    input  logic [6:0]      d_idx,      // channel方向的tile數

    input  logic           pass_done_i, //
    //TODO    新增tile運算完的訊號,判斷opsum與ofmap差別 (DMA_opsum_finish) ?
    // Output DMA control signals
    output logic [31:0]     dma_base_addr_o, //dma_addr_o
    // Output size of data to transfer
    output logic [31:0]     dma_len_o    //dma_len_o
     
    // output logic            DMA_filter_finish, //!new
    // output logic            DMA_ifmap_finish,  //!new
    // output logic            DMA_bias_finish,    //!new
    
);

    logic [31:0] offset;
    logic [31:0] ifmap_offset;
    logic [31:0] weight_offset;
    logic [31:0] bias_offset;
    logic [31:0] ipsum_offset; //TODO ipsum
    logic [31:0] opsum_offset;
    logic [6:0]  ifmap_tile_cnt,ofmap_tile_cnt;   //計算同一張ifmap的第幾次tile_n_i
    logic [6:0]  ifmap_channel_cnt,ofmap_channel_cnt;
    logic [13:0] bias_offset_tmp;
   
   
    //!預設input的base address 不會自動更新
    // d_idx:which channel 
    // ifmap_tile_cnt= 第幾次(same ifmap)
    always_comb begin
    
        unique case (layer_type_i)
            2'd0: begin
                
                weight_offset = (k_idx * tile_D_i * tile_K_i) + (d_idx * tile_D_i *out_K_i);  
                
                                    // 同一tile 更新channel              下一次tile的讀取                      channel tile if in_D_i> 32
                ifmap_offset  = ( ifmap_channel_cnt * in_R_i *in_C_i) + ifmap_tile_cnt * tile_n_i +  (d_idx * in_R_i * in_C_i * tile_D_i);
    
                bias_offset_tmp = k_idx * tile_K_i;
                bias_offset   =  bias_offset_tmp + bias_offset_tmp; //! 2byte  bias

                opsum_offset  = ( ofmap_channel_cnt * out_R_i *out_C_i) + ofmap_tile_cnt * tile_n_i +  (d_idx * in_R_i * in_C_i * tile_K_i );

                //TODO ispum
                ipsum_offset  = ( ofmap_channel_cnt * out_R_i *out_C_i) + ofmap_tile_cnt * tile_n_i +  (d_idx * in_R_i * in_C_i * tile_K_i );
 
                case(input_type)// 0=filter, 1=ifmap, 2=bias, 3=opsum, 4=ipsum 5=ofmap
                    3'd0: dma_base_addr_o = base_weight_i + weight_offset;
                    3'd1: dma_base_addr_o = base_ifmap_i  + ifmap_offset;
                    3'd2: dma_base_addr_o = base_bias_i   + bias_offset_tmp;
                    3'd3: dma_base_addr_o = base_ofmap_i  + opsum_offset + opsum_offset; //2byte add twice
                    3'd4: dma_base_addr_o = base_ofmap_i  + ipsum_offset + ipsum_offset;
                    3'd5: dma_base_addr_o = base_ifmap_i  + opsum_offset;               //!這邊base_ifmap_i 是下一層layer的 不確定用甚麼判斷ofmap
                 endcase

                case(input_type) 
                    3'd0: dma_len_o = tile_D_i * tile_K_i;   
                    3'd1: dma_len_o = tile_n_i;              
                    3'd2: dma_len_o = tile_K_i + tile_K_i;  //2byte
                    3'd3,3'd4: dma_len_o = tile_n_i + tile_n_i;  
                    3'd5: dma_len_o = tile_n_i;// PW時會與ifmap數量一樣 (1*1filter)          
                endcase
            end

            2'd1: begin // Depthwise 
                weight_offset = (k_idx * tile_K_i * 9 );
            
                                    // 同一tile 更新channel              下一次tile的讀取               channel tile if in_D_i> 32
                ifmap_offset  = ( ifmap_channel_cnt * in_R_i *in_C_i) + ifmap_tile_cnt * tile_n_i +  (d_idx * in_R_i * in_C_i * tile_D_i);
    
                bias_offset_tmp = k_idx * tile_K_i;
                bias_offset   =  bias_offset_tmp + bias_offset_tmp;// 2byte

                opsum_offset  = ( ofmap_channel_cnt * out_R_i *out_C_i) + ofmap_tile_cnt * tile_n_i +  (d_idx * in_R_i * in_C_i * tile_K_i );
                
 
                case(input_type)　// 0=filter, 1=ifmap, 2=bias, 3=opsum, 4=ipsum 5=ofmap
                    3'd0: dma_base_addr_o = base_weight_i + weight_offset;
                    3'd1: dma_base_addr_o = base_ifmap_i  + ifmap_offset;
                    3'd2: dma_base_addr_o = base_bias_i   + bias_offset_tmp;
                    3'd3: dma_base_addr_o = base_ofmap_i  + opsum_offset + opsum_offset;
                    3'd4: dma_base_addr_o = base_ofmap_i  + opsum_offset + opsum_offset; 
                    3'd5: dma_base_addr_o = base_ifmap_i  + opsum_offset;  
                endcase

                case(input_type)
                    2'd0: dma_len_o = tile_D_i * 9;             
                    2'd1: dma_len_o = tile_n_i;                        //! last round may not be tile_D_i
                    2'd2: dma_len_o = tile_K_i + tile_K_i;  
                    2'd3,2'd4: dma_len_o = (stride_i==2'd1)? (tile_n_i+tile_n_i):tile_n;   //!: stride=1 = tile_n_i*2 stride2 = tile_n_i  (2byte)
                    3'd5: dma_len_o = (stride_i==2'd1)? (tile_n_i):tile_n>>1;
                endcase
            end

            2'd2: begin //CONV

            end
            default: begin
                
            end
        endcase
    end

    always_ff@(posedge clk) begin
        if(!rst_n) begin
            ifmap_tile_cnt <= 0;
            ifmap_channel_cnt <= 0;
            ofmap_tile_cnt <= 0;
            ofmap_channel_cnt <= 0;
        end
        else begin
            case(input_type)
                2'd1: begin // ifmap PW || DW 
                    if(dma_interrupt_i)
                        ifmap_channel_cnt <= ifmap_channel_cnt + 1; //單次tile channel cnt
                    else if(ifmap_channel_cnt == tile_D_i - 1)
                        ifmap_channel_cnt <= 0;

                    if(ifmap_channel_cnt == tile_D_i - 1)  // 改正這行：使用 ifmap_channel_cnt
                        ifmap_tile_cnt <= ifmap_tile_cnt + 1;
                    else if(pass_done_i) // tile_D個且完整的ifmap算完
                        ifmap_tile_cnt <= 0;
                end
                2'd3:begin // opsum PW || DW 
                    if(dma_interrupt_i)
                        ofmap_channel_cnt <= ofmap_channel_cnt + 1; //單次tile channel cnt
                    else if(ofmap_channel_cnt == tile_K_i -1)
                        ofmap_channel_cnt <= 0;

                    if(ofmap_channel_cnt== tile_K_i - 1) 
                        ofmap_tile_cnt <= ofmap_tile_cnt + 1;
                    else if(pass_done_i) // tile_D個且完整的ifmap算完
                        ofmap_tile_cnt <= 0;
                end
                default: begin
                    
                end
            endcase
        end
    end

endmodule
