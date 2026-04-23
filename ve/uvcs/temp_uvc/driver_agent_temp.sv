`define TEMP_DRV_CB temp_vif.driver_mp.drv_ck

class driver_agent_temp extends uvm_driver #(tranzactie_temp);

  `uvm_component_utils(driver_agent_temp)

  virtual temp_interface_dut temp_vif;

  function new(string name = "driver_agent_temp", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual temp_interface_dut)::get(this, "", "temp_intf", temp_vif)) begin
      `uvm_fatal("TEMP_DRV", "Nu s-a putut accesa interfata din config_db!")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    `TEMP_DRV_CB.temp_now   <= 8'h00;
    `TEMP_DRV_CB.temp_valid <= 1'b0;

    forever begin
      seq_item_port.get_next_item(req);
      send_transaction(req);
      seq_item_port.item_done();
    end
  endtask

  task send_transaction(tranzactie_temp req);
    repeat(req.delay) @(`TEMP_DRV_CB);

    wait(temp_vif.rst_n === 1'b1);

    @(`TEMP_DRV_CB);
    `TEMP_DRV_CB.temp_now   <= req.temp_now;
    `TEMP_DRV_CB.temp_valid <= req.temp_valid;

    @(`TEMP_DRV_CB);
    `TEMP_DRV_CB.temp_valid <= 1'b0;

  endtask

endclass : driver_agent_temp