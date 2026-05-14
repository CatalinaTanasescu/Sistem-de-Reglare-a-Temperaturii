// Module: temp_system (Top-Level)
// Description: This is the top-level module that instantiates and 
//              connects all the submodules: the APB interface, the thermal 
//              controller, and the physical sensor simulator. 
//              It exposes the APB bus for communication and provides 
//              visibility to the internal sensor/actuator states.
module temp_system #(
  // Parameters 
  parameter DATA_WIDTH = 8,    // Data width
  parameter UPDATE_CYCLES = 10 // Cycles between sensor updates
) (
  // Global signals
  input clk,                        // System clock
  input rst_n,                      // Asynchronous reset, active low
  // APB Interface  
  input [2:0] paddr,                // Address of the register to be accessed
  input psel,                       // APB select signal
  input penable,                    // APB enable signal
  input pwrite,                     // Read/Write indicator (1=write, 0=read)
  input [DATA_WIDTH-1:0] pwdata,    // Input data to the system
  output [DATA_WIDTH-1:0] prdata,   // Output data from the system
  output pready,                    // System confirms APB access completion
  output pslverr,                   // System reports an APB error
  // Temperature Interface
  output [DATA_WIDTH-1:0] temp_now, // Temperature value read from sensor
  output temp_valid,                // Valid flag for temp_now data    
  output heater_on,                 // Command pin to the heater
  output cooler_on                  // Command pin to the cooler
);

// Valid temperature bounds
localparam TEMP_MIN = 15; // Minimum valid temperature — lower saturation bound
localparam TEMP_MAX = 30; // Maximum valid temperature — upper saturation bound

// Internal connection wires
wire [DATA_WIDTH-1:0] target_temp;   // APB addr 0 -> desired temperature setpoint
wire [DATA_WIDTH-1:0] temp_tolerance; // APB addr 1 -> accepted deviation from setpoint
wire [DATA_WIDTH-1:0] control_reg;   // APB addr 2 -> system enable and manual overrides
wire [DATA_WIDTH-1:0] ambient_temp;  // APB addr 3 -> environmental temperature for drift simulation

// Instantiation of the APB slave module
apb_regs #(
  .DATA_WIDTH (DATA_WIDTH),
  .TEMP_MIN (TEMP_MIN),
  .TEMP_MAX (TEMP_MAX)
) apb_inst(
  .pclk (clk),
  .preset_n (rst_n),
  .paddr (paddr),
  .psel (psel),
  .penable (penable),
  .pwrite (pwrite),
  .pwdata (pwdata),
  .prdata (prdata),
  .pready (pready),
  .pslverr (pslverr),
  .target_temp (target_temp),
  .temp_tolerance (temp_tolerance),
  .control_reg (control_reg),
  .ambient_temp (ambient_temp)
);

// Instantiation of the thermal control module
temp_controller #(
  .DATA_WIDTH (DATA_WIDTH),
  .TEMP_MIN (TEMP_MIN),
  .TEMP_MAX (TEMP_MAX)
) temp_ctrl_inst(
  .clk (clk),
  .rst_n (rst_n),
  .temp_now (temp_now),
  .temp_valid (temp_valid),
  .heater_on (heater_on),
  .cooler_on (cooler_on),
  .target_temp (target_temp),
  .temp_tolerance (temp_tolerance),
  .control_reg (control_reg)
);

// Instantiation of the simulated environment and digital sensor
temp_sensor #(
  .DATA_WIDTH (DATA_WIDTH),
  .UPDATE_CYCLES (UPDATE_CYCLES),
  .TEMP_MIN (TEMP_MIN),
  .TEMP_MAX (TEMP_MAX)
) temp_sensor_inst(
  .clk (clk),
  .rst_n (rst_n),
  .heater_on (heater_on),
  .cooler_on (cooler_on),
  .temp_valid (temp_valid),
  .temp_now (temp_now),
  .ambient_temp (ambient_temp)
);

endmodule //temp_system