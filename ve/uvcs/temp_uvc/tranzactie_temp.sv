class tranzactie_temp extends uvm_sequence_item;

  rand bit [7:0] temp_now;
  rand bit       temp_valid;
  rand int       delay;

  // read-only, capturate de monitor
  bit heater_on;
  bit cooler_on;

  `uvm_object_utils_begin(tranzactie_temp)
    `uvm_field_int(temp_now,   UVM_ALL_ON)
    `uvm_field_int(temp_valid, UVM_ALL_ON)
    `uvm_field_int(delay,      UVM_ALL_ON)
    `uvm_field_int(heater_on,  UVM_ALL_ON)
    `uvm_field_int(cooler_on,  UVM_ALL_ON)
  `uvm_object_utils_end

  constraint c_delay     {delay inside {[0:5]};}
  constraint c_temp_range {temp_now inside {[0:255]};}

  function new(string name = "tranzactie_temp");
    super.new(name);
  endfunction

endclass : tranzactie_temp