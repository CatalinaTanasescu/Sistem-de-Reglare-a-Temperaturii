interface sgt_intf (
  input logic clk,
  input logic rst_n
);

  logic  [2:0] paddr;
  logic        psel;
  logic        penable;
  logic        pwrite;
  logic  [7:0] pwdata;
  logic  [7:0] prdata;
  logic        pready;
  logic        pslverr;

  logic  [7:0] temp_now;
  logic        temp_valid;
  logic        heater_on;
  logic        cooler_on;

endinterface : sgt_intf