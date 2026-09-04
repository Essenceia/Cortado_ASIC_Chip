/* 
	Hazard3 core wrapper with options to estimate implementaiton cost 
*/

`default_nettype none

module soc #(
	parameter  W_PADDR         = 9,
	localparam ABITS           = W_PADDR - 2, // do not modify
	localparam W_DR_SHIFT      = ABITS + 32 + 2, // seriously don't touch
	parameter  DTMCS_IDLE_HINT = 3'd4,
	`include "hazard3_config.vh"
) (
	input wire               clk,
	input wire               rst_n,

	// from jtag tap
	input  wire                  tck,
	input  wire                  trst_n,
	input  wire                  dr_wen_i,
	input  wire                  dr_ren_i,
	input  wire                  dr_sel_dmi_ndtmcs_i, 
	input  wire [W_DR_SHIFT-1:0] dr_wdata_i,
	output wire [W_DR_SHIFT-1:0] dr_rdata_o,

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

reg rst_core_n; 
always @(posedge clk) 
	rst_core_n <= rst_n; 

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
	.rst_n  (rst_core_n),
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

// jtag tap can force hard reset
wire rst_n_dmi;
wire dmihardreset_req;
wire assert_dmi_reset = ~rst_core_n | dmihardreset_req;

reset_sync dmi_reset_sync_u (
	.clk       (clk),
	.rst_n_in  (!assert_dmi_reset),
	.rst_n_out (rst_n_dmi)
);

/* JTAG interface 
dtm_core does the cdc between the JTAG and the DMI(same as core) clk domains
*/
wire              dmi_psel;
wire              dmi_penable;
wire              dmi_pwrite;
wire [8:0]        dmi_paddr;
wire [31:0]       dmi_pwdata;
wire [31:0]       dmi_prdata;
wire              dmi_pready;
wire              dmi_pslverr;

hazard3_jtag_dtm_core #(
	.DTMCS_IDLE_HINT (DTMCS_IDLE_HINT),
	.W_ADDR(ABITS)
) dtm_core (
	.tck               (tck),
	.trst_n            (trst_n),
	.clk_dmi           (clk),
	.rst_n_dmi         (rst_n_dmi),

	.dmihardreset_req  (dmihardreset_req),

	.dr_wen            (dr_wen_i),
	.dr_ren            (dr_ren_i),
	.dr_sel_dmi_ndtmcs (dr_sel_dmi_ndtmcs_i),
	.dr_wdata          (dr_wdata_i),
	.dr_rdata          (dr_rdata_o),

	.dmi_psel          (dmi_psel),
	.dmi_penable       (dmi_penable),
	.dmi_pwrite        (dmi_pwrite),
	.dmi_paddr         (dmi_paddr[W_PADDR-1:2]),
	.dmi_pwdata        (dmi_pwdata),
	.dmi_prdata        (dmi_prdata),
	.dmi_pready        (dmi_pready),
	.dmi_pslverr       (dmi_pslverr)
);
assign dmi_paddr[1:0] = 2'b00;

// Debug Module
localparam N_HARTS = 1; // single hart: single core system 
localparam XLEN = 32;

wire                      sys_reset_req;
wire                      sys_reset_done;
wire [N_HARTS-1:0]        hart_reset_req;
wire [N_HARTS-1:0]        hart_reset_done;

wire [N_HARTS-1:0]        hart_req_halt;
wire [N_HARTS-1:0]        hart_req_halt_on_reset;
wire [N_HARTS-1:0]        hart_req_resume;
wire [N_HARTS-1:0]        hart_halted;
wire [N_HARTS-1:0]        hart_running;

wire [N_HARTS*XLEN-1:0]   hart_data0_rdata;
wire [N_HARTS*XLEN-1:0]   hart_data0_wdata;
wire [N_HARTS-1:0]        hart_data0_wen;

wire [N_HARTS*XLEN-1:0]   hart_instr_data;
wire [N_HARTS-1:0]        hart_instr_data_vld;
wire [N_HARTS-1:0]        hart_instr_data_rdy;
wire [N_HARTS-1:0]        hart_instr_caught_exception;
wire [N_HARTS-1:0]        hart_instr_caught_ebreak;

wire [31:0]               sbus_addr;
wire                      sbus_write;
wire [1:0]                sbus_size;
wire                      sbus_vld;
wire                      sbus_rdy;
wire                      sbus_err;
wire [31:0]               sbus_wdata;
wire [31:0]               sbus_rdata;

hazard3_dm #(
	.N_HARTS      (N_HARTS),
	.NEXT_DM_ADDR (0),
	.HAVE_SBA     (1) // has system bus access 
) dm (
	.clk                         (clk),
	.rst_n                       (rst_n),

	.dmi_psel                    (dmi_psel),
	.dmi_penable                 (dmi_penable),
	.dmi_pwrite                  (dmi_pwrite),
	.dmi_paddr                   (dmi_paddr),
	.dmi_pwdata                  (dmi_pwdata),
	.dmi_prdata                  (dmi_prdata),
	.dmi_pready                  (dmi_pready),
	.dmi_pslverr                 (dmi_pslverr),

	.sys_reset_req               (sys_reset_req),//ndmreset
	.sys_reset_done              (sys_reset_done),
	.hart_reset_req              (hart_reset_req),
	.hart_reset_done             (hart_reset_done),

	.hart_req_halt               (hart_req_halt),
	.hart_req_halt_on_reset      (hart_req_halt_on_reset),
	.hart_req_resume             (hart_req_resume),
	.hart_halted                 (hart_halted),
	.hart_running                (hart_running),
	
	// access to data0 CSR core internal - TODO: do I need CSR ?  
	.hart_data0_rdata            (hart_data0_rdata),
	.hart_data0_wdata            (hart_data0_wdata),
	.hart_data0_wen              (hart_data0_wen),

	// core instruction injection
	.hart_instr_data             (hart_instr_data),
	.hart_instr_data_vld         (hart_instr_data_vld),
	.hart_instr_data_rdy         (hart_instr_data_rdy),
	.hart_instr_caught_exception (hart_instr_caught_exception),
	.hart_instr_caught_ebreak    (hart_instr_caught_ebreak),

	// debugger system bus access 
	.sbus_addr                   (sbus_addr),
	.sbus_write                  (sbus_write),
	.sbus_size                   (sbus_size),
	.sbus_vld                    (sbus_vld),
	.sbus_rdy                    (sbus_rdy),
	.sbus_err                    (sbus_err),
	.sbus_wdata                  (sbus_wdata),
	.sbus_rdata                  (sbus_rdata)
);


// core  
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
	.rst_n                      (rst_core_n),

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
	
	// Debugger run/halt control
	.dbg_req_halt               (hart_req_halt),
	.dbg_req_halt_on_reset      (hart_req_halt_on_reset),
	.dbg_req_resume             (hart_req_resume),
	.dbg_halted                 (hart_halted),
	.dbg_running                (hart_running),
	
	// Debugger access to data0 CSR
	.dbg_data0_rdata            (hart_data0_rdata),
	.dbg_data0_wdata            (hart_data0_wdata),
	.dbg_data0_wen              (hart_data0_wen),
	
	// Debugger instruction injection
	.dbg_instr_data             (hart_instr_data),
	.dbg_instr_data_vld         (hart_instr_data_vld),
	.dbg_instr_data_rdy         (hart_instr_data_rdy),
	.dbg_instr_caught_exception (hart_instr_caught_exception),
	.dbg_instr_caught_ebreak    (hart_instr_caught_ebreak),

	// debug access to system bus 
	.dbg_sbus_addr              (sbus_addr),
	.dbg_sbus_write             (sbus_write),
	.dbg_sbus_size              (sbus_size),
	.dbg_sbus_vld               (sbus_vld),
	.dbg_sbus_rdy               (sbus_rdy),
	.dbg_sbus_err               (sbus_err),
	.dbg_sbus_wdata             (sbus_wdata),
	.dbg_sbus_rdata             (sbus_rdata),

	.mhartid_val                (32'd0),
	.eco_version                (4'd0),

	.irq                        (irq_i),
	.soft_irq                   (soft_irq_i),
	.timer_irq                  (timer_irq_i)
);

endmodule
