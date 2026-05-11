# Modificări pentru Transformarea Temp UVC din Activ în Pasiv

## Descriere
Acest document descrie modificările efectuate pentru a transforma Universal Verification Component-ul (UVC) pentru temperatură din modul activ în modul pasiv în cadrul proiectului de verificare a Sistemului de Reglare a Temperaturii.

## Modificări Efectuate

### 1. Modificare în `ve/sgt/sgt_env.sv`
- **Fișier modificat**: `ve/sgt/sgt_env.sv`
- **Faza modificată**: `build_phase`
- **Schimbare**: Adăugată linia `temp_agent.is_active = UVM_PASSIVE;` imediat după crearea agent-ului temp.
- **Motiv**: Această setare face ca agent-ul să fie pasiv, ceea ce înseamnă că nu va crea componente active precum driver-ul și sequencer-ul.

### 2. Modificare în `ve/sgt/sgt_env.sv`
- **Fișier modificat**: `ve/sgt/sgt_env.sv`
- **Faza modificată**: `connect_phase`
- **Schimbare**: Conexiunea sequencer-ului a fost făcută condițională:
  ```systemverilog
  if (temp_agent.get_is_active() == UVM_ACTIVE) begin
    v_sequencer.temp_seqr = temp_agent.temp_seq;
  end
  ```
- **Motiv**: Când agent-ul este pasiv, `temp_seq` este `null`, așa că conexiunea trebuie să fie condițională pentru a evita erori de runtime.

## Impactul Modificărilor
- **Înainte**: Temp UVC era activ, generând stimuli prin driver și sequencer.
- **După**: Temp UVC este pasiv, funcționând doar ca monitor pentru a captura și analiza semnalele de temperatură.
- **Beneficii**: 
  - Reduce complexitatea testbench-ului când nu este nevoie de stimuli din partea temp UVC.
  - Permite utilizarea temp UVC doar pentru monitorizare și coverage.
  - Menține compatibilitatea cu codul existent prin utilizarea flag-ului `is_active`.

## Verificare
Pentru a verifica modificările:
1. Compilează proiectul cu un simulator SystemVerilog (ex: ModelSim, QuestaSim).
2. Rulează un test de bază pentru a confirma că nu există erori de compilare sau runtime.
3. Verifică log-urile pentru a vedea că temp UVC funcționează în mod pasiv (nu generează stimuli).

## Data Modificărilor
- Modificări efectuate la data: 11 Mai 2026