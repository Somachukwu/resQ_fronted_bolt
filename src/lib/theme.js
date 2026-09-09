const STORAGE_KEY = 'resq-theme'

function getSystemPref() {
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
}

function getStoredTheme() {
  try {
    return localStorage.getItem(STORAGE_KEY)
  } catch {
    return null
  }
}

export function initTheme(defaultMode) {
  const stored = getStoredTheme()
  const mode = stored || defaultMode || getSystemPref()
  applyTheme(mode)
  return mode
}

export function applyTheme(mode) {
  document.documentElement.setAttribute('data-theme', mode)
  try {
    localStorage.setItem(STORAGE_KEY, mode)
  } catch {
    // localStorage may be unavailable
  }
}

export function toggleTheme() {
  const current = document.documentElement.getAttribute('data-theme') || 'light'
  const next = current === 'dark' ? 'light' : 'dark'
  applyTheme(next)
  return next
}

export function createThemeToggle(container, mode = 'light') {
  const btn = document.createElement('button')
  btn.className = 'theme-toggle'
  btn.setAttribute('aria-label', 'Toggle light or dark theme')
  btn.innerHTML = `
    <svg class="theme-toggle-icon theme-toggle-sun" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
      <circle cx="12" cy="12" r="4"/>
      <path d="M12 2v2"/><path d="M12 20v2"/><path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/>
      <path d="M2 12h2"/><path d="M20 12h2"/><path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/>
    </svg>
    <svg class="theme-toggle-icon theme-toggle-moon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
      <path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/>
    </svg>
    <span class="theme-toggle-track"></span>
  `
  btn.addEventListener('click', () => {
    const next = toggleTheme()
    btn.setAttribute('data-theme', next)
  })
  btn.setAttribute('data-theme', mode)
  container.appendChild(btn)
  return btn
}
