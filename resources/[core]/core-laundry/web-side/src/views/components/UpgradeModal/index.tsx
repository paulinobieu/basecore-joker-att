import { cn } from '@app/utils'
import { Modal } from '@views/components/Modal'
import { HexSelected } from '@views/components/HexButton'

interface UpgradeModalProps {
    open: boolean
    onClose: () => void
    onConfirm: () => void
    upgradeName: string
    currentLevel: number
    cost: number
    formatCurrency: (v: number) => string
}

export function UpgradeModal({ open, onClose, onConfirm, upgradeName, currentLevel, cost, formatCurrency }: UpgradeModalProps) {
    const nextLevel = currentLevel + 1

    const handleConfirm = () => {
        onConfirm()
        onClose()
    }

    return (
        <Modal open={open} onClose={onClose}>
            <div
                className="flex flex-col items-center gap-[0.9375rem]"
                style={{ fontFamily: "'Outfit', sans-serif" }}
            >
                <div className="flex items-center gap-[0.9375rem]">
                    <div
                        className="relative flex h-[4.375rem] w-[4.6875rem] flex-shrink-0 items-center justify-center"
                        style={{ filter: 'drop-shadow(0 0 10px rgba(var(--accent-color-rgb), 0.6))' }}
                    >
                        <span className="absolute left-1/2 top-1/2 flex -translate-x-1/2 -translate-y-1/2">
                            <HexSelected />
                        </span>
                        <span className="relative z-[2] flex text-white">
                            <svg width={24} height={24} viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path
                                    d="M12 19V5M5 12l7-7 7 7"
                                    stroke="currentColor"
                                    strokeWidth="2.5"
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                />
                            </svg>
                        </span>
                    </div>
                    <div className="flex flex-col">
                        <span className="text-xs font-medium leading-none text-white/70">Realizar upgrade</span>
                        <h1 className="text-[1.6875rem] font-extrabold uppercase leading-[1.1] text-white">{upgradeName}</h1>
                    </div>
                </div>
                <span className="text-[0.8125rem] font-semibold text-white/60">
                    Nível <b className="font-extrabold text-white">{currentLevel}</b> → <b className="font-extrabold text-white">{nextLevel}</b> por{' '}
                    <b className="font-extrabold text-white">{formatCurrency(cost)}</b>
                </span>
                <div className="flex flex-col gap-2">
                    <button
                        type="button"
                        className="flex h-[1.9375rem] w-[13.75rem] items-center justify-center rounded-[0.1875rem] border border-[var(--accent-color)] text-sm font-extrabold uppercase text-white bg-blend-screen transition-all duration-500 hover:brightness-75 active:brightness-50"
                        style={{
                            fontFamily: "'Outfit', sans-serif",
                            background:
                                'linear-gradient(0deg, rgba(0, 0, 0, 0.6), rgba(0, 0, 0, 0.6)), radial-gradient(50% 43.54% at 50% 50%, rgba(var(--accent-color-rgb), 0.9) 0%, rgba(var(--accent-color-rgb), 0.9) 100%)',
                        }}
                        onClick={handleConfirm}
                    >
                        Confirmar
                    </button>
                    <button
                        type="button"
                        className={cn(
                            'flex h-[1.9375rem] w-[13.75rem] items-center justify-center rounded-[0.1875rem] border border-[rgba(221,221,221,0.25)] text-sm font-extrabold uppercase text-[#dddddd] bg-blend-screen transition-all duration-500',
                            'hover:border-[var(--accent-color)] hover:text-white hover:brightness-90 active:brightness-[0.6]',
                        )}
                        style={{ fontFamily: "'Outfit', sans-serif", background: 'var(--bn-glass)' }}
                        onClick={onClose}
                    >
                        Cancelar
                    </button>
                </div>
            </div>
        </Modal>
    )
}
