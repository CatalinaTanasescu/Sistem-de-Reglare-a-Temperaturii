interface temp_interface_dut (input logic clk, input logic rst_n);

   logic [7:0] temp_now;
   logic       temp_valid;
   logic       heater_on;
   logic       cooler_on;

   clocking mon_ck @(posedge clk);
      default input #1ns;
      input temp_now, temp_valid, heater_on, cooler_on;
   endclocking

   modport monitor_mp (clocking mon_ck, input clk, rst_n);

   // ------------------------------------------------------------------ //
   // X/HiZ checks
   // ------------------------------------------------------------------ //

   property temp_now_valid;
      @(posedge clk) disable iff(rst_n === 1'b0)
         (temp_valid |-> !$isunknown(temp_now));
   endproperty

   property temp_valid_no_x;
      @(posedge clk) disable iff(rst_n === 1'b0)
         (temp_valid !== 1'bx && temp_valid !== 1'bz);
   endproperty

   property heater_on_no_x;
      @(posedge clk) disable iff(rst_n === 1'b0)
         (heater_on !== 1'bx && heater_on !== 1'bz);
   endproperty

   property cooler_on_no_x;
      @(posedge clk) disable iff(rst_n === 1'b0)
         (cooler_on !== 1'bx && cooler_on !== 1'bz);
   endproperty

   temp_now_valid_a: assert property (temp_now_valid)
      else $error("[%0t][TEMP_INTF] ERROR: temp_now is X/HiZ while temp_valid=1", $time);

   temp_valid_no_x_a: assert property (temp_valid_no_x)
      else $error("[%0t][TEMP_INTF] ERROR: temp_valid is X/HiZ", $time);

   heater_on_no_x_a: assert property (heater_on_no_x)
      else $error("[%0t][TEMP_INTF] ERROR: heater_on is X/HiZ", $time);

   cooler_on_no_x_a: assert property (cooler_on_no_x)
      else $error("[%0t][TEMP_INTF] ERROR: cooler_on is X/HiZ", $time);

   // ------------------------------------------------------------------ //
   // Checks for protocol compliance
   // ------------------------------------------------------------------ //

   // heater and cooler should not be on at the same time
   property no_simultaneous_heat_cool;
      @(posedge clk) disable iff(rst_n === 1'b0)
         !(heater_on && cooler_on);
   endproperty

   // after reset, both outputs must be 0
   property outputs_deasserted_after_rst;
      @(posedge clk)
         ($fell(rst_n)) |=> (!heater_on && !cooler_on);
   endproperty

   no_simultaneous_heat_cool_a: assert property (no_simultaneous_heat_cool)
      else $error("[%0t][TEMP_INTF] ERROR: heater_on and cooler_on both active", $time);

   outputs_deasserted_after_rst_a: assert property (outputs_deasserted_after_rst)
      else $error("[%0t][TEMP_INTF] ERROR: heater_on/cooler_on not deasserted after reset", $time);

endinterface