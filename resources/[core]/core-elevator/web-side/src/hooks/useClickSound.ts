import { useEffect } from 'react'
import { useSound } from './useSound'
import clickSrc from '../assets/sounds/click.mp3'

export function useClickSound() {
    const { play } = useSound(clickSrc, { volume: 0.075 })

    useEffect(() => {
        const listener = (event: MouseEvent) => {
            const target = event.target as HTMLElement
            if (!target.closest('.floor-item')) return
            play()
        }

        window.addEventListener('mousedown', listener)
        return () => window.removeEventListener('mousedown', listener)
    }, [play])
}
