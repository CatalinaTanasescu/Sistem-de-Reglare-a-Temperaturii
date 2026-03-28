class agent_apb extends uvm_agent;
  
  `uvm_component_utils(agent_apb)
  
  driver_agent_apb    apb_drv;
  monitor_apb         apb_mon;
  sequencer_apb       apb_seq; 
  coverage_apb        apb_cov;
  
  uvm_analysis_port #(tranzactie_apb) agent_port_apb;

  function new(string name = "agent_apb", uvm_component parent = null);
    super.new(name, parent);
  endfunction 

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agent_port_apb = new("agent_port_apb", this);
    apb_mon = monitor_apb::type_id::create("apb_mon", this);
    
    if (get_is_active() == UVM_ACTIVE) begin
      apb_seq = sequencer_apb::type_id::create("apb_seq", this);
      apb_drv = driver_agent_apb::type_id::create("apb_drv", this);
    end

    apb_cov = coverage_apb::type_id::create("apb_cov", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  
    apb_mon.item_collected_port.connect(this.agent_port_apb);
  
    if (get_is_active() == UVM_ACTIVE) begin
      apb_drv.seq_item_port.connect(apb_seq.seq_item_export);
    end
    
    apb_mon.item_collected_port.connect(apb_cov.apb_in);
  endfunction
  
endclass