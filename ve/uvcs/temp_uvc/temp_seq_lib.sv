class temp_base_seq extends uvm_sequence #(tranzactie_temp);

  `uvm_object_utils(temp_base_seq)

  function new(string name = "temp_base_seq");
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

endclass : temp_base_seq


class temp_seq extends temp_base_seq;

  `uvm_object_utils(temp_seq)

  rand bit [7:0] temp_now;
  rand bit       temp_valid;
  rand int       delay;

  constraint c_delay { delay inside {[0:5]}; }

  function new(string name = "temp_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Executing %s sequence", get_type_name()), UVM_LOW)
    `uvm_do_with(req, {
      req.temp_now   == local::temp_now;
      req.temp_valid == local::temp_valid;
      req.delay      == local::delay;
    })
    `uvm_info(get_type_name(), $sformatf("%s sent", get_type_name()), UVM_LOW)
  endtask

endclass : temp_seq

// class temp_base_test_seq extends temp_base_seq;

//   `uvm_object_utils(temp_base_test_seq)

//   rand int unsigned iterations;

//   temp_seq temp_sequence;

//   function new(string name = "temp_base_test_seq");
//     super.new(name);
//   endfunction

//   constraint max_iterations_c {soft iterations inside {[5:20]};}

// endclass : temp_base_test_seq


// class temp_single_seq extends temp_base_test_seq;

//   `uvm_object_utils(temp_single_seq)

//   function new(string name = "temp_single_seq");
//     super.new(name);
//   endfunction

//   virtual task body();
//     `uvm_info(get_type_name(), "Executing temp_single_seq", UVM_LOW)
//     `uvm_do(temp_sequence);
//   endtask

// endclass : temp_single_seq


// class temp_random_seq extends temp_base_test_seq;

//   `uvm_object_utils(temp_random_seq)

//   function new(string name = "temp_random_seq");
//     super.new(name);
//   endfunction

//   virtual task body();
//     `uvm_info(get_type_name(), "Executing temp_random_seq", UVM_LOW)
//     repeat(iterations) begin
//       `uvm_do(temp_sequence);
//     end 
//   endtask

// endclass : temp_random_seq