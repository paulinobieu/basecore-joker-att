import { create } from "zustand";

export type NotifyType = "success" | "error" | "warn" | "info";

export interface INotify {
	id: number;
	type: NotifyType;
	desc: string;
	time: number;
}

const DEFAULT_TIME = 5000;

interface Store {
	notifys: INotify[];
}

interface Actions {
	pushNotify(type: NotifyType, desc: string, time?: number): void;
	removeNotify(id: number): void;
}

let sequence = 0;

export const useNotify = create<Store & Actions>()((set) => ({
	notifys: [],

	pushNotify: (type, desc, time = DEFAULT_TIME) => {
		sequence += 1;

		set((state) => ({
			notifys: [...state.notifys, { id: sequence, type, desc, time }],
		}));
	},

	removeNotify: (id) =>
		set((state) => ({
			notifys: state.notifys.filter((notify) => notify.id !== id),
		})),
}));
