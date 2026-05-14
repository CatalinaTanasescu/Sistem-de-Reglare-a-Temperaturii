// Module: apb_regs
// Description: This module implements an APB slave interface. 
//              Its role is to allow a master to configure the system registers 
//              (target temperature, tolerance, manual control) 
//              and read their current values.
module apb_regs #(
  // Parameters
  parameter DATA_WIDTH = 8, // Width of the data bus and registers
  parameter TEMP_MIN = 15,  // Minimum valid temperature
  parameter TEMP_MAX = 30   // Maximum valid temperature
) (
  // Standard APB Interface
  input pclk,                                 // APB bus clock
  input preset_n,                             // Asynchronous APB reset (active low)
  input [2:0] paddr,                          // Address bus (3 bits, allows 8 addresses)
  input psel,                                 // Slave select signal
  input penable,                              // Enable signal (access phase indicator)
  input pwrite,                               // Transfer direction: 1 = write, 0 = read
  input [DATA_WIDTH-1:0] pwdata,              // Write data from master
  output reg [DATA_WIDTH-1:0] prdata,         // Read data sent back to master
  output reg pready,                          // Ready signal, slave has completed the transaction
  output reg pslverr,                         // Error signal, asserted on invalid address access
  // Output interface to the temperature logic
  output reg [DATA_WIDTH-1:0] target_temp,    // Address 0: Desired target temperature
  output reg [DATA_WIDTH-1:0] temp_tolerance, // Address 1: Allowed margin of error / Deadband
  output reg [DATA_WIDTH-1:0] control_reg,    // Address 2: Control register (enable, force_heat, force_cool)
  output reg [DATA_WIDTH-1:0] ambient_temp    // Address 3: Default environmental temperature
);

localparam [DATA_WIDTH-1:0] TOL_MAX = 5; // Max 5 degrees Celsius deadband

// Clamps pwdata to [TEMP_MIN, TEMP_MAX] for temperature registers 
// and to [0, TOL_MAX] for the tolerance register
wire [DATA_WIDTH-1:0] valid_value, valid_tol;

assign valid_value = (pwdata > TEMP_MAX) ? TEMP_MAX : // Overflow check
                     (pwdata < TEMP_MIN) ? TEMP_MIN : // Underflow check
                      pwdata;                         // Keep value unchanged      

assign valid_tol = (pwdata > TOL_MAX) ? TOL_MAX : pwdata; // Overflow check

// Bus error signal generation (pslverr)
always @(posedge pclk or negedge preset_n)
  if (~preset_n)
    pslverr <= 1'b0;
  // Pulse condition
  else if (pslverr == 1)
    pslverr <= 0;
  // Assert error if the address is greater than 3 (valid addresses are 0, 1, 2, 3)
  else if (psel && ~penable && paddr > 3'b011)
    pslverr <= 1'b1;

// Transfer ready signal generation (pready)
always @(posedge pclk or negedge preset_n)
  if (~preset_n)
    pready <= 1'b0;
  // Pulse condition
  else if (pready == 1)
    pready <= 0;
  // No delay for pready
  else if (psel && ~penable)
    pready <= 1'b1;

// Register read logic
always @(posedge pclk or negedge preset_n)
  if (~preset_n)
    prdata <= 'b0;
  // If it is a valid read transaction
  else if (psel && ~penable && ~pwrite)
    case (paddr)
      3'b000: prdata <= target_temp;
      3'b001: prdata <= temp_tolerance;
      3'b010: prdata <= control_reg;
      3'b011: prdata <= ambient_temp;
      default: prdata <= 'b0; // Invalid address returns 0
    endcase

// Register write logic
always @(posedge pclk or negedge preset_n)
  if (~preset_n) begin
    // Default values for system reset
    target_temp <= 'd25;
    temp_tolerance <= 'd2;
    control_reg <= 'd1; // System enabled by default (control_reg[0]=1)
    ambient_temp <= 'd22;
  end
  // If it is a valid write transaction
  else if (psel && ~penable && pwrite)
    case (paddr)
      3'b000: target_temp <= valid_value;
      3'b001: temp_tolerance <= valid_tol;
      3'b010: control_reg <= pwdata;
      3'b011: ambient_temp <= valid_value;
      default: ;  // Ignore writes to invalid addresses
    endcase

endmodule //apb_regs