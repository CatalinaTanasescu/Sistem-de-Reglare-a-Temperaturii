class tranzactie_temp extends uvm_sequence_item;

  bit [7:0] temp_now;
  bit       temp_valid;
  bit       heater_on;
  bit       cooler_on;

  `uvm_object_utils_begin(tranzactie_temp)
    `uvm_field_int(temp_now,    UVM_ALL_ON)
    `uvm_field_int(temp_valid,  UVM_ALL_ON)
    `uvm_field_int(heater_on,   UVM_ALL_ON)
    `uvm_field_int(cooler_on,   UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "tranzactie_temp");
    super.new(name);
  endfunction

endclass : tranzactie_temp