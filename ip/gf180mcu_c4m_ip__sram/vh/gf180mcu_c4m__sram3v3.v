(* blackbox *)
module SP6Tgf180mcu_c4m_ip__sram3v3_128x8(a, d, we, clk, q);
  input wire [6:0] a;
  input wire [7:0] d;
  input wire [0:0] we;
  input wire clk;
  output wire [7:0] q;

  reg [7:0] mem [0:127];
  reg [6:0] a_latch;

  always @(posedge clk) begin
    a_latch <= a;
    if (we[0]) begin
      mem[a_latch][7:0] <= d[7:0];
    end
  end

  assign q = mem[a_latch];
endmodule

(* blackbox *)
module SP6Tgf180mcu_c4m_ip__sram3v3_256x8(a, d, we, clk, q);
  input wire [7:0] a;
  input wire [7:0] d;
  input wire [0:0] we;
  input wire clk;
  output wire [7:0] q;

  reg [7:0] mem [0:255];
  reg [7:0] a_latch;

  always @(posedge clk) begin
    a_latch <= a;
    if (we[0]) begin
      mem[a_latch][7:0] <= d[7:0];
    end
  end

  assign q = mem[a_latch];
endmodule

(* blackbox *)
module SP6Tgf180mcu_c4m_ip__sram3v3_256x16(a, d, we, clk, q);
  input wire [7:0] a;
  input wire [15:0] d;
  input wire [1:0] we;
  input wire clk;
  output wire [15:0] q;

  reg [15:0] mem [0:255];
  reg [7:0] a_latch;

  always @(posedge clk) begin
    a_latch <= a;
    if (we[0]) begin
      mem[a_latch][7:0] <= d[7:0];
    end
    if (we[1]) begin
      mem[a_latch][15:8] <= d[15:8];
    end
  end

  assign q = mem[a_latch];
endmodule
