class coverage_apb extends uvm_component;

    `uvm_component_utils(coverage_apb)

    `uvm_analysis_imp_decl(_apb)
    uvm_analysis_imp_apb#(tranzactie_apb, coverage_apb) apb_in;

    covergroup cg_apb_item with function sample(tranzactie_apb item);
        option.per_instance = 1;
        option.name = "APB Transaction Coverage";

        ADDR: coverpoint item.addr {
            bins all_addresses[] = {[0:7]};
        }

        RW_TYPE: coverpoint item.write {
            bins write = {1};
            bins read  = {0};
        }

        DATA: coverpoint item.data {
            bins min_val = {32'h0};
            bins low_vals = {[32'h1 : 32'h0000_FFFF]};
            bins mid_vals = {[32'h0010_0000 : 32'hFFFF_FFFE]};
            bins max_val = {32'hFFFF_FFFF};
        }

        cx_addr_rw: cross ADDR, RW_TYPE;

    endgroup : cg_apb_item

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_apb_item = new();
        apb_in = new("apb_in", this);
    endfunction

    virtual function void write_apb(tranzactie_apb t);
        cg_apb_item.sample(t);
        `uvm_info("COV", $sformatf("Sampled: Addr=%0h, Write=%0b. Coverage curent: %0.2f%%", 
                  t.addr, t.write, cg_apb_item.get_inst_coverage()), UVM_LOW)
    endfunction : write_apb

endclass : coverage_apb