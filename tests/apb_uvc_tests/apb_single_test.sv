class apb_single_test extends apb_base_test;

  `uvm_component_utils(apb_single_test)

  function new(string name = "apb_single_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_full_name(), "Build phase of apb_single_test started", UVM_LOW)

    uvm_config_wrapper::set(this, "apb_env.v_sequencer.run_phase",
      "default_sequence",
      apb_single_seq::type_id::get());

  endfunction : build_phase

endclass: apb_single_test