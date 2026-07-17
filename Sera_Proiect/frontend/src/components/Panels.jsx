import React from 'react';

/* ─── ALERTS ─── */
const alertColor = {
  ok:   { bg: '#E1F5EE', text: '#085041', icon: '✅' },
  warn: { bg: '#FAEEDA', text: '#633806', icon: '⚠️' },
  err:  { bg: '#FCEBEB', text: '#501313', icon: '🚨' },
};

export function AlertsPanel({ alerts }) {
  return (
    <div style={{ background: 'var(--surface)', border: '0.5px solid var(--border)', borderRadius: 'var(--radius-lg)', padding: '1rem 1.25rem' }}>
      <div style={{ fontSize: 11, fontWeight: 500, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.06em', marginBottom: 10 }}>
        🔔 Alerte sistem
      </div>
      {(!alerts || alerts.length === 0) && (
        <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>Fără alerte.</div>
      )}
      {alerts.map((a, i) => {
        const c = alertColor[a.type] || alertColor.ok;
        return (
          <div key={i} style={{
            background: c.bg, color: c.text,
            borderRadius: 'var(--radius-md)',
            padding: '7px 10px',
            fontSize: 12,
            marginBottom: 6,
            display: 'flex',
            gap: 7,
            alignItems: 'flex-start',
            lineHeight: 1.4,
          }}>
            <span>{c.icon}</span>
            <span>{a.msg}</span>
          </div>
        );
      })}
    </div>
  );
}

/* ─── NUTRIENTI ─── */
export function NutrientiPanel({ nutrienti }) {
  const items = [
    { key: 'N', label: 'Azot (N)',    color: '#639922' },
    { key: 'P', label: 'Fosfor (P)',  color: '#185FA5' },
    { key: 'K', label: 'Potasiu (K)', color: '#EF9F27' },
  ];
  return (
    <div style={{ background: 'var(--surface)', border: '0.5px solid var(--border)', borderRadius: 'var(--radius-lg)', padding: '1rem 1.25rem' }}>
      <div style={{ fontSize: 11, fontWeight: 500, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.06em', marginBottom: 10 }}>
        🧪 Nutrienți sol
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8 }}>
        {items.map(it => (
          <div key={it.key} style={{ textAlign: 'center', background: 'rgba(0,0,0,0.03)', borderRadius: 8, padding: '8px 4px' }}>
            <div style={{ fontFamily: 'var(--mono)', fontSize: 18, fontWeight: 500, color: it.color }}>
              {nutrienti?.[it.key] ?? '—'}
            </div>
            <div style={{ fontSize: 10, color: 'var(--text-muted)', marginTop: 2 }}>{it.label}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

/* ─── THRESHOLD ─── */
export function ThresholdPanel({ thresholds, onThreshold }) {
  const [local, setLocal] = React.useState(thresholds);

  React.useEffect(() => { setLocal(thresholds); }, [thresholds]);

  const handleChange = (field, val) => {
    setLocal(prev => ({ ...prev, [field]: Number(val) }));
  };

  const handleApply = () => {
    onThreshold('temp_max',     local.temp_max);
    onThreshold('humidity_min', local.humidity_min);
    onThreshold('water_min',    local.water_min);
  };

  const rows = [
    { field: 'temp_max',     label: 'Temp. max.',   unit: '°C', min: 15, max: 45 },
    { field: 'humidity_min', label: 'Umid. min.',   unit: '%',  min: 20, max: 90 },
    { field: 'water_min',    label: 'Apă min.',     unit: '%',  min: 10, max: 80 },
  ];

  return (
    <div style={{ background: 'var(--surface)', border: '0.5px solid var(--border)', borderRadius: 'var(--radius-lg)', padding: '1rem 1.25rem' }}>
      <div style={{ fontSize: 11, fontWeight: 500, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.06em', marginBottom: 12 }}>
        🎚 Praguri automat
      </div>
      {rows.map(r => (
        <div key={r.field} style={{ marginBottom: 14 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12, marginBottom: 4 }}>
            <span>{r.label}</span>
            <span style={{ fontFamily: 'var(--mono)', color: 'var(--text-muted)' }}>
              {local[r.field]}{r.unit}
            </span>
          </div>
          <input
            type="range" min={r.min} max={r.max} step="1"
            value={local[r.field]}
            onChange={e => handleChange(r.field, e.target.value)}
            style={{ width: '100%', accentColor: 'var(--green)' }}
          />
        </div>
      ))}
      <button
        onClick={handleApply}
        style={{
          width: '100%', padding: '8px', borderRadius: 'var(--radius-md)',
          background: 'var(--green)', color: '#fff', border: 'none',
          fontSize: 13, fontWeight: 500, cursor: 'pointer', marginTop: 4,
        }}
      >
        Aplică praguri
      </button>
    </div>
  );
}

/* ─── STATS ─── */
export function StatsPanel({ stats }) {
  const labels = {
    tempreature: { name: 'Temperatură', unit: '°C' },
    humidity:    { name: 'Umiditate',   unit: '%' },
    water_level: { name: 'Nivel apă',   unit: '%' },
  };

  return (
    <div style={{ background: 'var(--surface)', border: '0.5px solid var(--border)', borderRadius: 'var(--radius-lg)', padding: '1rem 1.25rem' }}>
      <div style={{ fontSize: 11, fontWeight: 500, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.06em', marginBottom: 12 }}>
        📊 Statistici dataset (37,922 înregistrări)
      </div>
      {Object.keys(labels).map(col => {
        const info = stats[col];
        const lbl  = labels[col];
        if (!info) return null;
        return (
          <div key={col} style={{ marginBottom: 12 }}>
            <div style={{ fontSize: 12, fontWeight: 500, marginBottom: 4 }}>{lbl.name}</div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 4 }}>
              {['mean', 'min', 'max'].map(k => (
                <div key={k} style={{ background: 'rgba(0,0,0,0.03)', borderRadius: 6, padding: '5px 7px', textAlign: 'center' }}>
                  <div style={{ fontSize: 13, fontFamily: 'var(--mono)', fontWeight: 500 }}>
                    {info[k]}{lbl.unit}
                  </div>
                  <div style={{ fontSize: 10, color: 'var(--text-muted)' }}>{k}</div>
                </div>
              ))}
            </div>
          </div>
        );
      })}
    </div>
  );
}

/* ─── LOG ─── */
export function LogPanel({ log }) {
  return (
    <div style={{ background: 'var(--surface)', border: '0.5px solid var(--border)', borderRadius: 'var(--radius-lg)', padding: '1rem 1.25rem' }}>
      <div style={{ fontSize: 11, fontWeight: 500, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.06em', marginBottom: 10 }}>
        📋 Jurnal acțiuni operator
      </div>
      <div style={{ maxHeight: 200, overflowY: 'auto' }}>
        {(!log || log.length === 0) && (
          <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>Fără acțiuni înregistrate.</div>
        )}
        {log.map((entry, i) => (
          <div key={i} style={{
            fontFamily: 'var(--mono)',
            fontSize: 11,
            padding: '4px 0',
            borderBottom: '0.5px solid var(--border)',
            display: 'flex',
            gap: 8,
            color: 'var(--text-muted)',
          }}>
            <span style={{ color: 'var(--green)', flexShrink: 0 }}>{entry.timestamp}</span>
            <span style={{ color: 'var(--text)' }}>{entry.action}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

export default AlertsPanel;
