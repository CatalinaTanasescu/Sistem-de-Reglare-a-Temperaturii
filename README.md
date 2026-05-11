# Sistem de Reglare a Temperaturii - Proiect de Verificare

Proiect de verificare pentru un sistem de reglare a temperaturii implementat în Verilog, realizat în cadrul cursului SECI-SI la Universitatea Transilvania din Brașov.

Modulul primește temperatura curentă de la un senzor și pornește încălzirea sau răcirea în funcție de o temperatură țintă configurabilă. O marjă de eroare previne comutările repetate când temperatura e aproape de valoarea setată.

---

## Semnale principale

- `temp_now [7:0]`, `temp_valid` — intrare senzor
- `heater_on`, `cooler_on` — ieșiri către actuatoare
- `clk`, `rst_n` — clock și reset asincron activ low

## Registre APB

- `TARGET_TEMP` (addr 0) — temperatură țintă (default 25)
- `TEMP_TOLERANCE` (addr 1) — marjă de eroare ± (default 2)
- `CONTROL_REG` (addr 2) — control: [0] enable, [1] force_heat, [2] force_cool (default 1)

---

## Verificare

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

