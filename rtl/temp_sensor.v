// Module: temp_sensor
// Description: This module simulates a physical environment and a digital temperature sensor. 
//              It dynamically adjusts the temperature based on the heater/cooler status and  
//              generates periodic 'temp_valid' pulses to mimic a real ADC sampling rate.
module temp_sensor #(
  parameter DATA_WIDTH = 8,     // Data width for temperature
  parameter UPDATE_CYCLES = 10, // Number of clock cycles between temperature updates
  parameter TEMP_MIN = 15,      // Minimum valid temperature
  parameter TEMP_MAX = 30       // Maximum valid temperature
) (
  // System interface
  input clk,                           // Internal clock
  input rst_n,                         // Asynchronous reset (active low)
  // Inputs from actuators
  input heater_on,                     // Indicates if the heater is actively warming
  input cooler_on,                     // Indicates if the cooler is actively cooling
  input [DATA_WIDTH-1:0] ambient_temp, // Default environmental temperature
  // Outputs to the controller
  output reg temp_valid,               // One-cycle pulse indicating a new temp sample
  output reg [DATA_WIDTH-1:0] temp_now // The current simulated temperature
);

localparam RESET_TEMP = 22; // Initial temperature at system startup

// Internal signals for timing
reg [$clog2(UPDATE_CYCLES)-1:0] delay_cnt; // Counter to track cycles between updates
wire update_temp; // Flag triggered when the counter reaches the limit

// Intermediate wires for increment/decrement
wire [DATA_WIDTH-1:0] temp_inc, temp_dec;

// Trigger the update pulse when the counter reaches the defined cycle limit
assign update_temp = (delay_cnt == UPDATE_CYCLES - 1);

// Clamped increment — prevents temp_now from exceeding TEMP_MAX
assign temp_inc = (temp_now + 1 > TEMP_MAX) ? TEMP_MAX : temp_now + 1;
// Clamped decrement — prevents temp_now from dropping below TEMP_MIN
assign temp_dec = (temp_now - 1 < TEMP_MIN) ? TEMP_MIN : temp_now - 1;

// Counter logic for sampling frequency
always @(posedge clk or negedge rst_n)
  if (~rst_n)
    delay_cnt <= 'b0;
  // Reset counter when an update occurs
  else if (update_temp)
    delay_cnt <= 'b0;
  // Increment counter otherwise
  else
    delay_cnt <= delay_cnt + 1;

// Generation of the 'temp_valid' pulse for the controller
always @(posedge clk or negedge rst_n)
  if (~rst_n)
    temp_valid <= 1'b0;
  else
    temp_valid <= update_temp;

// Updating the physical temperature
always @(posedge clk or negedge rst_n)
  if (~rst_n)
    temp_now <= RESET_TEMP;
  else if (update_temp)
    // If heater is on, increase temperature
    if (heater_on)
      temp_now <= temp_inc;
    // If cooler is on, decrease temperature
    else if (cooler_on)
      temp_now <= temp_dec;
    // If both are off and it's colder than ambient, naturally warm up
    else if (temp_now < ambient_temp)
      temp_now <= temp_inc;
    // If both are off and it's hotter than ambient, naturally cool down
    else if (temp_now > ambient_temp)
      temp_now <= temp_dec;

endmodule // temp_sensor