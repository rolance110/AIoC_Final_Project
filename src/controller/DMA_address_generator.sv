//------------------------------------------------------------------------------
// dma_addr_generator.sv
//------------------------------------------------------------------------------
// [R][C][D] 內存排列 → 支援 Pointwise / Depthwise
//------------------------------------------------------------------------------ 
module dma_address_generator (
    
    input  logic clk,
    input  logic rst_n,
    
    input  logic [7:0]      tile_D_i,         //!ic_real tile_scheduler 要記得改
    input  logic [7:0]      tile_K_i,
    input  logic [31:0]     tile_n_i,         //!in_real 
    input  logic [7:0]     tile_D_f_i,       // input channels per tile (filter)
    input  logic [7:0]     tile_K_f_i,       // output channels per tile (filter)

    // Inputs from layer_decoder
    input  logic [7:0]      in_R_i,           // ifmap/ofmap height
    input  logic [7:0]      in_C_i,           // ifmap/ofmap width
    input  logic [10:0]      in_D_i,           // input channel total
    input  logic [10:0]      out_K_i,          // ifmap/ofmap height
    input  logic [7:0]      out_R_i,          // ofmap height
    input  logic [7:0]      out_C_i,          // ofmap width
    input  logic [31:0]     base_ifmap_i,
    input  logic [31:0]     base_weight_i,
    input  logic [31:0]     base_bias_i,
    input  logic [31:0]     base_ofmap_i,

    input  logic [1:0]      layer_type_i,     // 0=PW, 1=DW, 2=STD, 3=LIN
    input  logic [2:0]      input_type,       // 0=filter, 1=ifmap, 2=bias, 3=opsum, 4=ipsum
    input  logic            dma_interrupt_i,  // from DMA
    input  logic [1:0]      stride_i,
   //from tile scheduler
    input  logic [7:0]      k_idx,      // output||filter 方向的tile數
    input  logic [7:0]      d_idx,      // channel方向的tile數

    input  logic           pass_done_i, //
    //TODO    新增tile運算完的訊號,判斷opsum與ofmap差別 (DMA_opsum_finish) ?
    // Output DMA control signals
    output logic [31:0]     dma_base_addr_o, //dma_addr_o
    // Output size of data to transfer
    output logic [31:0]     dma_len_o,    //dma_len_o
    output logic            DMA_ifmap_finish,
    output logic            DMA_opsum_finish,
    output logic            DMA_ipsum_finish,
    input  logic [3:0]      cs_ts,
    output logic [31:0]     DMADST
    
);
    typedef enum logic [3:0] {
        IDLE,
        uLD_LOAD,
        TILE_IDX_GEN,
        GEN_ADDR_filter,
        DMA_filter,
        GEN_ADDR_ifmap, 
        DMA_ifmap,
        GEN_ADDR_ipsum,
        DMA_ipsum,
        GEN_ADDR_bias,
        DMA_bias,
        PASS_START,
        PASS_FINISH,
        GEN_ADDR_opsum,
        DMA_opsum
    } state_e;
    // state_e cs_ts;

    logic [31:0] offset;
    logic [31:0] ifmap_offset;
    logic [31:0] weight_offset;
    logic [31:0] bias_offset;
    logic [31:0] ipsum_offset; 
    logic [31:0] opsum_offset;
    logic [6:0]  ifmap_tile_cnt,ofmap_tile_cnt,ipsum_tile_cnt;   //計算同一張ifmap的第幾次tile_n_i
    logic [6:0]  ifmap_channel_cnt,ofmap_channel_cnt,ipsum_channel_cnt;
    logic [13:0] bias_offset_tmp;
    
    logic ipsum_end;
    logic opsum_end;
    logic ifmap_end;

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
                ifmap_offset  = ( ifmap_channel_cnt * in_R_i *in_C_i) + ifmap_tile_cnt * (tile_n_i * in_C_i)+  (d_idx * in_R_i * in_C_i * tile_D_i);
    
                bias_offset_tmp = k_idx * tile_K_i;
                bias_offset   =  bias_offset_tmp + bias_offset_tmp;// 2byte
                //DW tile_n_i=1 meaning one row / need depart stride 1 ,2 situation 
                opsum_offset  = ( ofmap_channel_cnt * out_R_i *out_C_i) + ofmap_tile_cnt * (tile_n_i * in_C_i) +  (d_idx * in_R_i * in_C_i * tile_K_i );

                ipsum_offset  = ( ofmap_channel_cnt * out_R_i *out_C_i) + ofmap_tile_cnt * (tile_n_i * in_C_i) +  (d_idx * in_R_i * in_C_i * tile_K_i );           
 
                case(input_type)// 0=filter, 1=ifmap, 2=bias, 3=opsum, 4=ipsum 5=ofmap
                    3'd0: dma_base_addr_o = base_weight_i + weight_offset;
                    3'd1: dma_base_addr_o = base_ifmap_i  + ifmap_offset;
                    3'd2: dma_base_addr_o = base_bias_i   + bias_offset_tmp;
                    3'd3: dma_base_addr_o = base_ofmap_i  + opsum_offset + opsum_offset;
                    3'd4: dma_base_addr_o = base_ofmap_i  + ipsum_offset + ipsum_offset; 
                    3'd5: dma_base_addr_o = base_ifmap_i  + opsum_offset;  
                endcase

                case(input_type)
                    3'd0: dma_len_o = tile_D_i * 9;             
                    3'd1: dma_len_o = tile_n_i;                       
                    3'd2: dma_len_o = tile_K_i + tile_K_i;     //tile_n - 2 因為filter 3*3
                    3'd3,3'd4: dma_len_o = (stride_i==2'd1)? (tile_n_i+tile_n_i-4)*in_C_i:(tile_n_i-2)*in_C_i;   //!: stride=1 = tile_n_i*2 stride2 = tile_n_i  (2byte)
                    3'd5: dma_len_o = (stride_i==2'd1)? (tile_n_i-2)*in_C_i:((tile_n_i-2)*in_C_i)>>1;
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
            ipsum_tile_cnt <= 0;
            ipsum_channel_cnt <=0;
            DMA_ifmap_finish <=0;
            DMA_opsum_finish <=0;
            DMA_ipsum_finish <=0;
        end
        else begin
            case(input_type)
                3'd1: begin // ifmap PW || DW 
                    if(dma_interrupt_i)begin
                        ifmap_channel_cnt <= ifmap_channel_cnt + 1; //單次tile channel cnt
                    end
                    else if(ifmap_channel_cnt == tile_D_i-1)begin
                        ifmap_channel_cnt <= 0;
                        DMA_ifmap_finish  <=1'b1;
                    end
                    else begin
                        ifmap_channel_cnt <= ifmap_channel_cnt;
                        DMA_ifmap_finish  <= 0;
                    end

                    if(ifmap_channel_cnt == tile_D_i - 1)  // 改正這行：使用 ifmap_channel_cnt
                        ifmap_tile_cnt <= ifmap_tile_cnt + 1;
                    else if(ifmap_end) // tile_D個且完整的ifmap算完
                        ifmap_tile_cnt <= 0;
                end
                3'd3:begin // opsum PW || DW 
                    if(dma_interrupt_i)begin
                        ofmap_channel_cnt <= ofmap_channel_cnt + 1; //單次tile channel cnt
                    end
                    else if(ofmap_channel_cnt == tile_K_i -1)begin
                        ofmap_channel_cnt <= 0;
                        DMA_opsum_finish <=1'b1;
                    end
                    else begin
                        ofmap_channel_cnt <= ofmap_channel_cnt;
                        DMA_opsum_finish <= 0;
                    end
                    if(ofmap_channel_cnt== tile_K_i - 1) 
                        ofmap_tile_cnt <= ofmap_tile_cnt + 1;
                    else if(opsum_end) 
                        ofmap_tile_cnt <= 0;
                end
                3'd4:begin // opsum PW || DW 
                    if(dma_interrupt_i)begin
                        ipsum_channel_cnt <= ipsum_channel_cnt + 1; //單次tile channel cnt
                    end
                    else if(ipsum_channel_cnt == tile_D_i -1)begin
                        ipsum_channel_cnt <= 0;
                        DMA_ipsum_finish <=1'b1;
                    end
                    else begin
                        ipsum_channel_cnt <= ipsum_channel_cnt;
                        DMA_ipsum_finish <= 0;
                    end
                    if(ipsum_channel_cnt== tile_D_i - 1) 
                        ipsum_tile_cnt <= ipsum_tile_cnt + 1;
                    else if(ipsum_end) // tile_D個且完整的ifmap算完
                        ipsum_tile_cnt <= 0;
                end
                default: begin
                    
                end
            endcase
        end
    end
    logic [32:0] ifmap_size_cnt;
    logic [32:0] size ;
    assign size = in_R_i*in_C_i;
    always_ff@(posedge clk )begin
        if(!rst_n)begin
            ifmap_size_cnt <=0;
            ifmap_end <=1'b0;
        end
        else begin
            if(ifmap_size_cnt == size)begin
                ifmap_end <=1'b1;
                ifmap_size_cnt <=1'b0;
            end
            else begin
                if(ifmap_channel_cnt== tile_D_i - 1)
                    ifmap_size_cnt <= ifmap_size_cnt+tile_n_i;
            end
        end
    end

    logic [32:0] opsum_size_cnt;
    logic [32:0] opsum_size ;
    assign opsum_size = out_C_i*out_R_i;
    
    always_ff@(posedge clk)begin
        if(!rst_n)begin
            opsum_size_cnt <=0;
            opsum_end <=1'b0;
        end
        else begin
            if(opsum_size_cnt == opsum_size)begin
                opsum_end <=1'b1;
                opsum_size_cnt <=1'b0;
            end
            else begin
                if(ofmap_channel_cnt== tile_D_i - 1)
                    opsum_size_cnt <= opsum_size_cnt+tile_n_i;
            end
        end
    end

    logic [32:0] ipsum_size_cnt;
    logic [32:0] ipsum_size ;
    assign ipsum_size =out_C_i*out_R_i;
    
    always_ff@(posedge clk)begin
        if(!rst_n)begin
            ipsum_size_cnt <=0;
            ipsum_end <=1'b0;
        end
        else begin
            if(ipsum_size_cnt == ipsum_size)begin
                ipsum_end <=1'b1;
                ipsum_size_cnt <=1'b0;
            end
            else begin
                if(ipsum_channel_cnt== tile_D_i - 1)
                    ipsum_size_cnt <= ipsum_size_cnt+tile_n_i;
            end
        end
    end



    //DMADST//
    always_ff@(posedge clk )begin
        if(!rst_n)begin
            DMADST <= 32'd0;
        end
        else begin
            if(cs_ts == GEN_ADDR_filter)begin
                DMADST <= 32'h1000_0000;  //! 看之後GLB設定成多少
            end
            else if(dma_interrupt_i)begin
                DMADST <= DMADST + dma_len_o;
            end
            // else if(cs_ts == DMA_filter && dma_interrupt_i)begin //weight -> ifmap
            //     DMADST <= DMADST + dma_len_o;
            // end
            // else if(cs_ts == DMA_ifmap && dma_interrupt_i)begin
            //     DMADST <= DMADST + dma_len_o;
            // end
            // else if(cs_ts == DMA_bias && dma_interrupt_i)begin
            //     DMADST <= DMADST + dma_len_o;
            // end

        end
    end
endmodule