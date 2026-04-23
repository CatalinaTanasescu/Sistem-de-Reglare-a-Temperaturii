class apb_env extends uvm_env;

  `uvm_component_utils(apb_env)

  agent_apb        apb_agent;
  virtual apb_interface_dut apb_vif;

  function new(string name = "apb_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(virtual apb_interface_dut)::get(this, "", "apb_intf", apb_vif))
      `uvm_fatal(get_type_name(), "Virtual APB interface not passed!")
    uvm_config_db #(virtual apb_interface_dut)::set(this, "apb_agent", "apb_intf", apb_vif);

    apb_agent = agent_apb::type_id::create("apb_agent", this);
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), "Report phase of apb_env", UVM_LOW)
  endfunction

endclass : apb_env