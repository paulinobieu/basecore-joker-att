import { useState, useCallback, useEffect } from 'react'
import { useNuiEvent } from './useNuiEvent'
import { fetchNui } from '../utils/fetchNui'
import { isEnvBrowser } from '../utils/misc'

export function useVisibility() {
    const [visible, setVisible] = useState(isEnvBrowser())

    useNuiEvent<boolean>('setVisible', (data) => {
        setVisible(data)
    })

    const closeFrame = useCallback(() => {
        if (isEnvBrowser()) {
            setVisible(false)
            return
        }
        fetchNui('close')
        setVisible(false)
    }, [])

    useEffect(() => {
        const handleKeyDown = (e: KeyboardEvent) => {
            if (e.key === 'Escape' && visible) {
                closeFrame()
            }
        }
        window.addEventListener('keydown', handleKeyDown)
        return () => window.removeEventListener('keydown', handleKeyDown)
    }, [visible, closeFrame])

    return { visible, setVisible, closeFrame }
}
