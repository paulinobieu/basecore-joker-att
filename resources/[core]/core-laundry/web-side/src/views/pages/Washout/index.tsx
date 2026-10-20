import { type CSSProperties, type ReactNode, useState } from 'react'
import { useNuiMessage } from '@app/hooks/useNuiMessage'
import { fetchNui } from '@app/utils/fetchNui'
import { isEnvBrowser } from '@app/utils/misc'
import { formatMoney, formatTime } from '@app/utils/format'
import { cn } from '@app/utils'
import {
    type WashConfig,
    type WashStatus,
    type TabKey,
    defaultConfig,
    defaultStatus,
} from '@app/types'
import { CloseIcon, CollectIcon, BoxPlusIcon, EfficiencyIcon, PowerIcon, MoneyIcon } from '@views/components/Icons'
import { HexButton, HexInfoIcon, HexBasketIcon, HexGearIcon } from '@views/components/HexButton'
import { UpgradeBars } from '@views/components/UpgradeBars'
import { CleanersModal } from '@views/components/CleanersModal'
import { UpgradeModal } from '@views/components/UpgradeModal'

const glass: CSSProperties = { background: 'var(--bn-glass)', backgroundBlendMode: 'screen' }
const accentGrad: CSSProperties = { background: 'var(--bn-accent-grad)', backgroundBlendMode: 'screen' }

function hexToRgbTuple(hex: string): string | null {
    const m = hex.trim().replace(/^#/, '')
    const full = m.length === 3 ? m.split('').map((c) => c + c).join('') : m
    if (!/^[0-9a-fA-F]{6}$/.test(full)) return null
    const r = parseInt(full.slice(0, 2), 16)
    const g = parseInt(full.slice(2, 4), 16)
    const b = parseInt(full.slice(4, 6), 16)
    return `${r}, ${g}, ${b}`
}

interface WashoutProps {
    closing?: boolean
    onRequestClose: () => void
    initial?: Partial<WashConfig> & { initialStatus?: WashStatus; logoUrl?: string }
}

export function Washout({ closing = false, onRequestClose, initial }: WashoutProps) {
    const [config, setConfig] = useState<WashConfig>(() => {
        if (!initial) return defaultConfig
        const { initialStatus, ...cfg } = initial
        return { ...defaultConfig, ...cfg }
    })
    const [status, setStatus] = useState<WashStatus>(() => initial?.initialStatus ?? defaultStatus)
    const [inputAmount, setInputAmount] = useState('')
    const [activeTab, setActiveTab] = useState<TabKey>('quantidade')
    const [logoError, setLogoError] = useState(false)

    const [cleanersModalOpen, setCleanersModalOpen] = useState(false)
    const [upgradeModal, setUpgradeModal] = useState<{ open: boolean; type: 'efficiency' | 'power' }>({
        open: false,
        type: 'efficiency',
    })

    const fmt = (v: number) => `${config.currencyPrefix}${formatMoney(v, config.currencySeparator)}${config.currencySuffix}`

    useNuiMessage<WashConfig & { initialStatus?: WashStatus }>('openLaundry', (data) => {
        const { initialStatus, ...cfg } = data
        setConfig((prev) => ({ ...prev, ...cfg }))
        setStatus(initialStatus ?? defaultStatus)
        setInputAmount('')
        setActiveTab('quantidade')
        setLogoError(false)

        if (cfg.themeColor) {
            const root = document.documentElement.style
            root.setProperty('--accent-color', cfg.themeColor)
            const rgb = hexToRgbTuple(cfg.themeColor)
            if (rgb) {
                root.setProperty('--accent-color-rgb', rgb)
                root.setProperty('--accent-color-dim', `rgba(${rgb}, 0.15)`)
                root.setProperty('--accent-color-bg', `rgba(${rgb}, 0.06)`)
            }
        }
    })

    useNuiMessage<Partial<WashStatus>>('updateWashStatus', (data) => {
        setStatus((prev) => ({ ...prev, ...data }))
    })

    useNuiMessage<Partial<WashConfig>>('updateConfig', (data) => {
        setConfig((prev) => ({ ...prev, ...data }))
    })

    useNuiMessage('washDone', () => {
        setStatus((prev) => ({ ...prev, isWashing: false, isDone: true, progress: 100 }))
    })

    const handleStartWash = () => {
        const amount = parseInt(inputAmount.replace(/\D/g, '')) || 0
        if (amount <= 0) return

        fetchNui('core-laundry', { action: 'startWash', amount })

        if (isEnvBrowser()) {
            const result = Math.floor(amount * (1 - config.taxRate / 100))
            setStatus({ isWashing: true, isDone: false, amount, result, time: 23, cleaners: 5, progress: 7 })
        }
    }

    const handleCollect = () => {
        fetchNui('core-laundry', { action: 'collectWash' })
        if (isEnvBrowser()) {
            setStatus(defaultStatus)
            setInputAmount('')
        }
    }

    const handleUpgradeEfficiency = () => {
        fetchNui('core-laundry', { action: 'upgradeEfficiency' })
        if (isEnvBrowser()) {
            setConfig((prev) => ({ ...prev, efficiencyLevel: Math.min(prev.efficiencyLevel + 1, prev.efficiencyMax) }))
        }
    }

    const handleUpgradePower = () => {
        fetchNui('core-laundry', { action: 'upgradePower' })
        if (isEnvBrowser()) {
            setConfig((prev) => ({ ...prev, powerLevel: Math.min(prev.powerLevel + 1, prev.powerMax) }))
        }
    }

    const handleAmountChange = (val: string) => {
        setInputAmount(val.replace(/\D/g, ''))
    }

    const handleAddAmount = (amount: number) => {
        const current = parseInt(inputAmount.replace(/\D/g, '')) || 0
        setInputAmount(String(current + amount))
    }

    const handleResetAmount = () => setInputAmount('')

    const handleAddCleaners = (amount: number) => {
        fetchNui('core-laundry', { action: 'addCleaners', amount })
        if (isEnvBrowser()) {
            setConfig((prev) => ({ ...prev, cleanersOwned: prev.cleanersOwned + amount }))
        }
    }

    const isActive = status.isWashing || status.isDone
    const fade = closing ? 'animate-bnFadeOut' : 'animate-bnFadeIn'

    const tabs: { key: TabKey; label: string; icon: ReactNode }[] = [
        { key: 'quantidade', label: 'Quantidade', icon: <MoneyIcon size={26} /> },
        { key: 'status', label: 'Status', icon: <HexInfoIcon /> },
        { key: 'armazem', label: 'Armazém', icon: <HexBasketIcon /> },
        { key: 'melhorias', label: 'Melhorias', icon: <HexGearIcon /> },
    ]
    const slotPos = ['top-0 left-0', 'top-[2.1875rem] right-0', 'top-[4.375rem] left-0', 'top-[6.5625rem] right-0']

    const parsedAmount = parseInt(inputAmount.replace(/\D/g, '')) || 0
    const projectedResult = Math.floor(parsedAmount * (1 - config.taxRate / 100))
    const footerTotal = isActive ? status.result : projectedResult

    const footerLabel = status.isDone ? 'Coletar' : status.isWashing ? 'Em Lavagem...' : 'Iniciar Lavagem'
    const footerDisabled = status.isWashing || (!status.isDone && parsedAmount <= 0)
    const handleFooterAction = () => {
        if (status.isDone) {
            handleCollect()
            return
        }
        if (!status.isWashing) handleStartWash()
    }

    const chipCls =
        'group relative h-[2.125rem] rounded-[0.1875rem] border border-[rgba(221,221,221,0.25)] font-outfit font-bold text-[0.6875rem] uppercase text-[#dddddd] cursor-pointer overflow-hidden transition-all duration-500 enabled:hover:border-accent enabled:hover:text-white enabled:active:brightness-[0.6] disabled:opacity-45 disabled:cursor-not-allowed'

    const Chip = ({
        onClick,
        disabled,
        wide,
        children,
    }: {
        onClick: () => void
        disabled?: boolean
        wide?: boolean
        children: ReactNode
    }) => (
        <button type="button" className={cn(chipCls, wide && 'w-full')} style={glass} onClick={onClick} disabled={disabled}>
            <span
                className="absolute inset-0 opacity-0 transition-opacity duration-500 group-enabled:group-hover:opacity-100"
                style={accentGrad}
            />
            <span className="relative z-[1]">{children}</span>
        </button>
    )

    return (
        <>
            {config.logoUrl && !logoError && (
                <img
                    className={cn(
                        'fixed top-[1.25rem] left-1/2 -translate-x-1/2 h-[6.25rem] w-[12.5rem] object-contain pointer-events-none z-20',
                        fade,
                    )}
                    src={config.logoUrl}
                    alt=""
                    onError={() => setLogoError(true)}
                />
            )}

            <nav className={cn('fixed left-[2.5rem] top-1/2 w-[8.125rem] h-[10.9375rem] mt-[-5.46875rem] z-20', fade)}>
                {tabs.map((tab, i) => (
                    <div key={tab.key} className={cn('absolute w-[4.375rem] h-[4.375rem]', slotPos[i])}>
                        <HexButton
                            icon={tab.icon}
                            label={tab.label}
                            active={activeTab === tab.key}
                            onClick={() => setActiveTab(tab.key)}
                        />
                    </div>
                ))}
            </nav>

            <div
                className={cn(
                    'fixed right-[2.5rem] bottom-[2.5rem] h-[92.5vh] w-[19.1875rem] flex flex-col z-20',
                    fade,
                )}
            >
                <header className="w-[17.5rem] mx-auto mb-[1.25rem] flex items-center justify-between">
                    <div className="flex flex-col">
                        <span className="font-extrabold text-[1rem] uppercase tracking-[-0.02em]">Lavagem</span>
                        <span className="font-semibold text-[0.6875rem] uppercase text-white/45">{config.machineName}</span>
                    </div>
                    <button
                        type="button"
                        className="w-[1.75rem] h-[1.75rem] flex items-center justify-center rounded-[0.1875rem] border border-[rgba(221,221,221,0.25)] text-white/70 cursor-pointer transition-all duration-500 hover:border-accent hover:text-white"
                        style={glass}
                        onClick={onRequestClose}
                    >
                        <CloseIcon size={12} />
                    </button>
                </header>

                <main className="bn-scroll flex-1 overflow-y-auto overflow-x-hidden flex flex-col gap-[1.375rem] mb-[2rem] pb-[0.25rem]">
                    {activeTab === 'quantidade' && (
                        <>
                            <div className="w-[17.5rem] mx-auto flex flex-col items-center gap-[0.625rem] flex-shrink-0">
                                <h1 className="flex items-center justify-center gap-[0.4rem] font-semibold text-[1rem] uppercase text-center">
                                    Quantidade
                                </h1>
                                <input
                                    className="w-full h-[2.125rem] rounded-[0.1875rem] border border-[rgba(221,221,221,0.25)] text-center font-outfit font-semibold text-[0.875rem] text-white placeholder:text-white/35 disabled:opacity-50 outline-none"
                                    style={glass}
                                    placeholder={`Mínimo ${fmt(50000)}`}
                                    value={inputAmount ? fmt(parseInt(inputAmount)) : ''}
                                    onChange={(e) => handleAmountChange(e.target.value)}
                                    disabled={isActive}
                                />
                                <div className="w-full grid grid-cols-2 gap-[0.5rem]">
                                    <Chip onClick={() => handleAddAmount(50000)} disabled={isActive}>+ {fmt(50000)}</Chip>
                                    <Chip onClick={() => handleAddAmount(100000)} disabled={isActive}>+ {fmt(100000)}</Chip>
                                    <Chip onClick={() => handleAddAmount(500000)} disabled={isActive}>+ {fmt(500000)}</Chip>
                                    <Chip onClick={handleResetAmount} disabled={isActive}>Resetar</Chip>
                                </div>
                            </div>
                            <div className="w-[17.5rem] mx-auto flex flex-col items-center gap-[0.625rem] flex-shrink-0">
                                <h1 className="flex items-center justify-center gap-[0.4rem] font-semibold text-[1rem] uppercase text-center">
                                    Informações
                                </h1>
                                <Line label="Taxa da Máquina" value={`${config.taxRate}%`} valueColor="var(--bn-red)" />
                                <Line label="Notas Marcadas" value={fmt(parsedAmount)} />
                                <Line label="Resultado Estimado" value={fmt(projectedResult)} valueColor="var(--bn-green)" />
                            </div>
                        </>
                    )}

                    {activeTab === 'status' && (
                        <div className="w-[17.5rem] mx-auto flex flex-col items-center gap-[0.625rem] flex-shrink-0">
                            <h1 className="flex items-center justify-center gap-[0.4rem] font-semibold text-[1rem] uppercase text-center">
                                Status
                            </h1>
                            <Line label="Lavando" value={fmt(isActive ? status.amount : 0)} />
                            <Line label="Resultado" value={fmt(isActive ? status.result : 0)} valueColor="var(--bn-green)" />
                            <Line label="Tempo" value={isActive ? formatTime(status.time) : '00:00'} />
                            <Line label="Limpadores" value={String(isActive ? status.cleaners : 0)} />
                        </div>
                    )}

                    {activeTab === 'armazem' && (
                        <div className="w-[17.5rem] mx-auto flex flex-col items-center gap-[0.625rem] flex-shrink-0">
                            <h1 className="flex items-center justify-center gap-[0.4rem] font-semibold text-[1rem] uppercase text-center">
                                Armazém
                            </h1>
                            <div className="w-full flex items-center gap-[0.5rem]">
                                <Line
                                    className="flex-1"
                                    label="Dinheiro Limpo"
                                    value={fmt(isActive ? status.result : 0)}
                                    valueColor="var(--bn-green)"
                                />
                                <IconBtn onClick={handleCollect} disabled={!status.isDone}>
                                    <CollectIcon size={16} />
                                </IconBtn>
                            </div>
                            <div className="w-full flex items-center gap-[0.5rem]">
                                <Line className="flex-1" label="Limpadores" value={String(config.cleanersOwned)} />
                                <IconBtn onClick={() => setCleanersModalOpen(true)}>
                                    <BoxPlusIcon size={16} />
                                </IconBtn>
                            </div>
                        </div>
                    )}

                    {activeTab === 'melhorias' && (
                        <>
                            <div className="w-[17.5rem] mx-auto flex flex-col items-center gap-[0.625rem] flex-shrink-0">
                                <h1 className="flex items-center justify-center gap-[0.4rem] font-semibold text-[1rem] uppercase text-center">
                                    <EfficiencyIcon size={15} /> Eficiência
                                </h1>
                                <span className="font-semibold text-[0.6875rem] uppercase text-white/45 mt-[-0.375rem]">
                                    Capacidade da Máquina
                                </span>
                                <div className="w-full [&>.upgrade-bars]:w-full [&>.upgrade-bars]:mb-0">
                                    <UpgradeBars level={config.efficiencyLevel} maxLevel={config.efficiencyMax} />
                                </div>
                                {config.efficiencyLevel >= config.efficiencyMax ? (
                                    <span
                                        className="w-full h-[2.125rem] flex items-center justify-center rounded-[0.1875rem] border border-[rgba(36,245,120,0.35)] bg-[rgba(36,245,120,0.08)] font-bold text-[0.6875rem] uppercase"
                                        style={{ color: 'var(--bn-green)' }}
                                    >
                                        Nível Máximo
                                    </span>
                                ) : (
                                    <Chip wide onClick={() => setUpgradeModal({ open: true, type: 'efficiency' })}>
                                        Melhorar · {fmt(config.efficiencyCost)}
                                    </Chip>
                                )}
                            </div>
                            <div className="w-[17.5rem] mx-auto flex flex-col items-center gap-[0.625rem] flex-shrink-0">
                                <h1 className="flex items-center justify-center gap-[0.4rem] font-semibold text-[1rem] uppercase text-center">
                                    <PowerIcon size={15} /> Potência
                                </h1>
                                <span className="font-semibold text-[0.6875rem] uppercase text-white/45 mt-[-0.375rem]">
                                    Velocidade da Máquina
                                </span>
                                <div className="w-full [&>.upgrade-bars]:w-full [&>.upgrade-bars]:mb-0">
                                    <UpgradeBars level={config.powerLevel} maxLevel={config.powerMax} />
                                </div>
                                {config.powerLevel >= config.powerMax ? (
                                    <span
                                        className="w-full h-[2.125rem] flex items-center justify-center rounded-[0.1875rem] border border-[rgba(36,245,120,0.35)] bg-[rgba(36,245,120,0.08)] font-bold text-[0.6875rem] uppercase"
                                        style={{ color: 'var(--bn-green)' }}
                                    >
                                        Nível Máximo
                                    </span>
                                ) : (
                                    <Chip wide onClick={() => setUpgradeModal({ open: true, type: 'power' })}>
                                        Melhorar · {fmt(config.powerCost)}
                                    </Chip>
                                )}
                            </div>
                        </>
                    )}
                </main>

                <footer className="w-[17.5rem] mx-auto flex flex-col gap-[0.75rem]">
                    <div className="w-full flex items-center justify-between">
                        <span className="font-bold text-[0.875rem] uppercase">Total:</span>
                        <h1 className="font-bold text-[1.25rem]" style={{ color: 'var(--bn-green)' }}>
                            {fmt(footerTotal)}
                        </h1>
                    </div>
                    <button
                        type="button"
                        className="w-full h-[2.5rem] flex items-center justify-center rounded-[0.3125rem] border border-accent text-white font-outfit font-extrabold text-[0.875rem] uppercase tracking-[-0.04em] cursor-pointer transition-[filter] duration-500 enabled:hover:brightness-75 enabled:active:brightness-50 disabled:opacity-50 disabled:cursor-not-allowed disabled:grayscale-[0.4]"
                        style={accentGrad}
                        onClick={handleFooterAction}
                        disabled={footerDisabled}
                    >
                        {footerLabel}
                    </button>
                </footer>
            </div>

            <div className={cn('fixed bottom-[2.5rem] left-1/2 -translate-x-1/2 flex gap-[1.25rem] z-20', fade)}>
                <div className="flex items-center gap-[0.625rem] font-bold text-[0.75rem] uppercase text-white/60">
                    <span
                        className="h-[1.4375rem] flex items-center justify-center px-[0.5625rem] rounded-[0.25rem] border border-white/25 font-extrabold text-[0.8125rem] text-white"
                        style={glass}
                    >
                        ESC
                    </span>
                    Sair
                </div>
            </div>

            <CleanersModal open={cleanersModalOpen} onClose={() => setCleanersModalOpen(false)} onConfirm={handleAddCleaners} />
            <UpgradeModal
                open={upgradeModal.open}
                onClose={() => setUpgradeModal((prev) => ({ ...prev, open: false }))}
                onConfirm={upgradeModal.type === 'efficiency' ? handleUpgradeEfficiency : handleUpgradePower}
                upgradeName={upgradeModal.type === 'efficiency' ? 'Eficiência' : 'Potência'}
                currentLevel={upgradeModal.type === 'efficiency' ? config.efficiencyLevel : config.powerLevel}
                cost={upgradeModal.type === 'efficiency' ? config.efficiencyCost : config.powerCost}
                formatCurrency={fmt}
            />
        </>
    )
}

function Line({
    label,
    value,
    valueColor,
    className,
}: {
    label: string
    value: string
    valueColor?: string
    className?: string
}) {
    return (
        <div
            className={cn(
                'w-full h-[2.125rem] flex-shrink-0 flex items-center justify-between px-[0.75rem] rounded-[0.1875rem] border border-[rgba(221,221,221,0.25)]',
                className,
            )}
            style={glass}
        >
            <span className="font-semibold text-[0.6875rem] uppercase text-white/55">{label}</span>
            <b className="font-bold text-[0.8125rem] text-white" style={valueColor ? { color: valueColor } : undefined}>
                {value}
            </b>
        </div>
    )
}

function IconBtn({
    onClick,
    disabled,
    children,
}: {
    onClick: () => void
    disabled?: boolean
    children: ReactNode
}) {
    return (
        <button
            type="button"
            className="relative w-[2.5rem] h-[2.125rem] flex-shrink-0 flex items-center justify-center rounded-[0.1875rem] border border-[rgba(221,221,221,0.25)] text-[#dddddd] cursor-pointer transition-all duration-500 enabled:hover:border-accent enabled:hover:text-white enabled:active:brightness-[0.6] disabled:opacity-45 disabled:cursor-not-allowed"
            style={glass}
            onClick={onClick}
            disabled={disabled}
        >
            {children}
        </button>
    )
}

export default Washout
