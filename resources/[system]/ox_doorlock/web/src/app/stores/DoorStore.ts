import { create } from "zustand";

export type StringField = string | null | undefined;
export type NumberField = number | null | undefined;

export interface DoorFormState {
	id?: number;
	name: StringField;
	passcode: StringField;
	autolock: NumberField;
	items: { name: StringField; metadata?: StringField; remove: boolean | null }[];
	characters: StringField[];
	groups: { name: StringField; grade: NumberField }[];
	maxDistance: NumberField;
	doorRate: NumberField;
	lockSound: StringField;
	unlockSound: StringField;
	lockpickDifficulty: Array<
		string | { areaSize: number; speedMultiplier: number }
	>;
	auto: boolean | null;
	state: boolean | null;
	lockpick: boolean | null;
	hideUi: boolean | null;
	doors: boolean | null;
	holdOpen: boolean | null;
}

export interface DoorColumn extends Omit<DoorFormState, "groups"> {
	id: number;
	name: string;
	zone: string;
	groups: { [k: string]: number };
}

interface DoorFormActions {
	sounds: string[];
	setSounds: (value: string[]) => void;
	setField: <K extends keyof DoorFormState>(
		key: K,
		value: DoorFormState[K],
	) => void;
	toggleCheckbox: (
		type: "state" | "doors" | "auto" | "lockpick" | "hideUi" | "holdOpen",
	) => void;
	setItems: (
		fn: (state: DoorFormState["items"]) => DoorFormState["items"],
	) => void;
	setCharacters: (
		fn: (
			state: DoorFormState["characters"],
		) => DoorFormState["characters"],
	) => void;
	setGroups: (
		fn: (state: DoorFormState["groups"]) => DoorFormState["groups"],
	) => void;
	setLockpickDifficulty: (
		fn: (
			state: DoorFormState["lockpickDifficulty"],
		) => DoorFormState["lockpickDifficulty"],
	) => void;
	resetForm: () => void;
	loadDoor: (data: DoorFormState) => void;
}

const defaultFormState: DoorFormState = {
	name: "",
	passcode: "",
	autolock: 0,
	items: [{ name: "", metadata: "", remove: false }],
	characters: [""],
	groups: [{ name: "", grade: undefined }],
	lockpickDifficulty: [""],
	maxDistance: 0,
	doorRate: 0,
	lockSound: "",
	unlockSound: "",
	auto: false,
	state: false,
	lockpick: false,
	hideUi: false,
	doors: false,
	holdOpen: false,
};

export const useDoorFormStore = create<DoorFormState & DoorFormActions>(
	(set, get) => ({
		...defaultFormState,
		sounds: [],
		setSounds: (value) => set({ sounds: value }),
		setField: (key, value) => set({ [key]: value }),
		toggleCheckbox: (type) =>
			set((state) => ({ [type]: !state[type] })),
		setItems: (fn) =>
			set((state) => ({ items: fn(state.items) })),
		setCharacters: (fn) =>
			set((state) => ({ characters: fn(state.characters) })),
		setGroups: (fn) =>
			set((state) => ({ groups: fn(state.groups) })),
		setLockpickDifficulty: (fn) =>
			set((state) => ({
				lockpickDifficulty: fn(state.lockpickDifficulty),
			})),
		resetForm: () => set({ ...defaultFormState, id: undefined }),
		loadDoor: (data) => set({ ...data }),
	}),
);

export const getDefaultFormState = () => ({ ...defaultFormState });

// Doors list store
interface DoorsListState {
	doors: DoorColumn[];
	setDoors: (doors: DoorColumn[]) => void;
}

export const useDoorsStore = create<DoorsListState>((set) => ({
	doors: [],
	setDoors: (doors) => set({ doors }),
}));

// Search store
interface SearchState {
	value: string;
	debouncedValue: string;
	setValue: (value: string) => void;
	setDebouncedValue: (value: string) => void;
}

export const useSearchStore = create<SearchState>((set) => ({
	value: "",
	debouncedValue: "",
	setValue: (value) => set({ value }),
	setDebouncedValue: (value) => set({ debouncedValue: value }),
}));

// Clipboard store
interface ClipboardState {
	clipboard: DoorFormState | null;
	setClipboard: (value: DoorFormState) => void;
}

export const useClipboardStore = create<ClipboardState>((set) => ({
	clipboard: null,
	setClipboard: (value) => set({ clipboard: value }),
}));
