# Reglare Debit Lichid — G.U.N.T. RT0x0
## Rezolvare cu datele din `nustiudelacesunt.docx`

---

## Despre datele experimentale

Fișierul conține măsurători de **debit lichid** (RT020, [L/h]) colectate cu instalația G.U.N.T. RT0x0 în buclă **închisă**, cu referințe succesive:

```
0 → 100 → 20 → 70 → 100 → 150 → 200 L/h
```

**Observații din analiza datelor:**
- Sistemul este în buclă închisă pe toată durata măsurătorilor
- Procesul răspunde rapid la comanda pompei (~proporțional)
- Comanda m [%] variază între 0 și ~120% pentru a menține referința

**Structura fizică:** Pompă → Valve → Debit (RT020)

---

## Fișiere incluse

### 1. `date_experimentale.m`
Datele brute extrase din docx:
- `t_exp` — timp [s], `dt = 0.2s`, total ~1249s
- `m_exp` — comanda pompă [%]
- `y_exp` — debit măsurat [L/h]
- `w_exp` — referință debit [L/h]

### 2. `debit_identificare.m` *(rulați primul)*
**Identificare experimentală a procesului:**

- Detectează saltul de comandă din segmentul 0→100 L/h
- Aplică metoda tangentei → **K_proc, T, Tm**
- Calculează modelele elementelor auxiliare (H_EE, H_TM)
- Calculează regulatoarele:
  - **P** simplu: `K_R = T/(K_f·Ty)`
  - **PI** (criteriul modulului): `K_R = T/(2·K_f·Ty)`, `T_I = T`
  - **PID** (criteriul simetriei): `K_R`, `T_I`, `T_D`
- Salvează `debit_params.mat`

### 3. `debit_simulare.m`
**Simulare și comparație regulatoare:**

- **Figura 1:** Comparație răspuns experimental vs simulat (PI)
- **Figura 2:** Comparație P / PI / PID pe secvența completă de referințe
- **Figura 3:** Zoom pe prima treaptă (0→100 L/h)
- **Tabel centralizator:** a_stp, σ, tr, [c_min; c_max] pentru P, PI, PID

---

## Ordinea de rulare

```matlab
cd('calea/catre/lab_debit')

run('debit_identificare.m')   % obligatoriu primul
run('debit_simulare.m')
```

---

## Cerințe software
- MATLAB R2016b+
- Control System Toolbox
