# LABORATOR NR. 6 - Simularea sistemelor de reglare a mărimilor electrice aferente unei termocentrale

---

## Despre datele experimentale

**Lab 6 NU folosește datele experimentale G.U.N.T.** (fisierele .docx).
Ultimul set rămas (`nustiudelacesunt.docx`) conține doar date de debit (L/h) de la instalația hidraulică, care nu are nicio legătură cu termocentrala.

Lab 6 este **100% teoretic** — toate funcțiile de transfer sunt date direct în lucrare (ecuațiile 6.1–6.21), cu valorile numerice din proiectul de semestru al termocentralei:
- Puterea grupului: P = 360 MW
- Presiunea aburului viu: p = 126 bar
- Frecvența nominală: f = 50 Hz
- Tensiunea nominală generator: U_G,nom = 25 kV

---

## Structura sistemelor

### a) Sistemul de reglare a puterii active și frecvenței (fig. 6.2)

```
u*f → [EC1(±)] → [K_ST] ──────────────────────────────────────────┐
                                                                    ↓
u*P → [HREF1] → [EC2(+++-)] → [R_P(PD)] → [SMH] → [V] → [T+G] → [S] → Σ → f
                     ↑                                               ↑      ↓
                     └──────────────[H_Pup] ←────────────────────────    pf
                                    [H_fuf] ←───────────────────────── f
```

**Funcții de transfer (ec. 6.1–6.8):**
- `H_SMH(s) = 0.01 + 1/(20s)` — servomotor hidraulic
- `H_V = 10667.51` — ventil
- `H_T+G(s) = 0.337/(1+10s)` — turbină + generator
- `H_S(s) = 0.139/((1+s)(1+2s))` — sistem energetic
- `H_P/up = 0.027` — traductor putere
- `H_f/uf = 0.2` — traductor frecvență
- `H_RP(s) = 10·(1+10s)/(1+0.2s)` — regulator PD cu filtru
- `K_ST = 125` — coeficient statism

### b) Sistemul de reglare a tensiunii la bornele generatorului (fig. 6.11/6.12)

Structură în cascadă cu **3 bucle**:
- **Bucla 1 (interioară):** Curent excitație IE → regulator `R_IE` (PID cu filtru)
- **Bucla 2 (mijlocie):** Tensiune excitație UE → regulator `R_UE` (PI)
- **Bucla 3 (exterioară):** Tensiune generator UG → regulator `R_UG` (PID)

**Regulatoare calculate (ec. 6.18–6.21):**
- `H_RUE(s) = 4·(1 + 1/(0.1s))` — PI
- `H_RIE(s) = 26·(1 + 1/(0.52s) + 0.019s)/(1+0.05s)` — PID realizabil
- `H_RUG(s) = 212·(1 + 1/(4.02s) + 0.198s)/(1+4.2s)` — PID cu filtru

---

## Fișiere incluse

### 1. `lab6_putere_frecventa.m`
**Sistem a) — Putere activă și frecvență**

Realizează toate simulările cerute în lucrare:

- **Simulare 1** (fig. 6.4 echiv.) — Pornire sistem + perturbație frecvență treaptă `pf = -5 Hz` la `t=150s`
- **Simulare 2** (fig. 6.6/6.7 echiv.) — Cu semnale "întârziate" prin filtre `H_REF1 = 1/((1+5s)(1+8s))`
- **Simulare 3** (fig. 6.8 echiv.) — Ajustare `Tf = 0.09s` (filtrul regulatorului)
- **Simulare 4** (cerința 6.4 pct.4) — Pornire la `P = 300 MW` în loc de 360 MW

**Figuri generate:** 1, 2, 3, 4

### 2. `lab6_tensiune.m`
**Sistem b) — Tensiunea la bornele generatorului**

- **Simulare 1** (fig. 6.13/6.14 echiv.) — Treapta referință + perturbație tensiune `pU = -1000V` la `t=70s`
- **Simulare 2** (fig. 6.15/6.16/6.17/6.18 echiv.) — Cu semnale întârziate
- **Simulare 3** (cerința 6.4 pct.5) — Studiu influența `Tf2` din `[0.01s; 2s]` asupra sistemului

**Figuri generate:** 5, 6, 7

### 3. `lab6_simulink.m` *(necesită Simulink)*
Construiește automat:
- `lab6_putere_frecventa.slx` — schema fig. 6.3
- `lab6_tensiune_generator.slx` — schema fig. 6.12
- Rulează simulările și generează **Figurile 10, 11**

---

## Ordinea de rulare

```matlab
cd('calea/catre/lab6')

% Sistem a) - Putere activa si frecventa:
run('lab6_putere_frecventa.m')

% Sistem b) - Tensiunea la bornele generatorului:
run('lab6_tensiune.m')

% Optional (cu Simulink):
run('lab6_simulink.m')
```

---

## Semnale de referință și perturbații

| Semnal | Valoare | Semnificație fizică |
|--------|---------|---------------------|
| `u*P = 10V` | P = 360 MW | Putere activă nominală |
| `u*f = 10V` | f = 50 Hz | Frecvență nominală |
| `pf = -5 Hz` | scădere frecvență | Perturbație frecvență (sistem a) |
| `u*G = 9.5V` | UG = 23.75 kV | Referință tensiune generator |
| `pU = -1000V` | scădere tensiune | Perturbație tensiune (sistem b) |

---

## Cerințe din 6.4 (Desfășurarea lucrării)

1. ✅ Implementarea schemei a) în Simulink + ajustarea `Tf` și `T_intarziere`
2. ✅ Implementarea schemei b) în Simulink + studiu `Tf2 ∈ [0.01s; 2s]`
3. ✅ Ajustarea filtrelor pentru `m_qabv ∈ [0; 0.1]m` fără oscilații (simulare 3)
4. ✅ Refacerea simulărilor pentru `P = 300 MW` (simulare 4)
5. ✅ Studiu influența `Tf2` (simulare 3 din lab6_tensiune.m)

---

## Cerințe software
- MATLAB R2016b+
- Control System Toolbox
- Simulink (opțional, pentru `lab6_simulink.m`)
