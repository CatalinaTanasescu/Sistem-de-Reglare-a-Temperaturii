`timescale 1ns/1ps

module sgt_tb;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import pkg_apb::*;
  import pkg_temp::*;
  import sgt_pkg::*;
  import sgt_tests_pkg::*;

  reg clk;
  reg rst_n;

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst_n = 0;
    #20 rst_n = 1;
  end

  temp_system #(
    .DATA_WIDTH    (8),
    .UPDATE_CYCLES (10),
    .AMBIENT_TEMP  (22)
  ) dut (
    .clk       (clk),
    .rst_n     (rst_n),
    .paddr     (apb_if_inst.paddr),
    .psel      (apb_if_inst.psel),
    .penable   (apb_if_inst.penable),
    .pwrite    (apb_if_inst.pwrite),
    .pwdata    (apb_if_inst.pwdata[7:0]),
    .prdata    (prdata_8bit),
    .pready    (apb_if_inst.pready),
    .pslverr   (apb_if_inst.pslverr),
    .temp_now  (temp_if_inst.temp_now),
    .temp_valid(temp_if_inst.temp_valid),
    .heater_on (temp_if_inst.heater_on),
    .cooler_on (temp_if_inst.cooler_on)
  );

  // Width adaptation: DUT prdata is 8-bit, APB UVC is 32-bit, for the assertion prdata_valid 
  wire [7:0] prdata_8bit;
  assign apb_if_inst.prdata = {24'b0, prdata_8bit};

  apb_interface_dut apb_if_inst (
    .pclk  (clk),
    .rst_n (rst_n)
  );

  temp_interface_dut temp_if_inst (
    .clk   (clk),
    .rst_n (rst_n)
  );

  sgt_intf sgt_if_inst (
    .clk   (clk),
    .rst_n (rst_n)
  );

  assign sgt_if_inst.paddr    = apb_if_inst.paddr;
  assign sgt_if_inst.psel     = apb_if_inst.psel;
  assign sgt_if_inst.penable  = apb_if_inst.penable;
  assign sgt_if_inst.pwrite   = apb_if_inst.pwrite;
  assign sgt_if_inst.pwdata   = apb_if_inst.pwdata[7:0];
  assign sgt_if_inst.prdata   = prdata_8bit;
  assign sgt_if_inst.pready   = apb_if_inst.pready;
  assign sgt_if_inst.pslverr  = apb_if_inst.pslverr;
  assign sgt_if_inst.temp_now  = temp_if_inst.temp_now;
  assign sgt_if_inst.temp_valid = temp_if_inst.temp_valid;
  assign sgt_if_inst.heater_on = temp_if_inst.heater_on;
  assign sgt_if_inst.cooler_on = temp_if_inst.cooler_on;

  initial begin
    uvm_config_db #(virtual apb_interface_dut)::set(null, "uvm_test_top.env", "apb_vif", apb_if_inst);
    uvm_config_db #(virtual temp_interface_dut)::set(null, "uvm_test_top.env", "temp_vif", temp_if_inst);
    uvm_config_db #(virtual sgt_intf)::set(null, "uvm_test_top.env", "sgt_vif", sgt_if_inst);
    run_test();
  end

endmodule : sgt_tb