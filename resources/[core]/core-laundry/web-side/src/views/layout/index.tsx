import { useCallback, useEffect, useState } from 'react'
import { useVisibilityStore } from '@app/stores/visibility'
import { useNuiMessage } from '@app/hooks/useNuiMessage'
import { useClickSound } from '@app/hooks/useClickSound'
import { fetchNui } from '@app/utils/fetchNui'
import { isEnvBrowser } from '@app/utils/misc'
import { cn } from '@app/utils'
import { type WashConfig, type WashStatus, type AdminSettings, type MachinePoint } from '@app/types'
import { Washout } from '@views/pages/Washout'
import { Admin } from '@views/pages/Admin'
import { Notifys } from '@views/components/Notifys'

type WashInitial = Partial<WashConfig> & { initialStatus?: WashStatus; logoUrl?: string }

function hexToRgbTuple(hex: string): string | null {
    const m = hex.trim().replace(/^#/, '')
    const full = m.length === 3 ? m.split('').map((c) => c + c).join('') : m
    if (!/^[0-9a-fA-F]{6}$/.test(full)) return null
    const r = parseInt(full.slice(0, 2), 16)
    const g = parseInt(full.slice(2, 4), 16)
    const b = parseInt(full.slice(4, 6), 16)
    return `${r}, ${g}, ${b}`
}

export function Layout() {
    const visible = useVisibilityStore((s) => s.visible)
    const setVisible = useVisibilityStore((s) => s.setVisible)
    const close = useVisibilityStore((s) => s.close)

    const [closing, setClosing] = useState(false)
    const [washInitial, setWashInitial] = useState<WashInitial | undefined>(undefined)

    const [adminOpen, setAdminOpen] = useState(false)
    const [adminMachines, setAdminMachines] = useState<MachinePoint[]>([])
    const [adminSettings, setAdminSettings] = useState<AdminSettings | null>(null)
    const [adminLogo, setAdminLogo] = useState('')
    const [placementHiding, setPlacementHiding] = useState(false)

    useClickSound()

    useNuiMessage<boolean>('setVisible', (value) => {
        setVisible(value)
        if (!value) {
            setAdminOpen(false)
            setClosing(false)
        }
    })

    useNuiMessage<WashInitial>('openLaundry', (data) => {
        setWashInitial(data)
        setAdminOpen(false)
        setClosing(false)
        setVisible(true)

        if (data.themeColor) {
            const root = document.documentElement.style
            root.setProperty('--accent-color', data.themeColor)
            const rgb = hexToRgbTuple(data.themeColor)
            if (rgb) {
                root.setProperty('--accent-color-rgb', rgb)
                root.setProperty('--accent-color-dim', `rgba(${rgb}, 0.15)`)
                root.setProperty('--accent-color-bg', `rgba(${rgb}, 0.06)`)
            }
        }
    })

    useNuiMessage<{ machines: MachinePoint[]; settings?: AdminSettings; logoUrl?: string }>('openAdmin', (data) => {
        setAdminMachines(data.machines ?? [])
        if (data.settings) setAdminSettings(data.settings)
        if (data.logoUrl !== undefined) setAdminLogo(data.logoUrl)
        setAdminOpen(true)
        setClosing(false)
    })

    useNuiMessage<{ machines: MachinePoint[] }>('updateMachines', (data) => {
        setAdminMachines(data.machines ?? [])
    })

    useNuiMessage<AdminSettings>('setAdminSettings', (data) => {
        setAdminSettings(data)
    })

    useNuiMessage('hidePlacement', () => {
        setPlacementHiding(true)
    })

    useNuiMessage('showPlacement', () => {
        setPlacementHiding(false)
    })

    const closeWithAnimation = useCallback(() => {
        setClosing((prev) => {
            if (prev) return prev
            close()
            setTimeout(() => setClosing(false), 250)
            return true
        })
    }, [close])

    useEffect(() => {
        const onKeyDown = (e: KeyboardEvent) => {
            if (e.key !== 'Escape') return
            if (adminOpen) {
                setAdminOpen(false)
                close()
                return
            }
            closeWithAnimation()
        }
        window.addEventListener('keydown', onKeyDown)
        return () => window.removeEventListener('keydown', onKeyDown)
    }, [adminOpen, close, closeWithAnimation])

    const handleCloseAdmin = () => {
        setAdminOpen(false)
        fetchNui('core-laundry', { action: 'close' })
        setVisible(false)
    }

    const browser = isEnvBrowser()
    const wrapperCls = cn(
        'nui-wrapper fixed inset-0 flex items-center justify-center',
        placementHiding && 'invisible pointer-events-none',
    )
    const browserBg = browser
        ? {
              background:
                  "url('https://files.fivemerr.com/images/ab427266-34e9-4649-8024-077a230837c6.png') center/cover no-repeat",
          }
        : undefined

    let content: React.ReactNode = null
    if (adminOpen) {
        content = (
            <div className={cn(wrapperCls, browser && 'browser-mode')} style={browserBg}>
                <Admin
                    machines={adminMachines}
                    settings={adminSettings}
                    logoUrl={adminLogo}
                    onClose={handleCloseAdmin}
                    onRefresh={() => fetchNui('core-laundry', { action: 'refreshMachines' })}
                />
            </div>
        )
    } else if (visible || closing) {
        content = (
            <div className={cn(wrapperCls, 'nui-wrapper--game', browser && 'browser-mode')} style={browserBg}>
                <Washout closing={closing} initial={washInitial} onRequestClose={closeWithAnimation} />
            </div>
        )
    }

    return (
        <>
            {content}
            <Notifys />
        </>
    )
}

export default Layout
