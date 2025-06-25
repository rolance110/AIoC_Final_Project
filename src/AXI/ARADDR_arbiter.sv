
module ARADDR_arbiter(
	input ACLK,
	input ARESETn,
	//M0 
	input [`AXI_ID_BITS-1:0] ARID_M0,   //Bits of master is 4 and for slave is 8, see A5-80 in spec
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0, //address 32bit
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,   //Burst length 4bit 4bit for 32bit data
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,  //Burst size.
	input [1:0] ARBURST_M0, // only use INCR type
	input ARVALID_M0,
	output logic ARREADY_M0,
	
	//M1
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
	//M2


	output logic [`AXI_IDS_BITS-1:0] ARID_BUS,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_BUS,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_BUS,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_BUS,
	output logic [1:0] ARBURST_BUS,
	output logic ARVALID_BUS,
	
    input ARREADY_S0,
	input ARREADY_S1,
	input ARREADY_S2,

	
	input RVALID_M0, 
	input RREADY_M0,
	input RLAST_M0,
	input RVALID_M1,
	input RREADY_M1,
	input RLAST_M1,
	
	output logic [3:0] cs,  //current state
	output logic [2:0] slave  

);

	logic [`AXI_LEN_BITS-1:0] LEN_reg;
	logic [`AXI_ID_BITS-1:0] ID_reg;
	logic [`AXI_ADDR_BITS-1:0] ADDR_reg;
	logic [1:0] BURST_reg;
	logic [3:0] ns; //next state
	

    parameter R_IDLE = 4'd0, 
	          R_M0 = 4'd1,
			  R_M1 = 4'd2,
			  R_M2 = 4'd3,
			  R_M0_ADDR = 4'd4, 
			  R_M1_ADDR = 4'd5,
			  R_M2_ADDR = 4'd6,
			  R_M0_DATA = 4'd7, 
			  R_M1_DATA = 4'd8,
			  R_M2_DATA = 4'd9;
	parameter S0=3'd0, S1=3'd1, S2=3'd2, S3=3'd3, S4=3'd4, S5=3'd5, DEF=3'd6; 
	//S1=2'd0, S2=2'd1, DEF=2'd2;
	
	always_ff@(posedge ACLK)begin
        if(!ARESETn)
            cs <= R_IDLE;
        else 
            cs <= ns;
    end

//!! MEM Address for HW3
	always_comb begin
    if (ARADDR_BUS >= 32'h3000_0000 && ARADDR_BUS <= 32'h3000_4000) begin
        slave = S0; // ROM
    end else if (ARADDR_BUS >= 32'h1000_0000 && ARADDR_BUS <= 32'h1FFF_FFFF) begin
        slave = S1; // IM
    end else if (ARADDR_BUS >= 32'h2000_0000 && ARADDR_BUS <= 32'h2FFF_FFFF) begin
        slave = S2; // DM
    end else if (ARADDR_BUS >= 32'h1002_0000 && ARADDR_BUS <= 32'h1002_0400) begin
        slave = S3; // DMA
    end else if (ARADDR_BUS >= 32'h1001_0000 && ARADDR_BUS <= 32'h1001_03FF) begin
        slave = S4; // WDT
    end else if (ARADDR_BUS >= 32'h2000_0000 && ARADDR_BUS <= 32'h201F_FFFF) begin
        slave = S5; // DRAM
    end else begin
        slave = S0; // Default case (address out of range)
    end
	end

    //! memory size is 2^16  for HW2
    // always_comb begin
	// 	if(ARADDR_BUS[31:16] == 16'd0)
	// 	    slave = S1;          //0x0000_xxxx
			
	// 	else if(ARADDR_BUS[31:16] == 16'd1)
	// 	    slave = S2;               //0x0001_XXXX
	// 	else 
	// 	    slave = DEF; // 0x0002_XXXX
    // end
	
    always_comb begin 
        case(cs)
			R_IDLE:begin
				ns = ARVALID_M0 ?  R_M0_ADDR:
					 ARVALID_M1 ?  R_M1_ADDR:
					 R_IDLE;
			end
			R_M0:begin
				ns = ARVALID_M0 ?  R_M0_ADDR:
					 ARVALID_M1 ?  R_M1_ADDR:
					 R_M1;
			end
			R_M1:begin
				ns = ARVALID_M1 ?  R_M1_ADDR:
					 ARVALID_M0 ?  R_M0_ADDR:
					 R_M0;
			end
			R_M2:begin
				ns = ARVALID_M1 ?  R_M1_ADDR:
					 ARVALID_M0 ?  R_M0_ADDR:			 
					 R_M0;
			end
			R_M0_ADDR:begin
				ns = (ARREADY_M0 && ARVALID_M0)  ? R_M0_DATA : R_M0_ADDR;
			end
			R_M1_ADDR:begin
				ns = (ARREADY_M1 && ARVALID_M1)  ? R_M1_DATA : R_M1_ADDR;
			end
			R_M2_ADDR:begin
				// ns = (ARREADY_M2 && ARVALID_M2)  ? R_M2_DATA : R_M2_ADDR;
			end
			R_M0_DATA:begin
				ns = (RVALID_M0 && RREADY_M0 && RLAST_M0)  ?   R_M0 :R_M0_DATA;
			end
			R_M1_DATA:begin
				ns = (RVALID_M1 && RREADY_M1 && RLAST_M1)  ?   R_M0 :R_M1_DATA;
			end
			R_M2_DATA:begin
				// ns = (RVALID_M2 && RREADY_M2 && RLAST_M2)  ?   R_M0 :R_M2_DATA;
			end
			default:begin
				ns=R_IDLE;
			end
        endcase 
    end


	always_ff@(posedge  ACLK)begin
		if(!ARESETn)begin
			ADDR_reg <= 32'd0;
			ID_reg <= 4'd0;
			LEN_reg <=  4'd0; 
			BURST_reg <= 2'd0;
			
		end
		else begin
			if(cs==R_M0_ADDR)begin
				ADDR_reg <=ARADDR_M0 ;
				ID_reg <= ARID_M0;
				LEN_reg <= ARLEN_M0;
				BURST_reg <= ARBURST_M0;
				
			end
			else if(cs==R_M1_ADDR)begin
				ADDR_reg <=ARADDR_M1 ;
				ID_reg <= ARID_M1;
				LEN_reg <= ARLEN_M1;
				BURST_reg <= ARBURST_M1;
				
			end
			else begin
				ADDR_reg <= ADDR_reg;
				ID_reg <= ID_reg;
				LEN_reg <= LEN_reg;
				BURST_reg <= BURST_reg;
				
			end
		end
	end


	always_comb begin
		case(cs)
			R_M0:begin
				ARID_BUS = {4'd0, ID_reg};
				ARADDR_BUS = ADDR_reg ;
				ARLEN_BUS = LEN_reg; 
				ARSIZE_BUS = 3'd0;
				ARBURST_BUS = BURST_reg;
				ARVALID_BUS = 1'd0;
				ARREADY_M0 = 1'd0;
				ARREADY_M1 = 1'd0;
				// ARREADY_M2 = 1'd0;
			end
			R_M1:begin
				ARID_BUS = {4'd0, ID_reg};
				ARADDR_BUS = ADDR_reg ;
				ARLEN_BUS = LEN_reg; 
				ARSIZE_BUS =3'd0;
				ARBURST_BUS = BURST_reg;
				ARVALID_BUS = 1'd0;
				ARREADY_M0 = 1'd0;
				ARREADY_M1 = 1'd0;
				// ARREADY_M2 = 1'd0;
			end
			R_M0_ADDR:begin 
				ARID_BUS = {4'd0, ARID_M0};
				ARADDR_BUS = ARADDR_M0;
				ARLEN_BUS = ARLEN_M0; 
				ARSIZE_BUS = ARSIZE_M0;
				ARBURST_BUS = ARBURST_M0;
				ARVALID_BUS = ARVALID_M0;
				//! for HW3
				 if (ARADDR_M0 >= 32'h3000_0000 && ARADDR_M0 <= 32'h3000_4000) begin
       				 ARREADY_M0 = ARREADY_S0; // ROM
    				end else if (ARADDR_M0 >= 32'h1000_0000 && ARADDR_M0 <= 32'h1FFF_FFFF) begin
      				  ARREADY_M0 = ARREADY_S1; // IM
    				end else if (ARADDR_M0 >= 32'h2000_0000 && ARADDR_M0 <= 32'h2FFF_FFFF) begin
     				   ARREADY_M0 = ARREADY_S2; // DM
    				end 
                    else begin
    				    ARREADY_M0 = DEF; // Default case (address out of range)
    				end
				ARREADY_M1 = 1'd0;
				// ARREADY_M2 = 1'd0;
			end

			R_M1_ADDR:begin
				ARID_BUS = {4'd0, ARID_M1};
				ARADDR_BUS = ARADDR_M1;
				ARLEN_BUS = ARLEN_M1; 
				ARSIZE_BUS = ARSIZE_M1;
				ARBURST_BUS = ARBURST_M1;
				ARVALID_BUS = ARVALID_M1;

				ARREADY_M0 = 1'd0;
	
				if (ARADDR_M1 >= 32'h3000_0000 && ARADDR_M1 <= 32'h3000_4000) begin
       				 ARREADY_M1 = ARREADY_S0; // ROM
    				end else if (ARADDR_M1 >= 32'h1000_0000 && ARADDR_M1 <= 32'h1FFF_FFFF) begin
      				    ARREADY_M1 = ARREADY_S1; // IM
    				end else if (ARADDR_M1 >= 32'h2000_0000 && ARADDR_M1 <= 32'h2FFF_FFFF) begin
     				    ARREADY_M1 = ARREADY_S2; // DM
    				end
                    else begin
    				    ARREADY_M1 = DEF; // Default case (address out of range)
    				end
			end
			
			R_M0_DATA:begin
				ARID_BUS = {4'd0, ID_reg};
				ARADDR_BUS = ADDR_reg;
				ARLEN_BUS = LEN_reg; 
				ARSIZE_BUS = 3'd0;
				ARBURST_BUS = BURST_reg;
				ARVALID_BUS = 1'd0;
				ARREADY_M0 = 1'd0;
				ARREADY_M1 = 1'd0;
				// ARREADY_M2 = 1'd0;
			end
			R_M1_DATA:begin
				ARID_BUS = {4'd0, ID_reg};
				ARADDR_BUS = ADDR_reg;
				ARLEN_BUS = LEN_reg; 
				ARSIZE_BUS = 3'd0;
				ARBURST_BUS = BURST_reg;
				ARVALID_BUS = 1'd0;
				ARREADY_M0 = 1'd0;
				ARREADY_M1 = 1'd0;
				// ARREADY_M2 = 1'd0;
			end
			R_M2_DATA:begin
				ARID_BUS = {4'd0, ID_reg};
				ARADDR_BUS = ADDR_reg;
				ARLEN_BUS = LEN_reg; 
				ARSIZE_BUS = 3'd0;
				ARBURST_BUS = BURST_reg;
				ARVALID_BUS = 1'd0;
				ARREADY_M0 = 1'd0;
				ARREADY_M1 = 1'd0;
				// ARREADY_M2 = 1'd0;
			end
			default:begin
				ARID_BUS = {4'd0, ID_reg};
				ARADDR_BUS = ADDR_reg;
				ARLEN_BUS = LEN_reg; 
				ARSIZE_BUS = 3'd0;
				ARBURST_BUS = BURST_reg;
				ARVALID_BUS = 1'd0;
				ARREADY_M0 = 1'd0;
			end
		endcase
	end

	
	
	
endmodule
