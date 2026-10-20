import type { Screen } from "@app/constants/callbacks";
import { create } from "zustand";

interface ScreenStore {
	screen: Screen | null;
}

interface ScreenActions {
	setScreen: (screen: Screen | null) => void;
}

export const useScreenStore = create<ScreenStore & ScreenActions>()((set) => ({
	screen: null,

	setScreen: (screen) => set({ screen }),
}));
