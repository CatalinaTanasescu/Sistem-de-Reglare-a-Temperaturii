class sequencer_temp extends uvm_sequencer #(tranzactie_temp);

  `uvm_component_utils(sequencer_temp)

  function new(string name = "sequencer_temp", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass : sequencer_temp