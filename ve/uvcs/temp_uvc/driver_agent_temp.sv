// driver_agent_temp — ELIMINAT
// Fisierul este pastrat doar pentru referinta istorica
// Driver-ul nu mai este instantiat — temp_sensor este intern in DUT
// temp_now si temp_valid sunt generate intern, nu conduse din testbench
//
// Pentru a reactiva in mod ACTIV: 
//   1. Readauga declaratia in agent_temp.sv
//   2. Instantiaza in build_phase cu get_is_active() == UVM_ACTIVE
//   3. Reconecteaza seq_item_port in connect_phase
