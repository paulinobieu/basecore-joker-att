import { CRAFTING_MOCK } from "@app/mocks/crafting";
import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { create } from "zustand";

export interface IIngredient {
	id: string;
	name: string;
	image: string;
	/** Quantidade consumida por fabricacao. */
	amount: number;
}

/** Quanto o jogador tem de cada material, indexado pelo spawn do item. */
export type IMaterials = Record<string, number>;

export interface IRecipe {
	id: string;
	name: string;
	image: string;
	category: string;
	/** Quantidade produzida por fabricacao. */
	amount: number;
	/** Segundos gastos por fabricacao. */
	time: number;
	weight: number;
	ingredients: IIngredient[];
}

export interface IQueueEntry {
	id: number;
	name: string;
	image: string;
	/** Unidades que ainda serao produzidas nesta entrada. */
	amount: number;
	/** Segundos totais da entrada. */
	duration: number;
	/**
	 * Segundos ate esta entrada terminar, contando as que estao na frente da
	 * fila, no momento em que o Lua enviou a atualizacao.
	 */
	remaining: number;
}

/** Entrada da fila com o termino ja resolvido no relogio da interface. */
export interface IQueueLine extends IQueueEntry {
	endsAt: number;
}

export interface IStation {
	label: string;
	description: string;
}

export interface ICategory {
	id: string;
	label: string;
}

export interface ICraftingData {
	station: IStation;
	categories: ICategory[];
	recipes: IRecipe[];
	materials: IMaterials;
	queue: IQueueEntry[];
}

export interface ICraftingUpdate {
	materials: IMaterials;
	queue: IQueueEntry[];
}

export interface ICraftResult {
	success: boolean;
	message: string;
}

/**
 * O Lua manda tabela vazia como objeto: listas e mapas são normalizados aqui
 * para a tela nunca receber a forma errada.
 */
const toList = <T>(value: unknown): T[] => (Array.isArray(value) ? value : []);

const toMaterials = (value: unknown): IMaterials =>
	value && typeof value === "object" && !Array.isArray(value)
		? (value as IMaterials)
		: {};

const toQueueLines = (queue: IQueueEntry[]): IQueueLine[] =>
	queue.map((entry) => ({
		...entry,
		endsAt: Date.now() + entry.remaining * 1000,
	}));

let mockSequence = 100;

/**
 * Enfileira a fabricacao no navegador para a tela poder ser conferida sem o
 * jogo aberto. Em jogo quem devolve fila e materiais e o `craft:update`, e o
 * custo sai do inventario assim que a producao entra na fila.
 */
const simulateCraft = (
	queue: IQueueLine[],
	materials: IMaterials,
	recipe: IRecipe,
	amount: number,
) => {
	const now = Date.now();
	const duration = recipe.time * amount;
	const lastEnd = queue.reduce(
		(end, entry) => Math.max(end, entry.endsAt),
		now,
	);

	const spent: IMaterials = { ...materials };

	for (const ingredient of recipe.ingredients) {
		const owned = spent[ingredient.id] ?? 0;

		spent[ingredient.id] = Math.max(0, owned - ingredient.amount * amount);
	}

	mockSequence += 1;

	return {
		materials: spent,
		queue: [
			...queue,
			{
				id: mockSequence,
				name: recipe.name,
				image: recipe.image,
				amount: recipe.amount * amount,
				duration,
				remaining: (lastEnd - now) / 1000 + duration,
				endsAt: lastEnd + duration * 1000,
			},
		],
	};
};

interface Store {
	station: IStation | null;
	categories: ICategory[];
	recipes: IRecipe[];
	materials: IMaterials;
	queue: IQueueLine[];

	status: "idle" | "loading" | "ready";
	sending: boolean;

	recipe: string | null;
	amount: number;
	category: string;
	search: string;
}

interface Actions {
	getCraftingData(): Promise<void>;
	applyUpdate(update: ICraftingUpdate): void;

	selectRecipe(id: string): void;
	setAmount(amount: number): void;
	setCategory(category: string): void;
	setSearch(search: string): void;

	craft(recipe: IRecipe, amount: number): Promise<ICraftResult>;
	collectCraft(id: number): Promise<ICraftResult>;
	cancelCraft(id: number): Promise<ICraftResult>;

	clearStore(): void;
}

const initialState: Store = {
	station: null,
	categories: [],
	recipes: [],
	materials: {},
	queue: [],

	status: "idle",
	sending: false,

	recipe: null,
	amount: 1,
	category: "all",
	search: "",
};

const firstOfCategory = (recipes: IRecipe[], category: string) =>
	recipes.find(
		(recipe) => category === "all" || recipe.category === category,
	) ?? null;

export const useCrafting = create<Store & Actions>()((set, get) => ({
	...initialState,

	getCraftingData: async () => {
		set({ status: "loading" });

		const data = await fetchNui<ICraftingData | null>({
			path: "craft:getData",
			mockData: CRAFTING_MOCK,
			delay: 250,
		});

		if (!data) {
			set({ status: "ready" });
			return;
		}

		const recipes = toList<IRecipe>(data.recipes);

		set({
			station: data.station,
			categories: toList<ICategory>(data.categories),
			recipes,
			materials: toMaterials(data.materials),
			queue: toQueueLines(toList<IQueueEntry>(data.queue)),
			recipe: recipes[0]?.id ?? null,
			amount: 1,
			status: "ready",
		});
	},

	applyUpdate: (update) =>
		set({
			materials: toMaterials(update?.materials),
			queue: toQueueLines(toList<IQueueEntry>(update?.queue)),
		}),

	selectRecipe: (id) => set({ recipe: id, amount: 1 }),

	setAmount: (amount) => set({ amount: Math.max(1, Math.trunc(amount)) }),

	setCategory: (category) =>
		set({
			category,
			amount: 1,
			recipe: firstOfCategory(get().recipes, category)?.id ?? null,
		}),

	setSearch: (search) => set({ search }),

	craft: async (recipe, amount) => {
		if (get().sending) {
			return { success: false, message: "Fabricação em andamento" };
		}

		set({ sending: true });

		const result = await fetchNui<ICraftResult | null>({
			path: "craft:start",
			payload: { recipe: recipe.id, amount },
			mockData: { success: true, message: "Fabricação enviada para a fila" },
			delay: 350,
		});

		const feedback = result ?? {
			success: false,
			message: "Não foi possível iniciar a fabricação",
		};

		set({ sending: false });

		if (feedback.success && isEnvBrowser()) {
			const { queue, materials } = get();

			set(simulateCraft(queue, materials, recipe, amount));
		}

		return feedback;
	},

	collectCraft: async (id) => {
		const result = await fetchNui<ICraftResult | null>({
			path: "craft:collect",
			payload: { id },
			mockData: { success: true, message: "Itens coletados" },
			delay: 200,
		});

		const feedback = result ?? {
			success: false,
			message: "Não foi possível coletar os itens",
		};

		if (feedback.success) {
			set({ queue: get().queue.filter((entry) => entry.id !== id) });
		}

		return feedback;
	},

	cancelCraft: async (id) => {
		const result = await fetchNui<ICraftResult | null>({
			path: "craft:cancel",
			payload: { id },
			mockData: { success: true, message: "Fabricação cancelada" },
			delay: 200,
		});

		const feedback = result ?? {
			success: false,
			message: "Não foi possível cancelar a fabricação",
		};

		if (feedback.success) {
			set({ queue: get().queue.filter((entry) => entry.id !== id) });
		}

		return feedback;
	},

	clearStore: () => set({ ...initialState }),
}));
