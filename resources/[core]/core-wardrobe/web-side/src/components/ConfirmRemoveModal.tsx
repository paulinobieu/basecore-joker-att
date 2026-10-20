interface ConfirmRemoveModalProps {
    outfitName: string
    onConfirm: () => void
    onClose: () => void
}

export function ConfirmRemoveModal({ outfitName, onConfirm, onClose }: ConfirmRemoveModalProps) {
    return (
        <div className="inline-modal-overlay" onClick={onClose}>
            <div className="inline-modal" onClick={(e) => e.stopPropagation()}>
                <div className="inline-modal-title-row">
                    <span className="inline-modal-title">Remover Roupa</span>
                </div>

                <div className="inline-modal-icon">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                        <path d="M12 9v4m0 4h.01M3 12a9 9 0 1 1 18 0 9 9 0 0 1-18 0Z" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                    </svg>
                </div>

                <p className="confirm-modal-text">
                    Tem certeza que quer apagar a roupa <strong>{outfitName}</strong>?
                </p>

                <button className="inline-modal-confirm-btn" onClick={onConfirm}>
                    Confirmar
                </button>
                <button className="inline-modal-cancel-btn" onClick={onClose}>
                    Cancelar
                </button>
            </div>
        </div>
    )
}
