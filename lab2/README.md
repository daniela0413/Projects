# LABORATOR NR. 2 - Acordarea regulatoarelor pentru procese cu timp mort
## Fisiere MATLAB pentru Desfasurarea Lucrarii (sectiunea 2.5)

---

## Cuprins fisiere

### 1. `task1_identificare_regulatoare.m`
**Sarcina 1 + 2: Identificare experimentala + calcul regulatoare (Tab. 2.1 si 2.2)**

Functia de transfer a partii fixate (data in lucrare):
```
H_F(s) = 4.25 / ((1+0.3s)*(1+22.5s)*(1+40s))   [minute]
```

Realizeaza:
- Simuleaza raspunsul indicial al procesului de ordin superior
- Aplica **metoda tangentei** → identifica K_f, T, Tm
- Aplica **metoda Cohen-Coon** → identifica K_f, T_cc, Tm_cc, alpha
- Calculeaza parametrii **TUTUROR** regulatoarelor din Tabelul 2.1 si 2.2:
  - **Tabelul 2.1** (referinta): Ziegler-Nichols, Oppelt, CHR (aperiodic)
  - **Tabelul 2.2** (perturbatii): Kopelovici aperiodic, Kopelovici oscilant, CHR, Cohen-Coon
- Salveaza toti parametrii in `lab2_params.mat`

**Rulati PRIMUL, inainte de orice alt script.**

---

### 2. `task2_simulare_tab21.m`
**Sarcina 3 - Tabelul 2.1: Simulare si comparatie (raspuns la referinta)**

Realizeaza:
- Simuleaza sistemul in bucla inchisa cu fiecare regulator din Tabelul 2.1 (p=0)
- Calculeaza performantele: sigma (suprareglaj), tr (timp de raspuns), a_stp

**Figuri generate:**
- **Figura 1**: Comparatie pe linie (P vs PI vs PID) - sublot pentru fiecare tip
- **Figura 2**: Comparatie pe coloana (toate tipurile per criteriu)

---

### 3. `task2_simulare_tab22.m`
**Sarcina 3 - Tabelul 2.2: Simulare si comparatie (raspuns la perturbatii)**

Realizeaza:
- Simuleaza raspunsul la perturbatie treapta unitara (w=0) pentru fiecare regulator din Tabelul 2.2
- Calculeaza |y|_max si timpul de revenire

**Figuri generate:**
- **Figura 3**: Comparatie pe linie (P vs PI vs PID)
- **Figura 4**: Comparatie pe coloana (P/PI/PID per criteriu)

---

### 4. `task3_tabel_perf_si_ZN_limita.m`
**Sarcina 4: Tabel centralizator + Sarcina 5: Ziegler-Nichols limita stabilitate**

**Sarcina 4:**
- Calculeaza si afiseaza tabelul centralizator cu toate performantele:
  - Abatere stationara la pozitie (a_stp)
  - Suprareglaj sigma [%]
  - Timp de raspuns tr [min]
  - Domeniul de variatie al comenzii [c_min; c_max]
- **Figura 5**: Grafice comparative (bar charts) pentru toate performantele

**Sarcina 5 (Ziegler-Nichols limita stabilitate):**
Functia de transfer:
```
H_f2(s) = 3.3 / ((1+11s)*(1+22s)) * exp(-5s)   [minute]
```
- Determina automat K_Rlim (constanta de proportionalitate la limita de stabilitate)
- Calculeaza T_lim (perioada oscilatiilor intretinute)
- Calculeaza regulatoarele P, PI, PID conform Tabelului 2.3
- **Figura 6**: Raspuns sistem cu regulatoarele PI si PID calculate

---

## Ordinea de rulare

### Varianta A — Control System Toolbox (fara Simulink)
```matlab
cd('calea/catre/lab2')
run('task1_identificare_regulatoare.m')   % obligatoriu primul
run('task2_simulare_tab21.m')
run('task2_simulare_tab22.m')
run('task3_tabel_perf_si_ZN_limita.m')
```

### Varianta B — Cu Simulink (modele .slx)
```matlab
cd('calea/catre/lab2')
run('task1_identificare_regulatoare.m')   % obligatoriu primul
run('task_simulink_builder.m')            % construieste + ruleaza schema fig. 2.1
run('task_simulink_sarcina5.m')           % schema + Ziegler-Nichols limita stabilitate
```
> Ambele variante produc rezultate identice matematic.
> Variantele Simulink genereaza si fisierele `.slx` care pot fi deschise si editate vizual.

---

### 5. `task_simulink_builder.m`  *(necesita Simulink)*
**Construieste automat modelul Simulink `lab2_schema_fig21.slx` (schema fig. 2.1)**

- Adauga si conecteaza toate blocurile: Step (w), Sumator, HR (regulator), HF (parte fixata), Transport Delay (timp mort), perturbatie p, Scope-uri, To Workspace
- Itereaza prin **toti** regulatoarele din Tab. 2.1 + 2.2, actualizeaza HR si ruleaza simularea
- Genereaza graficele comparative (figurile 10 si 11)
- Salveaza modelul ca `lab2_schema_fig21.slx`

### 6. `task_simulink_sarcina5.m`  *(necesita Simulink)*
**Schema Simulink + Ziegler-Nichols limita stabilitate pentru Sarcina 5**

- Construieste `lab2_schema_sarcina5.slx` pentru procesul `H_f2(s) = 3.3/((1+11s)(1+22s))·e^(-5s)`
- Detecteaza automat K_Rlim si T_lim prin simulare cu regulator P
- Calculeaza P/PI/PID din Tabelul 2.3
- Simuleaza si genereaza grafice raspuns + semnal de comanda (figurile 20 si 21)

---

## Parametri procesului (din enunt)

| Parametru | Valoare |
|-----------|---------|
| K_F1 (proportionalitate) | adimensional |
| T1, T2, T3 [min] | 0.3, 22.5, 40 |
| H_F(s) | 4.25/((1+0.3s)(1+22.5s)(1+40s)) |
| H_f2(s) Sarcina 5 | 3.3/((1+11s)(1+22s))·e^(-5s) |

Timpii morti sunt exprimati in **minute**.

---

## Cerinte software
- MATLAB R2016b sau mai nou
- Control System Toolbox (`tf`, `feedback`, `step`, `bode`, `pade`, `pole`)
- Simulink **nu este necesar** (simularea se face cu Control System Toolbox)
