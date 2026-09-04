/* 
	Hazard3 core wrapper with options to estimate implementaiton cost 
*/

`default_nettype none

module soc #(
	parameter [3:0]  TAP_VERSION_NUM = 4'd3, // tapeout 3 featuring a custom jtag tap
	parameter [15:0] TAP_PART_NUM = 16'hbeef,
	parameter [10:0] TAP_MANIFACTURE_ID = 11'h6b, // continuing the inside joke
	`include "hazard3_config.vh"
) (
	input wire               clk,
	input wire               rst_n,

	// AHB5 Master port
	output reg  [W_ADDR-1:0]  haddr_o,
	output reg                hwrite_o,
	output reg  [1:0]         htrans_o,
	output reg  [2:0]         hsize_o,
	output wire [2:0]         hburst_o,
	output reg  [3:0]         hprot_o,
	output wire               hmastlock_o,
	output reg  [7:0]         hmaster_o,
	output reg                hexcl_o,
	input  wire               hready_i,
	input  wire               hresp_i,
	input  wire               hexokay_i,
	output wire [W_DATA-1:0]  hwdata_o,
	input  wire [W_DATA-1:0]  hrdata_i,

	// Debugger run/halt control
	input  wire               dbg_req_halt_i,
	input  wire               dbg_req_halt_on_reset_i,
	input  wire               dbg_req_resume_i,
	output wire               dbg_halted_o,
	output wire               dbg_running_o,
	// Debugger access to data0 CSR
	input  wire [W_DATA-1:0]  dbg_data0_rdata_i,
	output wire [W_DATA-1:0]  dbg_data0_wdata_o,
	output wire               dbg_data0_wen_o,
	// Debugger instruction injection
	input  wire [W_DATA-1:0]  dbg_instr_data_i,
	input  wire               dbg_instr_data_vld_i,
	output wire               dbg_instr_data_rdy_o,
	output wire               dbg_instr_caught_exception_o,
	output wire               dbg_instr_caught_ebreak_o,

	// Level-sensitive interrupt sources
	input wire [NUM_IRQS-1:0] irq_i,       // -> mip.meip
	input wire                soft_irq_i,  // -> mip.msip
	input wire                timer_irq_i  // -> mip.mtip
);
// tie backs
wire pwrup_req; 
wire unblock_out;
// unused outputs
wire clk_en_unused;
wire fence_i_vld_unused;
wire fence_d_vld_unused; 
wire dbg_sbus_rdy_unused; 
wire dbg_sbus_err_unused; 
wire [W_DATA-1:0] dbg_sbus_rdata_unused;

reg rst_d1_q; 
always @(posedge clk) 
	rst_d1_q <= rst_n; 

`ifdef EXTERNAL_REGILE
// external regfile
wire [W_REGADDR-1:0] rf_raddr1; 
reg  [W_DATA-1:0]    rf_rdata1;
wire [W_REGADDR-1:0] rf_raddr2; 
reg  [W_DATA-1:0]    rf_rdata2;
wire [W_REGADDR-1:0] rf_waddr; 
wire [W_DATA-1:0]    rf_wdata;
wire                 rf_wen;

hazard3_regfile_1w2r #(
`include "hazard3_config_inst.vh"
) regs (
	.clk    (clk),
	.rst_n  (rst_d1_q),
	// On downstream stall, we feed D's addresses back into regfile
	// so that output does not change.
	// GF180MCU: use fine rather than coarse predecode as the we rely on the
	// regfile read port for zeroing x0.
	.raddr1 (rf_raddr1),
	.rdata1 (rf_rdata1),
	.raddr2 (rf_raddr2),
	.rdata2 (rf_rdata2),
	.waddr  (rf_waddr),
	.wdata  (rf_wdata),
	.wen    (rf_wen)
);
`endif // EXTERNAL_REGFILE

// JTAG 
localparam [31:0] IDCODE = {VERSION_NUM, PART_NUM, MANIFACTURE_ID, 1'b1};
 
hazard3_cpu_1port #(
	// These must have the values given here for you to end up with a useful SoC:
	.RESET_VECTOR    (32'h0000_0040),
	.MTVEC_INIT      (32'h0000_0000),
	.CSR_M_MANDATORY (1),
	.CSR_M_TRAP      (1),
	.DEBUG_SUPPORT   (1),
	.NUM_IRQS        (1),
	.RESET_REGFILE   (0),
	// Can be overridden from the defaults in hazard3_config.vh during
	// instantiation of example_soc():
	.EXTENSION_A         (EXTENSION_A),
	.EXTENSION_C         (EXTENSION_C),
	.EXTENSION_E         (EXTENSION_E),
	.EXTENSION_M         (EXTENSION_M),
	.EXTENSION_ZBA       (EXTENSION_ZBA),
	.EXTENSION_ZBB       (EXTENSION_ZBB),
	.EXTENSION_ZBC       (EXTENSION_ZBC),
	.EXTENSION_ZBKB      (EXTENSION_ZBKB),
	.EXTENSION_ZBKX      (EXTENSION_ZBKX),
	.EXTENSION_ZBS       (EXTENSION_ZBS),
	.EXTENSION_ZCB       (EXTENSION_ZCB),
	.EXTENSION_ZCLSD     (EXTENSION_ZCLSD),
	.EXTENSION_ZCMP      (EXTENSION_ZCMP),
	.EXTENSION_ZIFENCEI  (EXTENSION_ZIFENCEI),
	.EXTENSION_ZILSD     (EXTENSION_ZILSD),
	.EXTENSION_XH3BEXTM  (EXTENSION_XH3BEXTM),
	.EXTENSION_XH3IRQ    (EXTENSION_XH3IRQ),
	.EXTENSION_XH3PMPM   (EXTENSION_XH3PMPM),
	.EXTENSION_XH3POWER  (EXTENSION_XH3POWER),
	.CSR_COUNTER         (CSR_COUNTER),
	.U_MODE              (U_MODE),
	.PMP_REGIONS         (PMP_REGIONS),
	.PMP_GRAIN           (PMP_GRAIN),
	.PMP_HARDWIRED       (PMP_HARDWIRED),
	.PMP_HARDWIRED_ADDR  (PMP_HARDWIRED_ADDR),
	.PMP_HARDWIRED_CFG   (PMP_HARDWIRED_CFG),
	.MVENDORID_VAL       (MVENDORID_VAL),
	.BREAKPOINT_TRIGGERS (BREAKPOINT_TRIGGERS),
	.IRQ_PRIORITY_BITS   (IRQ_PRIORITY_BITS),
	.REDUCED_BYPASS      (REDUCED_BYPASS),
	.MULDIV_UNROLL       (MULDIV_UNROLL),
	.MUL_FAST            (MUL_FAST),
	.MUL_FASTER          (MUL_FASTER),
	.MULH_FAST           (MULH_FAST),
	.FAST_BRANCHCMP      (FAST_BRANCHCMP),
	.BRANCH_PREDICTOR    (BRANCH_PREDICTOR),
	.MTVEC_WMASK         (MTVEC_WMASK)
) cpu (
	.clk                        (clk),
	.clk_always_on              (clk),
	.rst_n                      (rst_d1_q),

	.pwrup_req                  (pwrup_req),
	.pwrup_ack                  (pwrup_req),   // Tied back
	.clk_en                     (clk_en_unused),
	.unblock_out                (unblock_out),
	.unblock_in                 (unblock_out), // Tied back

	`ifdef EXTERNAL_REGILE 
	.raddr1_o(rf_raddr1), 
	.raddr1_i(rf_raddr1),
	.raddr2_o(rf_radd2), 
	.raddr2_i(rf_raddr2),
	.waddr_o (rf_waddr), 
	.wdata_o (rf_wdata), 
	.wen_o   (rf_wen),
	`endif

	// AMB5 port 
	.haddr                      (haddr_o),
	.hwrite                     (hwrite_o),
	.htrans                     (htrans_o),
	.hsize                      (hsize_o),
	.hburst                     (hburst_o),
	.hprot                      (hprot_o),
	.hmastlock                  (hmastlock_o),
	.hmaster                    (hmaster_o),
	.hexcl                      (hexcl_o),
	.hready                     (hready_i),
	.hresp                      (hresp_i),
	.hexokay                    (hexokay_i),
	.hwdata                     (hwdata_o),
	.hrdata                     (hrdata_i),

	.fence_i_vld                (fence_i_vld_unused),
	.fence_d_vld                (fence_d_vld_unused),
	.fence_rdy                  (1'b1),

	.dbg_req_halt               (dbg_req_halt_i),
	.dbg_req_halt_on_reset      (dbg_req_halt_on_reset_i),
	.dbg_req_resume             (dbg_req_resume_i),
	.dbg_halted                 (dbg_halted_o),
	.dbg_running                (dbg_running_o),
	.dbg_data0_rdata            (dbg_data0_rdata_i),
	.dbg_data0_wdata            (dbg_data0_wdata_o),
	.dbg_data0_wen              (dbg_data0_wen_o),
	.dbg_instr_data             (dbg_instr_data_i),
	.dbg_instr_data_vld         (dbg_instr_data_vld_i),
	.dbg_instr_data_rdy         (dbg_instr_data_rdy_o),
	.dbg_instr_caught_exception (dbg_instr_caught_exception_o),
	.dbg_instr_caught_ebreak    (dbg_instr_caught_ebreak_o),

	// TODO figure out what this is ? 
    .dbg_sbus_addr              (32'd0),
    .dbg_sbus_write             (1'b0),
    .dbg_sbus_size              (2'h0),
    .dbg_sbus_vld               (1'b0),
    .dbg_sbus_rdy               (dbg_sbus_rdy_unused),
    .dbg_sbus_err               (dbg_sbus_err_unused),
    .dbg_sbus_wdata             (32'd0),
    .dbg_sbus_rdata             (dbg_sbus_rdata_unused),

	.mhartid_val                (32'd0),
	.eco_version                (4'd0),

	.irq                        (irq_i),
	.soft_irq                   (soft_irq_i),
	.timer_irq                  (timer_irq_i)
);

endmodule
