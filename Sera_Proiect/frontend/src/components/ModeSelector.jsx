import React from 'react';

const MODES = [
  { id: 'auto',    label: 'Auto',    icon: '🤖', desc: 'Control automat bazat pe praguri' },
  { id: 'manual',  label: 'Manual',  icon: '🖐',  desc: 'Operator controlează manual' },
  { id: 'eco',     label: 'Eco',     icon: '🌿', desc: 'Consum redus de resurse' },
  { id: 'urgenta', label: 'Urgență', icon: '🚨', desc: 'Activare maximă — situație critică' },
];

const s = {
  wrap: {
    display: 'flex',
    gap: 8,
  },
  btn: (active, id) => ({
    flex: 1,
    padding: '10px 8px',
    border: active
      ? `1.5px solid ${id === 'urgenta' ? 'var(--red)' : 'var(--green)'}`
      : '0.5px solid var(--border)',
    borderRadius: 'var(--radius-md)',
    background: active
      ? (id === 'urgenta' ? 'var(--red-light)' : 'var(--green-light)')
      : 'var(--surface)',
    cursor: 'pointer',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: 4,
    transition: 'all 0.15s',
  }),
  icon: { fontSize: 18 },
  label: (active, id) => ({
    fontSize: 12,
    fontWeight: 500,
    color: active
      ? (id === 'urgenta' ? 'var(--red)' : 'var(--green-dark)')
      : 'var(--text-muted)',
  }),
};

export default function ModeSelector({ mode, onMode }) {
  return (
    <div style={s.wrap}>
      {MODES.map(m => (
        <button
          key={m.id}
          style={s.btn(mode === m.id, m.id)}
          onClick={() => onMode(m.id)}
          title={m.desc}
        >
          <span style={s.icon}>{m.icon}</span>
          <span style={s.label(mode === m.id, m.id)}>{m.label}</span>
        </button>
      ))}
    </div>
  );
}
