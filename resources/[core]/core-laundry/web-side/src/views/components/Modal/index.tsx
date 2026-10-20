import { useEffect } from 'react'

interface ModalProps {
    open: boolean
    onClose: () => void
    children: React.ReactNode
}

export function Modal({ open, onClose, children }: ModalProps) {
    useEffect(() => {
        if (!open) return
        const onKeyDown = (e: KeyboardEvent) => {
            if (e.key === 'Escape') onClose()
        }
        window.addEventListener('keydown', onKeyDown)
        return () => window.removeEventListener('keydown', onKeyDown)
    }, [open, onClose])

    if (!open) return null

    return (
        <div
            className="absolute inset-0 flex items-center justify-center z-[200] bg-black/60 animate-modalOverlayIn"
            onClick={onClose}
        >
            <div
                className="relative animate-modalSlideIn"
                onClick={(e) => e.stopPropagation()}
            >
                <div className="relative z-[1]">{children}</div>
            </div>
        </div>
    )
}
