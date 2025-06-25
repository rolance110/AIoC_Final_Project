
module AWADDR_arbiter(
	input ACLK,
	input ARESETn,
	input [`AXI_ID_BITS-1:0] ID_M0,
	input [`AXI_ADDR_BITS-1:0] ADDR_M0,
	input [`AXI_LEN_BITS-1:0] LEN_M0,
	input [`AXI_SIZE_BITS-1:0] SIZE_M0,
	input [1:0] BURST_M0,
	input VALID_M0,
	
	input [`AXI_ID_BITS-1:0] ID_M1,
	input [`AXI_ADDR_BITS-1:0] ADDR_M1,
	input [`AXI_LEN_BITS-1:0] LEN_M1,
	input [`AXI_SIZE_BITS-1:0] SIZE_M1,
	input [1:0] BURST_M1,
	input VALID_M1,
	
	// input [`AXI_ID_BITS-1:0] ID_M2,
	// input [`AXI_ADDR_BITS-1:0] ADDR_M2,
	// input [`AXI_LEN_BITS-1:0] LEN_M2,
	// input [`AXI_SIZE_BITS-1:0] SIZE_M2,
	// input [1:0] BURST_M2,
	// input VALID_M2,
	
	input DONE,
	
	input WVALID_M0,
	input WVALID_M1,
	// input WVALID_M2,
	
	output logic [`AXI_IDS_BITS-1:0] ID_BUS,
	output logic [`AXI_ADDR_BITS-1:0] ADDR_BUS,
	output logic [`AXI_LEN_BITS-1:0] LEN_BUS,
	output logic [`AXI_SIZE_BITS-1:0] SIZE_BUS,
	output logic [1:0] BURST_BUS,
	output logic VALID_BUS,
	
	//input READY_S0, ROM no write
	input READY_S0,
	input READY_S1,
	input READY_S2,
	input READY_S3,
	input READY_S4,
	input READY_S5,
	output logic READY_M0,
	output logic READY_M1,
	// output logic READY_M2,
	
	output logic [3:0] cs,
	output logic [2:0] slave   
);
	
	logic [3:0] ns;
	logic [`AXI_ADDR_BITS-1:0] ADDR_reg;
    parameter W_IDLE =4'd0, 
	          W_M0 = 4'd1, 
			  W_M1 = 4'd2,
			  W_M2 = 4'd3,
			  W_M0_ADDR = 4'd4, 
			  W_M1_ADDR = 4'd5,
			  W_M2_ADDR = 4'd6,
			  W_M0_DATA = 4'd7, 
			  W_M1_DATA = 4'd8,
			  W_M2_DATA = 4'd9, 
			  W_M0_B = 4'd10,  
			  W_M1_B = 4'd11,
			  W_M2_B = 4'd12;
    parameter S0=3'd0, S1=3'd1, S2=3'd2, S3=3'd3, S4=3'd4, S5=3'd5, DEF=3'd6;

	always_comb begin
    if (ADDR_BUS >= 32'h3000_0000 && ADDR_BUS <= 32'h3000_4000) begin
        slave = S0; // ROM
    end else if (ADDR_BUS >= 32'h1000_0000 && ADDR_BUS <= 32'h1FFF_FFFF) begin
        slave = S1; // IM
    end else if (ADDR_BUS >= 32'h2000_0000 && ADDR_BUS <= 32'h2FFF_FFFF) begin
        slave = S2; // DM
    end else if (ADDR_BUS >= 32'h1002_0000 && ADDR_BUS <= 32'h1002_0400) begin
        slave = S3; // DMA
    end else if (ADDR_BUS >= 32'h1001_0000 && ADDR_BUS <= 32'h1001_03FF) begin
        slave = S4; // WDT
    end else if (ADDR_BUS >= 32'h2000_0000 && ADDR_BUS <= 32'h201F_FFFF) begin
        slave = S5; // DRAM
    end else begin
        slave = S0; // Default case (address out of range)
    end
 end
// ! FOR HW2
	// always_comb begin
	// 	if(ADDR_BUS[31:16] == 16'd0)
	// 	    slave = S1;
			
	// 	else if(ADDR_BUS[31:16] == 16'd1)
	// 	    slave = S2;
	// 	else 
	// 	    slave = DEF;
    // end
	
	 always_ff@(posedge ACLK)begin
         if(!ARESETn)
             cs <= W_IDLE;
         else 
             cs <= ns;
     end

	always_comb begin	
			case(cs)
				W_IDLE:begin
					ns = W_M0;
				end
				W_M0:begin


					    if ((slave == S0) && VALID_M0) begin
							ns = (READY_S0) ? W_M0_DATA : W_M0_ADDR;
						end else if ((slave == S1) && VALID_M0) begin
							ns = (READY_S1) ? W_M0_DATA : W_M0_ADDR;
						end else if ((slave == S2) && VALID_M0) begin
							ns = (READY_S2) ? W_M0_DATA : W_M0_ADDR;
						end else if ((slave == S3) && VALID_M0) begin
							ns = (READY_S3) ? W_M0_DATA : W_M0_ADDR;
						end else if ((slave == S4) && VALID_M0) begin
							ns = (READY_S4) ? W_M0_DATA : W_M0_ADDR;
						end else if ((slave == S5) && VALID_M0) begin
							ns = (READY_S5) ? W_M0_DATA : W_M0_ADDR;
						end else begin
							ns = W_M1;
						end		
				end
				W_M1:begin
						// if((slave == S1) && VALID_M1)begin			
						// 		ns = (READY_S1) ?W_M1_DATA :W_M1_ADDR ;
						// end
						// else if((slave == S2) && VALID_M1)begin
						// 		ns = (READY_S2) ?W_M1_DATA :W_M1_ADDR ;
						// end
						// else begin
						// 	ns = W_M0;
						// end
						if ((slave == S0) && VALID_M1) begin
							ns = (READY_S0) ? W_M1_DATA : W_M1_ADDR;
						end 
					    else if ((slave == S1) && VALID_M1) begin
							ns = (READY_S1) ? W_M1_DATA : W_M1_ADDR;
						end else if ((slave == S2) && VALID_M1) begin
							ns = (READY_S2) ? W_M1_DATA : W_M1_ADDR;
						end else if ((slave == S3) && VALID_M1) begin
							ns = (READY_S3) ? W_M1_DATA : W_M1_ADDR;
						end else if ((slave == S4) && VALID_M1) begin
							ns = (READY_S4) ? W_M1_DATA : W_M1_ADDR;
						end else if ((slave == S5) && VALID_M1) begin
							ns = (READY_S5) ? W_M1_DATA : W_M1_ADDR;
						end else begin
							ns = W_M0;
						end						
				end
				// W_M2:begin
				// 		if ((slave == S1) && VALID_M2) begin
				// 			ns = (READY_S1) ? W_M2_DATA : W_M2_ADDR;
				// 		end else if ((slave == S2) && VALID_M2) begin
				// 			ns = (READY_S2) ? W_M2_DATA : W_M2_ADDR;
				// 		end else if ((slave == S3) && VALID_M2) begin
				// 			ns = (READY_S3) ? W_M2_DATA : W_M2_ADDR;
				// 		end else if ((slave == S4) && VALID_M2) begin
				// 			ns = (READY_S4) ? W_M2_DATA : W_M2_ADDR;
				// 		end else if ((slave == S5) && VALID_M2) begin
				// 			ns = (READY_S5) ? W_M2_DATA : W_M2_ADDR;
				// 		end else begin
				// 			ns = W_M0;
				// 		end					
				// end
				W_M0_ADDR:begin
						ns = (
							(slave == S0 && READY_S0) || 
			      			(slave == S1 && READY_S1) || 
			      			(slave == S2 && READY_S2) || 
			    			(slave == S3 && READY_S3) || 
			    			(slave == S4 && READY_S4) || 
			    			(slave == S5 && READY_S5)) ? W_M0_DATA : W_M0_ADDR;		

				end
				W_M1_ADDR:begin			
					 // ns=((slave == S1 && READY_S1) || (slave == S2 && READY_S2))?W_M1_DATA:W_M1_ADDR;	
						ns = (
							(slave == S0 && READY_S0) || 
			      			(slave == S1 && READY_S1) || 
			      			(slave == S2 && READY_S2) || 
			    			(slave == S3 && READY_S3) || 
			    			(slave == S4 && READY_S4) || 
			    			(slave == S5 && READY_S5)) ? W_M1_DATA : W_M1_ADDR;		
				end

				W_M0_DATA:begin
					ns =(DONE)? W_M0:W_M0_DATA;	
				end			
				W_M1_DATA:begin
					ns =(DONE)? W_M1:W_M1_DATA;	
				end

				default:begin
					ns = W_M0;
				end
			endcase
	
	end

	
	always_comb begin
		case(cs)
			W_M0:begin
				LEN_BUS = LEN_M0 ;
				ADDR_BUS = ADDR_M0 ;
				SIZE_BUS =SIZE_M0 ;
				BURST_BUS = BURST_M0 ;
				ID_BUS = {4'd0, ID_M0};
				READY_M0 = 	(slave == S0) ? READY_S0 :
							(slave == S1) ? READY_S1 :
							(slave == S2) ? READY_S2 :
							1'd0;
				// READY_M0 = 	(slave == S1) ? READY_S1 :
				// 		(slave == S2) ? READY_S2 :
				// 		(slave == S3) ? READY_S3 :
				// 		(slave == S4) ? READY_S4 :
				// 		(slave == S5) ? READY_S5 :
						// 1'd0;
				READY_M1 = 1'd0;
				// READY_M2 = 1'd0;
				VALID_BUS = VALID_M0 ;
			end
			W_M1:begin
				LEN_BUS = LEN_M1 ;
				ADDR_BUS = ADDR_M1 ;
				SIZE_BUS =SIZE_M1 ;
				BURST_BUS = BURST_M1 ;
				ID_BUS = {4'd0, ID_M1};
				READY_M0 = 1'd0;
				// READY_M1 = 	(slave == S1) ? READY_S1 :
				// 			(slave == S2) ? READY_S2 :
				// 			1'd0;
				READY_M1 =	(slave == S0) ? READY_S0 : 	
						(slave == S1) ? READY_S1 :
						(slave == S2) ? READY_S2 :
						(slave == S3) ? READY_S3 :
						(slave == S4) ? READY_S4 :
						(slave == S5) ? READY_S5 :
						1'd0;
				// READY_M2 = 1'd0;
				VALID_BUS = VALID_M1 ;
			end
			W_M2:begin
				// LEN_BUS = LEN_M2 ;
				// ADDR_BUS = ADDR_M2 ;
				// SIZE_BUS =SIZE_M2 ;
				// BURST_BUS = BURST_M2 ;
				// ID_BUS = {4'd0, ID_M2};
				// READY_M0 = 1'd0;
				// READY_M1 = 1'd0;
				// READY_M2 = 	(slave == S1) ? READY_S1 :
				// 		(slave == S2) ? READY_S2 :
				// 		(slave == S3) ? READY_S3 :
				// 		(slave == S4) ? READY_S4 :
				// 		(slave == S5) ? READY_S5 :
				// 		1'd0;
				// VALID_BUS = VALID_M2 ;
			end

			W_M0_ADDR:begin
				LEN_BUS = LEN_M0 ;
				ADDR_BUS = ADDR_M0 ;
				SIZE_BUS =SIZE_M0 ;
				BURST_BUS = BURST_M0 ;
				ID_BUS = {4'd0, ID_M0};
				READY_M0 = 
						(slave == S0) ? READY_S0 :
						(slave == S1) ? READY_S1 :
						(slave == S2) ? READY_S2 :
						(slave == S3) ? READY_S3 :
						(slave == S4) ? READY_S4 :
						(slave == S5) ? READY_S5 :1'd1;
				READY_M1 = 	1'd0;
				VALID_BUS = VALID_M0 ;
			end

			W_M1_ADDR:begin
				LEN_BUS = LEN_M1 ;
				ADDR_BUS = ADDR_M1 ;
				SIZE_BUS =SIZE_M1 ;
				BURST_BUS = BURST_M1 ;
				ID_BUS = {4'd0, ID_M1};
				READY_M0 = 1'd0;
				// READY_M2 = 1'd0;
				// READY_M1 = 	(slave == S1) ? READY_S1 :
				// 			(slave == S2) ? READY_S2 :
				// 			1'd1;
				READY_M1 = 	
						(slave == S0) ? READY_S0 :
						(slave == S1) ? READY_S1 :
						(slave == S2) ? READY_S2 :
						(slave == S3) ? READY_S3 :
						(slave == S4) ? READY_S4 :
						(slave == S5) ? READY_S5 :
						1'd1;
				VALID_BUS = VALID_M1 ;
			end
			W_M2_ADDR:begin
				// LEN_BUS = LEN_M2 ;
				// ADDR_BUS = ADDR_M2 ;
				// SIZE_BUS =SIZE_M2 ;
				// BURST_BUS = BURST_M2 ;
				// ID_BUS = {4'd0, ID_M2};
				// READY_M0 = 1'd0;
				// READY_M1 = 1'd0;
				// READY_M2 = 	
				// 		(slave == S1) ? READY_S1 :
				// 		(slave == S2) ? READY_S2 :
				// 		(slave == S3) ? READY_S3 :
				// 		(slave == S4) ? READY_S4 :
				// 		(slave == S5) ? READY_S5 :
				// 		1'd1;
				// VALID_BUS = VALID_M2 ;
			end

			W_M1_DATA:begin
				LEN_BUS = 4'd0;
				ADDR_BUS = ADDR_reg ;
				SIZE_BUS =3'd0 ;
				BURST_BUS = 2'd0 ;
				ID_BUS = 8'd0;
				READY_M0 = 1'd0;
				READY_M1 = 1'd0;
				// READY_M2 = 1'd0;
				VALID_BUS =1'd0;
			end

			W_M1_DATA:begin
				LEN_BUS = 4'd0;
				ADDR_BUS = ADDR_reg ;
				SIZE_BUS =3'd0 ;
				BURST_BUS = 2'd0 ;
				ID_BUS = 8'd0;
				READY_M0 = 1'd0;
				READY_M1 = 1'd0;
				// READY_M2 = 1'd0;
				VALID_BUS =1'd0;
			end
			W_M2_DATA:begin
				// LEN_BUS = 4'd0;
				// ADDR_BUS = ADDR_reg ;
				// SIZE_BUS =3'd0 ;
				// BURST_BUS = 2'd0 ;
				// ID_BUS = 8'd0;
				// READY_M0 = 1'd0;
				// READY_M1 = 1'd0;
				// READY_M2 = 1'd0;
				// VALID_BUS =1'd0;
			end
			default:begin
				LEN_BUS = 4'd0;
				ADDR_BUS = 32'd0 ;
				SIZE_BUS =3'd0 ;
				BURST_BUS = 2'd0 ;
				ID_BUS = 8'd0;
				READY_M0 = 1'd0;
				READY_M1 = 1'd0;
				// READY_M2 = 1'd0;
				VALID_BUS =1'd0;
			end
		endcase
	end
	
	always_ff@(posedge ACLK)begin
		if(~ARESETn)begin
			ADDR_reg <= 32'd0;
		end
		else begin
			if(cs == W_M0 || cs == W_M1 || cs == W_M1_ADDR||cs == W_M2 || cs == W_M2_ADDR )begin
				ADDR_reg <= ADDR_BUS;
			end
			else begin
				ADDR_reg <= ADDR_reg;
			end
		end
	end


	
endmodule
