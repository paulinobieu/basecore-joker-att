import { useRef, useEffect, useState } from 'react'
import type { Mission } from '../App'
import MissionCard from './MissionCard'

interface MissionsPageProps {
    missions: Mission[]
    onClaimMission: (id: number) => void
}

export default function MissionsPage({ missions, onClaimMission }: MissionsPageProps) {
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

    const scrollAreaRef = useRef<HTMLDivElement>(null)
    const [scrollAreaHeight, setScrollAreaHeight] = useState(0)

    useEffect(() => {
        const el = scrollAreaRef.current
        if (!el) return
        const observer = new ResizeObserver(() => {
            setScrollAreaHeight(el.clientHeight)
        })
        observer.observe(el)
        return () => observer.disconnect()
    }, [])

    const gridEl = gridRef.current
    const thumbRatio = gridEl ? gridEl.clientHeight / gridEl.scrollHeight : 1
    const thumbHeight = Math.max(30, scrollAreaHeight * thumbRatio)
    const thumbTop = scrollPercent * (scrollAreaHeight - thumbHeight)

    const totalMissionsCompleted = missions.filter((m) => m.completed).length
    const totalXp = missions.reduce((acc, m) => acc + (m.completed ? m.xp : 0), 0)

    return (
        <div className="missions-page">
            <div className="missions-page-container">
                <div className="missions-page-header">
                    <span className="missions-page-header-text">
                        Missões do <span style={{ fontWeight: 700 }}>trabalho</span>
                    </span>
                </div>

                <div className="missions-page-body">
                    <div className="missions-page-scroll-area" ref={scrollAreaRef}>
                        <div className="missions-page-grid" ref={gridRef}>
                            {missions.map((mission) => (
                                <MissionCard key={mission.id} mission={mission} onClaim={onClaimMission} />
                            ))}
                        </div>

                        <div className="missions-vertical-scroll">
                            <div className="missions-vertical-track" />
                            <div className="missions-vertical-thumb" style={{ top: thumbTop, height: thumbHeight }} />
                        </div>
                    </div>

                    <div className="missions-stats-panel">
                        <div className="missions-stat-card">
                            <span className="missions-stat-number">{totalMissionsCompleted}</span>
                            <span className="missions-stat-label">Missões feitas</span>
                            <p className="missions-stat-desc">
                                Acompanhe o total de missões que você já completou ao longo da sua jornada e veja o seu esforço gerando resultados práticos.
                            </p>
                        </div>

                        <div className="missions-stat-card">
                            <span className="missions-stat-number">{totalXp.toLocaleString('pt-BR')}</span>
                            <span className="missions-stat-label">XP Total</span>
                            <p className="missions-stat-desc">
                                Toda a sua experiência acumulada! Eleve seu XP para garantir bônus fantásticos e mais rentabilidade em todos os seus serviços.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}
