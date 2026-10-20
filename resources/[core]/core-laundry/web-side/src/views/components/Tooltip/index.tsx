import { useState, useRef, useEffect } from 'react'
import { createPortal } from 'react-dom'

interface TooltipProps {
    text: string
    children: React.ReactNode
}

export function Tooltip({ text, children }: TooltipProps) {
    const [show, setShow] = useState(false)
    const [coords, setCoords] = useState({ top: 0, left: 0 })
    const wrapperRef = useRef<HTMLDivElement>(null)

    useEffect(() => {
        if (show && wrapperRef.current) {
            const rect = wrapperRef.current.getBoundingClientRect()
            setCoords({
                top: rect.top + rect.height / 2,
                left: rect.right + 10,
            })
        }
    }, [show])

    return (
        <div
            ref={wrapperRef}
            className="relative inline-flex"
            onMouseEnter={() => setShow(true)}
            onMouseLeave={() => setShow(false)}
        >
            {children}
            {show &&
                createPortal(
                    <div
                        className="fixed w-max max-w-[280px] z-[1000] px-[14px] py-[10px] pointer-events-none animate-tooltipFadeIn"
                        style={{
                            top: coords.top,
                            left: coords.left,
                            transform: 'translate(0, -50%)',
                            background: 'rgba(20, 20, 20, 0.97)',
                            border: '1px solid var(--border-panel)',
                            borderRadius: 'var(--radius-sm)',
                        }}
                    >
                        <span
                            className="text-[12px] font-medium leading-[1.5] whitespace-pre-line"
                            style={{ color: 'var(--text-secondary)' }}
                        >
                            {text}
                        </span>
                    </div>,
                    document.body,
                )}
        </div>
    )
}
