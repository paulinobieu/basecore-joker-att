import { create } from 'zustand'
import { fetchNui } from '@app/utils/fetchNui'
import { isEnvBrowser } from '@app/utils/misc'

interface VisibilityStore {
    visible: boolean
    setVisible: (value: boolean) => void
    close: () => void
}

export const useVisibilityStore = create<VisibilityStore>()((set) => ({
    visible: isEnvBrowser(),
    setVisible: (value: boolean) => set({ visible: value }),
    close: () => {
        set({ visible: false })
        if (!isEnvBrowser()) {
            fetchNui('core-laundry', { action: 'close' })
        }
    },
}))
