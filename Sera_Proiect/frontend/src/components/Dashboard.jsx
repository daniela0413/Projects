import React from 'react';
import SensorCard from './SensorCard';
import ActuatorPanel from './ActuatorPanel';
import ChartPanel from './ChartPanel';
import ModeSelector from './ModeSelector';
import { AlertsPanel, NutrientiPanel, ThresholdPanel, StatsPanel, LogPanel } from './Panels';

/* SVG frunza pentru hero */
const LeafSVG = ({ style }) => (
  <svg style={style} viewBox="0 0 160 200" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M80 190 Q10 140 20 60 Q50 110 100 80 Q90 130 80 190Z" fill="white"/>
    <path d="M80 190 Q150 140 140 60 Q110 110 60 80 Q70 130 80 190Z" fill="white" opacity="0.5"/>
    <path d="M80 60 L80 185" stroke="white" strokeWidth="1.5" strokeOpacity="0.4"/>
    <path d="M80 100 Q60 90 45 95" stroke="white" strokeWidth="1" strokeOpacity="0.3"/>
    <path d="M80 120 Q100 110 115 115" stroke="white" strokeWidth="1" strokeOpacity="0.3"/>
    <path d="M80 140 Q62 132 50 136" stroke="white" strokeWidth="1" strokeOpacity="0.3"/>
  </svg>
);

const s = {
  root: { minHeight: '100vh', padding: '0 0 2rem' },
  header: {
    background: 'rgba(255,255,255,0.97)',
    backdropFilter: 'blur(8px)',
    borderBottom: '0.5px solid var(--border)',
    padding: '0.85rem 1.5rem',
    display: 'flex', alignItems: 'center', justifyContent: 'space-between',
    position: 'sticky', top: 0, zIndex: 10,
  },
  logo: { display: 'flex', alignItems: 'center', gap: 10 },
  logoIcon: {
    width: 34, height: 34, background: 'var(--green)',
    borderRadius: 'var(--radius-md)',
    display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18,
  },
  logoTitle: { fontSize: 15, fontWeight: 600, color: 'var(--text)' },
  logoSub:   { fontSize: 11, color: 'var(--text-muted)', marginTop: 1 },
  pill: {
    display: 'flex', alignItems: 'center', gap: 6,
    fontSize: 11, fontFamily: 'var(--mono)',
    color: 'var(--green-dark)', background: 'var(--green-light)',
    border: '0.5px solid #5DCAA5', borderRadius: 20, padding: '4px 12px',
  },
  dot: {
    width: 7, height: 7, borderRadius: '50%', background: 'var(--green)',
    animation: 'pulse 2s infinite',
  },
  main: {
    maxWidth: 1200, margin: '0 auto',
    padding: '1.25rem 1.5rem',
    display: 'grid', gap: '1rem',
  },
  sensorsRow: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))',
    gap: '0.75rem',
  },
  row2: { display: 'grid', gridTemplateColumns: '1.15fr 1fr', gap: '1rem' },
  row3: { display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '1rem' },
  alertCol: { display: 'flex', flexDirection: 'column', gap: '1rem' },
  errorBanner: {
    background: 'var(--red-light)', color: 'var(--red)',
    border: '0.5px solid #F09595', borderRadius: 'var(--radius-md)',
    padding: '10px 14px', fontSize: 13,
    display: 'flex', alignItems: 'center', gap: 8,
  },
};

export default function Dashboard({
  status, error,
  history, historyCol, onHistoryColChange,
  forecast, stats, log, nutrienti,
  onActuator, onMode, onThreshold,
}) {
  const sensors    = status?.sensors    ?? {};
  const actuators  = status?.actuators  ?? {};
  const alerts     = status?.alerts     ?? [];
  const mode       = status?.mode       ?? 'auto';
  const thresholds = status?.thresholds ?? { temp_max: 30, humidity_min: 50, water_min: 30 };
  const ts         = status?.timestamp  ?? '--:--:--';

  const tempOk  = sensors.temperature != null;
  const modeLabel = { auto: 'Automat', manual: 'Manual', eco: 'Eco', urgenta: 'Urgență' }[mode] ?? mode;

  return (
    <div style={s.root}>

      {/* ── Header sticky ── */}
      <header style={s.header}>
        <div style={s.logo}>
          <div style={s.logoIcon}>🌿</div>
          <div>
            <div style={s.logoTitle}>SmartGreen — Control Seră IoT</div>
            <div style={s.logoSub}>Sera #1 · Pop Daniela-Liliana · AC 2026 · UTCluj-Napoca</div>
          </div>
        </div>
        <div style={s.pill}>
          <div style={s.dot}></div>
          <span>{ts}</span>
        </div>
      </header>

      {/* ── Hero banner cu frunze ── */}
      <div className="gh-hero">
        {/* frunze decorative animate */}
        <LeafSVG style={{ position:'absolute', top:-20, right:60,  width:130, opacity:0.13, animation:'leafFloat 8s ease-in-out infinite' }} />
        <LeafSVG style={{ position:'absolute', top:10,  right:220, width:85,  opacity:0.10, animation:'leafFloat 8s ease-in-out infinite', animationDelay:'2s', transform:'scaleX(-1) rotate(-10deg)' }} />
        <LeafSVG style={{ position:'absolute', bottom:-15, right:140, width:110, opacity:0.09, animation:'leafFloat 9s ease-in-out infinite', animationDelay:'4s', transform:'rotate(25deg)' }} />
        <LeafSVG style={{ position:'absolute', top:5, right:380, width:70, opacity:0.08, animation:'leafFloat 10s ease-in-out infinite', animationDelay:'1s', transform:'rotate(-15deg)' }} />

        <div className="gh-hero-content">
          <div className="gh-hero-title">🌱 Sistem Inteligent de Monitorizare Seră</div>
          <div className="gh-hero-sub">IoT · Machine Learning · Control Automatizat · Date în timp real</div>
          <div className="gh-hero-stats">
            <div>
              <div className="gh-hero-stat-val">{tempOk ? `${sensors.temperature?.toFixed(1)}°C` : '—'}</div>
              <div className="gh-hero-stat-lbl">Temperatură curentă</div>
            </div>
            <div>
              <div className="gh-hero-stat-val">{sensors.humidity?.toFixed(0) ?? '—'}%</div>
              <div className="gh-hero-stat-lbl">Umiditate</div>
            </div>
            <div>
              <div className="gh-hero-stat-val">{sensors.water_level?.toFixed(0) ?? '—'}%</div>
              <div className="gh-hero-stat-lbl">Nivel apă</div>
            </div>
            <div>
              <div className="gh-hero-stat-val">{modeLabel}</div>
              <div className="gh-hero-stat-lbl">Mod operare</div>
            </div>
            <div>
              <div className="gh-hero-stat-val">37,922</div>
              <div className="gh-hero-stat-lbl">Înregistrări dataset</div>
            </div>
          </div>
        </div>
      </div>

      {/* ── Conținut principal ── */}
      <main style={s.main}>
        {error && <div style={s.errorBanner}>⚠ {error}</div>}

        <ModeSelector mode={mode} onMode={onMode} />

        <div style={s.sensorsRow}>
          <SensorCard label="Temperatură" value={sensors.temperature} unit="°C"
            icon="🌡" color="#1D9E75" max={45} />
          <SensorCard label="Umiditate" value={sensors.humidity} unit="%"
            icon="💧" color="#185FA5" max={100} />
          <SensorCard label="Nivel apă" value={sensors.water_level} unit="%"
            icon="🪣" color="#185FA5" max={100} />
          <SensorCard label="Lumină naturală" value={sensors.light} unit="%"
            icon="☀️" color="#EF9F27" max={100} />
        </div>

        <div style={s.row2}>
          <ActuatorPanel actuators={actuators} mode={mode} onToggle={onActuator} />
          <div style={s.alertCol}>
            <AlertsPanel alerts={alerts} />
            <NutrientiPanel nutrienti={nutrienti} />
          </div>
        </div>

        <ChartPanel
          history={history}
          historyCol={historyCol}
          onColChange={onHistoryColChange}
          forecast={forecast}
        />

        <div style={s.row3}>
          <ThresholdPanel thresholds={thresholds} onThreshold={onThreshold} />
          <StatsPanel stats={stats} />
          <LogPanel log={log} />
        </div>
      </main>
    </div>
  );
}
