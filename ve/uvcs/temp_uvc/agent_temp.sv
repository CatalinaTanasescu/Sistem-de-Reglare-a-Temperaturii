class agent_temp extends uvm_agent;

  `uvm_component_utils(agent_temp)

  monitor_temp  temp_mon;
  coverage_temp temp_cov;

  uvm_analysis_port #(tranzactie_temp) agent_port_temp;

  function new(string name = "agent_temp", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    temp_mon = monitor_temp::type_id::create("temp_mon", this);
    temp_cov = coverage_temp::type_id::create("temp_cov", this);

    agent_port_temp = new("agent_port_temp", this);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    temp_mon.item_collected_port.connect(agent_port_temp);
    temp_mon.item_collected_port.connect(temp_cov.temp_in);
  endfunction : connect_phase

endclass : agent_temp