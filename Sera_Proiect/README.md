# SmartGreen — Sistem Automatizare Seră IoT
**Student:** Pop Daniela-Liliana | **Grupa:** 30135/2 | **Disciplina:** SBC 2025

---

## Structura proiect

```
Sera_Proiect/
├── app.py                          ← Backend Flask (API REST)
├── requirements.txt                ← Dependente Python
├── Processed_IoT_Data_Complete.csv ← Dataset IoT (37,922 inregistrari)
└── frontend/
    ├── package.json
    ├── public/index.html
    └── src/
        ├── index.js
        ├── App.jsx
        ├── App.css
        └── components/
            ├── Dashboard.jsx
            ├── SensorCard.jsx
            ├── ActuatorPanel.jsx
            ├── ChartPanel.jsx
            ├── ModeSelector.jsx
            └── Panels.jsx
```

---

## Instalare si rulare

### 1. Backend Python (Flask)

```bash
# In folderul Sera_Proiect/
pip install -r requirements.txt

python app.py
# => API pornit la http://localhost:5000
```

### 2. Frontend React

```bash
# Intr-un terminal separat
cd frontend
npm install
npm start
# => Site deschis la http://localhost:3000
```

---

## Functionalitati

| Modul | Descriere |
|---|---|
| **Senzori live** | Temperatura, umiditate, nivel apa, lumina — actualizare la 4s |
| **Control actuatori** | Ventilator, pompe, iluminat LED, sistem ceata |
| **Moduri operare** | Auto / Manual / Eco / Urgenta |
| **Praguri automate** | Slideuri pentru a seta cand se activeaza actuatorii |
| **Grafic + prognoza** | Date istorice + ARIMA(3,2,1) pentru urmatorele 6h |
| **Statistici** | Media, min, max din cei 37,922 de inregistrari |
| **Jurnal actiuni** | Log cu toate comenzile operatorului |
| **Alerte** | Notificari automate la depasirea pragurilor |

---

## Rute API

| Metoda | Ruta | Descriere |
|---|---|---|
| GET | `/api/status` | Senzori + actuatori + alerte |
| POST | `/api/actuator` | Comanda actuator (`{actuator, state}`) |
| POST | `/api/mode` | Schimba modul (`{mode}`) |
| POST | `/api/thresholds` | Seteaza praguri (`{temp_max, humidity_min, water_min}`) |
| GET | `/api/history` | Date istorice CSV (`?col=tempreature&n=150`) |
| GET | `/api/forecast` | Prognoza ARIMA urmatorele 6h |
| GET | `/api/stats` | Statistici descriptive dataset |
| GET | `/api/log` | Jurnal actiuni |
| GET | `/api/nutrienti` | Valorile N, P, K |
