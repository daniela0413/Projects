import React from 'react';

const ACTUATORS = [
  { id: 'fan',             label: 'Ventilator',         icon: '🌀', desc: 'Răcire / circulație aer' },
  { id: 'water_pump',      label: 'Pompă apă',          icon: '⛽', desc: 'Rezervor principal' },
  { id: 'irrigation_pump', label: 'Pompă irigare',      icon: '🚿', desc: 'Udarea plantelor' },
  { id: 'grow_lights',     label: 'Iluminat LED',       icon: '💡', desc: 'Grow lights suplimentare' },
  { id: 'mist_system',     label: 'Sistem ceată',       icon: '🌫', desc: 'Umidificare fină' },
];

const s = {
  panel: {
    background: 'var(--surface)',
    border: '0.5px solid var(--border)',
    borderRadius: 'var(--radius-lg)',
    padding: '1rem 1.25rem',
  },
  title: {
    fontSize: 11,
    fontWeight: 500,
    color: 'var(--text-muted)',
    textTransform: 'uppercase',
    letterSpacing: '0.06em',
    marginBottom: '0.85rem',
    display: 'flex',
    alignItems: 'center',
    gap: 6,
  },
  row: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '9px 0',
    borderBottom: '0.5px solid var(--border)',
  },
  rowLast: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '9px 0 2px',
  },
  left: { display: 'flex', alignItems: 'center', gap: 10 },
  iconWrap: { fontSize: 18, width: 26, textAlign: 'center' },
  name: { fontSize: 13, fontWeight: 500 },
  desc: { fontSize: 11, color: 'var(--text-muted)', marginTop: 1 },
  right: { display: 'flex', alignItems: 'center', gap: 8 },
  statusText: (on) => ({
    fontSize: 11,
    fontFamily: 'var(--mono)',
    color: on ? 'var(--green)' : 'var(--text-muted)',
    minWidth: 28,
    textAlign: 'right',
  }),
};

/* Toggle switch CSS-in-JS */
const toggleStyle = `
  .act-toggle { position: relative; display: inline-block; width: 40px; height: 22px; }
  .act-toggle input { opacity: 0; width: 0; height: 0; }
  .act-slider {
    position: absolute; top:0; left:0; right:0; bottom:0;
    background: rgba(0,0,0,0.15);
    border-radius: 22px;
    transition: 0.25s;
    cursor: pointer;
  }
  .act-slider:before {
    content: '';
    position: absolute;
    width: 16px; height: 16px;
    left: 3px; top: 3px;
    background: #fff;
    border-radius: 50%;
    transition: 0.25s;
  }
  input:checked + .act-slider { background: #1D9E75; }
  input:checked + .act-slider:before { transform: translateX(18px); }
  .act-toggle input:disabled + .act-slider { opacity: 0.5; cursor: not-allowed; }
`;

export default function ActuatorPanel({ actuators, mode, onToggle }) {
  const isManual = mode === 'manual' || mode === 'urgenta';

  return (
    <div style={s.panel}>
      <style>{toggleStyle}</style>
      <div style={s.title}>⚙️ Control actuatori {!isManual && <span style={{color:'var(--green)', fontSize:10}}>(mod {mode})</span>}</div>

      {ACTUATORS.map((act, i) => {
        const on = !!actuators[act.id];
        const rowStyle = i === ACTUATORS.length - 1 ? s.rowLast : s.row;
        return (
          <div key={act.id} style={rowStyle}>
            <div style={s.left}>
              <div style={s.iconWrap}>{act.icon}</div>
              <div>
                <div style={s.name}>{act.label}</div>
                <div style={s.desc}>{act.desc}</div>
              </div>
            </div>
            <div style={s.right}>
              <span style={s.statusText(on)}>{on ? 'ON' : 'OFF'}</span>
              <label className="act-toggle" aria-label={`Comutare ${act.label}`}>
                <input
                  type="checkbox"
                  checked={on}
                  disabled={!isManual && act.id !== 'grow_lights' && act.id !== 'mist_system'}
                  onChange={e => onToggle(act.id, e.target.checked)}
                />
                <span className="act-slider"></span>
              </label>
            </div>
          </div>
        );
      })}

      {!isManual && (
        <div style={{ fontSize: 11, color: 'var(--text-muted)', marginTop: 10, lineHeight: 1.5 }}>
          💡 Schimbă în <strong>Manual</strong> pentru control complet al actuatorilor.
        </div>
      )}
    </div>
  );
}
