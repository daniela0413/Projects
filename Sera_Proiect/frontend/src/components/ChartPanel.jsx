import React from 'react';
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid,
  Tooltip, Legend, ResponsiveContainer
} from 'recharts';

const COLS = [
  { id: 'tempreature', label: 'Temperatură (°C)', color: '#1D9E75' },
  { id: 'humidity',    label: 'Umiditate (%)',    color: '#185FA5' },
  { id: 'water_level', label: 'Nivel apă (%)',    color: '#EF9F27' },
];

const s = {
  panel: {
    background: 'var(--surface)',
    border: '0.5px solid var(--border)',
    borderRadius: 'var(--radius-lg)',
    padding: '1rem 1.25rem',
  },
  header: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: '1rem',
    flexWrap: 'wrap',
    gap: 8,
  },
  title: {
    fontSize: 11,
    fontWeight: 500,
    color: 'var(--text-muted)',
    textTransform: 'uppercase',
    letterSpacing: '0.06em',
    display: 'flex',
    alignItems: 'center',
    gap: 6,
  },
  tabs: {
    display: 'flex',
    gap: 4,
    background: 'rgba(0,0,0,0.04)',
    borderRadius: 'var(--radius-md)',
    padding: 3,
  },
  tab: (active) => ({
    padding: '4px 12px',
    fontSize: 12,
    borderRadius: 6,
    border: active ? '0.5px solid var(--border)' : 'none',
    background: active ? 'var(--surface)' : 'transparent',
    fontWeight: active ? 500 : 400,
    color: active ? 'var(--text)' : 'var(--text-muted)',
    cursor: 'pointer',
    fontFamily: 'var(--sans)',
    transition: '0.15s',
  }),
};

export default function ChartPanel({ history, historyCol, onColChange, forecast }) {
  const colInfo = COLS.find(c => c.id === historyCol) || COLS[0];

  // Merge history + forecast in same array (ultimele 60 puncte din history)
  const histSlice = history.labels.slice(-60).map((lbl, i) => ({
    time:    lbl,
    istoric: history.values[history.values.length - 60 + i],
  }));

  const forecastData = (forecast || []).map(f => ({
    time:     f.time,
    prognoza: f.value,
  }));

  const combined = [
    ...histSlice,
    ...forecastData,
  ];

  return (
    <div style={s.panel}>
      <div style={s.header}>
        <div style={s.title}>📈 Evoluție date senzori (istoric + prognoză)</div>
        <div style={s.tabs}>
          {COLS.map(c => (
            <button
              key={c.id}
              style={s.tab(historyCol === c.id)}
              onClick={() => onColChange(c.id)}
            >
              {c.label}
            </button>
          ))}
        </div>
      </div>

      <ResponsiveContainer width="100%" height={260}>
        <LineChart data={combined} margin={{ top: 5, right: 10, left: -10, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(0,0,0,0.06)" />
          <XAxis
            dataKey="time"
            tick={{ fontSize: 10, fill: '#888' }}
            interval={Math.floor(combined.length / 8)}
          />
          <YAxis tick={{ fontSize: 10, fill: '#888' }} />
          <Tooltip
            contentStyle={{
              fontSize: 12,
              borderRadius: 8,
              border: '0.5px solid var(--border)',
              background: '#fff',
            }}
          />
          <Legend wrapperStyle={{ fontSize: 12 }} />
          <Line
            type="monotone"
            dataKey="istoric"
            name={colInfo.label}
            stroke={colInfo.color}
            dot={false}
            strokeWidth={1.5}
            connectNulls
          />
          <Line
            type="monotone"
            dataKey="prognoza"
            name="Prognoză ARIMA(3,2,1)"
            stroke="#D85A30"
            strokeDasharray="5 3"
            dot={false}
            strokeWidth={1.5}
            connectNulls
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
