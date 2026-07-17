import React, { useState, useEffect, useCallback } from 'react';
import axios from 'axios';
import Dashboard from './components/Dashboard';

const API = 'http://localhost:5000/api';
const POLL_MS = 4000;

export default function App() {
  const [status, setStatus]       = useState(null);
  const [history, setHistory]     = useState({ labels: [], values: [] });
  const [historyCol, setHistoryCol] = useState('tempreature');
  const [forecast, setForecast]   = useState([]);
  const [stats, setStats]         = useState({});
  const [log, setLog]             = useState([]);
  const [nutrienti, setNutrienti] = useState({ N: 255, P: 255, K: 255 });
  const [error, setError]         = useState(null);

  const fetchStatus = useCallback(async () => {
    try {
      const r = await axios.get(`${API}/status`);
      setStatus(r.data);
      setError(null);
    } catch {
      setError('Backend offline — pornește app.py');
    }
  }, []);

  const fetchHistory = useCallback(async (col) => {
    try {
      const r = await axios.get(`${API}/history?col=${col}&n=150`);
      setHistory({ labels: r.data.labels, values: r.data.values });
    } catch {}
  }, []);

  const fetchAux = useCallback(async () => {
    try {
      const [fc, st, lg, nu] = await Promise.all([
        axios.get(`${API}/forecast`),
        axios.get(`${API}/stats`),
        axios.get(`${API}/log`),
        axios.get(`${API}/nutrienti`),
      ]);
      setForecast(fc.data.forecast);
      setStats(st.data);
      setLog(lg.data);
      setNutrienti(nu.data);
    } catch {}
  }, []);

  // Polling principal
  useEffect(() => {
    fetchStatus();
    fetchAux();
    const id = setInterval(() => { fetchStatus(); }, POLL_MS);
    return () => clearInterval(id);
  }, [fetchStatus, fetchAux]);

  // Reincarca graficul cand se schimba coloana
  useEffect(() => {
    fetchHistory(historyCol);
  }, [historyCol, fetchHistory]);

  // ── Handlers pentru comenzi operator ──

  const handleActuator = async (name, state) => {
    try {
      await axios.post(`${API}/actuator`, { actuator: name, state });
      fetchStatus();
    } catch {}
  };

  const handleMode = async (mode) => {
    try {
      await axios.post(`${API}/mode`, { mode });
      fetchStatus();
      fetchAux();
    } catch {}
  };

  const handleThreshold = async (field, value) => {
    try {
      await axios.post(`${API}/thresholds`, { [field]: value });
      fetchStatus();
    } catch {}
  };

  return (
    <Dashboard
      status={status}
      error={error}
      history={history}
      historyCol={historyCol}
      onHistoryColChange={setHistoryCol}
      forecast={forecast}
      stats={stats}
      log={log}
      nutrienti={nutrienti}
      onActuator={handleActuator}
      onMode={handleMode}
      onThreshold={handleThreshold}
    />
  );
}
