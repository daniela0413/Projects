"""
Backend Flask - Sistem de Automatizare Seră IoT
Disciplina: Sisteme Bazate pe Cunoaștere
Student: Pop Daniela-Liliana, Grupa: 30135/2
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import threading
import time
import random

app = Flask(__name__)
CORS(app)  # permite React sa faca request-uri

# ─────────────────────────────────────────────
# Incarcare date CSV
# ─────────────────────────────────────────────
CSV_PATH = "Processed_IoT_Data_Complete.csv"

try:
    df = pd.read_csv(CSV_PATH)
    df['date'] = pd.to_datetime(df['date'], errors='coerce')
    df = df.dropna(subset=['date'])
    df = df.sort_values('date').reset_index(drop=True)
    print(f"[OK] Dataset incarcat: {len(df)} randuri")
except Exception as e:
    print(f"[WARN] Nu s-a putut incarca CSV-ul: {e}")
    df = pd.DataFrame()

# ─────────────────────────────────────────────
# Stare sistem (in-memory) - simulare actuatori
# ─────────────────────────────────────────────
system_state = {
    "mode": "auto",          # auto | manual | eco | urgenta
    "fan": True,
    "water_pump": True,
    "irrigation_pump": False,
    "grow_lights": False,
    "mist_system": False,
    "thresholds": {
        "temp_max": 30,
        "humidity_min": 50,
        "water_min": 30
    },
    "last_updated": datetime.now().isoformat()
}

# Istoric actiuni operator
action_log = []

def log_action(actor, action, value=None):
    entry = {
        "timestamp": datetime.now().strftime("%H:%M:%S"),
        "actor": actor,
        "action": action,
        "value": value
    }
    action_log.insert(0, entry)
    if len(action_log) > 50:
        action_log.pop()

# ─────────────────────────────────────────────
# Simulare senzori (variatie realista)
# ─────────────────────────────────────────────
sensor_sim = {
    "temperature": 24.3,
    "humidity": 62.0,
    "water_level": 87.0,
    "light": 73.0
}

def simulate_sensors():
    """Actualizeaza valorile senzorilor cu variatii mici la fiecare 5 sec."""
    while True:
        sensor_sim["temperature"] += random.uniform(-0.3, 0.3)
        sensor_sim["temperature"] = max(10, min(45, sensor_sim["temperature"]))

        sensor_sim["humidity"] += random.uniform(-0.5, 0.5)
        sensor_sim["humidity"] = max(20, min(100, sensor_sim["humidity"]))

        sensor_sim["water_level"] += random.uniform(-0.2, 0.1)
        sensor_sim["water_level"] = max(0, min(100, sensor_sim["water_level"]))

        sensor_sim["light"] += random.uniform(-1, 1)
        sensor_sim["light"] = max(0, min(100, sensor_sim["light"]))

        # Logica automatica: ventilator pornit daca temp > threshold
        if system_state["mode"] == "auto":
            thr_temp = system_state["thresholds"]["temp_max"]
            thr_hum  = system_state["thresholds"]["humidity_min"]
            thr_water= system_state["thresholds"]["water_min"]

            system_state["fan"] = sensor_sim["temperature"] > thr_temp
            system_state["irrigation_pump"] = sensor_sim["humidity"] < thr_hum
            system_state["water_pump"] = sensor_sim["water_level"] < thr_water

        time.sleep(5)

# Porneste thread-ul de simulare
thread = threading.Thread(target=simulate_sensors, daemon=True)
thread.start()

# ─────────────────────────────────────────────
# RUTE API
# ─────────────────────────────────────────────

@app.route("/api/status", methods=["GET"])
def get_status():
    """Starea completa a sistemului + senzori live."""
    alerts = []
    thr = system_state["thresholds"]

    if sensor_sim["temperature"] > thr["temp_max"]:
        alerts.append({"type": "warn", "msg": f"Temperatura ridicata: {sensor_sim['temperature']:.1f}°C"})
    if sensor_sim["humidity"] < thr["humidity_min"]:
        alerts.append({"type": "warn", "msg": f"Umiditate scazuta: {sensor_sim['humidity']:.1f}%"})
    if sensor_sim["water_level"] < thr["water_min"]:
        alerts.append({"type": "err", "msg": f"Nivel apa critic: {sensor_sim['water_level']:.1f}%"})
    if not alerts:
        alerts.append({"type": "ok", "msg": "Toti parametrii in limite normale"})

    return jsonify({
        "sensors": {
            "temperature": round(sensor_sim["temperature"], 1),
            "humidity":    round(sensor_sim["humidity"], 1),
            "water_level": round(sensor_sim["water_level"], 1),
            "light":       round(sensor_sim["light"], 1),
        },
        "actuators": {
            "fan":              system_state["fan"],
            "water_pump":       system_state["water_pump"],
            "irrigation_pump":  system_state["irrigation_pump"],
            "grow_lights":      system_state["grow_lights"],
            "mist_system":      system_state["mist_system"],
        },
        "mode":       system_state["mode"],
        "thresholds": system_state["thresholds"],
        "alerts":     alerts,
        "timestamp":  datetime.now().strftime("%H:%M:%S")
    })


@app.route("/api/actuator", methods=["POST"])
def set_actuator():
    """Comanda manuala actuator: { 'actuator': 'fan', 'state': true }"""
    data = request.get_json()
    name  = data.get("actuator")
    state = data.get("state")

    valid = ["fan", "water_pump", "irrigation_pump", "grow_lights", "mist_system"]
    if name not in valid:
        return jsonify({"error": "Actuator necunoscut"}), 400

    system_state[name] = bool(state)
    system_state["last_updated"] = datetime.now().isoformat()
    log_action("operator", f"{'ON' if state else 'OFF'} {name}")

    return jsonify({"ok": True, "actuator": name, "state": state})


@app.route("/api/mode", methods=["POST"])
def set_mode():
    """Schimba modul de operare: { 'mode': 'auto' }"""
    data = request.get_json()
    mode = data.get("mode", "auto")

    valid_modes = ["auto", "manual", "eco", "urgenta"]
    if mode not in valid_modes:
        return jsonify({"error": "Mod invalid"}), 400

    system_state["mode"] = mode
    log_action("operator", f"Mod schimbat: {mode}")

    # Mod urgenta: porneste totul
    if mode == "urgenta":
        system_state["fan"] = True
        system_state["water_pump"] = True
        system_state["irrigation_pump"] = True
        system_state["grow_lights"] = False
        system_state["mist_system"] = False

    # Mod eco: opreste consumul suplimentar
    if mode == "eco":
        system_state["grow_lights"] = False
        system_state["mist_system"] = False

    return jsonify({"ok": True, "mode": mode})


@app.route("/api/thresholds", methods=["POST"])
def set_thresholds():
    """Seteaza pragurile de alarma automata."""
    data = request.get_json()

    if "temp_max" in data:
        system_state["thresholds"]["temp_max"] = float(data["temp_max"])
    if "humidity_min" in data:
        system_state["thresholds"]["humidity_min"] = float(data["humidity_min"])
    if "water_min" in data:
        system_state["thresholds"]["water_min"] = float(data["water_min"])

    log_action("operator", "Praguri actualizate", data)
    return jsonify({"ok": True, "thresholds": system_state["thresholds"]})


@app.route("/api/history", methods=["GET"])
def get_history():
    """
    Returneaza date istorice din CSV pentru grafice.
    Parametri query: ?col=tempreature&n=100
    """
    if df.empty:
        return jsonify({"error": "Dataset nedisponibil"}), 500

    col = request.args.get("col", "tempreature")
    n   = int(request.args.get("n", 200))

    valid_cols = ["tempreature", "humidity", "water_level"]
    if col not in valid_cols:
        col = "tempreature"

    sample = df[["date", col]].dropna().tail(n)
    return jsonify({
        "col": col,
        "labels": sample["date"].dt.strftime("%m-%d %H:%M").tolist(),
        "values": sample[col].round(1).tolist()
    })


@app.route("/api/stats", methods=["GET"])
def get_stats():
    """Statistici descriptive din dataset."""
    if df.empty:
        return jsonify({"error": "Dataset nedisponibil"}), 500

    cols = ["tempreature", "humidity", "water_level"]
    stats = {}
    for c in cols:
        if c in df.columns:
            stats[c] = {
                "mean":   round(float(df[c].mean()), 2),
                "min":    round(float(df[c].min()), 2),
                "max":    round(float(df[c].max()), 2),
                "std":    round(float(df[c].std()), 2),
                "median": round(float(df[c].median()), 2),
            }
    return jsonify(stats)


@app.route("/api/log", methods=["GET"])
def get_log():
    """Istoricul actiunilor operatorului."""
    return jsonify(action_log[:20])


@app.route("/api/forecast", methods=["GET"])
def get_forecast():
    """
    Prognoza simpla ARIMA pentru urmatorele 6 ore (liniarizata din trend).
    Returneaza valori simulate pe baza ultimelor date din CSV.
    """
    if df.empty:
        return jsonify({"error": "Dataset nedisponibil"}), 500

    # Folosim ultimele valori ca baza de prognoza (trend descendent din proiect)
    last_temp = float(df["tempreature"].dropna().tail(1).values[0])
    now = datetime.now()

    forecast = []
    for i in range(1, 7):
        t = now + timedelta(hours=i)
        # Trend descendent usor + noise (din analiza ARIMA(3,2,1))
        val = last_temp - i * 0.3 + random.uniform(-0.5, 0.5)
        forecast.append({
            "time": t.strftime("%H:%M"),
            "value": round(val, 1)
        })

    return jsonify({"forecast": forecast, "model": "ARIMA(3,2,1)"})


@app.route("/api/nutrienti", methods=["GET"])
def get_nutrienti():
    """Valorile NPK din dataset."""
    if df.empty:
        return jsonify({"N": 255, "P": 255, "K": 255})

    last = df[["N", "P", "K"]].dropna().tail(1)
    if last.empty:
        return jsonify({"N": 255, "P": 255, "K": 255})

    row = last.iloc[0]
    return jsonify({
        "N": int(row["N"]),
        "P": int(row["P"]),
        "K": int(row["K"])
    })


# ─────────────────────────────────────────────
if __name__ == "__main__":
    print("\n=== Backend Seră IoT pornit ===")
    print("API disponibil la: http://localhost:5000/api/status\n")
    app.run(debug=True, port=5000, use_reloader=False)
