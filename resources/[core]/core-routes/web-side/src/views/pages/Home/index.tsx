import { useCallback, useEffect, useRef, useState, type CSSProperties } from 'react'
import { useNuiMessage } from '@app/hooks/useNuiMessage'
import { fetchNui } from '@app/utils/fetchNui'
import { isEnvBrowser } from '@app/utils/misc'
import {
  LinkIcon,
  MapPinIcon,
  CheckIcon,
  ChevronIcon,
  NotificationIcon,
  PackageIcon,
} from '@views/components/Icons'
import { Hexagon } from '@views/components/Hexagon'
import type { RouteItem } from '@views/types/routes'

const GRID_COLS = 5
const GRID_ROWS = 3

const NOTIFICATION_POSITIONS: Record<string, CSSProperties> = {
  'bottom-left':   { bottom: '2.4375rem', left: '22.9375rem' },
  'bottom-center': { bottom: '2.4375rem', left: '50%', transform: 'translateX(-50%)' },
  'bottom-right':  { bottom: '2.4375rem', right: '1.375rem' },
  'top-left':      { top: '1.375rem',     left: '1.375rem' },
  'top-center':    { top: '1.375rem',     left: '50%', transform: 'translateX(-50%)' },
  'top-right':     { top: '1.375rem',     right: '1.375rem' },
  'middle-left':   { top: '50%',          left: '1.375rem', transform: 'translateY(-50%)' },
  'middle-right':  { top: '50%',          right: '1.375rem', transform: 'translateY(-50%)' },
}

const ROUTE_STYLES = [
  { id: 'terrestre', label: 'Terrestre' },
  { id: 'aquatica', label: 'Aquática' },
  { id: 'aerea', label: 'Aérea' },
]

/**
 * O Lua manda uma cor por rota; as duas tonalidades escuras do tema saem dela,
 * na mesma proporção da identidade (#df1553 → #9e0f3c → #670a27).
 */
function applyThemeColor(hex: string) {
  const value = hex.replace('#', '').trim()
  if (value.length !== 6) return

  const r = parseInt(value.substring(0, 2), 16)
  const g = parseInt(value.substring(2, 4), 16)
  const b = parseInt(value.substring(4, 6), 16)
  if ([r, g, b].some(Number.isNaN)) return

  const shade = (factor: number) =>
    [r, g, b].map(channel => Math.round(channel * factor)).join(', ')

  const root = document.documentElement
  root.style.setProperty('--primaryColor', `${r}, ${g}, ${b}`)
  root.style.setProperty('--secondaryColor', shade(0.71))
  root.style.setProperty('--thirdyColor', shade(0.46))
}

interface ItemSlot {
  item: RouteItem | null
  selected: boolean
}

export function Home() {
  const [visible, setVisible] = useState<boolean>(false)
  const [isPanelRendered, setIsPanelRendered] = useState<boolean>(false)
  const [isClosing, setIsClosing] = useState<boolean>(false)
  const closeTimeoutRef = useRef<number | null>(null)

  const [title, setTitle] = useState<string>('IMPORTAÇÃO')
  const [description, setDescription] = useState<string>('Selecione os insumos desejados e continue na ação abaixo.')

  const [slots, setSlots] = useState<ItemSlot[]>(() =>
    Array.from({ length: GRID_COLS * GRID_ROWS }, () => ({ item: null, selected: false }))
  )

  const [selectedStyleId, setSelectedStyleId] = useState<string>('terrestre')
  const [isDropdownOpen, setIsDropdownOpen] = useState(false)
  const [allowedStyleIds, setAllowedStyleIds] = useState<string[]>(['terrestre', 'aquatica', 'aerea'])
  const [notificationPosition, setNotificationPosition] = useState<string>('bottom-left')

  const [baseRouteCost, setBaseRouteCost] = useState<number>(0)

  const totalCost = baseRouteCost + slots.reduce((acc, slot) => {
    return acc + (slot.selected && slot.item?.price ? Number(slot.item.price) : 0)
  }, 0)

  const [view, setView] = useState<'home' | 'confirm'>('home')

  const [confirmCost, setConfirmCost] = useState<number>(0)

  const [notification, setNotification] = useState<{
    userName: string
    time: string
    collected: number
    total: number
  } | null>(null)

  const selectedCount = slots.filter(s => s.selected).length

  const dropdownRef = useRef<HTMLDivElement | null>(null)
  const scrollContainerRef = useRef<HTMLDivElement | null>(null)
  const scrollTrackRef = useRef<HTMLDivElement | null>(null)
  const [scrollThumbHeight, setScrollThumbHeight] = useState(0)
  const [scrollThumbOffset, setScrollThumbOffset] = useState(0)

  /*
    A trilha é medida no DOM em vez de ter altura fixa: como o layout é em rem
    sobre a largura da tela, ela muda de tamanho a cada resolução.
  */
  const updateScrollbar = useCallback(() => {
    const el = scrollContainerRef.current
    const track = scrollTrackRef.current
    if (!el || !track) return

    const trackHeight = track.clientHeight
    const { scrollTop, scrollHeight, clientHeight } = el
    const canScroll = scrollHeight > clientHeight + 1

    if (!canScroll) {
      setScrollThumbHeight(trackHeight)
      setScrollThumbOffset(0)
      return
    }

    const thumbH = Math.max(trackHeight * 0.12, (clientHeight / scrollHeight) * trackHeight)
    const maxOffset = trackHeight - thumbH
    const maxScroll = scrollHeight - clientHeight
    const offset = (scrollTop / maxScroll) * maxOffset

    setScrollThumbHeight(thumbH)
    setScrollThumbOffset(offset)
  }, [])

  const handleSlotClick = useCallback((index: number) => {
    setSlots(prev => {
      const next = [...prev]
      const slot = next[index]

      if (slot.item) {
        next[index] = { ...slot, selected: !slot.selected }
      }

      return next
    })
  }, [])

  const handleStartRoute = useCallback(() => {
    setConfirmCost(totalCost)
    setView('confirm')
  }, [totalCost])

  const submitConfirm = useCallback(() => {
    void fetchNui({
      path: 'routes:start',
      payload: {
        items: slots.filter(s => s.selected && s.item).map(s => s.item!),
        style: selectedStyleId,
      },
    })

    setVisible(false)

    if (isEnvBrowser()) {
      setTimeout(() => {
        setNotification({
          userName: 'Bieuzadas Dev',
          time: '12:30',
          collected: 0,
          total: 32,
        })
      }, 500)
    }

    setView('home')
  }, [selectedStyleId, slots])

  const handleCancelConfirm = useCallback(() => {
    setView('home')
    setConfirmCost(0)
  }, [])

  const closeInterface = useCallback(() => {
    setVisible(false)
    void fetchNui({ path: 'routes:close' })
  }, [])

  useNuiMessage<{ visible: boolean }>('routes:ui:visible', ({ visible: v }) => setVisible(v))

  useNuiMessage<{
    title?: string
    description?: string
    items?: RouteItem[]
    routeCost?: number
    themeColor?: string
    allowedStyles?: string[]
  }>('routes:ui:open', (data) => {
    if (data.title) setTitle(data.title)
    if (data.description) setDescription(data.description)
    if (data.routeCost !== undefined) setBaseRouteCost(data.routeCost)
    if (data.themeColor) applyThemeColor(data.themeColor)

    const newAllowed = (data.allowedStyles && data.allowedStyles.length > 0)
      ? data.allowedStyles
      : ['terrestre', 'aquatica', 'aerea']
    setAllowedStyleIds(newAllowed)
    setSelectedStyleId(newAllowed[0])

    setView('home')
    setConfirmCost(0)
    setNotification(null)

    if (data.items) {
      const totalSlots = Math.max(GRID_COLS * GRID_ROWS, Math.ceil(data.items.length / GRID_COLS) * GRID_COLS)
      const newSlots: ItemSlot[] = Array.from({ length: totalSlots }, (_, i) => ({
        item: data.items![i] || null,
        selected: false,
      }))
      setSlots(newSlots)
    }

    setVisible(true)
  })

  useEffect(() => {
    if (closeTimeoutRef.current !== null) {
      window.clearTimeout(closeTimeoutRef.current)
      closeTimeoutRef.current = null
    }

    if (visible) {
      setIsPanelRendered(true)
      setIsClosing(false)
      return
    }

    if (!isPanelRendered) return

    setIsClosing(true)
    closeTimeoutRef.current = window.setTimeout(() => {
      setIsPanelRendered(false)
      setIsClosing(false)
      closeTimeoutRef.current = null
    }, 300)
  }, [visible, isPanelRendered])

  useEffect(() => {
    if (isPanelRendered && !isClosing) {
      requestAnimationFrame(updateScrollbar)
    }
  }, [isPanelRendered, isClosing, slots, updateScrollbar])

  useEffect(() => {
    return () => {
      if (closeTimeoutRef.current !== null) {
        window.clearTimeout(closeTimeoutRef.current)
      }
    }
  }, [])

  useEffect(() => {
    if (!isDropdownOpen) return

    const listener = (event: MouseEvent) => {
      if (dropdownRef.current?.contains(event.target as Node)) return
      setIsDropdownOpen(false)
    }

    window.addEventListener('mousedown', listener)
    return () => window.removeEventListener('mousedown', listener)
  }, [isDropdownOpen])

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && visible) {
        if (view === 'confirm') {
          handleCancelConfirm()
        } else {
          closeInterface()
        }
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [visible, closeInterface, handleCancelConfirm, view])

  useEffect(() => {
    if (!isEnvBrowser()) return

    setVisible(true)

    const mockItems: RouteItem[] = [
      { id: 'item-1', name: 'Chave Mestra', image: '', price: 50 },
      ...Array.from({ length: 25 }, (_, i) => ({
        id: `item-${i + 2}`,
        name: `Insumo ${i + 2}`,
        image: '',
        price: 20,
      })),
    ]

    const totalSlots = Math.max(GRID_COLS * GRID_ROWS, Math.ceil(mockItems.length / GRID_COLS) * GRID_COLS)
    const newSlots: ItemSlot[] = Array.from({ length: totalSlots }, (_, i) => ({
      item: mockItems[i] || null,
      selected: false,
    }))

    setSlots(newSlots)
    setBaseRouteCost(500)
  }, [])

  useEffect(() => {
    updateScrollbar()
  }, [slots, updateScrollbar])

  useEffect(() => {
    window.addEventListener('resize', updateScrollbar)

    return () => window.removeEventListener('resize', updateScrollbar)
  }, [updateScrollbar])

  const bgStyle: CSSProperties | undefined = isEnvBrowser()
    ? { backgroundImage: "url('/background.png')", backgroundSize: 'cover', backgroundPosition: 'center' }
    : undefined

  useNuiMessage<{ userName: string; time: string; collected: number; total: number; themeColor?: string; notificationPosition?: string }>(
    'routes:notification:show',
    (data) => {
      if (data.themeColor) applyThemeColor(data.themeColor)
      if (data.notificationPosition) setNotificationPosition(data.notificationPosition)
      setNotification(data)
    },
  )

  useNuiMessage('routes:notification:hide', () => setNotification(null))

  const activeStyles = ROUTE_STYLES.filter(s => allowedStyleIds.includes(s.id))
  const selectedStyleLabel = activeStyles.find(s => s.id === selectedStyleId)?.label ?? ''

  return (
    <main className="routes-root" style={bgStyle}>
      {view === 'confirm' ? (
        <div className="routes-confirm-view">
          <div className="routes-confirm-overlay" />

          <div className="routes-confirm-content">
            <div className="routes-confirm-icon-layer">
              <Hexagon className="routes-hexagon" />
              <MapPinIcon className="routes-confirm-icon" />
            </div>

            <div className="routes-confirm-title">
              <span className="routes-confirm-title-label">Iniciar</span>
              <div className="routes-confirm-badge">
                <span>ROTAS</span>
              </div>
            </div>

            <p className="routes-confirm-desc">
              Deseja iniciar a rota para importação dos insumos selecionados por <strong>R${confirmCost}</strong>
            </p>

            <div className="routes-confirm-actions">
              <button className="routes-confirm-btn routes-confirm-btn--primary" onClick={submitConfirm}>
                CONFIRMAR
              </button>
              <button className="routes-confirm-btn routes-confirm-btn--secondary" onClick={handleCancelConfirm}>
                CANCELAR
              </button>
            </div>
          </div>
        </div>
      ) : isPanelRendered ? (
        <div className={`routes-panel ${isClosing ? 'routes-panel--closing' : 'routes-panel--opening'}`}>
          <div className="routes-gradient" />

          <section className="routes-header">
            <div className="routes-title-badge">
              <div className="routes-title-icon">
                <Hexagon className="routes-hexagon" />
                <PackageIcon className="routes-title-icon-fg" />
              </div>
              <span>{title}</span>
            </div>
            <p className="routes-description">{description}</p>
          </section>

          <section className="routes-items-section">
            <div className="routes-items-container">
              <div className="routes-scrollbar-track" ref={scrollTrackRef}>
                <div
                  className="routes-scrollbar-thumb"
                  style={{
                    height: `${scrollThumbHeight}px`,
                    transform: `translateY(${scrollThumbOffset}px)`,
                  }}
                />
              </div>

              <div
                className="routes-items-grid"
                ref={scrollContainerRef}
                onScroll={updateScrollbar}
              >
                {slots.map((slot, index) => (
                  <button
                    key={index}
                    className={`routes-slot ${slot.item ? 'routes-slot--has-item' : ''} ${slot.selected ? 'routes-slot--selected' : ''}`}
                    onClick={() => handleSlotClick(index)}
                    type="button"
                  >
                    {slot.item && slot.item.image && (
                      <img
                        src={slot.item.image}
                        alt={slot.item.name}
                        className="routes-slot-image"
                      />
                    )}
                    {slot.item && (
                      <span className="routes-slot-name">{slot.item.name}</span>
                    )}
                    {slot.selected && <div className="routes-slot-glow" />}
                  </button>
                ))}
              </div>
            </div>
          </section>

          <div className="routes-view-fade">
            <section className="routes-info-label">
              <span className="routes-info-text">Itens</span>
              <div className="routes-info-badge">
                <span>SELECIONADOS</span>
              </div>
            </section>

            <div className="routes-info-row">
              <LinkIcon className="routes-info-icon routes-info-icon--link" />
              <span className="routes-info-row-label">Insumos selecionados:</span>
              <span className="routes-info-row-value">{selectedCount}</span>
            </div>

            <div className="routes-info-row">
              <MapPinIcon className="routes-info-icon routes-info-icon--pin" />
              <span className="routes-info-row-label">Custo de rota:</span>
              <span className="routes-info-row-value">R${totalCost}</span>
            </div>

            <div className="routes-style-box">
              <div className="routes-style-header">
                <span className="routes-option-label">Estilo de rota</span>
              </div>

              <div className="routes-dropdown" ref={dropdownRef}>
                <button
                  type="button"
                  className={`routes-dropdown-trigger ${isDropdownOpen ? 'routes-dropdown-trigger--open' : ''}`}
                  onClick={() => activeStyles.length > 1 && setIsDropdownOpen(open => !open)}
                >
                  <span>{selectedStyleLabel}</span>
                  {activeStyles.length > 1 && <ChevronIcon className="routes-dropdown-chevron" />}
                </button>

                {isDropdownOpen && (
                  <div className="routes-dropdown-list">
                    {activeStyles.map(style => (
                      <button
                        key={style.id}
                        type="button"
                        className={`routes-dropdown-item ${style.id === selectedStyleId ? 'routes-dropdown-item--active' : ''}`}
                        onClick={() => {
                          setSelectedStyleId(style.id)
                          setIsDropdownOpen(false)
                        }}
                      >
                        {style.label}
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>

            <div className="routes-spacer" />

            <button
              className="routes-start-btn"
              onClick={handleStartRoute}
              type="button"
            >
              <span>Iniciar rota</span>
              <CheckIcon className="routes-start-icon" />
            </button>
          </div>
        </div>
      ) : null}

      {notification && (
        <aside className="routes-notification-hud" style={NOTIFICATION_POSITIONS[notificationPosition] ?? NOTIFICATION_POSITIONS['bottom-left']}>
          <div className="routes-noti-content">
            <div className="routes-noti-title-row">
              <NotificationIcon className="routes-noti-icon" />
              <span className="routes-noti-label">Rota em</span>
              <div className="routes-noti-badge">
                <span>ANDAMENTO {notification.collected} / {notification.total}</span>
              </div>
            </div>
            <div className="routes-noti-hint-row">
              <div className="routes-noti-key">
                <span>F7</span>
              </div>
              <span className="routes-noti-hint-text">Para finalizar a rota, clique na tecla</span>
            </div>
          </div>
        </aside>
      )}
    </main>
  )
}
