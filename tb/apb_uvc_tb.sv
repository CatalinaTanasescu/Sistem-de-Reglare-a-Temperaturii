`timescale 1ns/1ps

module tb_apb;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  import apb_pkg::*;
  import apb_env_pkg::*;
  import apb_tests_pkg::*;

  reg pclk;
  reg rst_n;

  initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
  end

  initial begin
    rst_n = 0;
    #20 rst_n = 1;
  end

  apb_interface_dut apb_if_inst (
    .pclk  (pclk),
    .rst_n (rst_n)
  );

  always_comb begin
    if (!rst_n) begin
      apb_if_inst.pready  = 1'b0;
      apb_if_inst.prdata  = 32'h0;
      apb_if_inst.pslverr = 1'b0;
    end else if (apb_if_inst.psel && apb_if_inst.penable) begin
      apb_if_inst.pready  = 1'b1;
      apb_if_inst.pslverr = 1'b0;
      apb_if_inst.prdata  = $urandom;
    end else begin
      apb_if_inst.pready  = 1'b0;
      apb_if_inst.prdata  = 32'h0;
      apb_if_inst.pslverr = 1'b0;
    end
  end

  initial begin
    uvm_config_db #(virtual apb_interface_dut)::set(null, "uvm_test_top.apb_environment", "apb_intf", apb_if_inst);
    run_test();
  end

endmodule : tb_apb