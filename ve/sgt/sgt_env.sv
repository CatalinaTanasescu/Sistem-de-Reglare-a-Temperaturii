class sgt_env extends uvm_env;

  `uvm_component_utils(sgt_env)

  agent_apb  apb_agent;
  agent_temp temp_agent;

  sgt_vseqr v_sequencer;
  sgt_scbd  scoreboard;

  virtual apb_interface_dut  apb_vif;
  virtual temp_interface_dut temp_vif;
  virtual sgt_intf           sgt_vif;

  function new(string name = "sgt_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(virtual apb_interface_dut)::get(this, "", "apb_vif", apb_vif))
      `uvm_fatal(get_type_name(), "APB virtual interface not found in config_db!")

    if (!uvm_config_db #(virtual temp_interface_dut)::get(this, "", "temp_vif", temp_vif))
      `uvm_fatal(get_type_name(), "TEMP virtual interface not found in config_db!")

    if (!uvm_config_db #(virtual sgt_intf)::get(this, "", "sgt_vif", sgt_vif))
      `uvm_fatal(get_type_name(), "SGT virtual interface not found in config_db!")

    uvm_config_db #(virtual apb_interface_dut)::set(this, "apb_agent*", "apb_intf", apb_vif);
    uvm_config_db #(virtual temp_interface_dut)::set(this, "temp_agent*", "temp_intf", temp_vif);

    apb_agent   = agent_apb::type_id::create("apb_agent", this);
    temp_agent  = agent_temp::type_id::create("temp_agent", this);
    v_sequencer = sgt_vseqr::type_id::create("v_sequencer", this);
    scoreboard  = sgt_scbd::type_id::create("scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    v_sequencer.apb_seqr  = apb_agent.apb_seq; 

    apb_agent.agent_port_apb.connect(scoreboard.apb_mon_port);
    temp_agent.agent_port_temp.connect(scoreboard.temp_mon_port);
  endfunction

endclass : sgt_env