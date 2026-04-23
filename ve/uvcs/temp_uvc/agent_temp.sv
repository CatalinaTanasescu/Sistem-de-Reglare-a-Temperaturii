class agent_temp extends uvm_agent;

  `uvm_component_utils(agent_temp)

  driver_agent_temp   temp_drv;
  monitor_temp        temp_mon;
  sequencer_temp      temp_seq;
  coverage_temp       temp_cov;

  uvm_analysis_port #(tranzactie_temp) agent_port_temp;

  function new(string name = "agent_temp", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent_port_temp = new("agent_port_temp", this);
    temp_mon = monitor_temp::type_id::create("temp_mon", this);

    if (get_is_active() == UVM_ACTIVE) begin
      temp_seq = sequencer_temp::type_id::create("temp_seq", this);
      temp_drv = driver_agent_temp::type_id::create("temp_drv", this);
    end

    temp_cov = coverage_temp::type_id::create("temp_cov", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    temp_mon.item_collected_port.connect(this.agent_port_temp);

    if (get_is_active() == UVM_ACTIVE) begin
      temp_drv.seq_item_port.connect(temp_seq.seq_item_export);
    end

    temp_mon.item_collected_port.connect(temp_cov.temp_in);
  endfunction

endclass