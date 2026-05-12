class sgt_base_vseq extends uvm_sequence;

  `uvm_object_utils(sgt_base_vseq)
  `uvm_declare_p_sequencer(sgt_vseqr)

  function new(string name = "sgt_base_vseq");
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

endclass : sgt_base_vseq


class sgt_base_test_vseq extends sgt_base_vseq;

  `uvm_object_utils(sgt_base_test_vseq)

  localparam bit [2:0] TARGET_TEMP_ADDR = 3'b000;
  localparam bit [2:0] TOLERANCE_ADDR   = 3'b001;
  localparam bit [2:0] CONTROL_ADDR     = 3'b010;

  localparam int SYS_ENABLE_BIT = 0;
  localparam int FORCE_HEAT_BIT = 1;
  localparam int FORCE_COOL_BIT = 2;

  rand bit [7:0] target_temp;
  rand bit [7:0] tolerance;
  rand bit       sys_enable;
  rand bit       force_heat;
  rand bit       force_cool;
  rand int       delay;

  apb_seq apb_sequence;

  function new(string name = "sgt_base_test_vseq");
    super.new(name);
  endfunction : new

  constraint good_values_c {
    soft target_temp inside {[20:30]};
    soft tolerance   inside {[1:5]};
    soft sys_enable  == 1'b1;
    soft delay inside {[0:5]};
  }

  task pre_body();
    super.pre_body();

    if (!this.randomize()) begin
      `uvm_error(get_type_name(), "Randomization failed!")
    end
  endtask : pre_body

  virtual task apb_write(bit [2:0] addr, bit [31:0] data);
    apb_sequence = apb_seq::type_id::create("apb_sequence");

    apb_sequence.addr  = addr;
    apb_sequence.data  = data;
    apb_sequence.write = 1'b1;
    apb_sequence.delay = delay;

    apb_sequence.start(p_sequencer.apb_seqr);
  endtask : apb_write

  virtual task apb_read(bit [2:0] addr);
    apb_sequence = apb_seq::type_id::create("apb_sequence");

    apb_sequence.addr  = addr;
    apb_sequence.data  = '0;
    apb_sequence.write = 1'b0;
    apb_sequence.delay = delay;

    apb_sequence.start(p_sequencer.apb_seqr);
  endtask : apb_read

  virtual task write_target_temp(bit [7:0] value);
    apb_write(TARGET_TEMP_ADDR, {24'b0, value});
  endtask : write_target_temp

  virtual task write_tolerance(bit [7:0] value);
    apb_write(TOLERANCE_ADDR, {24'b0, value});
  endtask : write_tolerance

  virtual task write_control(bit sys_enable_value,
                             bit force_heat_value,
                             bit force_cool_value);
    bit [31:0] control_value;

    control_value = '0;
    control_value[SYS_ENABLE_BIT] = sys_enable_value;
    control_value[FORCE_HEAT_BIT] = force_heat_value;
    control_value[FORCE_COOL_BIT] = force_cool_value;

    apb_write(CONTROL_ADDR, control_value);
  endtask : write_control

  virtual task read_all_registers();
    apb_read(TARGET_TEMP_ADDR);
    apb_read(TOLERANCE_ADDR);
    apb_read(CONTROL_ADDR);
  endtask : read_all_registers

endclass : sgt_base_test_vseq


class sgt_basic_vseq extends sgt_base_test_vseq; // todo modify this according to the desired behavior

  `uvm_object_utils(sgt_basic_vseq)

  function new(string name = "sgt_basic_vseq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Executing sgt_basic_vseq", UVM_NONE)

    read_all_registers();

    write_target_temp(8'd25);
    write_tolerance(8'd2);
    write_control(1'b1, 1'b0, 1'b0);

    read_all_registers();

    repeat (50) begin
      @(p_sequencer.env.sgt_vif.clk);
    end

    write_control(1'b1, 1'b1, 1'b0);

    repeat (30) begin
      @(p_sequencer.env.sgt_vif.clk);
    end

    write_control(1'b1, 1'b0, 1'b1);

    repeat (30) begin
      @(p_sequencer.env.sgt_vif.clk);
    end

    write_control(1'b0, 1'b0, 1'b0);

    repeat (30) begin
      @(p_sequencer.env.sgt_vif.clk);
    end

    write_control(1'b1, 1'b0, 1'b0);

    repeat (50) begin
      @(p_sequencer.env.sgt_vif.clk);
    end

    read_all_registers();

  endtask : body

endclass : sgt_basic_vseq