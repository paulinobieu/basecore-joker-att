import { create } from "zustand";

interface DismantlePanelData {
    name: string;
    primaryColor: string;
    panelData: {
        public: number;
        percent: number;
        money: number;
        wheels: number;
        doors: number;
        ehxausts: number;
        batteries: number;
    };
}

export type DismantleTab = "info" | "storage";

interface DismantleState {
    data: DismantlePanelData | null;
    tab: DismantleTab;
    setData: (data: DismantlePanelData) => void;
    setTab: (tab: DismantleTab) => void;
    updatePanelData: (partial: Partial<DismantlePanelData['panelData']>) => void;
}

export const useDismantleStore = create<DismantleState>((set) => ({
    data: {
        name: "Desmanche",
        primaryColor: "#3279c9",
        panelData: {
            public: 0,
            percent: 50,
            money: 10000,
            wheels: 10,
            doors: 20,
            ehxausts: 5,
            batteries: 3
        }
    },
    tab: "info",
    setData: (data) => set({ data }),
    setTab: (tab) => set({ tab }),
    updatePanelData: (partial) => set((state) => ({
        data: state.data ? { ...state.data, panelData: { ...state.data.panelData, ...partial } } : null
    }))
}));
