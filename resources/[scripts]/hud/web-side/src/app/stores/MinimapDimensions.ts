import { fetchNui } from "@app/utils/fetchNui";
import { create } from "zustand";

interface Store {
	width: number;
	height: number;
	left: number;
	top: number;
}

interface Actions {
	getDimensions(): Promise<void>;
}

export const useMinimapDimensions = create<Store & Actions>()((set) => ({
	width: 0,
	height: 0,
	left: 0,
	top: 0,

	async getDimensions() {
		const mockData: Store = {
			height: 174,
			width: 250,
			top: 700,
			left: 40,
		};
		const response = await fetchNui({ path: "fetchMapPosition", mockData });

		if (!response) return;

		set({
			width: response.width,
			height: response.height,
			left: response.left,
			top: response.top,
		});
	},
}));
