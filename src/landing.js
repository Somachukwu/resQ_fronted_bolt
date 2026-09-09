import './styles/resq.css'
import '../style.css'
import { initTheme, createThemeToggle } from './lib/theme.js'

const app = document.querySelector('#app')
const mode = initTheme()
app.innerHTML = `
  <div class="landing-shell">
    <header class="landing-nav"><a class="wordmark" href="/"><span class="wordmark-mark">R</span><span>ResQ</span></a><div class="nav-right"><span class="live-dot"></span><span class="nav-status">Response network online</span><span id="theme-slot"></span></div></header>
    <section class="landing-hero"><div class="eyebrow"><span class="eyebrow-line"></span>Responsive Emergency Systems Intelligence</div><h1>When every second<br/><em>changes everything.</em></h1><p>One connected response system for civilians, dispatchers, and responders across Nigeria.</p><div class="hero-actions"><a href="/civilian/" class="btn btn-amber hero-sos"><span class="sos-ring"></span>Report an emergency</a><a href="#portals" class="btn btn-ghost">Explore the network <span>↓</span></a></div></section>
    <section id="portals" class="portal-section"><div class="section-label">One system. Three perspectives.</div><div class="portal-grid"><a class="portal-card civilian-card" href="/civilian/"><div class="portal-top"><span class="portal-number">01</span><span class="portal-arrow">↗</span></div><div class="portal-icon">⌁</div><h2>Civilian</h2><p>Get calm, clear guidance when you need it most.</p><span class="portal-link">Open emergency guide <span>→</span></span></a><a class="portal-card dispatcher-card" href="/dispatcher/"><div class="portal-top"><span class="portal-number">02</span><span class="portal-arrow">↗</span></div><div class="portal-icon">⌖</div><h2>Dispatcher</h2><p>See the whole picture. Move the right help faster.</p><span class="portal-link">Open command center <span>→</span></span></a><a class="portal-card responder-card" href="/responder/"><div class="portal-top"><span class="portal-number">03</span><span class="portal-arrow">↗</span></div><div class="portal-icon">◉</div><h2>Responder</h2><p>Know the scene before you arrive.</p><span class="portal-link">Open scene brief <span>→</span></span></a></div></section>
    <footer class="landing-footer"><span>Built for the moments that matter.</span><span>ResQ / Nigeria, 2026</span></footer>
  </div>`
createThemeToggle(document.querySelector('#theme-slot'), mode)
