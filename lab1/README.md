# LABORATOR NR. 1 - Notiuni introductive
## Fisiere MATLAB pentru Desfasurarea Lucrarii (sectiunea 1.6)

---

## Cuprins fisiere

### 1. `task1_seturi_1_2.m`
**Sarcina 1 - Seturile 1 si 2**

Realizeaza:
- Traseaza grafic curbele experimentale pentru Setul 1 (proc. ordinul I fara timp mort) si Setul 2 (proc. ordinul I cu timp mort)
- Aplica metoda tangentei pentru ambele seturi
- Identifica parametrii functiilor de transfer (K, T1, Tm)
- Afiseaza comparatia raspuns experimental vs raspuns simulat (identificat)

**Figuri generate:**
- Figura 1: Setul 1 - metoda tangentei
- Figura 2: Setul 2 - metoda tangentei

**Rezultate asteptate:**
- Setul 1: H(s) = K / (1 + T1*s)   [proc. ord. I fara timp mort]
- Setul 2: H(s) = K / (1 + T2*s) * exp(-Tm*s)   [proc. ord. I cu timp mort]

---

### 2. `task1_setul3_tang_cohencoon.m`
**Sarcina 1 - Setul 3**

Realizeaza:
- Traseaza curba experimentala Setul 3 (proces de ordin superior)
- Aplica **metoda tangentei** (punct de inflexiune)
- Aplica **metoda Cohen-Coon** (prin t28 si t632)
- Afiseaza pe acelasi grafic: raspuns experimental + raspuns metoda tangentei + raspuns Cohen-Coon

**Figuri generate:**
- Figura 3: Comparatie cele 3 raspunsuri pe acelasi grafic

**Formule utilizate (din lucrare):**
- T = 1.5*(t632 - t28)          -- ec. (1.17)
- Tm = 1.5*(t28 - t632/3)       -- ec. (1.18)
- alpha = T/Tm                  -- ec. (1.19)

---

### 3. `task2_acordare_PID.m`
**Sarcina 2 - Acordarea regulatoarelor si verificarea performantelor**

Realizeaza:
- Calculeaza parametrii regulatorului **PI prin criteriul modulului** (ec. 1.23, 1.24)
- Calculeaza parametrii regulatorului **PID prin criteriul simetriei** (ec. 1.25-1.27)
- Simuleaza sistemul in bucla inchisa pentru **semnal de referinta tip treapta**
- Simuleaza sistemul in bucla inchisa pentru **semnal de referinta tip rampa**
- Calculeaza performantele: suprareglaj (sigma), timp de raspuns (tr), abatere stationara la pozitie/viteza

**Figuri generate:**
- Figura 4 (subplot 1): Raspuns la treapta - comparatie PI vs PID
- Figura 4 (subplot 2): Raspuns la rampa - comparatie PI vs PID

**Performante asteptate (din lucrare):**
- Criteriul modulului (PI):   sigma ≈ 4.3%,   tr ≈ 8.4*Ty
- Criteriul simetriei (PID):  sigma ≈ 43%,    tr ≈ 16.5*Ty

---

### 4. `task2_simulink_builder.m`
**Builder automat pentru modelele Simulink (fig. 1.8 si 1.9)**

Incearca sa creeze automat modelele Simulink descrise in lucrare.
Daca Simulink nu este disponibil, afiseaza instructiunile pentru construirea manuala a schemelor.

**Schema fig. 1.8:** utilizeaza functia de transfer a partii fixate H_F(s)
**Schema fig. 1.9:** utilizeaza separat H_EE(s), H_IT(s), H_TM(s)

---

## Cum se ruleaza

### Varianta recomandata (pas cu pas):
```matlab
% In MATLAB, navigati la folderul laborator:
cd('calea/catre/lab1')

% Sarcina 1 - Seturile 1 si 2:
run('task1_seturi_1_2.m')

% Sarcina 1 - Setul 3:
run('task1_setul3_tang_cohencoon.m')

% Sarcina 2 - Acordare si simulare:
run('task2_acordare_PID.m')

% Optional - Creare modele Simulink:
run('task2_simulink_builder.m')
```

---

## Notatii utilizate (conform lucrarii)
- **K_IT** = constanta de proportionalitate a procesului tehnologic
- **T1, T2** = constante de timp ale procesului
- **Tm** = timp mort al procesului
- **K_R** = constanta de proportionalitate a regulatorului
- **T_I** = constanta de timp de integrare a regulatorului
- **T_D** = constanta de timp de derivare a regulatorului
- **sigma** = suprareglaj [%]
- **tr** = timp de raspuns [s]
- **a_stp** = abatere stationara la pozitie

---

## Cerinte software
- MATLAB R2016b sau mai nou
- Control System Toolbox (pentru `tf`, `feedback`, `step`, `lsim`)
- Simulink (optional, pentru `task2_simulink_builder.m`)
