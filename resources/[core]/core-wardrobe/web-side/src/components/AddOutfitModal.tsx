import { useState } from 'react'

type Tab = 'current' | 'import'

interface AddOutfitModalProps {
    onAdd: (name: string) => void
    onImport: (code: string) => void
    onClose: () => void
}

export function AddOutfitModal({ onAdd, onImport, onClose }: AddOutfitModalProps) {
    const [tab, setTab] = useState<Tab>('current')
    const [name, setName] = useState('')
    const [code, setCode] = useState('')

    const handleSubmitCurrent = () => {
        const trimmed = name.trim()
        if (!trimmed) return
        onAdd(trimmed)
    }

    const handleSubmitImport = () => {
        const trimmed = code.trim()
        if (!trimmed) return
        onImport(trimmed)
    }

    const handleKeyDown = (e: React.KeyboardEvent) => {
        if (e.key === 'Enter') {
            if (tab === 'current') handleSubmitCurrent()
            else handleSubmitImport()
        }
    }

    return (
        <div className="inline-modal-overlay" onClick={onClose}>
            <div className="inline-modal" onClick={(e) => e.stopPropagation()}>
                <div className="inline-modal-title-row">
                    <span className="inline-modal-title">Adicionar Roupa</span>
                </div>

                <div className="inline-modal-icon">
                    <svg width="16" height="16" viewBox="0 0 28 28" fill="none">
                        <path d="M14 6.12499C13.6686 6.12492 13.344 6.21896 13.0639 6.39616C12.7838 6.57337 12.5599 6.82646 12.418 7.12599C12.2655 7.43504 11.9976 7.67171 11.6721 7.78491C11.3466 7.89811 10.9896 7.87874 10.6783 7.731C10.367 7.58325 10.1262 7.31898 10.008 6.99525C9.88989 6.67152 9.90379 6.31431 10.0468 6.00074C10.3395 5.38376 10.7727 4.84389 11.3115 4.42433C11.8503 4.00477 12.4799 3.71718 13.1498 3.58458C13.8198 3.45198 14.5114 3.47804 15.1695 3.66069C15.8275 3.84334 16.4336 4.1775 16.9394 4.63643C17.4451 5.09535 17.8364 5.6663 18.0819 6.30356C18.3274 6.94083 18.4203 7.62671 18.3532 8.30632C18.286 8.98593 18.0607 9.64039 17.6953 10.2173C17.3299 10.7942 16.8345 11.2776 16.2488 11.6287C15.9687 11.7891 15.7149 11.9915 15.4963 12.229C15.3318 12.4215 15.3125 12.537 15.3125 12.5895C15.3125 12.712 15.379 12.8275 15.4875 12.887L24.4265 17.8535C25.114 18.2346 25.6554 18.8333 25.9655 19.5556C26.2757 20.2779 26.337 21.0828 26.1399 21.8437C25.9427 22.6047 25.4983 23.2785 24.8764 23.7593C24.2546 24.2402 23.4906 24.5007 22.7045 24.5H5.28851C4.50345 24.4997 3.7407 24.2388 3.11986 23.7583C2.49903 23.2778 2.05522 22.6049 1.85804 21.845C1.66086 21.0851 1.72146 20.2813 2.03034 19.5595C2.33922 18.8378 2.8789 18.239 3.56476 17.857L10.3005 14.112C10.4514 14.0234 10.6185 13.9659 10.792 13.9428C10.9655 13.9197 11.1419 13.9316 11.3107 13.9777C11.4795 14.0238 11.6374 14.1031 11.7751 14.2112C11.9128 14.3192 12.0275 14.4536 12.1125 14.6066C12.1975 14.7596 12.251 14.9281 12.2699 15.1021C12.2888 15.2761 12.2727 15.4521 12.2225 15.6198C12.1724 15.7874 12.0893 15.9434 11.978 16.0785C11.8667 16.2135 11.7295 16.325 11.5745 16.4062L4.84051 20.1512C4.66148 20.2497 4.52038 20.4051 4.43953 20.5927C4.35867 20.7804 4.34268 20.9896 4.39408 21.1874C4.44548 21.3851 4.56133 21.5601 4.72332 21.6846C4.88531 21.8092 5.08419 21.8762 5.28851 21.875H22.7045C22.9086 21.8753 23.1071 21.8078 23.2687 21.6831C23.4302 21.5583 23.5457 21.3834 23.597 21.1858C23.6483 20.9882 23.6325 20.7792 23.552 20.5916C23.4716 20.404 23.331 20.2485 23.1525 20.1495L14.21 15.1812C13.7489 14.9237 13.3647 14.548 13.0968 14.0929C12.8289 13.6377 12.6871 13.1194 12.6858 12.5912C12.6858 11.732 13.062 11.0372 13.4908 10.5315C13.9108 10.0327 14.4358 9.65299 14.896 9.37649C15.2243 9.17996 15.4791 8.88126 15.6215 8.52611C15.7638 8.17096 15.7859 7.77895 15.6842 7.41008C15.5826 7.04121 15.3629 6.71582 15.0587 6.48372C14.7545 6.25163 14.3826 6.12562 14 6.12499Z" fill="currentColor" opacity="0.5" />
                    </svg>
                </div>

                {/* Tab switcher */}
                <div className="inline-modal-tabs">
                    <button
                        className={`inline-modal-tab${tab === 'current' ? ' active' : ''}`}
                        onClick={() => setTab('current')}
                    >
                        Roupa Atual
                    </button>
                    <button
                        className={`inline-modal-tab${tab === 'import' ? ' active' : ''}`}
                        onClick={() => setTab('import')}
                    >
                        Importar Código
                    </button>
                </div>

                {tab === 'current' ? (
                    <>
                        <div className="inline-modal-field">
                            <label className="inline-modal-label">Nome da roupa</label>
                            <input
                                type="text"
                                className="inline-modal-input"
                                placeholder="Ex: Roupa casual"
                                value={name}
                                onChange={(e) => setName(e.target.value)}
                                onKeyDown={handleKeyDown}
                                autoFocus
                                maxLength={32}
                            />
                        </div>

                        <button
                            className="inline-modal-save-btn"
                            onClick={handleSubmitCurrent}
                            disabled={!name.trim()}
                        >
                            Salvar
                        </button>
                    </>
                ) : (
                    <>
                        <div className="inline-modal-field">
                            <label className="inline-modal-label">Código compartilhado</label>
                            <input
                                type="text"
                                className="inline-modal-input"
                                placeholder="Ex: 1Y8M7J7V1E"
                                value={code}
                                onChange={(e) => setCode(e.target.value.toUpperCase())}
                                onKeyDown={handleKeyDown}
                                autoFocus
                                maxLength={16}
                            />
                        </div>

                        <button
                            className="inline-modal-save-btn"
                            onClick={handleSubmitImport}
                            disabled={!code.trim()}
                        >
                            Importar
                        </button>
                    </>
                )}

                <button className="inline-modal-cancel-btn" onClick={onClose}>
                    Cancelar
                </button>
            </div>
        </div>
    )
}
