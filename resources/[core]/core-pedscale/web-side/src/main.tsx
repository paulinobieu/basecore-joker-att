import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'
import { isEnvBrowser } from './utils/misc'

if (isEnvBrowser()) {
    const root = document.getElementById('root')
    if (root) {
        root.style.backgroundImage = 'url(https://i.imgur.com/KBpEbGr.png)'
        root.style.backgroundSize = 'cover'
        root.style.backgroundPosition = 'center'
    }
}

ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
        <App />
    </React.StrictMode>
)
