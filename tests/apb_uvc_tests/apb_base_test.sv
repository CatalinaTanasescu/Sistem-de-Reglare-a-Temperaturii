class apb_base_test extends uvm_test;

  `uvm_component_utils(apb_base_test)

  apb_env apb_environment;

  function new(string name = "apb_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_full_name(), "Build phase of base test started apb_base_test", UVM_LOW)

    apb_environment = apb_env::type_id::create("apb_environment", this);

    `uvm_info(get_full_name(), "Build phase of base test completed", UVM_LOW)
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this, 200ns);
    @(posedge apb_environment.apb_vif.rst_n);
    #10ns;
    phase.drop_objection(this);
  endtask : run_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_type_name(), {"Start of simulation for ", get_full_name()}, UVM_HIGH);
  endfunction : start_of_simulation_phase

endclass : apb_base_test
