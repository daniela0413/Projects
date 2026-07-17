# LABORATOR NR. 4 - Structuri de reglare bazate pe principiul compensării perturbației
## Rezolvare cu datele experimentale din BAZIN_REZERVOR (G.U.N.T. RT0x0)

---

## De ce BAZIN_REZERVOR?

Din cele 3 seturi de date disponibile:

| Set date | Marime reglata | Perturbatie | Potrivit Lab 4? |
|----------|---------------|-------------|-----------------|
| **Date_BAZIN_REZERVOR** | **Nivel lichid [cm]** | **Debit exterior / schimbare setpoint** | **✅ DA** |
| Presiune | Presiune [bar] | - | Partial (nu are perturbatie clara masurата) |
| nustiudelacesunt | Debit [L/h] | - | Nu (sistem deja in regim stationar) |

Datele de la **bazin/rezervor** conțin:
- 3 secvențe de răspuns indicial (setpoint: 0→10cm, 0→15cm, 0→17cm)
- Schimbările de setpoint funcționează ca **perturbații** (ce trebuie compensate)
- Structura este perfect compatibilă cu **figurile 4.2–4.5** din teorie
- Există TM2 (traductorul perturbației) = senzorul de nivel în bucla feedforward

---

## Structura sistemului (conform figurii 4.2)

```
w → [Σ(+-)] → [R1/PID] → [Σ(+-)] → [EE/Pompa] → [IT/Bazin] → Σ(++) → y(nivel)
         ↑          ↑                                               ↑
         r1         c2                                              p (perturbatie)
         |          |                                               |
       [TM1] ←──────────────────────────────────────────────────────
                  [BC] ←── [TM2] ←──────────────────────────────────
```

Unde:
- **IT** = instalatia tehnologica (bazinul) → `H_IT(s) = K_IT / (1+T*s)`
- **EE** = elementul de executie (pompa) → `H_EE(s) = 1 / (1+T_EE*s)`
- **TM1** = traductorul de masura nivel → `H_TM1(s) = 1 / (1+T_TM1*s)`
- **TM2** = traductorul de masura perturbatie → `H_TM2(s) = 1 / (1+T_TM2*s)`
- **BC** = blocul de compensare → calculat din relația (4.7)
- **R1** = regulatorul PID principal → calculat prin criteriul modulului

---

## Fisiere incluse

### 1. `date_experimentale.m`
Datele brute din fișierul BAZIN_REZERVOR, convertite în vectori MATLAB:
- `t_exp` — vectorul timp [s]
- `m_exp` — comanda pompa [%]
- `y_exp` — nivel masurat [cm]
- `w_exp` — referinta nivel [cm]

### 2. `lab4_identificare.m` *(rulati primul)*
**Pasul 1:** Identificare experimentala prin metoda tangentei
- Extrage segmentul de răspuns indicial (0 → 17 cm)
- Calculează: K_IT, T (constanta de timp), Tm (timp mort)
- **Pasul 2:** Calculează regulatorul R1 (PI, criteriul modulului)
- **Pasul 3:** Calculează blocul de compensare H_BC(s) în 3 forme:
  - Ideala (nerealizabila)
  - Realizabila (cu filtre Tf)
  - Simplificata (ec. 4.16)
  - Proportionala (cea mai simpla)
- Salvează `lab4_params.mat`
- Generează **Figura 1** (date experimentale complete) și **Figura 2** (identificare)

### 3. `lab4_simulare.m`
**Simulare cu Control System Toolbox** (fara Simulink)
- Compară **monocontur vs feedforward** pentru:
  - Perturbatie treapta → **Figura 3**
  - Perturbatie rampa (pornire t=30s) → **Figura 4**
  - Perturbatie sinusoidala (A=1, ω=0.05 rad/s) → **Figura 5**
- Răspuns la referinta (p=0) → **Figura 6**
- Afișează **Tabelul 4.1** centralizator performante

### 4. `lab4_simulink.m` *(necesita Simulink)*
**Construieste automat modelele Simulink:**
- `lab4_monocontur.slx` — schema monocontur cu perturbatie treapta (fig. 4.8)
- `lab4_feedforward.slx` — schema feedforward Varianta 1 cu bloc BC (fig. 4.12)
- Rulează simulările și generează **Figurile 10–11**

---

## Ordinea de rulare

```matlab
cd('calea/catre/lab4')

% Pasul 1 - obligatoriu primul:
run('lab4_identificare.m')

% Pasul 2 - simulari (fara Simulink):
run('lab4_simulare.m')

% Pasul 3 - optional (cu Simulink):
run('lab4_simulink.m')
```

---

## Rezultate asteptate

| Parametru identificat | Valoare estimata |
|-----------------------|-----------------|
| K_IT [cm/%] | ~0.20 |
| T [s] | ~12–15 |
| Tm [s] | ~0–1 |
| K_R (regulator PI) | calculat automat |
| T_I [s] | = T (criteriul modulului) |

### Concluzie teorica (din lucrare):
- **Monocontur**: abatere stationara nulă la treapta, dar nu poate rejecta rampa/hiperbolă
- **Feedforward real**: rejectie aproape perfecta a perturbatiei (a_stp → 0)
- **Feedforward simplificat**: performante usor mai slabe, comanda mult mai mica
- Perturbatia **sinusoidala**: feedforward reduce amplitudinea in regim stationar
- Perturbatia **treapta**: ambele sisteme similare (efectul feedforward derivativ e instantaneu)

---

## Cerinte software
- MATLAB R2016b+
- Control System Toolbox (`tf`, `feedback`, `step`, `lsim`)
- Simulink (optional, doar pentru `lab4_simulink.m`)
