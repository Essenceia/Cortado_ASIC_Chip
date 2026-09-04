/* phoney cell library used for linter and sim */

/* verilator lint_off DECLFILENAME */ 

// SDFFQ: base scan flop on rising edge 
module gf180mcu_fd_sc_sdffq(
	input  wire CLK, 
	input  wire D, 
	input  wire SI, 
	input  wire SE, 
	output wire Q	
);
always @(posedge CLK) begin
	if (SE) Q <= SI;
	else Q <= D;
end 
endmodule

module gf180mcu_fd_sc_mcu9t5v0__sdffq_1(
	input  wire CLK, 
	input  wire D, 
	input  wire SI, 
	input  wire SE, 
	output wire Q	
);
gf180mcu_fd_sc_sdffq m_sdffq(
.CLK(CLK), .D(D), .SI(SI), .SE(SE), .Q(Q)
);
endmodule

module gf180mcu_fd_sc_mcu9t5v0__sdffq_4(
	input  wire CLK, 
	input  wire D, 
	input  wire SI, 
	input  wire SE, 
	output wire Q	
);
gf180mcu_fd_sc_sdffq m_sdffq(
.CLK(CLK), .D(D), .SI(SI), .SE(SE), .Q(Q)
);
endmodule

// DFFRNQ: async active low reset, posedge triggered ff

module gf180mcu_fd_sc_dffrnq(
	input  wire CLK, 
	input  wire RN, 
	input  wire D,
	output wire Q 
);
always @(posedge CLK or negedge RN) 
	if (~RN) Q <= 1'b0;
	else Q <= D; 
endmodule

module gf180mcu_fd_sc_mcu7t5v0__dffrnq_1(
	input  wire CLK, 
	input  wire RN, 
	input  wire D,
	output wire Q 
);
gf180mcu_fd_sc_dffrnq m_dffrnq(
	.CLK (CLK), .RN(RN), .D(D), .Q(Q)
);
endmodule 

module gf180mcu_fd_sc_mcu9t5v0__dffrnq_1(
	input  wire CLK, 
	input  wire RN, 
	input  wire D,
	output wire Q 
);
gf180mcu_fd_sc_dffrnq m_dffrnq(
	.CLK (CLK), .RN(RN), .D(D), .Q(Q)
);
endmodule 











/* verilator lint_on DECLFILENAME */ 

