# LABORATOR NR. 7 - Controlul turației unui motor asincron

---

## Date despre sistem

**Lab 7 NU folosește date experimentale** — este un laborator teoretic bazat pe modelul matematic al unui motor asincron trifazat de 37kW.

**Parametri motor (din lucrare):**

| Parametru | Simbol | Valoare | Unitate |
|-----------|--------|---------|---------|
| Moment de inerție | J | 0.4 | kg·m² |
| Coef. frecare | Kf | 0.1115 | - |
| Rezistență rotorică | Rr | 0.156 | Ω |
| Rezistență statorică | Rs | 0.294 | Ω |
| Inductanță rotorică | Lr | 0.0417 | H |
| Inductanță statorică | Ls | 0.0424 | H |
| Inductanță mutuală | LM | 0.041 | H |
| Frecvență nominală | fn | 50 | Hz |
| Turație nominală | n_nom | 2940 | rot/min |
| Turație sincronism | n0 | 3000 | rot/min |
| Alunecare nominală | s | 0.02 | - |

---

## Modelul matematic (ec. 7.1)

Sistemul de 5 ecuații diferențiale nelinare (stări: φa, φb, ia, ib, ω):

```
dφa/dt = -α·φa - ω·φb + LM·α·ia
dφb/dt = -α·φb + ω·φa + LM·α·ib
dia/dt = -β·(dφa/dt) + (1/(γ·Ls))·(ua - Rs·ia)
dib/dt = -β·(dφb/dt) + (1/(γ·Ls))·(ub - Rs·ib)
dω/dt  = (1/J)·(LM/Lr)·(φa·ib - φb·ia) - (Kf/J)·ω - MR/J
```

unde: `α = Rr/Lr`, `β = LM/(Ls·Lr)`, `γ = 1 - LM²/(Ls·Lr)`

Ieșire: `n [rot/min] = (30/π)·ω`

---

## Tensiunile statorice

```
ua = 220√2 · sin(2π·f·t + π/2)
ub = 220√2 · sin(2π·f·t)
```

Controlul turației se realizează prin **varierea frecvenței f** a tensiunilor de alimentare, menținând raportul `U/f = ct.` (ec. 7.13, 7.14):

```
ua = (U1·f/fn) · sin(2π·f·t + π/2)
ub = (U2·f/fn) · sin(2π·f·t)
```

---

## Fișiere incluse

### 1. `lab7_model_bucla_deschisa.m` *(rulați primul)*
**Simulare în buclă deschisă (fig. 7.2, 7.3)**

- Simulează modelul motorului cu `ode45` la frecvența nominală fn=50Hz
- Evidențiază că turatia se stabilizează la **2940 rot/min** (nu la 3000 — din cauza alunecării s=2%)
- Generează **Figura 1** (fig. 7.2 echiv.) și **Figura 2** (fig. 7.3 — zoom pe alunecare)

### 2. `lab7_metoda_releului.m`
**Metoda releului pentru calculul parametrilor (fig. 7.5, 7.6, 7.7)**

- Simulează schema cu releu bipozițional (histerezis `a = ±50 rot/min`, ieșire `b = ±1`)
- Detectează automat oscilațiile întreținute → citește **A₀** și **T₀**
- Calculează `K₀ = 4b/(π·A₀)` (ec. 7.8)
- Calculează parametrii regulatoarelor P, PI, PID (Tabelul 7.1 — Ziegler-Nichols releu):
  - P:   `K_R = 0.5·K₀`
  - PI:  `K_R = 0.45·K₀`, `T_I = 0.8·T₀`
  - PID: `K_R = 0.6·K₀`, `T_I = 0.5·T₀`, `T_D = 0.12·T₀`
- Salvează `lab7_params.mat`
- Generează **Figurile 3, 4** (fig. 7.5, 7.7 echiv.)

**Valori așteptate (din lucrare):**
- A₀ ≈ 52.6 rot/min, T₀ ≈ 0.12s, K₀ ≈ 0.0242
- Regulator PI: K_R ≈ 0.0109, T_I ≈ 0.096s
- **Regulatorul PI modificat** (K redus de 4x pentru stabilitate): K_R ≈ 0.0027, T_I ≈ 0.096s

### 3. `lab7_reglare_turatie.m`
**Simularea sistemului de reglare (fig. 7.8, 7.9, 7.10, 7.11)**

- Implementează bucla închisă: `w → [PI] → c(Hz) → [VCO] → ua,ub → [Motor] → n`
- Semnalul de referință cu **trepte multiple** (fig. 7.9):
  - 0–5s: w = 1000 rot/min
  - 5–10s: w = 2000 rot/min
  - 10–15s: w = 1500 rot/min
- Calculează performanțele pe fiecare subdomeniu (a_stp, tr, frecvența stationară)
- **Cerința 7.5 pct.2:** Simulare cu referință "întârziată" (filtru ordinul I, T_int=1s)
- Generează **Figurile 5–9** (fig. 7.9–7.12 echiv.)

**Rezultate așteptate (din lucrare):**
- a_stp = 0 pe toate cele 3 subdomenii
- σ = 0 (fără suprareglaj)
- tr < 2.2s în toate cazurile

### 4. `lab7_simulink.m` *(necesită Simulink)*
- Creează `motor_asincron_sfunc.m` (S-Function pentru modelul neliniar)
- Construiește schematic `lab7_metoda_releului_slx.slx` (fig. 7.6)
- Construiește schematic `lab7_reglare_turatie_slx.slx` (fig. 7.8)

---

## Ordinea de rulare

```matlab
cd('calea/catre/lab7')

% 1. Buclă deschisă:
run('lab7_model_bucla_deschisa.m')

% 2. Metoda releului (calcul parametri):
run('lab7_metoda_releului.m')

% 3. Reglare turație în buclă închisă:
run('lab7_reglare_turatie.m')

% 4. Optional (Simulink):
run('lab7_simulink.m')
```

---

## Cerințe din 7.5 (Desfășurarea lucrării)

1. ✅ Simulare buclă deschisă → fig. 7.2, 7.3 (alunecare s=2%)
2. ✅ Metoda releului → A₀, T₀, K₀, parametri PI (Tabelul 7.1)
3. ✅ Simulare buclă închisă cu PI → fig. 7.9, 7.10, 7.11 (trepte multiple)
4. ✅ Evidențierea că frecvențele stationare sunt mai mari decât cele de sincronism
5. ✅ Simulare cu referință "întârziată" → reducerea valorilor mari de comandă

---

## Cerințe software
- MATLAB R2016b+ cu ODE solvers (inclus implicit)
- Control System Toolbox (opțional, pentru analiza în frecvență)
- Simulink (opțional, doar pentru `lab7_simulink.m`)

> **Notă importantă:** Datorită caracterului **neliniar** al modelului motorului asincron, nu se pot utiliza metodele liniare din laboratoarele anterioare (criteriul modulului, simetriei etc.). De aceea se folosește **metoda releului** pentru determinarea parametrilor regulatorului.
