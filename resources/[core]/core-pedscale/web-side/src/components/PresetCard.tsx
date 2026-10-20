import { useState } from 'react'
import type { Preset } from '../types'
import { PersonSilhouette } from './Icons'

interface PresetCardProps {
    preset: Preset
    isSelected: boolean
    onClick: () => void
}

const ICON_SCALES: Record<string, number> = {
    small: 0.35,
    medium: 0.42,
    normal: 0.50,
    large: 0.58,
}

export function PresetCard({ preset, isSelected, onClick }: PresetCardProps) {
    const [hovered, setHovered] = useState(false)

    const iconScale = ICON_SCALES[preset.id] ?? 0.50

    const cardClass = [
        'preset-card',
        isSelected ? 'preset-card--active' : '',
        hovered ? 'preset-card--hover' : '',
    ].join(' ')

    const labelClass = [
        'preset-label',
        isSelected ? 'preset-label--active' : '',
    ].join(' ')

    const silhouetteClass = [
        'preset-silhouette',
        isSelected ? 'preset-silhouette--active' : hovered ? 'preset-silhouette--hover' : '',
    ].join(' ')

    return (
        <button
            className={cardClass}
            onClick={onClick}
            onMouseEnter={() => setHovered(true)}
            onMouseLeave={() => setHovered(false)}
        >
            {isSelected && <div className="preset-indicator" />}
            <span className={labelClass}>{preset.label}</span>
            <div className="preset-icon-wrap">
                <PersonSilhouette scale={iconScale} className={silhouetteClass} />
            </div>
        </button>
    )
}
