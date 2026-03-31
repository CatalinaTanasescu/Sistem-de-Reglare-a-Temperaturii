class apb_base_seq extends uvm_sequence #(tranzactie_apb);

  `uvm_object_utils(apb_base_seq)

  function new(string name="apb_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    uvm_phase phase;
      `ifdef UVM_VERSION_1_2
    phase = get_starting_phase();
      `else
    phase = starting_phase;
      `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  task post_body();
    uvm_phase phase;
      `ifdef UVM_VERSION_1_2
    phase = get_starting_phase();
      `else
    phase = starting_phase;
      `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass : apb_base_seq

class apb_seq extends apb_base_seq;

  `uvm_object_utils(apb_seq)

  rand bit [2:0]  addr;
  rand bit [31:0] data; 
  rand bit        write;
  rand int        delay;

  function new(string name="apb_seq");
    super.new(name);
  endfunction

  constraint c_delay {delay inside {[0:10]};}

  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Executing %s sequence", get_type_name()), UVM_LOW)
    `uvm_do_with(req, {
        req.addr  == local::addr;
        req.data  == local::data;
        req.write == local::write;
        req.delay == local::delay;
      })
    `uvm_info(get_type_name(), $sformatf("%s sent", get_type_name()), UVM_LOW) 
  endtask

endclass : apb_seq

class apb_base_test_seq extends apb_base_seq;

  `uvm_object_utils(apb_base_test_seq)

  rand int unsigned iterations;

  apb_seq apb_sequence;

  function new(string name="apb_base_test_seq");
    super.new(name);
  endfunction

  constraint max_iterations_c {soft iterations inside {[10:20]};}

endclass : apb_base_test_seq

class apb_single_seq extends apb_base_test_seq;

  `uvm_object_utils(apb_single_seq)

  function new(string name="apb_single_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing apb_single_seq", UVM_LOW)
    `uvm_do(apb_sequence);
  endtask

endclass : apb_single_seq

class apb_random_seq extends apb_base_test_seq;

  `uvm_object_utils(apb_random_seq)

  function new(string name="apb_random_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing apb_random_seq", UVM_LOW)
    repeat(iterations) begin
      `uvm_do(apb_sequence);
    end
  endtask

endclass : apb_random_seq