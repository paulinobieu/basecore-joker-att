import { useEffect, useRef } from 'react'

/**
 * Hook that listens for NUI messages from the FiveM Lua client.
 * @param action - The action name to listen for
 * @param handler - Callback when this action is received
 */
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
