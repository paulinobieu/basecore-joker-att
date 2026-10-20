import type { Mission } from '../App'

interface MissionCardProps {
    mission: Mission
    onClaim?: (id: number) => void
}

export default function MissionCard({ mission, onClaim }: MissionCardProps) {
    const isCompleted = mission.completed
    const isCapped = !isCompleted && mission.current >= mission.total

    return (
        <div className={`mission-card ${isCapped ? 'can-claim' : ''}`}>
            <span className="mission-title">{mission.title}</span>
            <p className="mission-desc">{mission.description}</p>

            <div className="mission-badges">
                {isCompleted ? (
                    <div className="mission-progress-badge complete">
                        <span className="mission-progress-current">COMPLETO</span>
                    </div>
                ) : isCapped ? (
                    <button
                        className="mission-progress-badge complete claimable"
                        onClick={() => { if (onClaim) onClaim(mission.id) }}
                    >
                        RESGATAR
                    </button>
                ) : (
                    <div className="mission-progress-badge">
                        <span className="mission-progress-current">{mission.current}</span>
                        <span className="mission-progress-total">/{mission.total}</span>
                    </div>
                )}

                {/* XP badge */}
                <div className={`mission-xp-badge ${isCompleted || isCapped ? 'earned' : 'pending'}`}>
                    +{mission.xp} XP
                </div>
            </div>
        </div>
    )
}
