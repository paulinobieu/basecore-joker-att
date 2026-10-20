import { useState } from 'react'

interface ShareModalProps {
    code: string
    onConfirm: () => void
    onClose: () => void
}

export function ShareModal({ code, onConfirm, onClose }: ShareModalProps) {
    const [copied, setCopied] = useState(false)

    const handleCopy = () => {
        try {
            const textarea = document.createElement('textarea')
            textarea.value = code
            textarea.style.position = 'fixed'
            textarea.style.left = '-9999px'
            textarea.style.top = '-9999px'
            textarea.style.opacity = '0'
            document.body.appendChild(textarea)
            textarea.focus()
            textarea.select()
            document.execCommand('copy')
            document.body.removeChild(textarea)
            setCopied(true)
            setTimeout(() => setCopied(false), 2000)
        } catch {
            console.error('Failed to copy')
        }
    }

    return (
        <div className="inline-modal-overlay" onClick={onClose}>
            <div className="inline-modal" onClick={(e) => e.stopPropagation()}>
                <div className="inline-modal-title-row">
                    <span className="inline-modal-title">Compartilhar</span>
                </div>

                <div className="inline-modal-icon">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                        <path d="M12 2C9.243 2 7 4.243 7 7c0 2.757 2.243 5 5 5s5-2.243 5-5c0-2.757-2.243-5-5-5z" fill="currentColor" opacity="0.5" />
                        <path d="M12 14c-5.523 0-10 2.239-10 5v1a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-1c0-2.761-4.477-5-10-5z" fill="currentColor" opacity="0.5" />
                    </svg>
                </div>

                <div className="inline-modal-code-row">
                    <input
                        type="text"
                        className="inline-modal-code-input"
                        value={code}
                        readOnly
                    />
                    <button className="inline-modal-copy-btn" onClick={handleCopy} title={copied ? 'Copiado!' : 'Copiar'}>
                        {copied ? (
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                                <polyline points="20 6 9 17 4 12" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                            </svg>
                        ) : (
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                                <rect x="9" y="9" width="13" height="13" rx="2" stroke="currentColor" strokeWidth="2" />
                                <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" stroke="currentColor" strokeWidth="2" />
                            </svg>
                        )}
                    </button>
                </div>

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
