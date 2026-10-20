import { useRef, useEffect, useState } from 'react'

export interface BonusEntry {
    id: number
    workedHours: number
    reward: number
    currentHours: number
    claimed: boolean
}

interface BonusPageProps {
    bonuses: BonusEntry[]
    workedMinutes: number
    onClaimBonus: (id: number) => void
}

function formatHours(minutes: number): string {
    const hrs = Math.floor(minutes / 60)
    const mins = minutes % 60
    return `${hrs}h ${mins}m`
}

export default function BonusPage({ bonuses, workedMinutes, onClaimBonus }: BonusPageProps) {
    const gridRef = useRef<HTMLDivElement>(null)
    const [scrollPercent, setScrollPercent] = useState(0)

    useEffect(() => {
        const grid = gridRef.current
        if (!grid) return
        const handleScroll = () => {
            const { scrollTop, scrollHeight, clientHeight } = grid
            const maxScroll = scrollHeight - clientHeight
            if (maxScroll > 0) {
                setScrollPercent(scrollTop / maxScroll)
            }
        }
        grid.addEventListener('scroll', handleScroll)
        return () => grid.removeEventListener('scroll', handleScroll)
    }, [])

    const trackRef = useRef<HTMLDivElement>(null)
    const [trackHeight, setTrackHeight] = useState(0)

    useEffect(() => {
        const el = trackRef.current
        if (!el) return
        const observer = new ResizeObserver(() => {
            setTrackHeight(el.clientHeight)
        })
        observer.observe(el)
        return () => observer.disconnect()
    }, [])

    const gridEl = gridRef.current
    const thumbRatio = gridEl ? gridEl.clientHeight / gridEl.scrollHeight : 1
    const thumbHeight = Math.max(30, trackHeight * thumbRatio)
    const thumbTop = scrollPercent * (trackHeight - thumbHeight)

    const totalClaimed = bonuses.filter(b => b.claimed).length
    const totalBonusClaimed = bonuses.filter(b => b.claimed).reduce((acc, b) => acc + b.reward, 0)

    return (
        <div className="missions-page">
            <div className="missions-page-container">
                <div className="missions-page-header">
                    <span className="missions-page-header-text">
                        Bônus por <span style={{ fontWeight: 700 }}>horas trabalhadas</span>
                    </span>
                </div>

                <div className="missions-page-body">
                    <div className="missions-page-scroll-area">
                        <div className="missions-page-grid" ref={gridRef}>
                            {bonuses.map((bonus) => {
                                const isCompleted = bonus.claimed
                                const isCapped = !isCompleted && bonus.currentHours >= bonus.workedHours

                                return (
                                    <div key={bonus.id} className={`mission-card ${isCapped ? 'can-claim' : ''}`}>
                                        <span className="mission-title">{bonus.workedHours}h trabalhadas</span>
                                        <p className="mission-desc">
                                            Trabalhe {bonus.workedHours} horas para resgatar ${bonus.reward.toLocaleString('pt-BR')}
                                        </p>

                                        <div className="mission-badges">
                                            {isCompleted ? (
                                                <div className="mission-progress-badge complete">
                                                    <span className="mission-progress-current">COMPLETO</span>
                                                </div>
                                            ) : isCapped ? (
                                                <button
                                                    className="mission-progress-badge complete claimable"
                                                    onClick={() => onClaimBonus(bonus.id)}
                                                >
                                                    RESGATAR
                                                </button>
                                            ) : (
                                                <div className="mission-progress-badge">
                                                    <span className="mission-progress-current">
                                                        {Math.min(bonus.currentHours, bonus.workedHours)}
                                                    </span>
                                                    <span className="mission-progress-total">/{bonus.workedHours}h</span>
                                                </div>
                                            )}

                                            <div className={`mission-xp-badge ${isCompleted || isCapped ? 'earned' : 'pending'}`}>
                                                ${bonus.reward.toLocaleString('pt-BR')}
                                            </div>
                                        </div>
                                    </div>
                                )
                            })}
                        </div>

                        <div className="missions-vertical-scroll" ref={trackRef}>
                            <div className="missions-vertical-track" />
                            <div className="missions-vertical-thumb" style={{ top: thumbTop, height: thumbHeight }} />
                        </div>
                    </div>

                    <div className="missions-stats-panel">
                        <div className="missions-stat-card">
                            <span className="missions-stat-number">{formatHours(workedMinutes)}</span>
                            <span className="missions-stat-label">Horas Trabalhadas</span>
                            <p className="missions-stat-desc">
                                Tempo total registrado nos seus empregos. Continue trabalhando para desbloquear mais bônus!
                            </p>
                        </div>

                        <div className="missions-stat-card">
                            <span className="missions-stat-number">${totalBonusClaimed.toLocaleString('pt-BR')}</span>
                            <span className="missions-stat-label">Bônus Total</span>
                            <p className="missions-stat-desc">
                                Total em dinheiro resgatado através dos bônus por horas trabalhadas. ({totalClaimed}/{bonuses.length} bônus resgatados)
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}
