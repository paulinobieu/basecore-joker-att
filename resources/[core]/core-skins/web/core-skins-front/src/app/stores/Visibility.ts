import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { create } from "zustand";

interface VisibilityState {
	visible: boolean;
	admin: boolean;
	canCloseUi: boolean;
	previewMode: boolean;
	setVisible: (visible: boolean) => void;
	setAdmin: (admin: boolean) => void;
	setCanCloseUi: (canClose: boolean) => void;
	setPreviewMode: (preview: boolean) => void;
	fetchHideFrame: () => Promise<void>;
}

export const useVisibility = create<VisibilityState>()((set, get) => ({
	visible: isEnvBrowser(),
	admin: false,
	canCloseUi: true,
	previewMode: false,
	setVisible: (visible: boolean) => set({ visible }),
	setAdmin: (admin: boolean) => set({ admin }),
	setCanCloseUi: (canCloseUi: boolean) => set({ canCloseUi }),
	setPreviewMode: (previewMode: boolean) => set({ previewMode }),
	fetchHideFrame: async () => {
		const { visible, canCloseUi } = get();
		if (!visible || !canCloseUi) return;
		const result = await fetchNui({ path: "post:closeUi", mockData: true });
		if (result) set({ visible: false });
	},
}));
