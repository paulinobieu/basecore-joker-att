import type { IProduct } from "@app/stores/Shop";
import { fetchNui } from "@app/utils/fetchNui";
import { clamp } from "@app/utils/misc";
import { create } from "zustand";

export interface ICartLine {
	id: string;
	amount: number;
}

export interface ICheckoutResult {
	success: boolean;
	message: string;
}

/** Teto por item para evitar carrinho absurdo quando o estoque e ilimitado. */
export const MAX_AMOUNT_PER_LINE = 99;

interface Store {
	lines: ICartLine[];
	status: "idle" | "sending";
}

interface Actions {
	addProduct(product: IProduct, amount?: number): void;
	setAmount(product: IProduct, amount: number): void;
	removeLine(id: string): void;
	clearCart(): void;

	checkout(): Promise<ICheckoutResult>;
}

const maxAmountOf = (product: IProduct) =>
	product.stock < 0
		? MAX_AMOUNT_PER_LINE
		: Math.min(product.stock, MAX_AMOUNT_PER_LINE);

export const useCart = create<Store & Actions>()((set, get) => ({
	lines: [],
	status: "idle",

	addProduct: (product, amount = 1) => {
		const { lines } = get();
		const current = lines.find((line) => line.id === product.id);
		const limit = maxAmountOf(product);

		if (limit <= 0) return;

		if (!current) {
			set({
				lines: [...lines, { id: product.id, amount: clamp(amount, 1, limit) }],
			});
			return;
		}

		set({
			lines: lines.map((line) =>
				line.id === product.id
					? { ...line, amount: clamp(line.amount + amount, 1, limit) }
					: line,
			),
		});
	},

	setAmount: (product, amount) => {
		const limit = maxAmountOf(product);

		if (amount <= 0) {
			set({ lines: get().lines.filter((line) => line.id !== product.id) });
			return;
		}

		set({
			lines: get().lines.map((line) =>
				line.id === product.id
					? { ...line, amount: clamp(amount, 1, limit) }
					: line,
			),
		});
	},

	removeLine: (id) =>
		set({ lines: get().lines.filter((line) => line.id !== id) }),

	clearCart: () => set({ lines: [] }),

	checkout: async () => {
		const { lines, status } = get();

		if (status === "sending" || lines.length === 0) {
			return { success: false, message: "Carrinho vazio" };
		}

		set({ status: "sending" });

		const result = await fetchNui<ICheckoutResult | null>({
			path: "shop:checkout",
			payload: { items: lines },
			mockData: { success: true, message: "Compra realizada com sucesso" },
			delay: 400,
		});

		const feedback = result ?? {
			success: false,
			message: "Não foi possível concluir a compra",
		};

		set({
			status: "idle",
			lines: feedback.success ? [] : get().lines,
		});

		return feedback;
	},
}));
