`define APB_MON_CB apb_vif.monitor_mp.mon_ck

class monitor_apb extends uvm_monitor;

  `uvm_component_utils(monitor_apb)

  virtual apb_interface_dut apb_vif;
  
  uvm_analysis_port #(tranzactie_apb) item_collected_port;

  function new(string name = "monitor_apb", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_interface_dut)::get(this, "", "apb_intf", apb_vif)) begin
      `uvm_fatal("MON", "Nu s-a putut accesa interfata din config_db!")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      collect_transaction();
    end
  endtask

  task collect_transaction();
    tranzactie_apb tr;

    @(posedge apb_vif.pclk);
    
    if (`APB_MON_CB.psel === 1'b1 && `APB_MON_CB.penable === 1'b1 && `APB_MON_CB.pready === 1'b1) begin

      tr = tranzactie_apb::type_id::create("tr");
      tr.addr  = `APB_MON_CB.paddr;
      tr.write = `APB_MON_CB.pwrite;
      
      if (tr.write) begin
        tr.data = `APB_MON_CB.pwdata; 
      end else begin
        tr.data = `APB_MON_CB.prdata; 
      end

      item_collected_port.write(tr);
      
      `uvm_info("MON", $sformatf("Transfer APB detectat: Addr=%0h, Data=%0h, Write=%0b", tr.addr, tr.data, tr.write), UVM_HIGH)
    end
  endtask

endclass

