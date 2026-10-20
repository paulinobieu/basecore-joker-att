import { useRef, useEffect, useState } from 'react'

export interface RankingEntry {
    id: number
    name: string
    playerId: string
    job: string
    xp: number
}

interface RankingPageProps {
    entries: RankingEntry[]
}

function TrophyIcon({ color }: { color: string }) {
    return (
        <svg className="ranking-trophy" viewBox="0 0 20 26" fill="none">
            <path d="M18.333 2.5h-1.666V.833A1.667 1.667 0 0 0 15 0H5a1.667 1.667 0 0 0-1.667 1.667v.833H1.667A1.667 1.667 0 0 0 0 4.167v2.5a3.333 3.333 0 0 0 3.333 3.333h.269A6.667 6.667 0 0 0 9.167 14.945v3.388H5v1.667h10v-1.667h-3.333v-3.393A6.667 6.667 0 0 0 16.45 10h.216A3.333 3.333 0 0 0 20 6.667v-2.5A1.667 1.667 0 0 0 18.333 2.5ZM3.333 8.333A1.667 1.667 0 0 1 1.667 6.667v-2.5h1.666v4.166Zm15-1.666A1.667 1.667 0 0 1 16.667 8.333V4.167h1.666v2.5Z" fill={color} />
        </svg>
    )
}

export default function RankingPage({ entries }: RankingPageProps) {
    const listRef = useRef<HTMLDivElement>(null)
    const [scrollPercent, setScrollPercent] = useState(0)

    useEffect(() => {
        const list = listRef.current
        if (!list) return
        const handleScroll = () => {
            const { scrollTop, scrollHeight, clientHeight } = list
            const maxScroll = scrollHeight - clientHeight
            if (maxScroll > 0) {
                setScrollPercent(scrollTop / maxScroll)
            }
        }
        list.addEventListener('scroll', handleScroll)
        return () => list.removeEventListener('scroll', handleScroll)
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

    const listEl = listRef.current
    const thumbRatio = listEl ? listEl.clientHeight / listEl.scrollHeight : 1
    const thumbHeight = Math.max(30, trackHeight * thumbRatio)
    const thumbTop = scrollPercent * (trackHeight - thumbHeight)

    return (
        <div className="ranking-page">
            <div className="ranking-page-container">
                <div className="ranking-page-header">
                    <span className="ranking-page-header-text">Ranking de Trabalhadores</span>
                </div>

                <div className="ranking-page-body">
                    <div className="ranking-page-list" ref={listRef}>
                        {entries.map((entry, index) => {
                            const position = index + 1
                            const trophyColors = ['#FFD700', '#C0C0C0', '#CD7F32']

                            return (
                                <div className="ranking-row" key={entry.id}>
                                    <div className="ranking-position">
                                        {position <= 3 ? (
                                            <TrophyIcon color={trophyColors[position - 1]} />
                                        ) : (
                                            <span className="ranking-position-text">{position}</span>
                                        )}
                                    </div>

                                    <div className="ranking-divider" />

                                    <span className="ranking-name">{entry.name}</span>

                                    <div className="ranking-id-badge">
                                        <span className="ranking-id-text">#{entry.playerId}</span>
                                    </div>

                                    <span className="ranking-job">{entry.job}</span>

                                    <span className="ranking-xp">{entry.xp.toLocaleString('pt-BR')} EXP</span>
                                </div>
                            )
                        })}
                    </div>

                    <div className="ranking-vertical-scroll" ref={trackRef}>
                        <div className="ranking-vertical-track" />
                        <div className="ranking-vertical-thumb" style={{ top: thumbTop, height: thumbHeight }} />
                    </div>
                </div>
            </div>
        </div>
    )
}
