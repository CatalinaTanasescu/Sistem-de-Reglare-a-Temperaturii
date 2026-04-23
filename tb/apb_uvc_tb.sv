module tb_apb;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  import apb_pkg::*;
  import apb_env_pkg::*;
  import apb_pkg_tests::*;

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

  initial begin
    uvm_config_db #(virtual apb_interface_dut)::set(null, "uvm_test_top.apb_environment", "apb_intf", apb_if_inst);
    run_test();
  end

endmodule : tb_apb