import { useEffect, useRef } from 'react'

export function useNuiEvent<T = unknown>(
    action: string,
    handler: (data: T) => void
) {
    const savedHandler = useRef<(data: T) => void>(handler)

    useEffect(() => {
        savedHandler.current = handler
    }, [handler])

    useEffect(() => {
        const eventListener = (event: MessageEvent) => {
            const { action: eventAction, data } = event.data
            if (eventAction === action) {
                savedHandler.current(data as T)
            }
        }

        window.addEventListener('message', eventListener)
        return () => window.removeEventListener('message', eventListener)
    }, [action])
}
