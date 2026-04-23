interface apb_interface_dut (input logic pclk, input logic rst_n);
   logic  [2:0] paddr;  
   logic        psel;
   logic        penable;
   logic        pwrite;
   logic [31:0] pwdata;
   logic [31:0] prdata;
   logic        pready;
   logic        pslverr;

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

   // ------------------------------------------------------------------ //
   // X/HiZ checks
   // ------------------------------------------------------------------ //

   property psel_valid;
      @(posedge pclk) disable iff(rst_n === 1'b0)
         (psel !== 1'bx && psel !== 1'bz);
   endproperty

   property penable_valid;
      @(posedge pclk) disable iff(rst_n === 1'b0)
         (penable !== 1'bx && penable !== 1'bz);
   endproperty

   property pwrite_valid;
      @(posedge pclk) disable iff(rst_n === 1'b0)
         (pwrite !== 1'bx && pwrite !== 1'bz);
   endproperty

   property paddr_valid;
      @(posedge pclk) disable iff(rst_n === 1'b0)
         (psel |-> !$isunknown(paddr));
   endproperty

   property pwdata_valid;
      @(posedge pclk) disable iff(rst_n === 1'b0)
         (psel && pwrite && penable) |-> !$isunknown(pwdata);
   endproperty

   property prdata_valid;
      @(posedge pclk) disable iff(rst_n === 1'b0)
         (psel && !pwrite && pready) |-> !$isunknown(prdata);
   endproperty

   property pready_valid;
      @(posedge pclk) disable iff(rst_n === 1'b0)
         (penable |-> (pready !== 1'bx && pready !== 1'bz));
   endproperty

   property pslverr_valid;
      @(posedge pclk) disable iff(rst_n === 1'b0)
         (pready |-> (pslverr !== 1'bx && pslverr !== 1'bz));
   endproperty

   psel_valid_a: assert property (psel_valid)
      else $error("[%0t][APB_INTF] ERROR: psel is X/HiZ", $time);

   penable_valid_a: assert property (penable_valid)
      else $error("[%0t][APB_INTF] ERROR: penable is X/HiZ", $time);

   pwrite_valid_a: assert property (pwrite_valid)
      else $error("[%0t][APB_INTF] ERROR: pwrite is X/HiZ", $time);

   paddr_valid_a: assert property (paddr_valid)
      else $error("[%0t][APB_INTF] ERROR: paddr is X/HiZ during sel", $time);

   pwdata_valid_a: assert property (pwdata_valid)
      else $error("[%0t][APB_INTF] ERROR: pwdata is X/HiZ on write", $time);

   prdata_valid_a: assert property (prdata_valid)
      else $error("[%0t][APB_INTF] ERROR: prdata is X/HiZ on read", $time);

   pready_valid_a: assert property (pready_valid)
      else $error("[%0t][APB_INTF] ERROR: pready is X/HiZ", $time);

   pslverr_valid_a: assert property (pslverr_valid)
      else $error("[%0t][APB_INTF] ERROR: pslverr is X/HiZ", $time);

   // ------------------------------------------------------------------ //
   // Checks for protocol compliance
   // ------------------------------------------------------------------ //

   // penable check after 1 cycle of psel
   property penable_after_psel;
      @(posedge pclk) disable iff(rst_n === 1'b0)
         (psel && !penable) |=> penable;
   endproperty

   // during access, master should not change paddr/pwrite/pwdata
   property addr_stable_in_access;
      @(posedge pclk) disable iff(rst_n === 1'b0)
         (psel && penable && !pready) |=>
            ($stable(paddr) && $stable(pwrite));
   endproperty

   property wdata_stable_in_access;
      @(posedge pclk) disable iff(rst_n === 1'b0)
         (psel && penable && !pready && pwrite) |=> $stable(pwdata);
   endproperty

   // after access, penable should be deasserted
   property penable_deassert_after_access;
      @(posedge pclk) disable iff(rst_n === 1'b0)
         (psel && penable && pready) |=> !penable;
   endproperty

   penable_after_psel_a: assert property (penable_after_psel)
      else $error("[%0t][APB_INTF] ERROR: penable transition missing", $time);

   addr_stable_in_access_a: assert property (addr_stable_in_access)
      else $error("[%0t][APB_INTF] ERROR: paddr/pwrite changed during wait states", $time);

   wdata_stable_in_access_a: assert property (wdata_stable_in_access)
      else $error("[%0t][APB_INTF] ERROR: pwdata changed during wait states", $time);

   penable_deassert_after_access_a: assert property (penable_deassert_after_access)
      else $error("[%0t][APB_INTF] ERROR: penable not deasserted after access", $time);

endinterface