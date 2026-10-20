import { useState } from 'react'
import { cn } from '@app/utils'
import { Modal } from '@views/components/Modal'
import { HexSelected } from '@views/components/HexButton'

interface CleanersModalProps {
    open: boolean
    onClose: () => void
    onConfirm: (amount: number) => void
}

export function CleanersModal({ open, onClose, onConfirm }: CleanersModalProps) {
    const [inputValue, setInputValue] = useState('')

    const handleConfirm = () => {
        const amount = parseInt(inputValue.replace(/\D/g, '')) || 0
        if (amount <= 0) return
        onConfirm(amount)
        setInputValue('')
        onClose()
    }

    const handleClose = () => {
        setInputValue('')
        onClose()
    }

    return (
        <Modal open={open} onClose={handleClose}>
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
                            <svg width={26} height={26} viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M5 21C4.45 21 3.97933 20.8043 3.588 20.413C3.19667 20.0217 3.00067 19.5507 3 19V6.52501C3 6.29167 3.03767 6.06667 3.113 5.85001C3.18833 5.63334 3.30067 5.43334 3.45 5.25001L4.7 3.72501C4.88333 3.49167 5.11233 3.31234 5.387 3.18701C5.66167 3.06167 5.94933 2.99934 6.25 3.00001H17.75C18.05 3.00001 18.3377 3.06267 18.613 3.18801C18.8883 3.31334 19.1173 3.49234 19.3 3.72501L20.55 5.25001C20.7 5.43334 20.8127 5.63334 20.888 5.85001C20.9633 6.06667 21.0007 6.29167 21 6.52501V11.425C20.6833 11.3083 20.3583 11.2123 20.025 11.137C19.6917 11.0617 19.35 11.0247 19 11.026C18.45 11.026 17.9207 11.0887 17.412 11.214C16.9033 11.3393 16.4327 11.5347 16 11.8V8.00001H8V16L12 14L13.45 14.725C13.3167 15.075 13.2083 15.4377 13.125 15.813C13.0417 16.1883 13 16.5757 13 16.975C13 17.725 13.1333 18.446 13.4 19.138C13.6667 19.83 14.05 20.4507 14.55 21H5ZM18 21V18H15V16H18V13H20V16H23V18H20V21H18ZM5.4 6.00001H18.6L17.75 5.00001H6.25L5.4 6.00001Z" fill="currentColor" />
                            </svg>
                        </span>
                    </div>
                    <div className="flex flex-col">
                        <span className="text-xs font-medium leading-none text-white/70">Depositar</span>
                        <h1 className="text-[1.6875rem] font-extrabold uppercase leading-[1.1] text-white">Limpadores</h1>
                    </div>
                </div>
                <input
                    type="text"
                    className="h-[2.125rem] w-[13.75rem] rounded-[0.1875rem] border border-[rgba(221,221,221,0.25)] bg-blend-screen text-center text-sm font-semibold text-white outline-none transition-colors duration-500 placeholder:text-white/35 focus:border-[var(--accent-color)]"
                    style={{ background: 'var(--bn-glass)', fontFamily: "'Outfit', sans-serif" }}
                    value={inputValue}
                    onChange={(e) => setInputValue(e.target.value.replace(/\D/g, ''))}
                    placeholder="Quantidade"
                />
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
                        onClick={handleClose}
                    >
                        Cancelar
                    </button>
                </div>
            </div>
        </Modal>
    )
}
