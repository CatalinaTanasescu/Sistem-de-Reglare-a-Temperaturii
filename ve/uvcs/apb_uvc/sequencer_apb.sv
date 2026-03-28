class sequencer_apb extends uvm_sequencer #(tranzactie_apb);

  `uvm_component_utils(sequencer_apb)

  function new(string name = "sequencer_apb", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass : sequencer_apb