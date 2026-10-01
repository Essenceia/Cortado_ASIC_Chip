/* Julia Demsazes, 2026, all rights reserved 

This is just a simple test module to evaluate the area impact of the sram 
mix. Don't expect the logic to make sense: it doesn't */ 
module sram_test(
input wire  clk, 
input wire  d_i, 
output wire d_o
); 

// 128x8 
wire       sram128x8_we; 
wire [6:0] sram128x8_addr; 
wire [7:0] sram128x8_data_wr; 
wire [7:0] sram128x8_data_rd;

assign sram128x8_we      = d_i;
assign sram128x8_addr    = {7{d_i}}; 
assign sram128x8_data_wr = {8{d_i}};
 
(* keep *) SP6TBgf180mcu_c4m_ip__sram3v3_128x8 m_sram128x8(
.clk(clk), 
.we(sram128x8_we), 
.a(sram128x8_addr),
.d(sram128x8_data_wr), 
.q(sram128x8_data_rd)
);

// 2 x 256x16 
wire        sram256x16_we[1:0]; 
wire [7:0]  sram256x16_addr[1:0]; 
wire [15:0] sram256x16_data_wr[1:0]; 
wire [15:0] sram256x16_data_rd[1:0];

assign sram256x16_we[0]      = d_i;
assign sram256x16_addr[0]    = {8{d_i}}; 
assign sram256x16_data_wr[0] = {16{d_i}};

assign sram256x16_we[1]      = d_i;
assign sram256x16_addr[1]    = {8{d_i}}; 
assign sram256x16_data_wr[1] = {16{d_i}};
  
(* keep *) SP6TBgf180mcu_c4m_ip__sram3v3_256x16 m_sram256x16_0(
.clk(clk), 
.we({2{sram256x16_we[0]}}), 
.a (sram256x16_addr[0]),
.d (sram256x16_data_wr[0]), 
.q (sram256x16_data_rd[0])
);

(* keep *) SP6TBgf180mcu_c4m_ip__sram3v3_256x16 m_sram256x16_1(
.clk(clk), 
.we({2{sram256x16_we[1]}}), 
.a (sram256x16_addr[1]),
.d (sram256x16_data_wr[1]), 
.q (sram256x16_data_rd[1])
);

// 256x8
wire       sram256x8_we; 
wire [7:0] sram256x8_addr; 
wire [7:0] sram256x8_data_wr; 
wire [7:0] sram256x8_data_rd;

assign sram256x8_we      = d_i;
assign sram256x8_addr    = {8{d_i}}; 
assign sram256x8_data_wr = {8{d_i}};
 
(* keep *) SP6TBgf180mcu_c4m_ip__sram3v3_256x8 m_sram256x8(
.clk(clk), 
.we(sram256x8_we), 
.a (sram256x8_addr),
.d (sram256x8_data_wr), 
.q (sram256x8_data_rd)
);

assign d_o = |sram128x8_data_rd | |sram256x16_data_rd[0] | |sram256x16_data_rd[1] | |sram256x8_data_rd; 

endmodule
