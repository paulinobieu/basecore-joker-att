import { useEffect, useState } from 'react'
import { useClickSound } from './hooks/useClickSound'
import { useNuiEvent } from './hooks/useNuiEvent'
import { useVisibility } from './hooks/useVisibility'
import { fetchNui } from './utils/fetchNui'
import { isEnvBrowser } from './utils/misc'
import { ElevatorIcon, PersonIcon } from './components/Icons'

interface Floor {
    label: string
    index: number
    disabled: boolean
}

interface ElevatorData {
    title: string
    currentFloor: string
    floors: Floor[]
}

const mockData: ElevatorData = {
    title: 'Selecione o andar',
    currentFloor: 'Térreo',
    floors: [
        { label: 'Heliponto', index: 0, disabled: false },
        { label: 'Térreo', index: 1, disabled: true },
        { label: 'Garagem', index: 2, disabled: false },
    ],
}

function hexToRgbTuple(hex: string): [number, number, number] | null {
    const value = hex.replace('#', '')
    if (value.length !== 6) return null
    const num = Number.parseInt(value, 16)
    if (Number.isNaN(num)) return null
    return [(num >> 16) & 255, (num >> 8) & 255, num & 255]
}

function App() {
    useClickSound()
    const { visible, setVisible, handleClose } = useVisibility()
    const [closing, setClosing] = useState(false)
    const [elevatorData, setElevatorData] = useState<ElevatorData | null>(null)

    useEffect(() => {
        if (isEnvBrowser()) {
            setVisible(true)
            setElevatorData(mockData)
        }
    }, [setVisible])

    useNuiEvent<string>('setThemeColor', (color) => {
        if (!color) return
        document.documentElement.style.setProperty('--theme-color', color)
        const rgb = hexToRgbTuple(color)
        if (rgb) {
            document.documentElement.style.setProperty('--theme-color-rgb', rgb.join(', '))
        }
    })

    useNuiEvent<ElevatorData>('openElevator', (data) => {
        setElevatorData(data)
        setClosing(false)
        setVisible(true)
    })

    const closeWithAnimation = () => {
        if (closing) return
        setClosing(true)
        setTimeout(() => {
            setClosing(false)
            setElevatorData(null)
            handleClose()
        }, 300)
    }

    useEffect(() => {
        const onKeyDown = (e: KeyboardEvent) => {
            if (e.key === 'Escape') closeWithAnimation()
        }
        window.addEventListener('keydown', onKeyDown)
        return () => window.removeEventListener('keydown', onKeyDown)
    }, [closing])

    const handleSelectFloor = (floor: Floor) => {
        if (floor.disabled) return
        fetchNui('core-elevator', { action: 'selectFloor', floorIndex: floor.index })
        closeWithAnimation()
    }

    if (!visible && !closing) return null
    if (!elevatorData) return null

    return (
        <main className={`elevator-root${isEnvBrowser() ? ' browser-mode' : ''}`}>
            <section className={`elevator-shell ${closing ? 'elevator-shell--closing' : 'elevator-shell--opening'}`}>
                <div className="elevator-frame">
                    <div className="elevator-inner">
                        {/* Title */}
                        <div className="elevator-title">
                            <div className="title-icon">
                                <svg className="title-icon-bg" viewBox="0 0 36 36" fill="none">
                                    <rect x="18" y="2" width="22.63" height="22.63" rx="4" transform="rotate(45 18 2)" fill="var(--theme-color)" fillOpacity="0.2" stroke="var(--theme-color)" strokeWidth="1.2" />
                                    <rect x="18" y="6" width="16.97" height="16.97" rx="3" transform="rotate(45 18 6)" fill="var(--theme-color)" fillOpacity="0.5" />
                                </svg>
                                <ElevatorIcon size={26} />
                            </div>
                            <div>
                                <h1>Elevador</h1>
                                <p>Selecione o andar de destino</p>
                            </div>
                        </div>

                        {/* Floor List */}
                        <div className="floors-list">
                            {elevatorData.floors.filter((f) => !f.disabled).map((floor) => (
                                <div
                                    key={floor.index}
                                    className="floor-item"
                                    onClick={() => handleSelectFloor(floor)}
                                >
                                    <span className="floor-item-name">{floor.label}</span>
                                    <div className="floor-item-arrow">
                                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                                            <polyline points="9 18 15 12 9 6" />
                                        </svg>
                                    </div>
                                </div>
                            ))}
                        </div>

                        {/* Current Floor */}
                        <div className="current-floor-section">
                            <div className="current-floor-header">
                                <div className="section-line" />
                                <p>Andar Atual</p>
                                <div className="section-line section-line--right" />
                            </div>
                            <div className="current-floor-card">
                                <div className="current-floor-icon">
                                    <PersonIcon size={14} />
                                </div>
                                <strong className="current-floor-name">{elevatorData.currentFloor}</strong>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </main>
    )
}

export default App
