import { useState, useCallback, useEffect, useRef } from 'react'
import type { OpenPayload, Preset } from '../types'
import { fetchNui } from '../utils/fetchNui'
import { isEnvBrowser } from '../utils/misc'
import { PresetCard } from './PresetCard'
import { Hexagon } from './Hexagon'
import { ScaleIcon } from './Icons'

interface HeightPanelProps {
    config: OpenPayload
    closeFrame: () => void
}

export function HeightPanel({ config, closeFrame }: HeightPanelProps) {
    const { presets, range, currentScale } = config
    const [scale, setScale] = useState(currentScale)
    const [selectedPreset, setSelectedPreset] = useState<string | null>(() => {
        const match = presets.find((p) => Math.abs(p.value - currentScale) < 0.001)
        return match?.id ?? null
    })

    const throttleRef = useRef<number>(0)

    const sendScale = useCallback(
        (value: number) => {
            const now = Date.now()
            if (now - throttleRef.current < 30) return
            throttleRef.current = now

            if (!isEnvBrowser()) {
                fetchNui('applyScale', { scale: value })
            }
        },
        []
    )

    const handleSlider = useCallback(
        (e: React.ChangeEvent<HTMLInputElement>) => {
            const val = parseFloat(e.target.value)
            setScale(val)
            setSelectedPreset(null)
            sendScale(val)
        },
        [sendScale]
    )

    const handlePreset = useCallback(
        (preset: Preset) => {
            setScale(preset.value)
            setSelectedPreset(preset.id)
            sendScale(preset.value)
        },
        [sendScale]
    )

    const handleReset = useCallback(() => {
        const defaultVal = 1.0
        setScale(defaultVal)
        const match = presets.find((p) => Math.abs(p.value - defaultVal) < 0.001)
        setSelectedPreset(match?.id ?? null)

        if (!isEnvBrowser()) {
            fetchNui('resetScale')
        }
    }, [presets])

    useEffect(() => {
        setScale(currentScale)
        const match = presets.find((p) => Math.abs(p.value - currentScale) < 0.001)
        setSelectedPreset(match?.id ?? null)
    }, [currentScale, presets])

    const pct = ((scale - range.Min) / (range.Max - range.Min)) * 100

    return (
        <>
            {/* Header */}
            <div className="panel-header">
                <div className="panel-header-icon">
                    <Hexagon className="pedscale-hexagon" />
                    <ScaleIcon />
                </div>
                <div className="panel-header-info">
                    <span className="panel-header-title">AJUSTE DE ALTURA</span>
                    <span className="panel-header-subtitle">Personalização do Personagem</span>
                </div>
            </div>

            <div className="panel-divider" />

            {/* Slider */}
            <div className="slider-section">
                <div className="section-label">
                    <span className="section-label-text">Altura manual</span>
                    <span className="section-value">{(scale * 100).toFixed(1)}%</span>
                </div>

                <div className="slider-container">
                    <div className="slider-track">
                        <div className="slider-fill" style={{ width: `${Math.min(100, Math.max(0, pct))}%` }} />
                    </div>

                    <input
                        type="range"
                        min={range.Min}
                        max={range.Max}
                        step={range.Step}
                        value={scale}
                        onChange={handleSlider}
                        className="slider-input"
                    />

                    <div className="slider-thumb" style={{ left: `calc(${pct}% - 0.4375rem)` }} />
                </div>

                <div className="slider-ends">
                    <span>Mais baixo</span>
                    <span>Mais alto</span>
                </div>
            </div>

            <div className="panel-divider" />

            {/* Presets */}
            <div className="presets-section">
                <div className="section-label">
                    <span className="section-label-text">Predefinições</span>
                </div>

                <div className="presets-grid">
                    {presets.map((p) => (
                        <PresetCard
                            key={p.id}
                            preset={p}
                            isSelected={selectedPreset === p.id}
                            onClick={() => handlePreset(p)}
                        />
                    ))}
                </div>
            </div>

            {/* Action Buttons */}
            <div className="action-buttons">
                <button className="action-btn secondary" onClick={handleReset}>
                    Resetar
                </button>
                <button className="action-btn" onClick={closeFrame}>
                    Fechar
                </button>
            </div>
        </>
    )
}
