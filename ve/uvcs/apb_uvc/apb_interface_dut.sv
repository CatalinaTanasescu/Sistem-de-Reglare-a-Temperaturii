interface apb_interface_dut (input logic pclk, input logic rst_n);
   logic  [2:0] paddr;  
   logic        psel;
   logic        penable;
   logic        pwrite;
   logic [31:0] pwdata;
   logic [31:0] prdata;
   logic        pready;
   // posibil perr 

   clocking mst_ck @(posedge pclk);
      default input #1ns output #1ns;
      output paddr, psel, penable, pwrite, pwdata;
      input  prdata, pready;
   endclocking

   clocking mon_ck @(posedge pclk);
      default input #1ns output #1ns;
      input paddr, psel, penable, pwrite, pwdata, prdata, pready;
   endclocking

   modport master_mp (clocking mst_ck, input pclk, rst_n);
   modport monitor_mp (clocking mon_ck, input pclk, rst_n);

endinterface