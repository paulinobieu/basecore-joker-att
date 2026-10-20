import { useEffect, useState, type InputHTMLAttributes, type ReactNode } from 'react'
import { fetchNui } from '@app/utils/fetchNui'
import { isEnvBrowser } from '@app/utils/misc'
import { useNuiMessage } from '@app/hooks/useNuiMessage'
import { cn } from '@app/utils'
import { type AdminSettings, type MachinePoint, defaultAdminSettings } from '@app/types'

interface AdminPanelProps {
    machines: MachinePoint[]
    settings: AdminSettings | null
    logoUrl: string
    onClose: () => void
    onRefresh: () => void
}

type AdminPage = 'maquinas' | 'geral' | 'lavagem' | 'upgrades'

const PageMeta: Record<AdminPage, { title: string }> = {
    maquinas: { title: 'Máquinas' },
    geral: { title: 'Geral' },
    lavagem: { title: 'Lavagem' },
    upgrades: { title: 'Upgrades' },
}

function cloneSettings(s: AdminSettings): AdminSettings {
    return JSON.parse(JSON.stringify(s))
}

const SCROLL =
    '[&::-webkit-scrollbar]:w-[0.3125rem] [&::-webkit-scrollbar-track]:bg-[#d9d9d90a] [&::-webkit-scrollbar-track]:rounded-[0.3125rem] [&::-webkit-scrollbar-thumb]:rounded-[0.3125rem] [&::-webkit-scrollbar-thumb]:bg-[linear-gradient(49.08deg,rgba(var(--accent-color-rgb),0.9)_1.07%,rgba(var(--accent-color-rgb),0.9)_62.63%)]'

/* ---------- craft nav hex backgrounds ---------- */

function NavHexBg({ active }: { active: boolean }) {
    const base =
        'absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 flex pointer-events-none transition-opacity duration-500'
    return (
        <>
            <svg width="4.125rem" height="4.125rem" viewBox="0 0 66 66" fill="none" xmlns="http://www.w3.org/2000/svg" className={cn(base, !active ? 'opacity-100' : 'opacity-0')}>
                <path d="M62.3916 29.75C63.4802 31.6355 63.5484 33.9314 62.5957 35.8682L62.3916 36.25L50.5107 56.8291C49.3496 58.8402 47.2031 60.0791 44.8809 60.0791L21.1191 60.0791C18.9419 60.0791 16.9197 58.9897 15.7187 57.1963L15.4893 56.8291L3.6084 36.25C2.51979 34.3645 2.45163 32.0686 3.4043 30.1318L3.6084 29.75L15.4893 9.1709C16.6504 7.15981 18.7969 5.9209 21.1191 5.9209L44.8809 5.9209C47.0581 5.9209 49.0803 7.01032 50.2812 8.80371L50.5107 9.1709L62.3916 29.75Z" stroke="#484848" strokeWidth="3" />
                <path d="M58.5566 30.5C59.4498 32.047 59.4498 33.953 58.5566 35.5L47.9434 53.8827C47.0502 55.4297 45.3996 56.3827 43.6132 56.3827L22.3868 56.3827C20.6004 56.3827 18.9498 55.4297 18.0566 53.8827L7.44338 35.5C6.55022 33.953 6.55022 32.047 7.44338 30.5L18.0566 12.1173C18.9498 10.5703 20.6004 9.61731 22.3868 9.61731L43.6132 9.61731C45.3996 9.61731 47.0502 10.5703 47.9434 12.1173L58.5566 30.5Z" fill="#484848" fillOpacity="0.5" />
            </svg>
            <svg width="4.625rem" height="4.25rem" viewBox="0 0 74 68" fill="none" xmlns="http://www.w3.org/2000/svg" className={cn(base, active ? 'opacity-100' : 'opacity-0')}>
                <path d="M66.3916 30.75C67.4802 32.6355 67.5484 34.9314 66.5957 36.8682L66.3916 37.25L54.5107 57.8291C53.3496 59.8402 51.2031 61.0791 48.8809 61.0791L25.1191 61.0791C22.9419 61.0791 20.9197 59.9897 19.7187 58.1963L19.4893 57.8291L7.6084 37.25C6.51979 35.3645 6.45163 33.0686 7.4043 31.1318L7.6084 30.75L19.4893 10.1709C20.6504 8.15981 22.7969 6.9209 25.1191 6.9209L48.8809 6.9209C51.0581 6.9209 53.0803 8.01032 54.2812 9.80371L54.5107 10.1709L66.3916 30.75Z" stroke="url(#admhx_a)" strokeWidth="3" />
                <path d="M62.5566 31.5C63.4498 33.047 63.4498 34.953 62.5566 36.5L51.9434 54.8827C51.0502 56.4297 49.3996 57.3827 47.6132 57.3827L26.3868 57.3827C24.6004 57.3827 22.9498 56.4297 22.0566 54.8827L11.4434 36.5C10.5502 34.953 10.5502 33.047 11.4434 31.5L22.0566 13.1173C22.9498 11.5703 24.6004 10.6173 26.3868 10.6173L47.6132 10.6173C49.3996 10.6173 51.0502 11.5703 51.9434 13.1173L62.5566 31.5Z" fill="url(#admhx_b)" fillOpacity="0.9" />
                <path d="M62.5566 31.5C63.4498 33.047 63.4498 34.953 62.5566 36.5L51.9434 54.8827C51.0502 56.4297 49.3996 57.3827 47.6132 57.3827L26.3868 57.3827C24.6004 57.3827 22.9498 56.4297 22.0566 54.8827L11.4434 36.5C10.5502 34.953 10.5502 33.047 11.4434 31.5L22.0566 13.1173C22.9498 11.5703 24.6004 10.6173 26.3868 10.6173L47.6132 10.6173C49.3996 10.6173 51.0502 11.5703 51.9434 13.1173L62.5566 31.5Z" fill="url(#admhx_c)" fillOpacity="0.3" />
                <path d="M62.21 31.7002C62.9803 33.0345 63.0285 34.6587 62.3545 36.0293L62.21 36.2998L51.5967 54.6826C50.775 56.1058 49.2567 56.9824 47.6133 56.9824L26.3867 56.9824C24.8462 56.9824 23.4154 56.2122 22.5654 54.9434L22.4033 54.6826L11.79 36.2998C11.0197 34.9655 10.9715 33.3413 11.6455 31.9707L11.79 31.7002L22.4033 13.3174C23.225 11.8942 24.7433 11.0176 26.3867 11.0176L47.6133 11.0176C49.1538 11.0176 50.5846 11.7878 51.4346 13.0566L51.5967 13.3174L62.21 31.7002Z" stroke="rgb(var(--accent-color-rgb))" strokeWidth="0.8" />
                <defs>
                    <linearGradient id="admhx_a" x1="5.52308" y1="0.999997" x2="65.8511" y2="70.5964" gradientUnits="userSpaceOnUse">
                        <stop stopColor="rgb(var(--accent-color-rgb))" />
                        <stop offset="0.622285" stopColor="rgb(var(--accent-color-rgb))" />
                    </linearGradient>
                    <linearGradient id="admhx_b" x1="11.2462" y1="7" x2="60.6054" y2="63.9425" gradientUnits="userSpaceOnUse">
                        <stop stopColor="rgb(var(--accent-color-rgb))" />
                        <stop offset="0.622285" stopColor="rgb(var(--accent-color-rgb))" />
                    </linearGradient>
                    <radialGradient id="admhx_c" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(37 34) rotate(90) scale(27 328.336)">
                        <stop />
                        <stop offset="1" stopColor="rgb(var(--accent-color-rgb))" stopOpacity="0" />
                    </radialGradient>
                </defs>
            </svg>
        </>
    )
}

function NavHex({ active, label, onClick, children }: { active: boolean; label: string; onClick: () => void; children: ReactNode }) {
    const [hovered, setHovered] = useState(false)
    const lit = active || hovered

    return (
        <button
            type="button"
            className="relative flex items-center justify-center w-[4.125rem] h-[4.125rem] bg-transparent border-none cursor-pointer"
            title={label}
            onMouseEnter={() => setHovered(true)}
            onMouseLeave={() => setHovered(false)}
            onClick={onClick}
        >
            <NavHexBg active={lit} />
            <span className={cn('relative z-[2] flex transition-colors duration-500', lit ? 'text-white' : 'text-[#dddddd]')}>{children}</span>
        </button>
    )
}

/* ---------- icons ---------- */

const MachineIcon = (
    <svg width="1.5rem" height="1.5rem" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
        <rect x="4" y="2.5" width="16" height="19" rx="2" />
        <circle cx="12" cy="13.5" r="4.5" />
        <circle cx="7.2" cy="5.8" r="0.4" fill="currentColor" />
        <circle cx="9.8" cy="5.8" r="0.4" fill="currentColor" />
        <path d="M8 13.9c1.3-1.2 2.7 1.2 4 0s2.7 1.2 4 0" strokeWidth="1.3" />
    </svg>
)

const GeneralIcon = (
    <svg width="1.5rem" height="1.5rem" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round">
        <line x1="4" y1="7" x2="20" y2="7" />
        <line x1="4" y1="12" x2="20" y2="12" />
        <line x1="4" y1="17" x2="20" y2="17" />
        <circle cx="9" cy="7" r="1.8" fill="#111114" />
        <circle cx="15" cy="12" r="1.8" fill="#111114" />
        <circle cx="7" cy="17" r="1.8" fill="#111114" />
    </svg>
)

const WashIcon = (
    <svg width="1.4rem" height="1.4rem" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
        <path d="M12 2.7 6.6 10a6.7 6.7 0 1 0 10.8 0L12 2.7Z" />
        <path d="M9 14.5c1.5-1.3 3 1.3 4.5 0s1.5 1.3 1.5 1.3" strokeWidth="1.3" />
    </svg>
)

const UpgradeIcon = (
    <svg width="1.5rem" height="1.5rem" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">
        <path d="M5 14.5 12 7.5l7 7" />
        <path d="M5 20 12 13l7 7" opacity="0.45" />
    </svg>
)

const CloseIconSvg = (
    <svg width="1.3rem" height="1.3rem" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round">
        <path d="M18 6L6 18M6 6l12 12" />
    </svg>
)

const TeleportGlyph = (
    <svg width="0.9rem" height="0.9rem" viewBox="0 0 24 24" fill="currentColor">
        <path d="M3.004 11.998L21 2L12.002 20.996L10.002 13.998L3.004 11.998Z" />
    </svg>
)

const EditGlyph = (
    <svg width="0.9rem" height="0.9rem" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M12 20h9" />
        <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z" />
    </svg>
)

const TrashGlyph = (
    <svg width="0.9rem" height="0.9rem" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M3 6h18M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6" />
    </svg>
)

const LocationGlyph = (
    <svg width="0.9rem" height="0.9rem" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <circle cx="12" cy="12" r="3" />
        <circle cx="12" cy="12" r="8" />
        <line x1="12" y1="2" x2="12" y2="4" strokeLinecap="round" />
        <line x1="12" y1="20" x2="12" y2="22" strokeLinecap="round" />
        <line x1="2" y1="12" x2="4" y2="12" strokeLinecap="round" />
        <line x1="20" y1="12" x2="22" y2="12" strokeLinecap="round" />
    </svg>
)

/* ---------- primitives ---------- */

const FIELD_LABEL = 'font-extrabold text-[0.625rem] tracking-[0.03em] uppercase text-[#EDEAE566]'
const HINT = 'font-semibold text-[0.625rem] leading-[1.5] text-[#EDEAE54D] mt-auto'

function Field({ label, children }: { label: string; children: ReactNode }) {
    return (
        <div className="flex flex-col gap-[0.45rem]">
            <span className={FIELD_LABEL}>{label}</span>
            {children}
        </div>
    )
}

function Input({ center, className, ...props }: InputHTMLAttributes<HTMLInputElement> & { center?: boolean }) {
    return (
        <input
            {...props}
            className={cn(
                'h-[2.375rem] w-full rounded-[0.3125rem] border border-[rgba(255,255,255,0.08)] text-white font-bold text-[0.8125rem] outline-none transition-[border-color] duration-300 focus:border-accent placeholder:text-[#EDEAE54D]',
                center ? 'text-center px-[0.25rem]' : 'px-[0.75rem]',
                className,
            )}
            style={{ background: 'rgba(221, 221, 221, 0.05)' }}
        />
    )
}

function IconBtn({ red, className, children, ...props }: React.ButtonHTMLAttributes<HTMLButtonElement> & { red?: boolean }) {
    return (
        <button
            type="button"
            {...props}
            className={cn(
                'flex items-center justify-center w-[1.75rem] h-[1.75rem] rounded-[0.3125rem] border border-[rgba(255,255,255,0.03)] bg-[rgba(221,221,221,0.17)] text-[#EDEAE5B2] cursor-pointer transition-all duration-300 disabled:opacity-30 disabled:cursor-not-allowed',
                red
                    ? 'enabled:hover:bg-[rgba(221,221,221,0.25)] enabled:hover:text-[#F72420] enabled:hover:border-[rgba(247,36,32,0.4)]'
                    : 'enabled:hover:bg-[rgba(221,221,221,0.25)] enabled:hover:text-white',
                className,
            )}
        >
            {children}
        </button>
    )
}

function Toggle({ active, onToggle }: { active: boolean; onToggle: () => void }) {
    return (
        <button
            type="button"
            onClick={onToggle}
            className={cn(
                'relative w-[2.375rem] h-[1.25rem] shrink-0 rounded-full cursor-pointer transition-all duration-300 border',
                active ? 'border-[rgba(255,255,255,0.15)]' : 'border-[rgba(255,255,255,0.08)] bg-[rgba(221,221,221,0.15)]',
            )}
            style={active ? { background: 'var(--bn-accent-grad)' } : undefined}
        >
            <span
                className={cn(
                    'absolute top-1/2 w-[0.875rem] h-[0.875rem] rounded-full -translate-y-1/2 transition-all duration-300',
                    active ? 'left-[calc(100%-1rem)] bg-white' : 'left-[0.125rem] bg-[#adadad]',
                )}
            />
        </button>
    )
}

function Card({ className, style, children }: { className?: string; style?: React.CSSProperties; children: ReactNode }) {
    return (
        <div
            className={cn('flex flex-col gap-[0.9rem] pt-[1.4rem] px-[1.4rem] pb-[1.5rem] rounded-[0.5rem] min-h-0', className)}
            style={{ background: 'rgba(217, 217, 217, 0.035)', border: '1px solid rgba(255, 255, 255, 0.05)', ...style }}
        >
            {children}
        </div>
    )
}

function CardTitle({ children, bare }: { children: ReactNode; bare?: boolean }) {
    return (
        <h2 className={cn('font-black text-[0.8125rem] tracking-[0.02em] uppercase text-white', !bare && 'pb-[0.85rem] border-b border-[rgba(255,255,255,0.06)]')}>
            {children}
        </h2>
    )
}

const BTN_BASE =
    'flex items-center justify-center h-[2.25rem] gap-[0.375rem] rounded-[0.3125rem] font-black text-[0.6875rem] uppercase cursor-pointer transition-all duration-300'
const BTN_GHOST = 'bg-[rgba(221,221,221,0.17)] border border-[rgba(255,255,255,0.03)] text-[#EDEAE5B2] hover:bg-[rgba(221,221,221,0.25)] hover:text-white'
const BTN_DASHED = 'bg-transparent border border-dashed border-[rgba(255,255,255,0.15)] text-[#EDEAE580] hover:border-accent hover:text-white'

function numeric(value: string): number {
    return parseInt(value.replace(/\D/g, '')) || 0
}

/* ---------- panel ---------- */

export function Admin({ machines, settings, logoUrl, onClose, onRefresh }: AdminPanelProps) {
    const [page, setPage] = useState<AdminPage>('maquinas')
    const [draft, setDraft] = useState<AdminSettings>(cloneSettings(settings || defaultAdminSettings))
    const [filter, setFilter] = useState('')
    const [logoError, setLogoError] = useState(false)

    const [editingId, setEditingId] = useState<string | null>(null)
    const [name, setName] = useState('')
    const [permission, setPermission] = useState('')
    const [spawnObject, setSpawnObject] = useState(true)
    const [x, setX] = useState('')
    const [y, setY] = useState('')
    const [z, setZ] = useState('')
    const [h, setH] = useState('')

    useEffect(() => {
        setDraft(cloneSettings(settings || defaultAdminSettings))
    }, [settings])

    useNuiMessage<{ x: number; y: number; z: number; h: number }>('setPlacementCoords', (data) => {
        setX(String(data.x))
        setY(String(data.y))
        setZ(String(data.z))
        setH(String(data.h))
    })

    const resetForm = () => {
        setEditingId(null)
        setName('')
        setPermission('')
        setSpawnObject(true)
        setX('')
        setY('')
        setZ('')
        setH('')
    }

    const handleGetLocation = () => {
        if (isEnvBrowser()) {
            setX('-198.6')
            setY('-996.2')
            setZ('29.5')
            setH('34')
            return
        }
        fetchNui('core-laundry', { action: 'getLocation', spawnObject })
    }

    const handleSubmitMachine = () => {
        if (!name) return

        const payload = {
            name,
            permission,
            spawnObject,
            x: parseFloat(x) || 0,
            y: parseFloat(y) || 0,
            z: parseFloat(z) || 0,
            h: parseFloat(h) || 0,
        }

        if (editingId) {
            fetchNui('core-laundry', { action: 'editMachine', id: editingId, ...payload })
        } else {
            fetchNui('core-laundry', { action: 'createMachine', ...payload })
        }

        if (isEnvBrowser()) onRefresh()
        resetForm()
    }

    const handleEdit = (m: MachinePoint) => {
        setEditingId(m.id)
        setName(m.name)
        setPermission(m.permission)
        setSpawnObject(m.spawnObject !== false)
        setX(String(m.x))
        setY(String(m.y))
        setZ(String(m.z))
        setH(String(m.h))
    }

    const handleSave = () => {
        fetchNui('core-laundry', { action: 'saveSettings', settings: draft })
    }

    const filtered = machines.filter((m) => m.name.toLowerCase().includes(filter.toLowerCase()))

    const setEff = (patch: Partial<AdminSettings['upgrades']['efficiency']>) =>
        setDraft((d) => ({ ...d, upgrades: { ...d.upgrades, efficiency: { ...d.upgrades.efficiency, ...patch } } }))
    const setPot = (patch: Partial<AdminSettings['upgrades']['potency']>) =>
        setDraft((d) => ({ ...d, upgrades: { ...d.upgrades, potency: { ...d.upgrades.potency, ...patch } } }))

    return (
        <div
            className="adm-shell flex w-[64rem] h-[41rem] max-w-[94vw] max-h-[92vh] rounded-[0.625rem] overflow-hidden font-mulish animate-fadeInScale [&_*]:font-mulish"
            style={{ background: 'rgba(17, 17, 20, 0.9608)', outline: '0.5625rem solid #14141769' }}
        >
            <aside className="flex flex-col items-center justify-between w-[6.125rem] shrink-0 pt-[1.25rem] pb-[1rem]" style={{ borderRight: '1px solid #D9D9D91A' }}>
                <div className="flex items-center justify-center h-[3.125rem]">
                    {logoUrl && !logoError ? (
                        <img className="w-[3.125rem] h-[3.125rem] object-contain" src={logoUrl} alt="" onError={() => setLogoError(true)} />
                    ) : (
                        <span className="font-black text-[1.5rem] text-accent">$</span>
                    )}
                </div>

                <nav className="flex flex-col gap-[0.25rem]">
                    <NavHex active={page === 'maquinas'} label="Máquinas" onClick={() => setPage('maquinas')}>{MachineIcon}</NavHex>
                    <NavHex active={page === 'geral'} label="Geral" onClick={() => setPage('geral')}>{GeneralIcon}</NavHex>
                    <NavHex active={page === 'lavagem'} label="Lavagem" onClick={() => setPage('lavagem')}>{WashIcon}</NavHex>
                    <NavHex active={page === 'upgrades'} label="Upgrades" onClick={() => setPage('upgrades')}>{UpgradeIcon}</NavHex>
                </nav>

                <NavHex active={false} label="Fechar" onClick={onClose}>{CloseIconSvg}</NavHex>
            </aside>

            <div className="flex-1 min-w-0 flex flex-col">
                <header className="flex items-center h-[4.125rem] shrink-0 gap-[0.75rem] pl-[1.25rem] pr-[1.5625rem]" style={{ borderBottom: '1px solid #D9D9D91A' }}>
                    <h1 className="font-black text-[1.0625rem] uppercase text-white">{PageMeta[page].title}</h1>
                    <span className="font-bold text-[0.6875rem] uppercase" style={{ color: 'rgba(237, 234, 229, 0.3)' }}>Painel Administrativo</span>

                    {page === 'maquinas' ? (
                        <div
                            className="ml-auto flex items-center h-[1.5625rem] w-[16.25rem] gap-[0.375rem] px-[0.4375rem] rounded-[0.25rem]"
                            style={{ border: '1px solid rgba(255, 255, 255, 0.08)', background: 'rgba(221, 221, 221, 0.05)', color: 'rgba(237, 234, 229, 0.5)' }}
                        >
                            <svg width="0.8rem" height="0.8rem" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round">
                                <circle cx="11" cy="11" r="7" />
                                <line x1="21" y1="21" x2="16.65" y2="16.65" />
                            </svg>
                            <input
                                className="flex-1 bg-transparent border-none outline-none font-extrabold text-[0.625rem] uppercase text-white placeholder:text-[#EDEAE54D]"
                                placeholder="Buscar"
                                value={filter}
                                onChange={(e) => setFilter(e.target.value)}
                            />
                        </div>
                    ) : (
                        <button
                            type="button"
                            className="ml-auto flex items-center justify-center h-[1.75rem] px-[1.25rem] rounded-[0.3125rem] text-white font-black text-[0.6875rem] uppercase cursor-pointer transition-[filter] duration-300 hover:brightness-75 active:brightness-50"
                            style={{ border: '1px solid rgba(255, 255, 255, 0.15)', background: 'var(--bn-accent-grad)' }}
                            onClick={handleSave}
                        >
                            Salvar Alterações
                        </button>
                    )}
                </header>

                <main className={cn('flex-1 min-h-0 py-[1.75rem] px-[2rem] overflow-y-auto flex flex-col', SCROLL)}>
                    {page === 'maquinas' && (
                        <div className="flex-[1_1_auto] min-h-min w-full grid grid-cols-2 gap-[1.25rem] items-stretch">
                            <Card className="min-h-[24rem]">
                                <CardTitle>Pontos Ativos ({filtered.length})</CardTitle>
                                <div className={cn('flex-1 min-h-0 flex flex-col gap-[0.5rem] overflow-y-auto pr-[0.25rem]', SCROLL)}>
                                    {filtered.length === 0 && <div className="p-[1rem] text-center font-semibold text-[0.6875rem] text-[#adadad]">Nenhuma máquina cadastrada</div>}
                                    {filtered.map((m) => (
                                        <div
                                            key={m.id}
                                            className="flex items-center justify-between gap-[0.5rem] py-[0.625rem] px-[0.75rem] rounded-[0.3125rem] shrink-0"
                                            style={{ background: 'rgba(221, 221, 221, 0.05)', border: `1px solid ${editingId === m.id ? 'var(--accent-color)' : 'rgba(255, 255, 255, 0.03)'}` }}
                                        >
                                            <div className="flex flex-col gap-[0.125rem] min-w-0">
                                                <span className="font-extrabold text-[0.8125rem] uppercase text-white">{m.name}</span>
                                                <span className="font-semibold text-[0.625rem] text-[#adadad]">
                                                    {m.permission ? `Permissão: ${m.permission}` : 'Pública'}
                                                </span>
                                                <span className="font-semibold text-[0.625rem] text-[#adadad]">X {m.x} · Y {m.y} · Z {m.z} · H {m.h}</span>
                                            </div>
                                            <div className="flex gap-[0.375rem] shrink-0">
                                                <IconBtn title="Teleportar" onClick={() => fetchNui('core-laundry', { action: 'teleportToMachine', id: m.id })}>
                                                    {TeleportGlyph}
                                                </IconBtn>
                                                <IconBtn title="Editar" onClick={() => handleEdit(m)}>
                                                    {EditGlyph}
                                                </IconBtn>
                                                <IconBtn red title="Excluir" onClick={() => { fetchNui('core-laundry', { action: 'deleteMachine', id: m.id }); if (isEnvBrowser()) onRefresh() }}>
                                                    {TrashGlyph}
                                                </IconBtn>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </Card>

                            <Card>
                                <CardTitle>{editingId ? 'Editar Máquina' : 'Criar Máquina'}</CardTitle>

                                <Field label="Nome">
                                    <Input placeholder="Nome da máquina" value={name} onChange={(e) => setName(e.target.value)} />
                                </Field>
                                <Field label="Permissão (vazio = pública)">
                                    <Input placeholder="Ex.: Bennys" value={permission} onChange={(e) => setPermission(e.target.value)} />
                                </Field>

                                <div className="flex items-center justify-between gap-[0.5rem] min-h-[2.375rem] pl-[0.75rem] pr-[0.25rem] rounded-[0.3125rem] border border-[rgba(255,255,255,0.05)] bg-[rgba(221,221,221,0.04)]">
                                    <span className={cn(FIELD_LABEL, 'text-[#EDEAE599]')}>Spawnar prop da máquina</span>
                                    <Toggle active={spawnObject} onToggle={() => setSpawnObject(!spawnObject)} />
                                </div>

                                <div className="grid grid-cols-4 gap-[0.5rem]">
                                    <Input center placeholder="X" value={x} onChange={(e) => setX(e.target.value)} />
                                    <Input center placeholder="Y" value={y} onChange={(e) => setY(e.target.value)} />
                                    <Input center placeholder="Z" value={z} onChange={(e) => setZ(e.target.value)} />
                                    <Input center placeholder="H" value={h} onChange={(e) => setH(e.target.value)} />
                                </div>

                                <button type="button" className={cn(BTN_BASE, BTN_GHOST)} onClick={handleGetLocation}>
                                    {LocationGlyph} Pegar Localização
                                </button>

                                <div className="flex gap-[0.5rem] mt-auto">
                                    {editingId && (
                                        <button type="button" className={cn(BTN_BASE, BTN_GHOST, 'flex-1')} onClick={resetForm}>
                                            Cancelar
                                        </button>
                                    )}
                                    <button
                                        type="button"
                                        className={cn(BTN_BASE, 'flex-1 border border-[rgba(255,255,255,0.15)] text-white hover:brightness-75')}
                                        style={{ background: 'var(--bn-accent-grad)' }}
                                        onClick={handleSubmitMachine}
                                    >
                                        {editingId ? 'Salvar Edição' : 'Criar Máquina'}
                                    </button>
                                </div>
                            </Card>
                        </div>
                    )}

                    {page === 'geral' && (
                        <div className="flex-[1_1_auto] min-h-min w-full max-w-[32rem] mx-auto grid grid-cols-1 gap-[1.25rem] items-stretch">
                            <Card>
                                <CardTitle>Itens</CardTitle>
                                <Field label="Item de dinheiro sujo">
                                    <Input value={draft.items.dirty} onChange={(e) => setDraft({ ...draft, items: { ...draft.items, dirty: e.target.value } })} />
                                </Field>
                                <Field label="Item de dinheiro limpo">
                                    <Input value={draft.items.clean} onChange={(e) => setDraft({ ...draft, items: { ...draft.items, clean: e.target.value } })} />
                                </Field>
                                <Field label="Item de limpador (alvejante)">
                                    <Input value={draft.items.cleaner} onChange={(e) => setDraft({ ...draft, items: { ...draft.items, cleaner: e.target.value } })} />
                                </Field>
                                <span className={HINT}>Use exatamente o nome dos itens como estão cadastrados no inventário.</span>
                            </Card>
                        </div>
                    )}

                    {page === 'lavagem' && (
                        <div className="flex-[1_1_auto] min-h-min w-full grid grid-cols-2 gap-[1.25rem] items-stretch">
                            <Card>
                                <CardTitle>Matemática da Lavagem</CardTitle>
                                <Field label="Valor base de referência">
                                    <Input value={String(draft.mathematics.baseValue)} onChange={(e) => setDraft({ ...draft, mathematics: { ...draft.mathematics, baseValue: numeric(e.target.value) } })} />
                                </Field>
                                <Field label="Segundos de lavagem por valor base">
                                    <Input value={String(draft.mathematics.washTime)} onChange={(e) => setDraft({ ...draft, mathematics: { ...draft.mathematics, washTime: numeric(e.target.value) } })} />
                                </Field>
                                <Field label="Limpadores consumidos por valor base">
                                    <Input value={String(draft.mathematics.cleanerCost)} onChange={(e) => setDraft({ ...draft, mathematics: { ...draft.mathematics, cleanerCost: numeric(e.target.value) } })} />
                                </Field>
                                <Field label="Taxa da máquina (%)">
                                    <Input value={String(draft.mathematics.taxPercent)} onChange={(e) => setDraft({ ...draft, mathematics: { ...draft.mathematics, taxPercent: Math.min(100, numeric(e.target.value)) } })} />
                                </Field>
                                <Field label="Tempo mínimo de lavagem (s)">
                                    <Input value={String(draft.mathematics.minimumWashTime)} onChange={(e) => setDraft({ ...draft, mathematics: { ...draft.mathematics, minimumWashTime: numeric(e.target.value) } })} />
                                </Field>
                                <span className={HINT}>O tempo e o consumo de limpadores são proporcionais ao total lavado sobre o valor base.</span>
                            </Card>

                            <Card>
                                <CardTitle>Cancelamento</CardTitle>
                                <Field label="Reembolso do dinheiro sujo (%)">
                                    <Input value={String(draft.cancel.refundPercent)} onChange={(e) => setDraft({ ...draft, cancel: { ...draft.cancel, refundPercent: Math.min(100, numeric(e.target.value)) } })} />
                                </Field>
                                <div className="flex items-center justify-between gap-[0.5rem] min-h-[2.375rem] pl-[0.75rem] pr-[0.25rem] rounded-[0.3125rem] border border-[rgba(255,255,255,0.05)] bg-[rgba(221,221,221,0.04)]">
                                    <span className={cn(FIELD_LABEL, 'text-[#EDEAE599]')}>Devolver limpadores ao cancelar</span>
                                    <Toggle active={draft.cancel.refundCleaners} onToggle={() => setDraft({ ...draft, cancel: { ...draft.cancel, refundCleaners: !draft.cancel.refundCleaners } })} />
                                </div>
                                <span className={HINT}>Define o que o jogador recupera ao cancelar uma lavagem em andamento.</span>
                            </Card>
                        </div>
                    )}

                    {page === 'upgrades' && (
                        <div className="flex-[1_1_auto] min-h-min w-full grid grid-cols-2 gap-[1.25rem] items-stretch">
                            <Card>
                                <div className="flex items-center justify-between pb-[0.85rem] border-b border-[rgba(255,255,255,0.06)]">
                                    <CardTitle bare>Eficiência</CardTitle>
                                    <Toggle active={draft.upgrades.efficiency.enabled} onToggle={() => setEff({ enabled: !draft.upgrades.efficiency.enabled })} />
                                </div>

                                <Field label="Limite padrão (sem upgrade)">
                                    <Input value={String(draft.upgrades.efficiency.defaultLimit)} onChange={(e) => setEff({ defaultLimit: numeric(e.target.value) })} />
                                </Field>

                                <div className="flex flex-col gap-[0.4rem]">
                                    <div className="grid grid-cols-[1.75rem_minmax(0,1fr)_minmax(0,1fr)_1.75rem] gap-[0.4rem] px-[0.125rem] pb-[0.15rem] [&>span]:font-extrabold [&>span]:text-[0.5625rem] [&>span]:tracking-[0.03em] [&>span]:uppercase [&>span]:text-center [&>span]:text-[#EDEAE54D] [&>span:first-child]:text-left">
                                        <span>Nível</span>
                                        <span>Limite</span>
                                        <span>Preço</span>
                                        <span />
                                    </div>

                                    {draft.upgrades.efficiency.levels.map((lv, i) => (
                                        <div key={i} className="grid grid-cols-[1.75rem_minmax(0,1fr)_minmax(0,1fr)_1.75rem] gap-[0.4rem] items-center">
                                            <span className="font-black text-[0.75rem] text-center text-accent">{i + 1}</span>
                                            <Input center className="h-[2rem]" value={String(lv.limit)} onChange={(e) => { const levels = [...draft.upgrades.efficiency.levels]; levels[i] = { ...levels[i], limit: numeric(e.target.value) }; setEff({ levels }) }} />
                                            <Input center className="h-[2rem]" value={String(lv.price)} onChange={(e) => { const levels = [...draft.upgrades.efficiency.levels]; levels[i] = { ...levels[i], price: numeric(e.target.value) }; setEff({ levels }) }} />
                                            <IconBtn red className="h-[2rem]" onClick={() => setEff({ levels: draft.upgrades.efficiency.levels.filter((_, idx) => idx !== i) })} disabled={draft.upgrades.efficiency.levels.length <= 1}>
                                                {TrashGlyph}
                                            </IconBtn>
                                        </div>
                                    ))}
                                </div>

                                <button type="button" className={cn(BTN_BASE, BTN_DASHED, 'mt-auto')} onClick={() => { const last = draft.upgrades.efficiency.levels[draft.upgrades.efficiency.levels.length - 1]; if (draft.upgrades.efficiency.levels.length < 10) setEff({ levels: [...draft.upgrades.efficiency.levels, { limit: (last?.limit || 1000000) * 2, price: last?.price || 100000 }] }) }}>
                                    + Adicionar Nível
                                </button>
                            </Card>

                            <Card>
                                <div className="flex items-center justify-between pb-[0.85rem] border-b border-[rgba(255,255,255,0.06)]">
                                    <CardTitle bare>Potência</CardTitle>
                                    <Toggle active={draft.upgrades.potency.enabled} onToggle={() => setPot({ enabled: !draft.upgrades.potency.enabled })} />
                                </div>

                                <div className="flex flex-col gap-[0.4rem]">
                                    <div className="grid grid-cols-[1.75rem_minmax(0,1fr)_minmax(0,1fr)_1.75rem] gap-[0.4rem] px-[0.125rem] pb-[0.15rem] [&>span]:font-extrabold [&>span]:text-[0.5625rem] [&>span]:tracking-[0.03em] [&>span]:uppercase [&>span]:text-center [&>span]:text-[#EDEAE54D] [&>span:first-child]:text-left">
                                        <span>Nível</span>
                                        <span>Redução (%)</span>
                                        <span>Preço</span>
                                        <span />
                                    </div>

                                    {draft.upgrades.potency.levels.map((lv, i) => (
                                        <div key={i} className="grid grid-cols-[1.75rem_minmax(0,1fr)_minmax(0,1fr)_1.75rem] gap-[0.4rem] items-center">
                                            <span className="font-black text-[0.75rem] text-center text-accent">{i + 1}</span>
                                            <Input center className="h-[2rem]" value={String(lv.percent)} onChange={(e) => { const levels = [...draft.upgrades.potency.levels]; levels[i] = { ...levels[i], percent: Math.min(90, numeric(e.target.value)) }; setPot({ levels }) }} />
                                            <Input center className="h-[2rem]" value={String(lv.price)} onChange={(e) => { const levels = [...draft.upgrades.potency.levels]; levels[i] = { ...levels[i], price: numeric(e.target.value) }; setPot({ levels }) }} />
                                            <IconBtn red className="h-[2rem]" onClick={() => setPot({ levels: draft.upgrades.potency.levels.filter((_, idx) => idx !== i) })} disabled={draft.upgrades.potency.levels.length <= 1}>
                                                {TrashGlyph}
                                            </IconBtn>
                                        </div>
                                    ))}
                                </div>

                                <button type="button" className={cn(BTN_BASE, BTN_DASHED, 'mt-auto')} onClick={() => { const last = draft.upgrades.potency.levels[draft.upgrades.potency.levels.length - 1]; if (draft.upgrades.potency.levels.length < 10) setPot({ levels: [...draft.upgrades.potency.levels, { percent: Math.min(90, (last?.percent || 10) + 5), price: last?.price || 100000 }] }) }}>
                                    + Adicionar Nível
                                </button>
                            </Card>
                        </div>
                    )}
                </main>
            </div>
        </div>
    )
}

export default Admin
