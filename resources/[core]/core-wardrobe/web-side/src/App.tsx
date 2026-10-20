import { useEffect, useState } from 'react'
import { useNuiEvent } from './hooks/useNuiEvent'
import { useVisibility } from './hooks/useVisibility'
import { fetchNui } from './utils/fetchNui'
import { isEnvBrowser } from './utils/misc'
import { WardrobeSlot } from './components/WardrobeSlot'
import { LockedSlot } from './components/LockedSlot'
import { EmptySlot } from './components/EmptySlot'
import { SearchBar } from './components/SearchBar'
import { AddOutfitModal } from './components/AddOutfitModal'
import { ShareModal } from './components/ShareModal'
import { ConfirmRemoveModal } from './components/ConfirmRemoveModal'
import { Hexagon } from './components/Hexagon'
import { useClickSound } from './hooks/useClickSound'

export interface OutfitSlot {
    id: number
    name: string
    slotLabel: string
    shareCode?: string
}

export interface WardrobeConfig {
    maxSlots: number
    unlockedSlots: number
    outfits: OutfitSlot[]
    themeColor?: string
    slotPrice?: number
}

const defaultConfig: WardrobeConfig = {
    maxSlots: 8,
    unlockedSlots: 3,
    outfits: [
        { id: 1, name: 'Teste', slotLabel: 'Slot 1', shareCode: '1Y8M7J7V1E' },
    ],
    slotPrice: 40,
}

function generateCode(): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    let code = ''
    for (let i = 0; i < 10; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length))
    }
    return code
}

/**
 * O Lua manda uma cor só; as duas tonalidades escuras do tema saem dela, na
 * mesma proporção da identidade (#dc1553 → #9c0f3b → #650a26).
 */
const applyThemeColor = (hex: string) => {
    const value = hex.replace('#', '').trim()
    if (value.length !== 6) return

    const r = parseInt(value.substring(0, 2), 16)
    const g = parseInt(value.substring(2, 4), 16)
    const b = parseInt(value.substring(4, 6), 16)
    if ([r, g, b].some(Number.isNaN)) return

    const shade = (factor: number) =>
        [r, g, b].map((channel) => Math.round(channel * factor)).join(', ')

    const root = document.documentElement
    root.style.setProperty('--primaryColor', `${r}, ${g}, ${b}`)
    root.style.setProperty('--secondaryColor', shade(0.71))
    root.style.setProperty('--thirdyColor', shade(0.46))
}

function App() {
    useClickSound()
    const { visible, setVisible, handleClose } = useVisibility()
    const [closing, setClosing] = useState(false)
    const [search, setSearch] = useState('')
    const [config, setConfig] = useState<WardrobeConfig>(defaultConfig)
    const [selectedSlot, setSelectedSlot] = useState<number | null>(null)
    const [showAddModal, setShowAddModal] = useState(false)
    const [confirmRemoveId, setConfirmRemoveId] = useState<number | null>(null)
    const [showUnlockConfirm, setShowUnlockConfirm] = useState(false)
    const [shareSlotId, setShareSlotId] = useState<number | null>(null)

    useEffect(() => {
        if (isEnvBrowser()) setVisible(true)
    }, [setVisible])

    useNuiEvent<WardrobeConfig>('openWardrobe', (data) => {
        if (data.themeColor) applyThemeColor(data.themeColor)
        setConfig({
            maxSlots: data.maxSlots ?? defaultConfig.maxSlots,
            unlockedSlots: data.unlockedSlots ?? defaultConfig.unlockedSlots,
            outfits: data.outfits ?? defaultConfig.outfits,
        })
        setSearch('')
        setSelectedSlot(null)
        setConfirmRemoveId(null)
        setShowUnlockConfirm(false)
        setShowAddModal(false)
        setShareSlotId(null)
        setClosing(false)
        setVisible(true)
    })

    useNuiEvent<WardrobeConfig>('updateWardrobe', (data) => {
        setConfig(prev => ({
            ...prev,
            ...data,
        }))
    })

    const closeWithAnimation = () => {
        if (closing) return
        setClosing(true)
        handleClose()
        setTimeout(() => {
            setClosing(false)
        }, 300)
    }

    useEffect(() => {
        const onKeyDown = (e: KeyboardEvent) => {
            if (e.key === 'Escape') {
                if (confirmRemoveId !== null) {
                    setConfirmRemoveId(null)
                    return
                }
                if (showUnlockConfirm) {
                    setShowUnlockConfirm(false)
                    return
                }
                if (showAddModal) {
                    setShowAddModal(false)
                    return
                }
                if (shareSlotId !== null) {
                    setShareSlotId(null)
                    return
                }
                closeWithAnimation()
            }
        }
        window.addEventListener('keydown', onKeyDown)
        return () => window.removeEventListener('keydown', onKeyDown)
    }, [closing, showAddModal, shareSlotId, confirmRemoveId, showUnlockConfirm])

    const handleSelectOutfit = (id: number) => {
        setSelectedSlot(id)
        fetchNui('core-wardrobe', { action: 'selectOutfit', id })
    }

    const handleRemoveOutfit = (id: number) => {
        fetchNui('core-wardrobe', { action: 'removeOutfit', id })
        setConfig(prev => ({
            ...prev,
            outfits: prev.outfits.filter(o => o.id !== id),
        }))
        if (selectedSlot === id) setSelectedSlot(null)
        setConfirmRemoveId(null)
    }

    const handleUnlockSlot = () => {
        setShowUnlockConfirm(true)
    }

    const handleConfirmUnlock = () => {
        fetchNui('core-wardrobe', { action: 'unlockSlot' })
        setShowUnlockConfirm(false)
    }

    const handleAddOutfit = (name: string) => {
        fetchNui('core-wardrobe', { action: 'addOutfit', name })
        setShowAddModal(false)
    }

    const handleImportCode = (code: string) => {
        fetchNui('core-wardrobe', { action: 'importCode', code })
        setShowAddModal(false)
    }

    const handleWear = () => {
        if (selectedSlot === null) return
        fetchNui('core-wardrobe', { action: 'wearOutfit', id: selectedSlot })
    }

    const handleUpdate = () => {
        if (selectedSlot === null) return
        fetchNui('core-wardrobe', { action: 'updateOutfit', id: selectedSlot })
    }

    const handleShare = (id: number) => {
        setShareSlotId(id)
        fetchNui('core-wardrobe', { action: 'shareOutfit', id })
    }

    const handleShareConfirm = () => {
        if (shareSlotId === null) return
        fetchNui('core-wardrobe', { action: 'confirmShare', id: shareSlotId })
        setShareSlotId(null)
    }

    if (!visible && !closing) return null

    const filteredOutfits = config.outfits.filter(o =>
        o.name.toLowerCase().includes(search.toLowerCase())
    )

    const emptyUnlockedCount = Math.max(0, config.unlockedSlots - config.outfits.length)
    const lockedCount = Math.max(0, config.maxSlots - config.unlockedSlots)

    const selectedOutfit = selectedSlot !== null
        ? config.outfits.find(o => o.id === selectedSlot)
        : null

    const shareOutfit = shareSlotId !== null
        ? config.outfits.find(o => o.id === shareSlotId)
        : null

    return (
        <div className={`wardrobe-root${isEnvBrowser() ? ' browser-mode' : ''}`}>
            <div className={`wardrobe-shell${closing ? ' closing' : ''}`}>
                <div className="wardrobe-inner">
                    {/* Header */}
                    <div className="panel-header">
                        <div className="header-icon">
                            <Hexagon className="wardrobe-hexagon" />
                            <svg viewBox="0 0 24 24" fill="none">
                                <path d="M15 4L21 6V11H18V19C18 19.2652 17.8946 19.5196 17.7071 19.7071C17.5196 19.8946 17.2652 20 17 20H7C6.73478 20 6.48043 19.8946 6.29289 19.7071C6.10536 19.5196 6 19.2652 6 19V11H3V6L9 4C9 4.79565 9.31607 5.55871 9.87868 6.12132C10.4413 6.68393 11.2044 7 12 7C12.7956 7 13.5587 6.68393 14.1213 6.12132C14.6839 5.55871 15 4.79565 15 4Z" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                            </svg>
                        </div>
                        <div className="header-content">
                            <h1>Armário</h1>
                            <p>Gerencie suas roupas salvas</p>
                        </div>
                        <button className="panel-close-btn" onClick={closeWithAnimation}>
                            <svg width="8" height="8" viewBox="0 0 14 14" fill="none">
                                <path d="M1 1l12 12M13 1L1 13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
                            </svg>
                        </button>
                    </div>

                    {/* Toolbar */}
                    <div className="panel-toolbar">
                        <SearchBar value={search} onChange={setSearch} />
                        <div className="toolbar-actions">
                            <button
                                className="toolbar-btn toolbar-btn-primary"
                                onClick={() => setShowAddModal(true)}
                            >
                                Adicionar
                            </button>
                            <button
                                className="toolbar-btn toolbar-btn-secondary"
                                onClick={() => { if (selectedSlot !== null) setConfirmRemoveId(selectedSlot) }}
                                style={{ opacity: selectedSlot === null ? 0.4 : 1 }}
                            >
                                Remover
                            </button>
                        </div>
                    </div>

                    {/* Slots Grid */}
                    <div className="slots-container">
                        <div className="slots-grid">
                            {filteredOutfits.map((outfit) => (
                                <WardrobeSlot
                                    key={outfit.id}
                                    outfit={outfit}
                                    isSelected={selectedSlot === outfit.id}
                                    onSelect={() => handleSelectOutfit(outfit.id)}
                                    onShare={() => handleShare(outfit.id)}
                                />
                            ))}

                            {!search && Array.from({ length: emptyUnlockedCount }).map((_, i) => (
                                <EmptySlot key={`empty-${i}`} />
                            ))}

                            {!search && Array.from({ length: lockedCount }).map((_, i) => (
                                <LockedSlot
                                    key={`locked-${i}`}
                                    onUnlock={handleUnlockSlot}
                                />
                            ))}
                        </div>
                    </div>

                    {/* Confirm Remove Modal */}
                    {confirmRemoveId !== null && (() => {
                        const outfit = config.outfits.find(o => o.id === confirmRemoveId)
                        if (!outfit) return null
                        return (
                            <ConfirmRemoveModal
                                outfitName={outfit.name}
                                onConfirm={() => handleRemoveOutfit(confirmRemoveId)}
                                onClose={() => setConfirmRemoveId(null)}
                            />
                        )
                    })()}

                    {/* Confirm Unlock Modal */}
                    {showUnlockConfirm && (
                        <div className="inline-modal-overlay" onClick={() => setShowUnlockConfirm(false)}>
                            <div className="inline-modal" onClick={(e) => e.stopPropagation()}>
                                <div className="inline-modal-title-row">
                                    <span className="inline-modal-title">Desbloquear Slot</span>
                                </div>

                                <div className="inline-modal-icon">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                                        <path d="M6 5H18L21 10L12.5 19.5C12.4348 19.5665 12.357 19.6194 12.2712 19.6554C12.1853 19.6915 12.0931 19.7101 12 19.7101C11.9069 19.7101 11.8147 19.6915 11.7288 19.6554C11.643 19.6194 11.5652 19.5665 11.5 19.5L3 10L6 5Z" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                                        <path d="M10 12L8 9.79999L8.6 8.79999" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                                    </svg>
                                </div>

                                <p className="confirm-modal-text">
                                    Deseja adquirir um slot extra por <strong>{config.slotPrice ?? 40} Gemas</strong>?
                                </p>

                                <button className="inline-modal-save-btn" onClick={handleConfirmUnlock}>
                                    Confirmar
                                </button>
                                <button className="inline-modal-cancel-btn" onClick={() => setShowUnlockConfirm(false)}>
                                    Cancelar
                                </button>
                            </div>
                        </div>
                    )}

                    {/* Add Outfit Modal (inline inside panel) */}
                    {showAddModal && (
                        <AddOutfitModal
                            onAdd={handleAddOutfit}
                            onImport={handleImportCode}
                            onClose={() => setShowAddModal(false)}
                        />
                    )}

                    {/* Share Modal (inline inside panel) */}
                    {shareOutfit && (
                        <ShareModal
                            code={shareOutfit.shareCode || generateCode()}
                            onConfirm={handleShareConfirm}
                            onClose={() => setShareSlotId(null)}
                        />
                    )}
                </div>

            </div>

            {/* Bottom Bar - appears when a slot is selected */}
            {selectedOutfit && !closing && (
                <div className="bottom-bar">
                    <div className="bottom-bar-inner">
                        <div className="bottom-bar-icon">
                            <svg width="14" height="14" viewBox="0 0 28 28" fill="none">
                                <path d="M14 6.12499C13.6686 6.12492 13.344 6.21896 13.0639 6.39616C12.7838 6.57337 12.5599 6.82646 12.418 7.12599C12.2655 7.43504 11.9976 7.67171 11.6721 7.78491C11.3466 7.89811 10.9896 7.87874 10.6783 7.731C10.367 7.58325 10.1262 7.31898 10.008 6.99525C9.88989 6.67152 9.90379 6.31431 10.0468 6.00074C10.3395 5.38376 10.7727 4.84389 11.3115 4.42433C11.8503 4.00477 12.4799 3.71718 13.1498 3.58458C13.8198 3.45198 14.5114 3.47804 15.1695 3.66069C15.8275 3.84334 16.4336 4.1775 16.9394 4.63643C17.4451 5.09535 17.8364 5.6663 18.0819 6.30356C18.3274 6.94083 18.4203 7.62671 18.3532 8.30632C18.286 8.98593 18.0607 9.64039 17.6953 10.2173C17.3299 10.7942 16.8345 11.2776 16.2488 11.6287C15.9687 11.7891 15.7149 11.9915 15.4963 12.229C15.3318 12.4215 15.3125 12.537 15.3125 12.5895C15.3125 12.712 15.379 12.8275 15.4875 12.887L24.4265 17.8535C25.114 18.2346 25.6554 18.8333 25.9655 19.5556C26.2757 20.2779 26.337 21.0828 26.1399 21.8437C25.9427 22.6047 25.4983 23.2785 24.8764 23.7593C24.2546 24.2402 23.4906 24.5007 22.7045 24.5H5.28851C4.50345 24.4997 3.7407 24.2388 3.11986 23.7583C2.49903 23.2778 2.05522 22.6049 1.85804 21.845C1.66086 21.0851 1.72146 20.2813 2.03034 19.5595C2.33922 18.8378 2.8789 18.239 3.56476 17.857L10.3005 14.112C10.4514 14.0234 10.6185 13.9659 10.792 13.9428C10.9655 13.9197 11.1419 13.9316 11.3107 13.9777C11.4795 14.0238 11.6374 14.1031 11.7751 14.2112C11.9128 14.3192 12.0275 14.4536 12.1125 14.6066C12.1975 14.7596 12.251 14.9281 12.2699 15.1021C12.2888 15.2761 12.2727 15.4521 12.2225 15.6198C12.1724 15.7874 12.0893 15.9434 11.978 16.0785C11.8667 16.2135 11.7295 16.325 11.5745 16.4062L4.84051 20.1512C4.66148 20.2497 4.52038 20.4051 4.43953 20.5927C4.35867 20.7804 4.34268 20.9896 4.39408 21.1874C4.44548 21.3851 4.56133 21.5601 4.72332 21.6846C4.88531 21.8092 5.08419 21.8762 5.28851 21.875H22.7045C22.9086 21.8753 23.1071 21.8078 23.2687 21.6831C23.4302 21.5583 23.5457 21.3834 23.597 21.1858C23.6483 20.9882 23.6325 20.7792 23.552 20.5916C23.4716 20.404 23.331 20.2485 23.1525 20.1495L14.21 15.1812C13.7489 14.9237 13.3647 14.548 13.0968 14.0929C12.8289 13.6377 12.6871 13.1194 12.6858 12.5912C12.6858 11.732 13.062 11.0372 13.4908 10.5315C13.9108 10.0327 14.4358 9.65299 14.896 9.37649C15.2243 9.17996 15.4791 8.88126 15.6215 8.52611C15.7638 8.17096 15.7859 7.77895 15.6842 7.41008C15.5826 7.04121 15.3629 6.71582 15.0587 6.48372C14.7545 6.25163 14.3826 6.12562 14 6.12499Z" fill="currentColor" />
                            </svg>
                        </div>
                        <div className="bottom-bar-info">
                            <span className="bottom-bar-name">{selectedOutfit.name}</span>
                            <span className="bottom-bar-label">{selectedOutfit.slotLabel}</span>
                        </div>
                        <div className="bottom-bar-actions">
                            <button className="bottom-bar-btn bottom-bar-btn-primary" onClick={handleWear}>
                                Vestir
                            </button>
                            <button className="bottom-bar-btn bottom-bar-btn-secondary" onClick={handleUpdate}>
                                Atualizar
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    )
}

export default App
