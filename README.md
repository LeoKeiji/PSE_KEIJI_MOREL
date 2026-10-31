# Embedded Systems for Electrical Engineering — IME 2026

![Assembly](https://img.shields.io/badge/Assembly-8051-6E4C13?style=flat-square)
![PIC](https://img.shields.io/badge/MCU-PIC16F628A-C1272D?style=flat-square)
![Simulator](https://img.shields.io/badge/Simulator-EdSim51-1B1B2F?style=flat-square)
![Course](https://img.shields.io/badge/IME-Projeto%20de%20Sistemas%20Embarcados-E8A317?style=flat-square)

Course projects for **Projeto de Sistemas Embarcados para Engenharia Elétrica** (Instituto Militar de Engenharia, 2026.1), by Leonardo Keiji Hashimoto Kodate and João Victor Morel Rodrigues.

## Projects

| # | Project | Microcontroller | Contents |
|---|---|---|---|
| 1 | [**Star-delta (Y-Δ) starter for a 3-phase AC motor**](PartidaMotor/) | 8051 (Assembly) | Source code, README with pin map and timing, report (PDF) |
| 2 | [**Beer dispenser controller**](Maq_Chopp_Morel_Keiji.pdf) | PIC16F628A (C) | Report with source code (PDF) |

### 1 · Star-delta motor starter (8051)

Controls the Y-Δ start of a SEW-EURODRIVE DZ71K4 motor (0.15 kW, 380 V, 1680 RPM), cutting the starting current to 1/3 of a direct delta start.

- **Timer0 interrupt** (mode 1, 20 ms ticks) generates a 1 s time base used across the whole program
- **Selectable star time** (1–8 s) read from three switches on P2
- **Reverse command** with a 3 s delay before restarting in star
- **Software interlock**: star and delta contactors are never energized together — every transition passes through "all off"

```
START  →  STAR (KM1+KM2)  →  after T s  →  DELTA (KM1+KM3)
REVERSE → wait 3 s → STAR with reversal (KM1+KM4)
```

See [`PartidaMotor/README.md`](PartidaMotor/README.md) for the full pin map, register usage and how to run it in EdSim51.

### 2 · Beer dispenser (PIC16F628A)

Written in **C (mikroC)**. An LCD and four buttons drive a state sequence: welcome screen → choice of 4 beverages → cup size (small 3 s, medium 5 s, large 7 s) → timed dispensing (LED on, countdown on the LCD) → new order. Structured as `greetUser()`, `selectBeverage()`, `selectSize()` and `servirBebida()`. Pin map, schematic and full source code are in the [report](Maq_Chopp_Morel_Keiji.pdf).
