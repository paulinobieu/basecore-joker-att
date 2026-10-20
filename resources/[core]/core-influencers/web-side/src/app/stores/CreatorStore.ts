import { create } from "zustand";

export interface EmoteItem {
	label: string;
	command: string;
	music?: boolean;
	sync?: boolean;
}

export interface GroupMember {
	sid: number;
	name: string;
	isOwner: boolean;
}

export interface GroupState {
	owner: number | null;
	members: GroupMember[];
	enabled: boolean;
	isOwner: boolean;
}

export interface CameraState {
	open: boolean;
	aspect: string;
	mode: string;
	zoom: string;
	light: boolean;
	dof: boolean;
	grid: boolean;
	faceTrack: boolean;
	cleanCapture: boolean;
	keys: Record<string, boolean>;
}

export interface CreatorData {
	groups: Record<string, EmoteItem[]>;
	order: string[];
	group: GroupState;
	muted: boolean;
}

export const FAVORITES_CAT = "Favoritos";
export const FAVORITES_KEY = "core_influencers_favorites";

const EMPTY_GROUP: GroupState = {
	owner: null,
	members: [],
	enabled: false,
	isOwner: false,
};

const DEFAULT_CAMERA: CameraState = {
	open: false,
	aspect: "16:9",
	mode: "selfie",
	zoom: "1.0x",
	light: false,
	dof: false,
	grid: true,
	faceTrack: false,
	cleanCapture: false,
	keys: {},
};

interface CreatorStore {
	groups: Record<string, EmoteItem[]>;
	order: string[];
	activeCat: string | null;
	search: string;
	muted: boolean;
	favorites: string[];
	group: GroupState;
	camera: CameraState;
}

interface CreatorActions {
	setData: (data: Partial<CreatorData>) => void;
	setActiveCat: (cat: string) => void;
	setSearch: (value: string) => void;
	setMuted: (value: boolean) => void;
	setGroup: (group: GroupState) => void;
	setGroupEnabled: (enabled: boolean) => void;
	setCamera: (camera: Partial<CameraState>) => void;
	loadFavorites: () => void;
	toggleFavorite: (command: string) => void;
}

function readFavorites(): string[] {
	try {
		const raw = localStorage.getItem(FAVORITES_KEY);
		const arr = raw ? JSON.parse(raw) : [];
		return Array.isArray(arr) ? arr.map(String) : [];
	} catch {
		return [];
	}
}

function persistFavorites(favorites: string[]) {
	try {
		localStorage.setItem(FAVORITES_KEY, JSON.stringify(favorites));
	} catch {}
}

export const useCreatorStore = create<CreatorStore & CreatorActions>()(
	(set, get) => ({
		groups: {},
		order: [],
		activeCat: null,
		search: "",
		muted: false,
		favorites: readFavorites(),
		group: EMPTY_GROUP,
		camera: DEFAULT_CAMERA,

		setData: (data) =>
			set((state) => ({
				groups: data.groups ?? state.groups,
				order: data.order ?? state.order,
				group: data.group ?? state.group,
				muted: data.muted ?? state.muted,
				search: "",
			})),

		setActiveCat: (cat) => set({ activeCat: cat }),
		setSearch: (value) => set({ search: value }),
		setMuted: (value) => set({ muted: value }),
		setGroup: (group) => set({ group: group ?? EMPTY_GROUP }),
		setGroupEnabled: (enabled) =>
			set((state) => ({ group: { ...state.group, enabled } })),

		setCamera: (camera) =>
			set((state) => ({ camera: { ...state.camera, ...camera } })),

		loadFavorites: () => set({ favorites: readFavorites() }),

		toggleFavorite: (command) => {
			const cmd = String(command || "");
			if (!cmd) return;

			const current = get().favorites;
			const next = current.includes(cmd)
				? current.filter((c) => c !== cmd)
				: [...current, cmd];

			persistFavorites(next);
			set({ favorites: next });
		},
	}),
);
