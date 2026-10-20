import { useCallback, useEffect, useRef, useState } from 'react'
import { useNuiEvent } from './hooks/useNuiEvent'
import { useVisibility } from './hooks/useVisibility'
import { fetchNui } from './utils/fetchNui'
import { isEnvBrowser } from './utils/misc'
import JobCard from './components/JobCard'
import MissionCard from './components/MissionCard'
import MissionsPage from './components/MissionsPage'
import RankingPage from './components/RankingPage'
import type { RankingEntry } from './components/RankingPage'
import BonusPage from './components/BonusPage'
import type { BonusEntry } from './components/BonusPage'
import Sidebar from './components/Sidebar'

/* =========== Types =========== */
export interface Job {
    id: number | string
    name: string
    salary: number
    jobLevel: number
    description: string
    image?: string
    canStart: boolean
}

export interface Mission {
    id: number
    title: string
    description: string
    current: number
    total: number
    xp: number
    completed: boolean
}

export interface PlayerData {
    name: string
    avatar?: string
    level: number
    xp: number
    maxXp: number
    todayEarnings: number
    totalEarnings: number
}

/* =========== Mock data for devmode =========== */
const mockJobs: Job[] = [
    { id: 1, name: 'Lixeiro', salary: 2500, jobLevel: 1, image: './assets/jobs/lixeiro.png', description: 'Em conjunto ao Projeto Reciclar, este emprego tem o objetivo de promover a limpeza da cidade. Realize a coleta de lixo.', canStart: true },
    { id: 2, name: 'Entregador', salary: 3000, jobLevel: 3, image: './assets/jobs/entregador.png', description: 'Realize a condução dos ônibus de transporte público, coletando e entregando passageiros por toda a cidade.', canStart: true },
    { id: 3, name: 'Eletricista', salary: 3500, jobLevel: 0, image: './assets/jobs/eletricista.png', description: 'Realize a condução dos ônibus de transporte público, coletando e entregando passageiros por toda a cidade.', canStart: true },
    { id: 4, name: 'Lenhador', salary: 3800, jobLevel: 5, image: './assets/jobs/lenhador.png', description: 'Realize o corte de árvores para coleta de toras de madeira e venda-as na Cabana do Campo.', canStart: true },
    { id: 5, name: 'Agricultor | Laranjas', salary: 4000, jobLevel: 2, image: './assets/jobs/agricultor-laranjas.png', description: 'Em contato com belas vistas no campo, realize a colheita de laranjas, manualmente. Recomendado aos aspirantes à agroboy!', canStart: true },
    { id: 6, name: 'Agricultor | Trigo', salary: 4200, jobLevel: 0, image: './assets/jobs/agricultor-trigo.png', description: 'Em contato com belas vistas no campo, realize a colheita de trigo na fazenda utilizando um trator. Recomendado aos aspirantes à agroboy!', canStart: true },
    { id: 7, name: 'Pescador', salary: 4500, jobLevel: 1, image: './assets/jobs/pescador.png', description: 'Trabalho tranquilo e relaxante. Ótimo para ganhar uma grana e dar uma pensada na vida. Navegue pelas águas e obtenha pescados para vender.', canStart: true },
    { id: 8, name: 'Minerador', salary: 5000, jobLevel: 7, image: './assets/jobs/minerador.png', description: 'Realize a mineração de metais e pedras preciosas. Trabalho braçal, sob o forte sol presente na mineradora.', canStart: true },
    { id: 9, name: 'Motorista', salary: 6000, jobLevel: 9, image: './assets/jobs/motorista.png', description: 'Realize a condução dos ônibus de transporte público, coletando e entregando passageiros por toda a cidade.', canStart: true },
]

const mockMissions: Mission[] = [
    { id: 1, title: 'Entregue 25 passageiros', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vitae sodales velit. Vivamus a rhoncus nisi,', current: 25, total: 25, xp: 45000, completed: true },
    { id: 2, title: 'Entregue 25 passageiros', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vitae sodales velit. Vivamus a rhoncus nisi,', current: 10, total: 25, xp: 45000, completed: false },
    { id: 3, title: 'Entregue 25 passageiros', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vitae sodales velit. Vivamus a rhoncus nisi,', current: 10, total: 25, xp: 45000, completed: false },
    { id: 4, title: 'Entregue 25 passageiros', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vitae sodales velit. Vivamus a rhoncus nisi,', current: 10, total: 25, xp: 45000, completed: false },
    { id: 5, title: 'Faça 50 entregas', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vitae sodales velit. Vivamus a rhoncus nisi,', current: 30, total: 50, xp: 60000, completed: false },
    { id: 6, title: 'Dirija 100 km', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vitae sodales velit. Vivamus a rhoncus nisi,', current: 100, total: 100, xp: 30000, completed: true },
    { id: 7, title: 'Complete 10 rotas', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vitae sodales velit. Vivamus a rhoncus nisi,', current: 7, total: 10, xp: 25000, completed: false },
    { id: 8, title: 'Ganhe R$ 50.000', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vitae sodales velit. Vivamus a rhoncus nisi,', current: 35000, total: 50000, xp: 80000, completed: false },
    { id: 9, title: 'Entregue 100 passageiros', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vitae sodales velit. Vivamus a rhoncus nisi,', current: 45, total: 100, xp: 90000, completed: false },
    { id: 10, title: 'Trabalhe 5 horas', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vitae sodales velit. Vivamus a rhoncus nisi,', current: 5, total: 5, xp: 40000, completed: true },
    { id: 11, title: 'Alcance Level 10', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vitae sodales velit. Vivamus a rhoncus nisi,', current: 9, total: 10, xp: 55000, completed: false },
    { id: 12, title: 'Sem acidentes 20 viagens', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla vitae sodales velit. Vivamus a rhoncus nisi,', current: 14, total: 20, xp: 35000, completed: false },
]

const mockRanking: RankingEntry[] = [
    { id: 1, name: 'Bieu do Grau', playerId: '23232', job: '24h 50m', xp: 46000 },
    { id: 2, name: 'Bieu do Grau', playerId: '23232', job: '12h 10m', xp: 46000 },
    { id: 3, name: 'Bieu do Grau', playerId: '23232', job: '5h 30m', xp: 46000 },
    { id: 4, name: 'Bieu do Grau', playerId: '23232', job: '4h 0m', xp: 46000 },
    { id: 5, name: 'Bieu do Grau', playerId: '23232', job: '3h 15m', xp: 46000 },
    { id: 6, name: 'Bieu do Grau', playerId: '23232', job: '2h 5m', xp: 46000 },
    { id: 7, name: 'Bieu do Grau', playerId: '23232', job: '1h 50m', xp: 46000 },
    { id: 8, name: 'Bieu do Grau', playerId: '23232', job: '1h 10m', xp: 46000 },
    { id: 9, name: 'Bieu do Grau', playerId: '23232', job: '0h 45m', xp: 46000 },
    { id: 10, name: 'Bieu do Grau', playerId: '23232', job: '0h 30m', xp: 46000 },
    { id: 11, name: 'Bieu do Grau', playerId: '23232', job: '0h 15m', xp: 46000 },
    { id: 12, name: 'Bieu do Grau', playerId: '23232', job: '0h 5m', xp: 46000 },
]

const mockPlayer: PlayerData = {
    name: 'Bieu D.',
    level: 102,
    xp: 5555,
    maxXp: 6000,
    todayEarnings: 0,
    totalEarnings: 15000,
}

const mockBonuses: BonusEntry[] = [
    { id: 1, workedHours: 1, reward: 400, currentHours: 1, claimed: true },
    { id: 2, workedHours: 3, reward: 1400, currentHours: 2.5, claimed: false },
    { id: 3, workedHours: 5, reward: 2600, currentHours: 2.5, claimed: false },
    { id: 4, workedHours: 10, reward: 4500, currentHours: 2.5, claimed: false },
    { id: 5, workedHours: 15, reward: 6700, currentHours: 2.5, claimed: false }
]

function App() {
    const { visible, setVisible, handleClose } = useVisibility()
    const [activeTab, setActiveTab] = useState<'home' | 'missions' | 'bonus' | 'ranking'>('home')
    const [jobs, setJobs] = useState<Job[]>(isEnvBrowser() ? mockJobs : [])
    const [missions, setMissions] = useState<Mission[]>(isEnvBrowser() ? mockMissions : [])
    const [ranking, setRanking] = useState<RankingEntry[]>(isEnvBrowser() ? mockRanking : [])
    const [bonuses, setBonuses] = useState<BonusEntry[]>(isEnvBrowser() ? mockBonuses : [])
    const [workedMinutes, setWorkedMinutes] = useState<number>(isEnvBrowser() ? 150 : 0)
    const [player, setPlayer] = useState<PlayerData>(mockPlayer)
    const [jobScrollPercent, setJobScrollPercent] = useState(0)
    const [missionScrollPercent, setMissionScrollPercent] = useState(0)
    const jobsGridRef = useRef<HTMLDivElement>(null)
    const missionsGridRef = useRef<HTMLDivElement>(null)

    /* ----- Dev mode: auto-open ----- */
    useEffect(() => {
        if (isEnvBrowser()) setVisible(true)
    }, [setVisible])

    /* ----- NUI events ----- */
    useNuiEvent<{ jobs: Job[]; missions: Mission[]; player: PlayerData; ranking: RankingEntry[]; bonuses?: BonusEntry[]; workedMinutes?: number; themeColor?: string }>('openJobCenter', (data) => {
        if (data.jobs) setJobs(data.jobs)
        if (data.missions) setMissions(data.missions)
        if (data.player) setPlayer(data.player)
        if (data.ranking) setRanking(data.ranking)
        if (data.bonuses) setBonuses(data.bonuses)
        if (data.workedMinutes !== undefined) setWorkedMinutes(data.workedMinutes)
        if (data.themeColor) {
            document.documentElement.style.setProperty('--accent-blue', data.themeColor)

            const normalizedColor = data.themeColor.replace('#', '')
            const expandedColor = normalizedColor.length === 3
                ? normalizedColor.split('').map((character) => `${character}${character}`).join('')
                : normalizedColor

            if (/^[0-9a-fA-F]{6}$/.test(expandedColor)) {
                const colorValue = Number.parseInt(expandedColor, 16)
                const red = (colorValue >> 16) & 255
                const green = (colorValue >> 8) & 255
                const blue = colorValue & 255
                document.documentElement.style.setProperty('--primaryColor', `${red}, ${green}, ${blue}`)
            }
        }
        setVisible(true)
    })

    /* ----- ESC to close ----- */
    useEffect(() => {
        const onKeyDown = (e: KeyboardEvent) => {
            if (e.key === 'Escape') handleClose()
        }
        window.addEventListener('keydown', onKeyDown)
        return () => window.removeEventListener('keydown', onKeyDown)
    }, [handleClose])

    /* ----- Carousel Arrays ----- */
    const scrollAnimationRef = useRef<number | null>(null)
    const scrollTargetRef = useRef<number | null>(null)

    const scrollJobs = (direction: 'left' | 'right') => {
        const grid = jobsGridRef.current
        if (!grid) return

        const cardWidth = 350 // card width + gap

        // Calculate new target (if already scrolling, add to current target, else add to current scrollLeft)
        let start = grid.scrollLeft
        let target = (scrollTargetRef.current !== null ? scrollTargetRef.current : start) + (direction === 'left' ? -cardWidth : cardWidth)

        // Clamp target
        const maxScroll = grid.scrollWidth - grid.clientWidth
        if (target < 0) target = 0
        if (target > maxScroll) target = maxScroll

        scrollTargetRef.current = target

        // Helper to cancel existing animation
        if (scrollAnimationRef.current !== null) {
            cancelAnimationFrame(scrollAnimationRef.current)
        }

        const duration = 300 // ms
        let startTime: number | null = null

        const step = (timestamp: number) => {
            if (!startTime) startTime = timestamp
            const progress = Math.min((timestamp - startTime) / duration, 1)

            // easeOutQuart
            const easeProgress = 1 - Math.pow(1 - progress, 4)
            grid.scrollLeft = start + (target - start) * easeProgress

            if (progress < 1) {
                scrollAnimationRef.current = requestAnimationFrame(step)
            } else {
                scrollAnimationRef.current = null
                scrollTargetRef.current = null
            }
        }
        scrollAnimationRef.current = requestAnimationFrame(step)
    }

    const handleJobsScroll = () => {
        const grid = jobsGridRef.current
        if (!grid) return
        const maxScroll = grid.scrollWidth - grid.clientWidth
        if (maxScroll > 0) {
            setJobScrollPercent((grid.scrollLeft / maxScroll) * 100)
        }
    }

    /* ----- Actions ----- */
    const handleStartJob = (job: Job) => {
        fetchNui('startJob', { jobId: job.id })
        handleClose()
    }

    const handleClaimMission = (id: number) => {
        // Optimistic update — mark mission as completed immediately in the UI
        setMissions(prev => prev.map(m => m.id === id ? { ...m, completed: true } : m))

        fetchNui('jobs-center', { action: 'claimBonus', id }).then((res: any) => {
            if (res && res.success) {
                if (res.missions) setMissions(res.missions)
                setPlayer(prev => ({
                    ...prev,
                    xp: res.xp !== undefined ? res.xp : prev.xp,
                    maxXp: res.maxXp !== undefined ? res.maxXp : prev.maxXp,
                    level: res.level !== undefined ? res.level : prev.level
                }))
            }
        }).catch(err => console.log(err))
    }

    const handleClaimHourBonus = (id: number) => {
        // Optimistic update
        setBonuses(prev => prev.map(b => b.id === id ? { ...b, claimed: true } : b))

        fetchNui('jobs-center', { action: 'claimHourBonus', id }).then((res: any) => {
            if (res && res.success) {
                // If the server returned updated data we could sync it here. 
                // But the optimistic update should be enough for the UX.
            }
        }).catch(err => console.log(err))
    }

    /* ----- Horizontal scroll for home missions (convert wheel to horizontal) ----- */
    useEffect(() => {
        if (!visible) return
        setTimeout(() => {
            handleJobsScroll()
            handleMissionsScroll()
        }, 100)

        const grid = missionsGridRef.current
        if (!grid) return
        const handleWheel = (e: WheelEvent) => {
            if (Math.abs(e.deltaY) > 0) {
                e.preventDefault()
                grid.scrollLeft += e.deltaY
            }
        }
        grid.addEventListener('wheel', handleWheel, { passive: false })
        return () => grid.removeEventListener('wheel', handleWheel)
    }, [activeTab, visible])
    const handleMissionsScroll = () => {
        const grid = missionsGridRef.current
        if (!grid) return
        const maxScroll = grid.scrollWidth - grid.clientWidth
        if (maxScroll > 0) {
            setMissionScrollPercent((grid.scrollLeft / maxScroll) * 100)
        }
    }

    if (!visible) return null

    const jobImageUrl = './assets/default-job.png'
    const getJobImage = (job: Job) => {
        if (job.image && job.image.length > 0) {
            if (job.image.startsWith('http') || job.image.startsWith('nui://') || job.image.startsWith('./')) {
                return job.image
            }
            return `./assets/jobs/${job.image}`
        }
        return jobImageUrl
    }

    const tabSubtitle = {
        home: 'Vagas disponíveis',
        missions: 'Missões de trabalho',
        bonus: 'Bônus por horas',
        ranking: 'Ranking de trabalhadores',
    }[activeTab]

    return (
        <div className={`nui-wrapper${isEnvBrowser() ? ' browser-mode' : ''}`}>

            <div className="jobs-frame">
            <div className="main-container">
                {/* Sidebar — mesma hierarquia visual do core-craft-main */}
                <Sidebar activeTab={activeTab} onTabChange={setActiveTab} onExit={handleClose} />

                {/* Content Area */}
                <div className="content-area">
                    {/* Header — always visible */}
                    <div className="header">
                        <div className="header-logo">
                            <div className="header-logo-text">Central de empregos</div>
                        </div>

                        <div className="header-subtitle">{tabSubtitle}</div>

                        <div className="user-info-bar">
                            <div className="user-stats">
                                <div className="stat-box">
                                    <span className="stat-value">{player.xp}</span>
                                    <span className="stat-value-sub">/{player.maxXp} XP</span>
                                </div>
                                <div className="stat-box">
                                    <span className="stat-label">Ganhos de hoje:</span>
                                    <span className="stat-value">${player.todayEarnings}</span>
                                </div>
                                <div className="stat-box">
                                    <span className="stat-label">Ganhos Totais:</span>
                                    <span className="stat-value">${player.totalEarnings.toLocaleString('pt-BR')}</span>
                                </div>
                            </div>

                            <div className="user-profile">
                                <div className="user-avatar" role="img" aria-label="Avatar padrão">
                                    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                        <path d="M12 2C9.24 2 7 4.24 7 7C7 9.76 9.24 12 12 12C14.76 12 17 9.76 17 7C17 4.24 14.76 2 12 2ZM12 14C8.67 14 2 15.67 2 19V22H22V19C22 15.67 15.33 14 12 14Z" fill="currentColor" />
                                    </svg>
                                </div>
                                <div className="user-details">
                                    <div className="user-name-row">
                                        <span className="user-name">{player.name}</span>
                                        <div className="user-level-badge"><span>{player.level}</span></div>
                                    </div>
                                    <span className="user-subtitle">Carteira de emprego</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* ===== TAB CONTENT ===== */}
                    <div key={activeTab} className="tab-fade-in">
                        {activeTab === 'home' && (
                            <>
                                {/* Jobs Carousel */}
                                <div className="section-empregos">
                                    <div className="jobs-carousel-wrapper">
                                        <button className="carousel-arrow carousel-arrow-left" onClick={() => scrollJobs('left')}>
                                            <svg viewBox="0 0 16 14" fill="none" style={{ transform: 'rotate(180deg)' }}>
                                                <path d="M8.258 13.222a1.1 1.1 0 0 1 .058-.299c.04-.094.097-.18.17-.252l5.646-5.68L8.486 1.31A.775.775 0 0 1 9.038 0c.2-.004.395.075.542.21l6.194 6.23a.788.788 0 0 1 0 1.1l-6.194 6.232a.766.766 0 0 1-1.094 0 1.1 1.1 0 0 1-.17-.252 1.1 1.1 0 0 1-.058-.299Z" className="arrow-fill" />
                                                <path d="M0 6.99a.78.78 0 0 1 .774-.779h14.452a.778.778 0 0 1 0 1.558H.774A.78.78 0 0 1 0 6.99Z" className="arrow-fill" />
                                            </svg>
                                        </button>

                                        <button className="carousel-arrow carousel-arrow-right" onClick={() => scrollJobs('right')}>
                                            <svg viewBox="0 0 16 14" fill="none">
                                                <path d="M8.258 13.222a1.1 1.1 0 0 1 .058-.299c.04-.094.097-.18.17-.252l5.646-5.68L8.486 1.31A.775.775 0 0 1 9.038 0c.2-.004.395.075.542.21l6.194 6.23a.788.788 0 0 1 0 1.1l-6.194 6.232a.766.766 0 0 1-1.094 0 1.1 1.1 0 0 1-.17-.252 1.1 1.1 0 0 1-.058-.299Z" className="arrow-fill" />
                                                <path d="M0 6.99a.78.78 0 0 1 .774-.779h14.452a.778.778 0 0 1 0 1.558H.774A.78.78 0 0 1 0 6.99Z" className="arrow-fill" />
                                            </svg>
                                        </button>

                                        <div className="jobs-carousel" ref={jobsGridRef} onScroll={handleJobsScroll}>
                                            {jobs.map((job) => (
                                                <JobCard
                                                    key={job.id}
                                                    job={job}
                                                    imageUrl={getJobImage(job)}
                                                    onStart={() => handleStartJob(job)}
                                                />
                                            ))}
                                        </div>

                                        <div className="scroll-indicator">
                                            <div className="scroll-track" />
                                            <div className="scroll-thumb" style={{ left: `calc(${jobScrollPercent}% - ${jobScrollPercent * 0.5}px)` }} />
                                        </div>
                                    </div>
                                </div>

                                {/* Missions preview — show more for scrolling */}
                                <div className="section-missoes">
                                    <div className="missions-grid" ref={missionsGridRef} onScroll={handleMissionsScroll}>
                                        {missions.map((mission) => (
                                            <MissionCard key={mission.id} mission={mission} onClaim={handleClaimMission} />
                                        ))}
                                    </div>
                                    <div className="missions-scroll-indicator">
                                        <div className="missions-scroll-track" />
                                        <div className="missions-scroll-thumb" style={{ left: `calc(${missionScrollPercent}% - ${missionScrollPercent * 0.36}px)` }} />
                                    </div>
                                </div>
                            </>
                        )}

                        {activeTab === 'missions' && (
                            <MissionsPage missions={missions} onClaimMission={handleClaimMission} />
                        )}

                        {activeTab === 'bonus' && (
                            <BonusPage bonuses={bonuses} workedMinutes={workedMinutes} onClaimBonus={handleClaimHourBonus} />
                        )}

                        {activeTab === 'ranking' && (
                            <RankingPage entries={ranking} />
                        )}
                    </div>
                </div>

            </div>
            </div>
        </div>
    )
}

export default App
