class sgt_basic_test extends sgt_base_test;

  `uvm_component_utils(sgt_basic_test)

  function new(string name = "sgt_basic_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_full_name(), "Build phase of sgt_basic_test started", UVM_LOW)

    uvm_config_wrapper::set(this, "env.v_sequencer.run_phase",
        "default_sequence",
        sgt_basic_vseq::type_id::get());
  endfunction

endclass : sgt_basic_test