import { MOCK_BOOSTER } from "@app/mocks/booster";
import { fetchNui } from "@app/utils/fetchNui";
import { create } from "zustand";

export interface IReward {
	id: string;
	label: string;
	/** Quantidade do item; ausente em recompensa unica (veiculo, cargo). */
	amount?: number;
	image?: string;
	/** Chave do catalogo fixo de icones, usada quando nao existe imagem. */
	icon?: string;
	/** Sai junto com o beneficio quando o jogador perde o boost ou a tag. */
	linked?: boolean;
}

export interface IBenefit {
	id: string;
	title: string;
	description: string;
	/** Chave do catalogo fixo de icones da interface. */
	icon: string;
	/**
	 * Cor propria do card em hex. Sem ela o card acompanha o destaque do
	 * servidor, entao so beneficio de cor fixa (o boost do Discord) precisa
	 * declarar.
	 */
	accent?: string;
	/** Jogador possui o boost/tag no Discord neste momento. */
	active: boolean;
	/** Recompensa ja retirada no ciclo atual. */
	claimed: boolean;
	labels: { active: string; inactive: string };
	rewards: IReward[];
}

export interface IPlayer {
	name: string;
	/** Tag do servidor exibida no perfil do Discord. */
	tag: string;
	/** Emblema oficial da tag, vindo do CDN do Discord. */
	badge?: string;
	avatar: string;
}

export interface ILanguage {
	title: string;
	subtitle: string;
	close: string;
	claim: string;
	claimed: string;
	unavailable: string;
	collected: string;
	rewardsLabel: string;
	viewAll: string;
	linked: string;
	claimedMessage: string;
	availableMessage: string;
	inactiveMessage: string;
	empty: string;
}

export interface IBoosterData {
	player: IPlayer;
	benefits: IBenefit[];
	language: ILanguage;
}

export interface IClaim {
	success: boolean;
	message: string;
	/** Estado novo dos beneficios; o servidor e quem decide o que ficou coletado. */
	benefits?: IBenefit[];
}

interface Store {
	data: IBoosterData | null;
	/** Beneficio aberto na previa das recompensas. */
	preview: IBenefit | null;
	claiming: string | null;
	feedback: { id: string; success: boolean; message: string } | null;
}

interface Actions {
	getBoosterData: () => Promise<void>;
	claimBenefit: (id: string) => Promise<void>;
	openRewards: (benefit: IBenefit) => void;
	closeRewards: () => void;
	clearStore: () => void;
}

const initialState: Store = {
	data: null,
	preview: null,
	claiming: null,
	feedback: null,
};

export const useBooster = create<Store & Actions>()((set, get) => ({
	...initialState,

	getBoosterData: async () => {
		const data = await fetchNui<IBoosterData | false>({
			path: "booster:getData",
			mockData: MOCK_BOOSTER,
		});

		if (!data) return;

		set({ ...initialState, data });
	},

	/**
	 * A interface manda so o id: boost, tag e o que ja foi retirado sao
	 * reconferidos no servidor, que devolve os beneficios atualizados.
	 */
	claimBenefit: async (id) => {
		const { data, claiming } = get();
		if (!data || claiming) return;

		const benefit = data.benefits.find((item) => item.id === id);
		if (!benefit || !benefit.active || benefit.claimed) return;

		set({ claiming: id, feedback: null });

		const result = await fetchNui<IClaim | null>({
			path: "booster:claim",
			payload: { id },
			delay: 350,
			mockData: {
				success: true,
				message: "Recompensas entregues no seu inventário!",
				benefits: data.benefits.map((item) =>
					item.id === id ? { ...item, claimed: true } : item,
				),
			},
		});

		if (!result) {
			set({ claiming: null });
			return;
		}

		set({
			claiming: null,
			feedback: { id, success: result.success, message: result.message },
			data: { ...data, benefits: result.benefits ?? data.benefits },
		});
	},

	openRewards: (benefit) => set({ preview: benefit }),

	closeRewards: () => set({ preview: null }),

	clearStore: () => set({ ...initialState }),
}));
