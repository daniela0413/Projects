# LABORATOR NR. 3 - Sisteme de Reglare Numerice
## Structura proiectului

```
lab3/
├── run_all.m                  ← Script principal (ruleaza tot)
├── simulink_parametrii.m      ← Parametrii pentru modelul Simulink (Fig. 3.3)
├── README.md                  ← Acest fisier
├── common/
│   └── disp_tf_z.m            ← Functie ajutatoare (afisare FT in z)
├── dahlin/
│   └── metoda_dahlin.m        ← Rezolvare completa Metoda Dahlin
└── kalman/
    └── metoda_kalman.m        ← Rezolvare completa Metoda Kalman
```

---

## Cerinte (din sectiunea 3.5)

### Sistem 1 → Metoda Dahlin
```
H_f1(s) = 4.3 / ((1+5s)(1+23s)) * e^(-2.5s)
```

### Sistem 2 → Metoda Kalman
```
H_f2(s) = 1.25 / ((1+9s)(1+14s)) * e^(-3s)
```

---

## Cum se ruleaza

### Optiunea 1 – Script unic
```matlab
% In MATLAB, navigati in folderul lab3 si rulati:
run_all.m
```

### Optiunea 2 – Metode separate
```matlab
% Adaugati common la path:
addpath('common')

% Metoda Dahlin:
cd dahlin
metoda_dahlin

% Metoda Kalman:
cd ../kalman
metoda_kalman
```

### Optiunea 3 – Parametrii Simulink
```matlab
% Afiseaza toti parametrii pentru configurarea manuala a modelului Simulink:
addpath('common')
simulink_parametrii
```

---

## Ce calculeaza fiecare script

### `metoda_dahlin.m`
1. Discretizeaza H_f1(s) cu EOZ (c2d ZOH)
2. Calculeaza H0(z) – functia de transfer impusa in bucla inchisa
3. Obtine H_R(z) prin relatia Dahlin
4. Simuleaza si afiseaza performantele:
   - Regulator initial
   - Regulator cu saturatie comenzii c ∈ [0,1]

### `metoda_kalman.m`
1. Discretizeaza H_f2(s) cu EOZ
2. Calculeaza constanta K si amplifica H_f(z)
3. Obtine H_R(z) prin relatia Kalman
4. Identifica si elimina polul nedorit (cel mai aproape de z=1)
5. Simuleaza si afiseaza performantele:
   - Regulator initial
   - Regulator modificat (pol eliminat)
   - Regulator modificat cu saturatie c ∈ [0,1]

---

## Tabel rezultate (de completat dupa simulare)

| Nr. | Cazul tratat                                      | a_stp | σ [%] | tr [min] | [c_min, c_max] |
|-----|---------------------------------------------------|-------|-------|----------|----------------|
| 1   | Dahlin, regulator initial                         |       |       |          |                |
| 2   | Dahlin, regulator modificat                       |       |       |          |                |
| 3   | Dahlin, reg. modif. + saturatie [0,1]             |       |       |          |                |
| 4   | Kalman, regulator initial                         |       |       |          |                |
| 5   | Kalman, regulator modificat                       |       |       |          |                |
| 6   | Kalman, reg. modif. + saturatie [0,1]             |       |       |          |                |

*(Valorile se completeaza automat in Command Window dupa rularea scripturilor)*

---

## Note importante

- **Perioadele de esantionare** alese:
  - Sistem 1: T_E1 = 0.5 min (= T_m/5, submultiplu al timpului mort)
  - Sistem 2: T_E2 = 1.0 min (= T_m/3)
- **Constanta de timp impusa** (Dahlin): T01 = 3 min (< T1 = 5 min)
- **Perturbatia** p = 0 in toate simulările principale
- Simulink: folositi blocul **"Discrete Transfer Function"** (in z^-1) pentru regulator
- EOZ in Simulink: bloc **"Zero-Order-Hold"** cu Sample time = T_E
- Timp mort: bloc **"Transport Delay"** cu valoarea T_m

---

## Referinte
- Laborator Nr. 3, sectiunile 3.2 (Dahlin) si 3.3 (Kalman)
- Figura 3.3 – Schema de simulare Simulink
- Ecuatiile (3.3)-(3.4) pentru Dahlin, (3.14)-(3.16) pentru Kalman
