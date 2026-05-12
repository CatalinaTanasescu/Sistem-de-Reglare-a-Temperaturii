class coverage_temp extends uvm_component;

  `uvm_component_utils(coverage_temp)

  `uvm_analysis_imp_decl(_temp)
  uvm_analysis_imp_temp #(tranzactie_temp, coverage_temp) temp_in;

  covergroup cg_temp_item with function sample(tranzactie_temp item);
    option.per_instance = 1;
    option.name = "TEMP Transaction Coverage";

    TEMP_ZONE: coverpoint item.temp_now {
      bins temp_low    = {[0:84]};
      bins temp_medium = {[85:170]};
      bins temp_high   = {[171:255]};
    }

    ACTUATORS: coverpoint {item.heater_on, item.cooler_on} {
      bins both_off    = {2'b00};
      bins heater_only = {2'b10};
      bins cooler_only = {2'b01};
      illegal_bins both_on = {2'b11};
    }

    cx_zone_x_actuator: cross TEMP_ZONE, ACTUATORS;

  endgroup : cg_temp_item

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_temp_item = new();
    temp_in = new("temp_in", this);
  endfunction

  virtual function void write_temp(tranzactie_temp t);
    cg_temp_item.sample(t);

    `uvm_info("TEMP_COV",
      $sformatf("Sampled: Temp=%0d | Valid=%0b | Heater=%0b | Cooler=%0b | Coverage: %0.2f%%",
                t.temp_now, t.temp_valid, t.heater_on, t.cooler_on,
                cg_temp_item.get_inst_coverage()),
      UVM_LOW)
  endfunction : write_temp

endclass : coverage_temp