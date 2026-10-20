import { useState, useCallback } from 'react'
import { useNuiEvent } from './useNuiEvent'
import { fetchNui } from '../utils/fetchNui'
import { isEnvBrowser } from '../utils/misc'

/**
 * Controls NUI visibility state.
 * Listens for 'setVisible' from Lua and handles ESC to close.
 */
export function useVisibility() {
    const [visible, setVisible] = useState(false)

    useNuiEvent<boolean>('setVisible', (data) => {
        setVisible(data)
    })

    const handleClose = useCallback(() => {
        if (isEnvBrowser()) {
            setVisible(false)
            return
        }
        fetchNui('jobs-center', { action: "close" })
        setVisible(false)
    }, [])

    return { visible, setVisible, handleClose }
}
