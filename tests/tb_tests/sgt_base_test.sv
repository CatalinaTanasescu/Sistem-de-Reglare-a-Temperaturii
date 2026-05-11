class sgt_base_test extends uvm_test;

  `uvm_component_utils(sgt_base_test)

  sgt_env env;

  function new(string name = "sgt_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = sgt_env::type_id::create("env", this);
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Start of simulation for %s", get_full_name()), UVM_NONE)
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this, 200ns);
    phase.drop_objection(this);
  endtask

  function void check_phase(uvm_phase phase);
    check_config_usage();
  endfunction

  function void report_phase(uvm_phase phase);
    uvm_report_server svr = uvm_report_server::get_server();
    if (svr.get_severity_count(UVM_ERROR) > 0 || svr.get_severity_count(UVM_FATAL) > 0)
      `uvm_info(get_type_name(), "===== TEST FAILED =====", UVM_NONE)
    else
      `uvm_info(get_type_name(), "===== TEST PASSED =====", UVM_NONE)
  endfunction

endclass : sgt_base_test