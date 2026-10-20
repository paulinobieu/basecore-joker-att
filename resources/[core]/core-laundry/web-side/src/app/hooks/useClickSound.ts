import { useEffect } from 'react'
import { useSound } from './useSound'
import clickSound from '@views/assets/sounds/click.mp3'

export function useClickSound() {
    const { play } = useSound(clickSound, { volume: 0.075 })

    useEffect(() => {
        const listener = (event: MouseEvent) => {
            const target = event.target as HTMLElement
            if (target.nodeName !== 'BUTTON' || target.classList.contains('cursor-not-allowed')) return
            play()
        }
        window.addEventListener('mousedown', listener)
        return () => {
            window.removeEventListener('mousedown', listener)
        }
    }, [play])
}
