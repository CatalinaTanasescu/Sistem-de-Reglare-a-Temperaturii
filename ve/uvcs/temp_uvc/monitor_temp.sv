`define TEMP_MON_CB temp_vif.monitor_mp.mon_ck

class monitor_temp extends uvm_monitor;

  `uvm_component_utils(monitor_temp)

  virtual temp_interface_dut temp_vif;
  uvm_analysis_port #(tranzactie_temp) item_collected_port;

  function new(string name = "monitor_temp", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual temp_interface_dut)::get(this, "", "temp_intf", temp_vif)) begin
      `uvm_fatal("TEMP_MON", "Nu s-a putut accesa interfata din config_db!")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      collect_transaction();
    end
  endtask

  task collect_transaction();
    tranzactie_temp tr;

    @(`TEMP_MON_CB);

    if (`TEMP_MON_CB.temp_valid === 1'b1) begin
      tr = tranzactie_temp::type_id::create("tr");

      tr.temp_now   = `TEMP_MON_CB.temp_now;
      tr.temp_valid = `TEMP_MON_CB.temp_valid;

      @(`TEMP_MON_CB);

      tr.heater_on  = `TEMP_MON_CB.heater_on;
      tr.cooler_on  = `TEMP_MON_CB.cooler_on;

      item_collected_port.write(tr);

      `uvm_info("TEMP_MON",
        $sformatf("Transfer TEMP detectat: Temp=%0d | Valid=%0b | Heater=%0b | Cooler=%0b",
                  tr.temp_now, tr.temp_valid, tr.heater_on, tr.cooler_on),
        UVM_HIGH)
    end
  endtask

endclass