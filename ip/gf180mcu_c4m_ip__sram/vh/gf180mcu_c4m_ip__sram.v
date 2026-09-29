(* blackbox *)
module SP6TRBlock_128x8(a, d, we, clk, q);
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
module SP6TRBlock_256x16(a, d, we, clk, q);
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

(* blackbox *)
module SP6TRBlock_512x32(a, d, we, clk, q);
  input wire [8:0] a;
  input wire [31:0] d;
  input wire [3:0] we;
  input wire clk;
  output wire [31:0] q;

  reg [31:0] mem [0:511];
  reg [8:0] a_latch;

  always @(posedge clk) begin
    a_latch <= a;
    if (we[0]) begin
      mem[a_latch][7:0] <= d[7:0];
    end
    if (we[1]) begin
      mem[a_latch][15:8] <= d[15:8];
    end
    if (we[2]) begin
      mem[a_latch][23:16] <= d[23:16];
    end
    if (we[3]) begin
      mem[a_latch][31:24] <= d[31:24];
    end
  end

  assign q = mem[a_latch];
endmodule

(* blackbox *)
module SP6TRBlock_256x8(a, d, we, clk, q);
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
module SP6TRBlock_512x8(a, d, we, clk, q);
  input wire [8:0] a;
  input wire [7:0] d;
  input wire [0:0] we;
  input wire clk;
  output wire [7:0] q;

  reg [7:0] mem [0:511];
  reg [8:0] a_latch;

  always @(posedge clk) begin
    a_latch <= a;
    if (we[0]) begin
      mem[a_latch][7:0] <= d[7:0];
    end
  end

  assign q = mem[a_latch];
endmodule

(* blackbox *)
module DP8TRBlock_128x8(a1, d1, we1, clk1, q1, a2, d2, we2, clk2, q2);
  input wire [6:0] a1;
  input wire [6:0] a2;
  input wire [7:0] d1;
  input wire [7:0] d2;
  input wire [0:0] we1;
  input wire [0:0] we2;
  input wire clk1;
  input wire clk2;
  output wire [7:0] q1;
  output wire [7:0] q2;

  reg [7:0] mem [0:127];
  reg [6:0] a1_latch;
  reg [6:0] a2_latch;

  // TODO: Check for conflicting write to same address on both ports

  always @(posedge clk1) begin
    a1_latch <= a1;
    if (we1[0]) begin
      mem[a1_latch][7:0] <= d1[7:0];
    end
  end

  assign q1 = mem[a1_latch];

  always @(posedge clk2) begin
    a2_latch <= a2;
    if (we2[0]) begin
      mem[a2_latch][7:0] <= d2[7:0];
    end
  end

  assign q2 = mem[a2_latch];
endmodule

(* blackbox *)
module DP8TRBlock_256x16(a1, d1, we1, clk1, q1, a2, d2, we2, clk2, q2);
  input wire [7:0] a1;
  input wire [7:0] a2;
  input wire [15:0] d1;
  input wire [15:0] d2;
  input wire [1:0] we1;
  input wire [1:0] we2;
  input wire clk1;
  input wire clk2;
  output wire [15:0] q1;
  output wire [15:0] q2;

  reg [15:0] mem [0:255];
  reg [7:0] a1_latch;
  reg [7:0] a2_latch;

  // TODO: Check for conflicting write to same address on both ports

  always @(posedge clk1) begin
    a1_latch <= a1;
    if (we1[0]) begin
      mem[a1_latch][7:0] <= d1[7:0];
    end
    if (we1[1]) begin
      mem[a1_latch][15:8] <= d1[15:8];
    end
  end

  assign q1 = mem[a1_latch];

  always @(posedge clk2) begin
    a2_latch <= a2;
    if (we2[0]) begin
      mem[a2_latch][7:0] <= d2[7:0];
    end
    if (we2[1]) begin
      mem[a2_latch][15:8] <= d2[15:8];
    end
  end

  assign q2 = mem[a2_latch];
endmodule

(* blackbox *)
module DP8TRBlock_512x32(a1, d1, we1, clk1, q1, a2, d2, we2, clk2, q2);
  input wire [8:0] a1;
  input wire [8:0] a2;
  input wire [31:0] d1;
  input wire [31:0] d2;
  input wire [3:0] we1;
  input wire [3:0] we2;
  input wire clk1;
  input wire clk2;
  output wire [31:0] q1;
  output wire [31:0] q2;

  reg [31:0] mem [0:511];
  reg [8:0] a1_latch;
  reg [8:0] a2_latch;

  // TODO: Check for conflicting write to same address on both ports

  always @(posedge clk1) begin
    a1_latch <= a1;
    if (we1[0]) begin
      mem[a1_latch][7:0] <= d1[7:0];
    end
    if (we1[1]) begin
      mem[a1_latch][15:8] <= d1[15:8];
    end
    if (we1[2]) begin
      mem[a1_latch][23:16] <= d1[23:16];
    end
    if (we1[3]) begin
      mem[a1_latch][31:24] <= d1[31:24];
    end
  end

  assign q1 = mem[a1_latch];

  always @(posedge clk2) begin
    a2_latch <= a2;
    if (we2[0]) begin
      mem[a2_latch][7:0] <= d2[7:0];
    end
    if (we2[1]) begin
      mem[a2_latch][15:8] <= d2[15:8];
    end
    if (we2[2]) begin
      mem[a2_latch][23:16] <= d2[23:16];
    end
    if (we2[3]) begin
      mem[a2_latch][31:24] <= d2[31:24];
    end
  end

  assign q2 = mem[a2_latch];
endmodule

(* blackbox *)
module DP8TRBlock_512x8(a1, d1, we1, clk1, q1, a2, d2, we2, clk2, q2);
  input wire [8:0] a1;
  input wire [8:0] a2;
  input wire [7:0] d1;
  input wire [7:0] d2;
  input wire [0:0] we1;
  input wire [0:0] we2;
  input wire clk1;
  input wire clk2;
  output wire [7:0] q1;
  output wire [7:0] q2;

  reg [7:0] mem [0:511];
  reg [8:0] a1_latch;
  reg [8:0] a2_latch;

  // TODO: Check for conflicting write to same address on both ports

  always @(posedge clk1) begin
    a1_latch <= a1;
    if (we1[0]) begin
      mem[a1_latch][7:0] <= d1[7:0];
    end
  end

  assign q1 = mem[a1_latch];

  always @(posedge clk2) begin
    a2_latch <= a2;
    if (we2[0]) begin
      mem[a2_latch][7:0] <= d2[7:0];
    end
  end

  assign q2 = mem[a2_latch];
endmodule
