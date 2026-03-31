// Module: temp_system (Top-Level)
// Description: This is the top-level module that instantiates and connects 
//              the two submodules. It exposes only the necessary external pins: 
//              the APB bus for communication, and the sensor/actuator pins.
module temp_system #(
  // Parameters 
  parameter DATA_WIDTH = 8 // Data width
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
  // Temperature Interace
  input [DATA_WIDTH-1:0] temp_now,  // Temperature value read from sensor
  input temp_valid,                 // Valid flag for temp_now data    
  output heater_on,                 // Command pin to the heater
  output cooler_on                  // Command pin to the cooler
);

// Internal connection wires
wire [DATA_WIDTH-1:0] target_temp; // The desired target temperature
wire [DATA_WIDTH-1:0] temp_tolerance; // The configured tolerance
wire [DATA_WIDTH-1:0] control_reg; // Special commands (disable, force)

// Instantiation of the APB slave module
apb_submodule apb_inst(
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
  .control_reg (control_reg)
);

// Instantiation of the thermal control module
temp_submodule temp_inst(
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

endmodule //temp_system