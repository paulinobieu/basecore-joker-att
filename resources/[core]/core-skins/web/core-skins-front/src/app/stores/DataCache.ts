import { create } from "zustand";

const MAX_CACHE_SIZE = 50;

interface CacheEntry<T = unknown> {
	data: T;
	timestamp: number;
}

interface DataCacheState {
	cache: Record<string, CacheEntry>;
	set: (key: string, data: unknown) => void;
	get: (key: string, maxAge: number) => unknown | null;
	invalidate: (key: string) => void;
}

export const useDataCache = create<DataCacheState>()((set, get) => ({
	cache: {},
	set: (key, data) => {
		set((state) => {
			const entries = Object.entries(state.cache);
			let newCache = { ...state.cache, [key]: { data, timestamp: Date.now() } };
			if (entries.length >= MAX_CACHE_SIZE && !(key in state.cache)) {
				const oldest = entries.sort((a, b) => a[1].timestamp - b[1].timestamp)[0][0];
				const { [oldest]: _, ...rest } = newCache;
				newCache = rest;
			}
			return { cache: newCache };
		});
	},
	get: (key, maxAge) => {
		const entry = get().cache[key];
		if (!entry || Date.now() - entry.timestamp > maxAge) return null;
		return entry.data;
	},
	invalidate: (key) => {
		set((state) => {
			const { [key]: _, ...rest } = state.cache;
			return { cache: rest };
		});
	},
}));
