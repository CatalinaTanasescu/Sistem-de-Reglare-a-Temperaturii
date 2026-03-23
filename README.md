# Thermostat Digital - Proiect de Verificare

Proiect de verificare pentru un termostat digital implementat in Verilog, realizat in cadrul cursului SECI-SI la Universitatea Transilvania din Brasov.

Modulul primeste temperatura curenta de la un senzor si porneste incalzirea sau AC-ul in functie de o temperatura tinta configurabila. O marja de eroare previne comutarile repetate cand temperatura e aproape de valoarea setata.

---

## Semnale principale

- `temp_now [7:0]`, `temp_valid` — intrare senzor
- `heater_on`, `cooler_on` — iesiri catre actuatoare
- `clk`, `reset_n` — clock si reset asincron activ low

## Registri

- `TARGET_TEMP` — temperatura tinta (default 25)
- `MARGIN_OF_ERROR` — marja de histerezis (default ±2)
- `CONTROL` — sys_enable, force_heat, force_cool

---

## Verificare

Testele acopera functionarea normala, cazurile de forta majora (force_heat/cool), reset si scenarii random. SVA assertions verifica ca cele doua iesiri nu sunt active simultan si ca reset-ul e imediat.

---

Cordonas Cristian · Tanasescu Stefania-Catalina · Paruraru Alex Marius  
Coordonator: Alexandru Dinu
