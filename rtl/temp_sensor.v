// Module: temp_sensor
// Description: This module simulates a physical environment and a digital temperature sensor. 
//              It dynamically adjusts the temperature based on the heater/cooler status and  
//              generates periodic 'temp_valid' pulses to mimic a real ADC sampling rate.
module temp_sensor #(
  parameter DATA_WIDTH = 8,     // Data width for temperature
  parameter UPDATE_CYCLES = 10, // Number of clock cycles between temperature updates
  parameter AMBIENT_TEMP = 22   // Default room temperature the system drifts towards
) (
  // System interface
  input clk,                            // Internal clock
  input rst_n,                          // Asynchronous reset (active low)
  // Inputs from actuators
  input heater_on,                      // Indicates if the heater is actively warming
  input cooler_on,                      // Indicates if the cooler is actively chilling
  // Outputs to the controller
  output reg temp_valid,                // One-cycle pulse indicating a new temp sample
  output reg [DATA_WIDTH-1:0] temp_now  // The current simulated temperature
);

// Internal signals for timing
reg [DATA_WIDTH-1:0] delay_cnt; // Counter to track cycles between updates
wire update_temp; // Flag triggered when the counter reaches the limit

// Trigger the update pulse when the counter reaches the defined cycle limit
assign update_temp = (delay_cnt == UPDATE_CYCLES - 1);

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
  // Clear the valid pulse after one clock cycle
  else if (temp_valid)
    temp_valid <= 1'b0;
  // Assert valid pulse concurrently with the update trigger
  else if (update_temp)
    temp_valid <= 1'b1;
  else
    temp_valid <= 1'b0;

// Updating the physical temperature
always @(posedge clk or negedge rst_n)
  if (~rst_n)
    temp_now <= AMBIENT_TEMP;
  // If heater is on, increase temperature
  else if (update_temp && heater_on)
    temp_now <= temp_now + 1;
  // If cooler is on, decrease temperature
  else if (update_temp && cooler_on)
    temp_now <= temp_now - 1;
  // If both are off and it's colder than ambient, naturally warm up
  else if (update_temp && (temp_now < AMBIENT_TEMP))
    temp_now <= temp_now + 1;
  // If both are off and it's hotter than ambient, naturally cool down
  else if (update_temp && (temp_now > AMBIENT_TEMP))
    temp_now <= temp_now - 1;

endmodule // temp_sensor