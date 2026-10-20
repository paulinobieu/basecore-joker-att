import type { IItem } from "@app/stores/Arsenal";
import { fetchNui } from "@app/utils/fetchNui";
import { clamp } from "@app/utils/misc";
import { create } from "zustand";

export interface ILoadoutLine {
	id: string;
	amount: number;
}

/** Teto por linha: o arsenal nao tem estoque, entao o limite e da requisicao. */
export const MAX_AMOUNT_PER_LINE = 99;

interface Store {
	lines: ILoadoutLine[];
	status: "idle" | "sending";
	/** Ultima recusa do servidor, mostrada dentro do modal. */
	denied: boolean;
}

interface Actions {
	addItem(item: IItem, amount?: number): void;
	setAmount(item: IItem, amount: number): void;
	removeLine(id: string): void;
	clearLoadout(): void;

	clearDenied(): void;
	requisition(): Promise<boolean>;
}

export const useLoadout = create<Store & Actions>()((set, get) => ({
	lines: [],
	status: "idle",
	denied: false,

	addItem: (item, amount = 1) => {
		const { lines } = get();
		const current = lines.find((line) => line.id === item.id);

		if (!current) {
			set({
				lines: [
					...lines,
					{ id: item.id, amount: clamp(amount, 1, MAX_AMOUNT_PER_LINE) },
				],
				denied: false,
			});
			return;
		}

		set({
			lines: lines.map((line) =>
				line.id === item.id
					? {
							...line,
							amount: clamp(line.amount + amount, 1, MAX_AMOUNT_PER_LINE),
						}
					: line,
			),
			denied: false,
		});
	},

	setAmount: (item, amount) => {
		if (amount <= 0) {
			set({ lines: get().lines.filter((line) => line.id !== item.id) });
			return;
		}

		set({
			lines: get().lines.map((line) =>
				line.id === item.id
					? { ...line, amount: clamp(amount, 1, MAX_AMOUNT_PER_LINE) }
					: line,
			),
		});
	},

	removeLine: (id) =>
		set({ lines: get().lines.filter((line) => line.id !== id) }),

	clearLoadout: () => set({ lines: [], denied: false }),

	clearDenied: () => set({ denied: false }),

	/**
	 * O `buyProducts` do client responde so `true`/`false` -- a mensagem do
	 * resultado ja sai pelo Notify do jogo, entao a tela nao repete o aviso: em
	 * caso de recusa apenas marca `denied` e mantem a requisicao montada.
	 */
	requisition: async () => {
		const { lines, status } = get();

		if (status === "sending" || lines.length === 0) return false;

		set({ status: "sending", denied: false });

		const approved = await fetchNui<boolean>({
			path: "buyProducts",
			payload: {
				items: lines.map((line) => ({ key: line.id, quantity: line.amount })),
			},
			mockData: true,
			delay: 450,
		});

		set({
			status: "idle",
			denied: !approved,
			lines: approved ? [] : get().lines,
		});

		return !!approved;
	},
}));
