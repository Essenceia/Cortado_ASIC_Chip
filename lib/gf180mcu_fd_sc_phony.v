/* phoney cell library used for linter and sim */

/* verilator lint_off DECLFILENAME */ 

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

/* verilator lint_on DECLFILENAME */ 

