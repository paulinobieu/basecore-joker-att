import { isEnvBrowser } from '@app/utils/misc'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'

import '@views/styles/index.css'

if (isEnvBrowser()) {
  const root = document.getElementById('root')!
  root.style.backgroundImage =
    "url('https://files.fivemerr.com/images/ab427266-34e9-4649-8024-077a230837c6.png')"
  root.style.backgroundSize = 'cover'
  root.style.backgroundRepeat = 'no-repeat'
  root.style.backgroundPosition = 'center'
  root.style.height = '100vh'
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
