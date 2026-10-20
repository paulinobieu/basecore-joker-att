import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { create } from "zustand";

export type IVelocimeter = "rounded" | "digital";
export type ISurvival = "rounded" | "lonzege";

export type ICategory = "hud" | "adjustments";

export type IKeyOption =
	| "notify"
	| "radar"
	| "chat"
	| "hide"
	| "life"
	| "shield"
	| "hungry"
	| "thirst"
	| "stamina"
	| "stress"
	| "oxygen";

interface IMenu {
	notify: boolean;
	radar: boolean;
	chat: boolean;
	hide: boolean;

	survivalSettings: {
		life: boolean;
		shield: boolean;
		hungry: boolean;
		thirst: boolean;
		stamina: boolean;
		stress: boolean;
		oxygen: boolean;
	};
	velocimeter: IVelocimeter;
	survival: ISurvival;
}

interface Store extends IMenu {
	visible: boolean;
	selectedCategory: ICategory;
}

interface Actions {
	getSavedCustomizations(): Promise<void>;

	toggleOption(
		option: keyof IMenu | keyof IMenu["survivalSettings"],
	): Promise<void>;

	setVelocimeter(velocimeter: Store["velocimeter"]): Promise<void>;
	setSurvival(survival: Store["survival"]): Promise<void>;
	setSelectedCategory(selectedCategory: Store["selectedCategory"]): void;
	setVisible(visible: Store["visible"]): void;
}

const initialState: Store = {
	visible: isEnvBrowser(),
	selectedCategory: "hud",

	velocimeter: "digital",
	survival: "lonzege",
	chat: true,
	radar: true,
	hide: false,

	survivalSettings: {
		hungry: true,
		life: true,
		shield: true,
		stamina: true,
		thirst: true,
		stress: true,
		oxygen: true,
	},

	notify: false,
};

export const useMenu = create<Store & Actions>()((set) => ({
	...initialState,

	async getSavedCustomizations() {
		const mockData: IMenu = {
			velocimeter: "digital",
			survival: "rounded",
			chat: true,
			radar: true,
			hide: false,

			survivalSettings: {
				hungry: true,
				life: true,
				shield: true,
				stamina: true,
				thirst: true,
				stress: true,
				oxygen: true,
			},

			notify: true,
		};
		const response = await fetchNui({
			path: "get:menu:savedSettings",
			mockData,
		});

		if (!response) return;

		set(response);
	},

	async toggleOption(option) {
		const response = await fetchNui({
			path: `post:menu:toggle:${option}`,
			mockData: true,
		});

		if (!response) return;

		const isASurvivalOption = [
			"hungry",
			"life",
			"shield",
			"stamina",
			"thirst",
			"oxygen",
			"stress",
		].includes(option);

		if (isASurvivalOption) {
			return set((prevState) => ({
				survivalSettings: {
					...prevState.survivalSettings,
					[option]:
						!prevState.survivalSettings[
							option as keyof IMenu["survivalSettings"]
						],
				},
			}));
		}
		set((prevState) => ({
			[option]: !prevState[option as keyof IMenu],
		}));
	},

	async setVelocimeter(velocimeter) {
		const response = await fetchNui({
			path: "post:menu:setVelocimeter",
			payload: velocimeter,
			mockData: true,
		});

		if (!response) return;

		set({ velocimeter });
	},

	async setSurvival(survival) {
		const response = await fetchNui({
			path: "post:menu:setSurvival",
			payload: survival,
			mockData: true,
		});

		if (!response) return;

		set({ survival });
	},

	setSelectedCategory(selectedCategory) {
		set({ selectedCategory });
	},
	setVisible(visible) {
		set({ visible });
	},
}));
