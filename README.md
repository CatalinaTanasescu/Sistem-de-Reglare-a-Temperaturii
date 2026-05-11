<<<<<<< HEAD
# Sistem de Reglare a Temperaturii - Proiect de Verificare

Proiect de verificare pentru un sistem de reglare a temperaturii implementat în Verilog, realizat în cadrul cursului SECI-SI la Universitatea Transilvania din Brașov.

Modulul primește temperatura curentă de la un senzor și pornește încălzirea sau răcirea în funcție de o temperatură țintă configurabilă. O marjă de eroare previne comutările repetate când temperatura e aproape de valoarea setată.
=======
# Sistem de Reglare a Temperaturii — Proiect de Verificare

Proiect de verificare pentru un termostat digital implementat în Verilog, realizat în cadrul cursului **SECI-SI** la **Universitatea Transilvania din Brașov**.

Modulul primește temperatura curentă de la un senzor intern, o compară cu o valoare țintă configurabilă prin interfața APB și activează încălzitorul sau răcitorul pentru a menține temperatura în limitele dorite. O marjă de histerezis previne comutările repetate când temperatura se află aproape de valoarea setată.

---

## Structura proiectului

```
.
├── rtl/
│   ├── temp_system.v          # Top-level: interconectează submodulele
│   ├── apb_regs.v             # Slave APB cu 3 regiștri de configurare
│   ├── temp_controller.v      # Logică de control și histerezis
│   └── temp_sensor.v          # Simulare fizică + ADC (intern în DUT)
│
├── tb/
│   └── apb_uvc_tb.sv          # Testbench top-level
│
├── tests/
│   ├── apb_uvc_tests/         # Teste pentru UVC APB
│   │   ├── apb_base_test.sv
│   │   ├── apb_single_test.sv
│   │   └── apb_random_test.sv
│   └── tb_tests/              # Teste pentru mediul integrat sgt
│       ├── sgt_base_test.sv
│       └── Basic/sgt_basic_test.sv
│
└── ve/
    ├── uvcs/
    │   ├── apb_uvc/           # UVC APB — activ (driver + monitor + coverage)
    │   └── temp_uvc/          # UVC Temp — pasiv (monitor + coverage)
    └── sgt/                   # Mediu integrat: env, scoreboard, vseqr
```

---

## Arhitectura RTL

| Modul | Rol |
|---|---|
| `temp_system` | Top-level — instanțiază și interconectează submodulele |
| `apb_regs` | Slave APB — stochează `target_temp`, `temp_tolerance`, `control_reg` |
| `temp_controller` | Logică de decizie — histerezis, priorități, interlock hw |
| `temp_sensor` | Simulare fizică — generează `temp_now` și `temp_valid` intern |
>>>>>>> 3da0569f30350b521397ecd98c23f4d71c3684e9

---

## Semnale principale

<<<<<<< HEAD
- `temp_now [7:0]`, `temp_valid` — intrare senzor
- `heater_on`, `cooler_on` — ieșiri către actuatoare
- `clk`, `rst_n` — clock și reset asincron activ low

## Registre APB

- `TARGET_TEMP` (addr 0) — temperatură țintă (default 25)
- `TEMP_TOLERANCE` (addr 1) — marjă de eroare ± (default 2)
- `CONTROL_REG` (addr 2) — control: [0] enable, [1] force_heat, [2] force_cool (default 1)
=======
**Interfața de sistem**

| Semnal | Dir | Descriere |
|---|---|---|
| `clk` | I | Clock de sistem |
| `rst_n` | I | Reset asincron activ-low |

**Interfața APB**

| Semnal | Dir | Descriere |
|---|---|---|
| `psel`, `penable`, `pwrite` | I | Control protocol APB |
| `paddr [2:0]` | I | Adresa registrului (0x00–0x02) |
| `pwdata [7:0]` | I | Date scriere |
| `prdata [7:0]` | O | Date citire |
| `pready` | O | Slave ready, fără wait states |
| `pslverr` | O | Eroare la adresă invalidă (> 0x02) |

**Interfața senzor / actuator**

| Semnal | Dir | Descriere |
|---|---|---|
| `temp_now [7:0]` | — | Temperatura curentă, generată intern de `temp_sensor` |
| `temp_valid` | — | Puls de validare eșantion (mimic ADC) |
| `heater_on` | O | Comandă încălzitor |
| `cooler_on` | O | Comandă răcitor / AC |
>>>>>>> 3da0569f30350b521397ecd98c23f4d71c3684e9

---

## Regiștri APB

<<<<<<< HEAD
Testele acoperă funcționarea normală, cazurile de forță majoră (force_heat/cool), reset și scenarii random. 

### Asertiile SystemVerilog (SVA)
- **Protocol APB**: Verifică conformitatea cu specificația AMBA APB (transferuri corecte, stabilitate semnale, etc.)
- **Funcționale**: Verifică logica de control a temperaturii (încălzire/răcire automată, moduri manuale, interlock-uri de siguranță)
- **Interfață**: Verifică absența valorilor X/Z și constrângeri de protocol

Asertiile sunt implementate în:
- `ve/uvcs/apb_uvc/apb_interface_dut.sv` — protocol APB
- `ve/uvcs/temp_uvc/temp_interface_dut.sv` — interfață temperatură  
- `rtl/temp_controller.v` — logică funcțională

---

## Structura Proiectului

```
Sistem-de-Reglare-a-Temperaturii/
├── README.md                    # Acest fișier
├── MODIFICARI.md               # Descriere modificări recente
├── rtl/                        # RTL Design
│   ├── apb_regs.v              # Registre APB slave
│   ├── temp_controller.v       # Logic control temperatură
│   ├── temp_sensor.v           # Simulator senzor
│   └── temp_system.v           # Top-level DUT
├── tb/                         # Testbench
│   ├── apb_uvc_tb.sv           # Testbench APB
│   └── sgt_tb.sv               # Testbench sistem
├── ve/                         # Verification Environment
│   ├── apb_check/              # Coverage APB
│   ├── sgt/                    # Environment sistem
│   └── uvcs/                   # Universal Verification Components
└── tests/                      # Test cases
    ├── apb_uvc_tests/          # Teste APB
    └── tb_tests/               # Teste sistem
```

---

## Rulare Teste

1. Compilează proiectul cu un simulator SystemVerilog (ModelSim, QuestaSim)
2. Rulează testele din directorul `tests/`
3. Verifică coverage și rapoartele de asertiuni

---

Data ultimei actualizări: 11 Mai 2026

=======
| Adresă | Registru | Default | Descriere |
|---|---|---|---|
| `0x00` | `target_temp` | 25 | Temperatura țintă |
| `0x01` | `temp_tolerance` | 2 | Marjă de histerezis ±2°C |
| `0x02` | `control_reg` | 1 | `sys_enable[0]`, `force_heat[1]`, `force_cool[2]` |

Lanț de priorități: `rst_n` > `~sys_enable` > `force_heat` > `force_cool` > mod automat.

---

## Mediul de verificare UVM

### UVC APB — activ
- **Driver** (`driver_agent_apb`) — conduce tranzacții APB pe interfață
- **Monitor** (`monitor_apb`) — observă și capturează tranzacții
- **Coverage** (`coverage_apb`) — acoperire pe adresă, tip acces și date; cross `ADDR × RW`
- **Secvențe** — `apb_single_seq` (o tranzacție), `apb_random_seq` (10–20 tranzacții random)

### UVC Temp — pasiv
- `temp_sensor` este intern în DUT — nu se mai conduce din testbench
- **Monitor** (`monitor_temp`) — observă `temp_now`, `temp_valid`, `heater_on`, `cooler_on`
- **Coverage** (`coverage_temp`) — acoperire pe zonă termică, stare actuatoare; cross `TEMP_ZONE × ACTUATORS`; `both_on` marcat ca illegal bin
- Driver și sequencer au fost eliminate

### Scoreboard (`sgt_scbd`)
Verifică în timp real că `heater_on` și `cooler_on` corespund modelului de referință calculat din `target_temp`, `temp_tolerance` și `control_reg`. Raportează matches, mismatches și total tranzacții la sfârșitul simulării.

---

## Teste

| Test | Descriere |
|---|---|
| `apb_base_test` | Test de bază — reset și funcționare minimală |
| `apb_single_test` | O singură tranzacție APB randomizată |
| `apb_random_test` | 10–20 tranzacții APB random — acoperire maximă |
| `sgt_base_test` | Test integrat de bază pentru mediul sgt |
| `sgt_basic_test` | Scenariu funcțional de bază cu scoreboard activ |

---

## Asertări SVA

**Interfața APB** — verifică că semnalele nu sunt X/HiZ, că `penable` urmează `psel` după exact un ciclu, că adresa și datele rămân stabile în faza de acces.

**Interfața Temp** — verifică că `heater_on` și `cooler_on` nu sunt active simultan și că la reset ambele ieșiri sunt dezasertate imediat.
>>>>>>> 3da0569f30350b521397ecd98c23f4d71c3684e9
