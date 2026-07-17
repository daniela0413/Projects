import React from 'react';

const s = {
  card: {
    background: 'var(--surface)',
    border: '0.5px solid var(--border)',
    borderRadius: 'var(--radius-lg)',
    padding: '1rem 1.1rem',
  },
  label: {
    fontSize: 11,
    color: 'var(--text-muted)',
    textTransform: 'uppercase',
    letterSpacing: '0.06em',
    marginBottom: 4,
    display: 'flex',
    alignItems: 'center',
    gap: 5,
  },
  value: {
    fontFamily: 'var(--mono)',
    fontSize: 26,
    fontWeight: 500,
    lineHeight: 1.1,
  },
  unit: {
    fontSize: 14,
    fontWeight: 400,
    color: 'var(--text-muted)',
    marginLeft: 2,
  },
  barWrap: {
    height: 3,
    borderRadius: 2,
    background: 'rgba(0,0,0,0.07)',
    marginTop: 10,
    overflow: 'hidden',
  },
};

export default function SensorCard({ label, value, unit, icon, color, max = 100 }) {
  const pct = value != null ? Math.min(100, Math.round((value / max) * 100)) : 0;
  const display = value != null ? value.toFixed(1) : '—';

  return (
    <div style={s.card}>
      <div style={s.label}>
        <span>{icon}</span> {label}
      </div>
      <div style={s.value}>
        {display}
        <span style={s.unit}>{unit}</span>
      </div>
      <div style={s.barWrap}>
        <div style={{
          height: '100%',
          width: `${pct}%`,
          background: color,
          borderRadius: 2,
          transition: 'width 0.6s ease',
        }} />
      </div>
    </div>
  );
}
