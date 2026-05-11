`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_temp)

class sgt_scbd extends uvm_scoreboard;

  `uvm_component_utils(sgt_scbd)

  uvm_analysis_imp_apb  #(tranzactie_apb,  sgt_scbd) apb_mon_port;
  uvm_analysis_imp_temp #(tranzactie_temp, sgt_scbd) temp_mon_port;

  bit [7:0] reg_target_temp  = 8'd25;
  bit [7:0] reg_tolerance    = 8'd2;
  bit [7:0] reg_control      = 8'd1;

  int transactions_scbd = 0;
  int matches_scbd      = 0;
  int mismatches_scbd   = 0;

  function new(string name = "sgt_scbd", uvm_component parent = null);
    super.new(name, parent);
    apb_mon_port  = new("apb_mon_port",  this);
    temp_mon_port = new("temp_mon_port", this);
  endfunction

  function void write_apb(tranzactie_apb tr);
    if (tr.write) begin
      case (tr.addr)
        3'b000: reg_target_temp = tr.data[7:0];
        3'b001: reg_tolerance   = tr.data[7:0];
        3'b010: reg_control     = tr.data[7:0];
      endcase
      `uvm_info(get_type_name(), $sformatf("APB WRITE: addr=%0h data=%0h | Model: target=%0d tol=%0d ctrl=%0h",
                tr.addr, tr.data, reg_target_temp, reg_tolerance, reg_control), UVM_LOW)
    end else begin
      bit [7:0] expected;
      case (tr.addr)
        3'b000: expected = reg_target_temp;
        3'b001: expected = reg_tolerance;
        3'b010: expected = reg_control;
        default: expected = 8'h0;
      endcase
      transactions_scbd++;
      if (tr.data[7:0] == expected) begin
        matches_scbd++;
        `uvm_info(get_type_name(), $sformatf("APB READ MATCH: addr=%0h expected=%0h got=%0h",
                  tr.addr, expected, tr.data[7:0]), UVM_LOW)
      end else begin
        mismatches_scbd++;
        `uvm_error(get_type_name(), $sformatf("APB READ MISMATCH: addr=%0h expected=%0h got=%0h",
                   tr.addr, expected, tr.data[7:0]))
      end
    end
  endfunction

  function void write_temp(tranzactie_temp tr);
    bit exp_heater, exp_cooler;
    bit sys_enable, force_heat, force_cool;
    bit [7:0] lower_thresh, upper_thresh;

    sys_enable = reg_control[0];
    force_heat = reg_control[1];
    force_cool = reg_control[2];
    lower_thresh = reg_target_temp - reg_tolerance;
    upper_thresh = reg_target_temp + reg_tolerance;

    if (!sys_enable) begin
      exp_heater = 0;
      exp_cooler = 0;
    end else if (force_heat) begin
      exp_heater = 1;
      exp_cooler = 0;
    end else if (force_cool) begin
      exp_heater = 0;
      exp_cooler = 1;
    end else begin
      exp_heater = (tr.temp_now < lower_thresh);
      exp_cooler = (tr.temp_now > upper_thresh);
    end

    transactions_scbd++;
    if (tr.heater_on == exp_heater && tr.cooler_on == exp_cooler) begin
      matches_scbd++;
      `uvm_info(get_type_name(), $sformatf("TEMP MATCH: temp=%0d | heater: exp=%0b got=%0b | cooler: exp=%0b got=%0b",
                tr.temp_now, exp_heater, tr.heater_on, exp_cooler, tr.cooler_on), UVM_LOW)
    end else begin
      mismatches_scbd++;
      `uvm_error(get_type_name(), $sformatf("TEMP MISMATCH: temp=%0d | heater: exp=%0b got=%0b | cooler: exp=%0b got=%0b | target=%0d tol=%0d ctrl=%0h",
                 tr.temp_now, exp_heater, tr.heater_on, exp_cooler, tr.cooler_on,
                 reg_target_temp, reg_tolerance, reg_control))
    end
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("\n\tNumber of mismatches = %0d, \n\tNumber of matches = %0d, \n\tTotal transactions = %0d\n\t",
              mismatches_scbd, matches_scbd, transactions_scbd), UVM_LOW)
  endfunction

endclass : sgt_scbd

// todo posibil issue, timing (dacă APB write-ul și temp_valid vin aproape simultan, modelul s-ar putea să nu fie actualizat încă)