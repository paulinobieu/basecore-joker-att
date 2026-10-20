import { fetchNui } from "@app/utils/fetchNui";
import { setSymbol } from "@app/utils/format";
import { MOCK_ANSWER, MOCK_BOOTSTRAP, mockAccount } from "@app/utils/mock";
import { create } from "zustand";
import { notify } from "./Notify";

export interface BankAccount {
	id: number;
	name: string;
	business: boolean;
	owner: boolean;
	balance: number;
	members: number;
}

export interface Invite {
	account: number;
	name: string;
	owner: string;
	date: number;
}

export interface Product {
	code: string;
	name: string;
	description: string;
	rate: number;
	cycle: number;
	lock: number;
	minimum: number;
	maximum: number;
	penalty: number;
}

export interface Asset {
	asset: string;
	symbol: string;
	name: string;
	decimals: number;
	price: number;
	/** Variações percentuais que a CoinGecko devolve para a moeda. */
	hour: number;
	day: number;
	week: number;
}

export interface Market {
	assets: Asset[];
	fee: number;
	minimum: number;
	fresh: boolean;
	updatedAt: number;
}

export interface Movement {
	id: number;
	type: string;
	amount: number;
	description?: string;
	author?: string;
	date: number;
	outgoing: boolean;
}

export interface PixKey {
	key: string;
	date: number;
}

export interface Invoice {
	id: number;
	amount: number;
	reason: string;
	status: "pending" | "paid" | "canceled";
	system: boolean;
	issuer: string;
	target: string;
	date: number;
	paid: number | false;
}

export interface Fine {
	id: number;
	amount: number;
	description: string;
	infractions?: string;
	officer: string;
	date: number;
	paid: number | false;
}

export interface Position {
	id: number;
	code: string;
	name: string;
	amount: number;
	revenue: number;
	date: number;
	unlockAt: number;
	locked: boolean;
	penalty: number;
}

export interface Holding {
	asset: string;
	symbol: string;
	name: string;
	amount: number;
	value: number;
}

export interface Member {
	passport: number;
	name: string;
	owner: boolean;
	date: number;
}

export interface ChartPoint {
	day: number;
	balance: number;
}

export interface AccountData {
	id: number;
	name: string;
	business: boolean;
	owner: boolean;
	balance: number;
	statement: Movement[];
	chart: ChartPoint[];
	pix: PixKey[];
	transfers: Movement[];
	pixLog: Movement[];
	invoices: Invoice[];
	issued: Invoice[];
	fines: Fine[];
	positions: Position[];
	wallet: Holding[];
	members: Member[];
}

export interface Bootstrap {
	passport: number;
	name: string;
	symbol: string;
	accounts: BankAccount[];
	invites: Invite[];
	products: Product[];
	market: Market;
}

const EMPTY_MARKET: Market = {
	assets: [],
	fee: 0,
	minimum: 0,
	fresh: false,
	updatedAt: 0,
};

interface BankStore {
	passport: number;
	name: string;
	accounts: BankAccount[];
	invites: Invite[];
	products: Product[];
	market: Market;
	selected: number | null;
	account: AccountData | null;
	loading: boolean;
	busy: boolean;
}

interface BankActions {
	refresh: () => Promise<void>;
	select: (accountId: number) => Promise<void>;
	run: (
		path: string,
		payload?: Record<string, unknown>,
		options?: { silent?: boolean },
	) => Promise<{ success: boolean; message: string }>;
}

/**
 * Estado único do banco. Toda operação recarrega o bootstrap e a conta em uso,
 * então saldo, extrato e pendências andam juntos em qualquer aba.
 */
export const useBankStore = create<BankStore & BankActions>()((set, get) => ({
	passport: 0,
	name: "",
	accounts: [],
	invites: [],
	products: [],
	market: EMPTY_MARKET,
	selected: null,
	account: null,
	loading: true,
	busy: false,

	refresh: async () => {
		const bootstrap = await fetchNui<Bootstrap | false>({
			path: "get:bootstrap",
			mockData: MOCK_BOOTSTRAP,
		});

		if (!bootstrap) {
			set({ loading: false });
			return;
		}

		setSymbol(bootstrap.symbol);

		const accounts = bootstrap.accounts ?? [];

		// Mantém a conta em uso depois do refresh; se sumiu, cai na pessoal.
		const selected =
			accounts.find((item) => item.id === get().selected)?.id ??
			accounts[0]?.id ??
			null;

		const account = selected
			? await fetchNui<AccountData | false>({
					path: "get:account",
					payload: { account: selected },
					mockData: mockAccount(selected),
				})
			: false;

		set({
			passport: bootstrap.passport,
			name: bootstrap.name,
			accounts,
			invites: bootstrap.invites ?? [],
			products: bootstrap.products ?? [],
			market: bootstrap.market ?? EMPTY_MARKET,
			selected,
			account: account || null,
			loading: false,
		});
	},

	select: async (accountId) => {
		set({ selected: accountId });

		const account = await fetchNui<AccountData | false>({
			path: "get:account",
			payload: { account: accountId },
			mockData: mockAccount(accountId),
		});

		set({ account: account || null });
	},

	run: async (path, payload, options) => {
		if (get().busy) return { success: false, message: "" };

		set({ busy: true });

		const result = await fetchNui<{ success: boolean; message?: string }>({
			path,
			payload: { account: get().selected, ...payload },
			mockData: MOCK_ANSWER,
		});

		const message = result?.message || "";

		if (!result?.success) {
			const failure = message || "O banco recusou a operação.";
			if (!options?.silent) notify("error", failure);

			set({ busy: false });
			return { success: false, message: failure };
		}

		const done = message || "Operação concluída.";
		if (!options?.silent) notify("success", done);

		await get().refresh();
		set({ busy: false });

		return { success: true, message: done };
	},
}));
