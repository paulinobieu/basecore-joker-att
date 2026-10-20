interface LockedSlotProps {
    onUnlock: () => void
}

export function LockedSlot({ onUnlock }: LockedSlotProps) {
    return (
        <div className="slot-card locked">
            <div className="slot-card-header">
                <div className="slot-locked-icon">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                        <rect x="5" y="11" width="14" height="10" rx="2" stroke="currentColor" strokeWidth="1.5" />
                        <path d="M8 11V7a4 4 0 1 1 8 0v4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
                        <circle cx="12" cy="16" r="1.5" fill="currentColor" />
                    </svg>
                </div>
                <span className="slot-locked-text">Desbloquear slot</span>
            </div>
            <div className="slot-card-actions">
                <button className="slot-btn slot-btn-unlock" onClick={onUnlock}>
                    Adquirir
                </button>
            </div>
        </div>
    )
}
