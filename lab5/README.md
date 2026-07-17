# LABORATOR NR. 5 - Structuri de reglare în cascadă
## Rezolvare cu datele experimentale din Presiune (G.U.N.T. RT0x0)

---

## De ce setul Presiune?

Din cele 2 seturi de date rămase (BAZIN_REZERVOR folosit la Lab 4):

| Set date | Situație | Potrivit Lab 5? |
|----------|----------|-----------------|
| **Presiune** | Control presiune [bar], debit ca variabilă intermediară modelată | **✅ DA** |
| nustiudelacesunt | Control debit [L/h], variabila intermediară (nivel) = 0 pretutindeni | ❌ Nu |

**Setul Presiune** este ales deoarece:
- Procesul fizic real este exact cascada din teorie: **Pompa → Debit (IT2) → Presiune (IT1)**
- Variabila intermediară `y2 = debit` poate fi **modelată** chiar dacă nu e măsurată separat (exact ca în exemplul din subcap. 5.3)
- Există 4 trepte de referință (0 → 0.5 → 1.0 → 0.8 bar) utilizabile pentru identificare
- Structura este compatibilă cu **figura 5.3** din teorie

**Nota:** Datele sunt colectate în buclă închisă. Procesul global se identifică din răspunsul la prima treaptă de referință (0 → 0.5 bar), iar descompunerea în IT1 și IT2 se face conform teoriei (secțiunea 5.2).

---

## Structura sistemului (conform figurii 5.3)

```
         p2                      p1
          ↓                       ↓
w → [R1] → [R2] → [EE] → [IT2] → Σ → [IT1] → Σ → y (presiune)
       ↑      ↑                    ↑              ↑
       a1     a2                   y2             y
       |      |                    |              |
       |    [TM2] ←────────────────              |
       |                                         |
     [TM1] ←─────────────────────────────────────
```

Unde:
- **IT2** = subproces rapid (pompa → debit), constanta de timp `T2` mică
- **IT1** = subproces lent (debit → presiune), constanta de timp `T1` mare
- **R2** = regulator secundar (bucla interioară) → calculat prin **criteriul modulului**
- **R1** = regulator principal (bucla exterioară) → calculat prin **criteriul modulului**
- **TM1, TM2** = traductoare de măsură

---

## Fișiere incluse

### 1. `date_experimentale.m`
Date brute din fișierul Presiune.docx, convertite în vectori MATLAB:
- `t_exp` — timp [s], `dt = 0.2s`
- `m_exp` — comanda pompa [%]
- `y_exp` — presiune măsurată [bar]
- `w_exp` — referință presiune [bar]

### 2. `lab5_identificare.m` *(rulați primul)*
**Pasul 1:** Identificare proces global prin metoda tangentei → K_IT, T_global, Tm_global

**Pasul 2:** Descompunere în subprocese:
- `H_IT2(s) = K_IT2 / (1+T2*s)` — bucla interioară (rapid)
- `H_IT1(s) = K_IT1 / (1+T1*s)` — bucla exterioară (lent)
- Critériu: T2 ≈ 15% din T_global, T1 = restul

**Pasul 3:** Calcul **R2** (criteriul modulului, bucla interioară):
- K_R2 = T2 / (2·K_f2·T_Σ2)
- T_I2 = T2

**Pasul 4:** Calcul H_02(s) (funcția de transfer bucla interioară închisă):
- H_02(s) ≈ 1/(1 + 2·T_Σ2·s) (forma simplificată, ec. 5.5)

**Pasul 5:** Calcul **R1** (criteriul modulului, bucla exterioară):
- K_R1 = T1 / (2·K_f1·T_Σ1)
- T_I1 = T1

**Pasul 6:** Calcul **R_mono** (regulator monocontur echivalent, pentru comparație)

Salvează `lab5_params.mat` și generează **Figurile 1–2**.

### 3. `lab5_simulare.m`
Simulare cu **Control System Toolbox** (fără Simulink):

- **Figura 1:** Răspuns la referință treaptă — monocontur vs cascadă (R2 modul + R2 simetrie)
- **Figura 2:** Referință + perturbație treaptă p2=1 la t=80s (fig. 5.6 echivalent)
- **Figura 3:** Perturbație rampă p2=0.1·t (fig. 5.8 echivalent)
- **Figura 4:** Perturbație sinusoidală p2=sin(0.1·t) (fig. 5.9 echivalent)
- **Figura 5:** Semnale de comandă comparate (fig. 5.7 echivalent)
- **Tabelul 5.1** centralizator performanțe: a_stp, σ, tr, [c_min; c_max]

### 4. `lab5_simulink.m` *(necesită Simulink)*
Construiește automat:
- `lab5_monocontur.slx` — schema monocontur cu IT1 și IT2 separate (fig. 5.4)
- `lab5_cascada.slx` — schema în cascadă cu R1, R2, TM1, TM2 (fig. 5.5)
- Rulează simulările și generează **Figurile 10–11**

---

## Ordinea de rulare

```matlab
cd('calea/catre/lab5')

% Obligatoriu primul:
run('lab5_identificare.m')

% Simulare fara Simulink:
run('lab5_simulare.m')

% Optional (cu Simulink):
run('lab5_simulink.m')
```

---

## Cerinte software
- MATLAB R2016b+
- Control System Toolbox
- Simulink (opțional, doar pentru `lab5_simulink.m`)

---

## Observații importante
1. Funcțiile de transfer sunt calculate cu **constantele de timp în secunde**
2. Referința w = 0.1 (traductorul TM1 are K=0.1, deci pentru y=1 bar semnalul e 0.1)
3. Perturbațiile p1 și p2 acționează direct pe semnalele de ieșire ale IT1 și IT2
4. Sistemul în cascadă rejectează eficient perturbația p2 (nu se propagă la ieșirea principală)
5. Monoconturul nu poate rejecta perturbații de tip rampă (abatere stationară ≠ 0)
