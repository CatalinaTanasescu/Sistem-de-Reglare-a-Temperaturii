class tranzactie_apb extends uvm_sequence_item;

  // todo add delay + coverage + pus in driver 
  
  rand bit [2:0]  addr;
  rand bit [31:0] data; 
  rand bit        write; 

  `uvm_object_utils_begin(tranzactie_apb)
    `uvm_field_int(addr,  UVM_ALL_ON)
    `uvm_field_int(data,  UVM_ALL_ON)
    `uvm_field_int(write, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "tranzactie_apb");
    super.new(name);
  endfunction

endclass : tranzactie_apb