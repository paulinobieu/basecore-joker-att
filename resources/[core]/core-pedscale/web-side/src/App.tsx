import { useState, useEffect } from 'react'
import { useNuiEvent } from './hooks/useNuiEvent'
import { useVisibility } from './hooks/useVisibility'
import { useClickSound } from './hooks/useClickSound'
import { isEnvBrowser } from './utils/misc'
import { HeightPanel } from './components/HeightPanel'
import type { OpenPayload } from './types'
import './index.css'

/**
 * O Lua manda uma cor só; as duas tonalidades escuras do tema saem dela, na
 * mesma proporção da identidade (#dc1553 → #9c0f3b → #650a26).
 */
function applyThemeColor(hex: string) {
    const value = hex.replace('#', '').trim()
    if (value.length !== 6) return

    const r = parseInt(value.substring(0, 2), 16)
    const g = parseInt(value.substring(2, 4), 16)
    const b = parseInt(value.substring(4, 6), 16)
    if ([r, g, b].some(Number.isNaN)) return

    const shade = (factor: number) =>
        [r, g, b].map((channel) => Math.round(channel * factor)).join(', ')

    const root = document.documentElement
    root.style.setProperty('--primaryColor', `${r}, ${g}, ${b}`)
    root.style.setProperty('--secondaryColor', shade(0.71))
    root.style.setProperty('--thirdyColor', shade(0.46))
}

const BROWSER_CONFIG: OpenPayload = {
    themeColor: '#dc1553',
    currentScale: 1.0,
    presets: [
        { id: 'small', label: 'Baixo', value: 0.93 },
        { id: 'medium', label: 'Médio', value: 0.965 },
        { id: 'normal', label: 'Normal', value: 1.0 },
        { id: 'large', label: 'Alto', value: 1.038 },
    ],
    range: { Min: 0.93, Max: 1.038, Step: 0.001 },
}

export default function App() {
    const { visible, closeFrame } = useVisibility()
    const [config, setConfig] = useState<OpenPayload | null>(
        isEnvBrowser() ? BROWSER_CONFIG : null
    )

    useClickSound()

    useNuiEvent<OpenPayload>('openPanel', (data) => {
        setConfig(data)
        if (data.themeColor) applyThemeColor(data.themeColor)
    })

    useNuiEvent<boolean>('setVisible', (data) => {
        if (!data) setConfig(isEnvBrowser() ? BROWSER_CONFIG : null)
    })

    useEffect(() => {
        if (isEnvBrowser()) {
            const openDev = () => {
                window.postMessage({ action: 'setVisible', data: true })
                window.postMessage({ action: 'openPanel', data: BROWSER_CONFIG })
            }
            ;(window as any).showPanel = openDev
        }
    }, [])

    if (!visible || !config) return null

    return (
        <div className={`nui-wrapper${isEnvBrowser() ? ' browser-mode' : ''}`}>
            <div className="pedscale-panel">
                <div className="panel-content">
                    <HeightPanel config={config} closeFrame={closeFrame} />
                </div>
            </div>
        </div>
    )
}
