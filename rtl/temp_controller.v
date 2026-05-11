// Module: temp_controller
// Description: This module is the decision-making core of the thermal system. 
//              It takes the configuration values from the APB registers and 
//              sensor data to automatically determine if the heater 
//              or cooler should be activated.
module temp_controller #(
  // Parameters
  parameter DATA_WIDTH = 8 // Data width for temperature and settings
) (
  // System interface
  input clk,                              // Internal clock for sequential logic
  input rst_n,                            // Asynchronous reset (active low)
  // Interface with the temperature sensor
  input [DATA_WIDTH-1:0] temp_now,        // Current temperature reading     
  input temp_valid,                       // Signal indicating that temp_now is valid
  // Interface with the actuators
  output reg heater_on,                   // Command to turn on the heater  
  output reg cooler_on,                   // Command to turn on the cooler
  // Configuration inputs received from the APB module registers
  input [DATA_WIDTH-1:0] target_temp,     // Target temperature to reach
  input [DATA_WIDTH-1:0] temp_tolerance,  // Accepted deviation from target_temp
  input [DATA_WIDTH-1:0] control_reg      // Special control bits (enable, override)
);

// Internal wires for mapping control bits and status flags
wire sys_enable, force_heat, force_cool;
wire temp_low, temp_deadband, temp_high;
wire [DATA_WIDTH-1:0] lower_threshold, upper_threshold;

// Extracting individual bits from the control register
assign sys_enable = control_reg[0]; // Bit 0: 1=System active, 0=System completely off
assign force_heat = control_reg[1]; // Bit 1: 1=Ignore sensor and force heater on
assign force_cool = control_reg[2]; // Bit 2: 1=Ignore sensor and force cooler on

// Calculating threshold limits based on the allowed tolerance
assign lower_threshold = target_temp - temp_tolerance; // Lower bound (minimum accepted temp)
assign upper_threshold = target_temp + temp_tolerance; // Upper bound (maximum accepted temp)

// Generating status flags by comparing the current temp against calculated limits
assign temp_low = (temp_now < lower_threshold);
assign temp_high = (temp_now > upper_threshold);
assign temp_deadband = ~(temp_low || temp_high); // Temperature is in the ideal range

// ------------------------------------------------------------------ //
// SystemVerilog Assertions (SVA) for functional verification
// ------------------------------------------------------------------ //

// Property: System disabled should turn off both actuators
property sys_disabled_turns_off_actuators;
  @(posedge clk) disable iff(!rst_n)
    (!sys_enable) |-> ##1 (!heater_on && !cooler_on);
endproperty

// Property: Force heat should turn on heater and turn off cooler
property force_heat_control;
  @(posedge clk) disable iff(!rst_n)
    (force_heat && sys_enable) |-> ##1 (heater_on && !cooler_on);
endproperty

// Property: Force cool should turn on cooler and turn off heater
property force_cool_control;
  @(posedge clk) disable iff(!rst_n)
    (force_cool && sys_enable && !force_heat) |-> ##1 (cooler_on && !heater_on);
endproperty

// Property: No simultaneous heating and cooling
property no_simultaneous_heat_cool;
  @(posedge clk) disable iff(!rst_n)
    not (heater_on && cooler_on);
endproperty

// Property: Automatic heating when temperature is low
property auto_heat_when_temp_low;
  @(posedge clk) disable iff(!rst_n)
    (sys_enable && !force_heat && !force_cool && temp_valid && temp_low) |-> ##1 heater_on;
endproperty

// Property: Automatic cooling when temperature is high
property auto_cool_when_temp_high;
  @(posedge clk) disable iff(!rst_n)
    (sys_enable && !force_heat && !force_cool && temp_valid && temp_high) |-> ##1 cooler_on;
endproperty

// Property: Turn off heater when temperature is not low anymore
property turn_off_heat_when_not_low;
  @(posedge clk) disable iff(!rst_n)
    (sys_enable && !force_heat && !force_cool && temp_valid && !temp_low) |-> ##1 !heater_on;
endproperty

// Property: Turn off cooler when temperature is not high anymore
property turn_off_cool_when_not_high;
  @(posedge clk) disable iff(!rst_n)
    (sys_enable && !force_heat && !force_cool && temp_valid && !temp_high) |-> ##1 !cooler_on;
endproperty

// Property: Reset should turn off both actuators
property reset_turns_off_actuators;
  @(posedge clk)
    (!rst_n) |=> (!heater_on && !cooler_on);
endproperty

// Assert the properties
sys_disabled_turns_off_actuators_a: assert property (sys_disabled_turns_off_actuators)
  else $error("[%0t][TEMP_CTRL] ERROR: System disabled but actuators not turned off", $time);

force_heat_control_a: assert property (force_heat_control)
  else $error("[%0t][TEMP_CTRL] ERROR: Force heat not working correctly", $time);

force_cool_control_a: assert property (force_cool_control)
  else $error("[%0t][TEMP_CTRL] ERROR: Force cool not working correctly", $time);

no_simultaneous_heat_cool_a: assert property (no_simultaneous_heat_cool)
  else $error("[%0t][TEMP_CTRL] ERROR: Simultaneous heating and cooling detected", $time);

auto_heat_when_temp_low_a: assert property (auto_heat_when_temp_low)
  else $error("[%0t][TEMP_CTRL] ERROR: Auto heat not activated when temp low", $time);

auto_cool_when_temp_high_a: assert property (auto_cool_when_temp_high)
  else $error("[%0t][TEMP_CTRL] ERROR: Auto cool not activated when temp high", $time);

turn_off_heat_when_not_low_a: assert property (turn_off_heat_when_not_low)
  else $error("[%0t][TEMP_CTRL] ERROR: Heater not turned off when temp not low", $time);

turn_off_cool_when_not_high_a: assert property (turn_off_cool_when_not_high)
  else $error("[%0t][TEMP_CTRL] ERROR: Cooler not turned off when temp not high", $time);

reset_turns_off_actuators_a: assert property (reset_turns_off_actuators)
  else $error("[%0t][TEMP_CTRL] ERROR: Reset did not turn off actuators", $time);

// ------------------------------------------------------------------ //
// Sequential logic for the Heater
// ------------------------------------------------------------------ //
always @(posedge clk or negedge rst_n)
  if (~rst_n)
    heater_on <= 1'b0;
  // If the entire system is disabled, force shutoff
  else if (~sys_enable)
    heater_on <= 1'b0;
  // High priority: manual heater override from control register
  else if (force_heat)
    heater_on <= 1'b1;
  // Safety interlock: if forcing cooling, ensure heating is off
  else if (force_cool)
    heater_on <= 1'b0;
  // Automatic operation logic (applied only when sensor data is valid)
  else if (temp_valid)
    if (temp_low)
      heater_on <= 1'b1; // Too cold, turn on the heater
    else
      heater_on <= 1'b0; // Not cold anymore, turn it off

// Sequential logic for the Cooler
always @(posedge clk or negedge rst_n)
  if (~rst_n)
    cooler_on <= 1'b0;
  // If the entire system is disabled, force shutoff
  else if (~sys_enable)
    cooler_on <= 1'b0;
  // Safety interlock: if forcing heating, ensure cooling is off
  else if (force_heat)
    cooler_on <= 1'b0;
  // Manual cooler override from control register
  else if (force_cool)
    cooler_on <= 1'b1;
  // Automatic operation logic (applied only when sensor data is valid)
  else if (temp_valid)
    if (temp_high)
      cooler_on <= 1'b1; // Too hot, turn on the cooler
    else
      cooler_on <= 1'b0; // Not hot anymore, turn it off

endmodule // temp_controller