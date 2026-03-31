`define APB_DRV_CB apb_vif.master_mp.mst_ck

class driver_agent_apb extends uvm_driver #(tranzactie_apb);
  
  `uvm_component_utils(driver_agent_apb)
  
  virtual apb_interface_dut apb_vif;

  function new(string name = "driver_agent_apb", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_interface_dut)::get(this, "", "apb_intf", apb_vif)) begin
      `uvm_fatal("DRV", "Nu s-a putut accesa interfata din config_db!")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    `APB_DRV_CB.psel    <= 0;
    `APB_DRV_CB.penable <= 0;

    forever begin
      seq_item_port.get_next_item(req);
      send_transaction(req);
      seq_item_port.item_done();
    end
  endtask

  task send_transaction(tranzactie_apb req);
    repeat(req.delay) @(`APB_DRV_CB);

    wait(apb_vif.rst_n === 1'b1);

    @(`APB_DRV_CB);
    `APB_DRV_CB.psel    <= 1'b1;
    `APB_DRV_CB.penable <= 1'b0;
    `APB_DRV_CB.paddr   <= req.addr;
    `APB_DRV_CB.pwrite  <= req.write;
    
    if (req.write)
      `APB_DRV_CB.pwdata <= req.data;

    @(`APB_DRV_CB);
    `APB_DRV_CB.penable <= 1'b1;
    
    do 
      @(`APB_DRV_CB);
    while (`APB_DRV_CB.pready !== 1'b1);

    `APB_DRV_CB.psel    <= 1'b0;
    `APB_DRV_CB.penable <= 1'b0;
    
  endtask

endclass : driver_agent_apb