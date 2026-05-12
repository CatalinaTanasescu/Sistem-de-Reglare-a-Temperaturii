typedef class sgt_env;

class sgt_vseqr extends uvm_sequencer;

  `uvm_component_utils(sgt_vseqr)

  uvm_sequencer #(tranzactie_apb) apb_seqr;
  sgt_env env;

  function new(string name = "sgt_vseqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!$cast(env, get_parent())) begin
      `uvm_error("CAST", "Could not cast to sgt_env")
    end
  endfunction

endclass : sgt_vseqr