import type { IBoosterData } from "@app/stores/Booster";
import type { ThemeColors } from "@app/utils/colors";

/** Espelho do que o Lua entrega, usado so quando a tela roda no navegador. */
export const MOCK_COLORS: ThemeColors = {
	primaryColor: "#6b89ff",
	secondaryColor: "#42559e",
	thirdyColor: "#1e2647",
};

const ITEMS_URL = "https://cdn.corenetwork.dev/Itens/";
const VEHICLES_URL = "https://cdn.corenetwork.dev/corevehicles/";

export const MOCK_BOOSTER: IBoosterData = {
	player: {
		name: "Mengazo",
		tag: "MGZ",
		badge: "https://cdn.discordapp.com/guild-tag-badges/0/0.png?size=64",
		avatar: "https://cdn.corenetwork.dev/avatars/default.png",
	},
	benefits: [
		{
			id: "boost",
			title: "Server Boost",
			description:
				"Benefícios exclusivos para quem dá Boost no nosso servidor do Discord. Itens, veículos e saldo especiais!",
			icon: "rocket",
			accent: "#a855f7",
			active: true,
			claimed: true,
			labels: { active: "Boost ativo", inactive: "Boost inativo" },
			rewards: [
				{
					id: "boost-1",
					label: "Dinheiro no banco",
					amount: 50000,
					image: `${ITEMS_URL}dollar.png`,
					icon: "money",
				},
				{
					id: "boost-2",
					label: "Diamantes",
					amount: 10,
					image: `${ITEMS_URL}gemstone.png`,
					icon: "sparkles",
				},
				{
					id: "boost-3",
					label: "COREHYPER001",
					image: `${VEHICLES_URL}corehyper001.png`,
					icon: "vehicle",
					linked: true,
				},
			],
		},
		{
			id: "tag",
			title: "Tag do Servidor",
			description:
				"Recompensas para quem utiliza a tag do nosso servidor no Discord. Mantenha a tag ativa para manter o benefício!",
			icon: "tag",
			active: true,
			claimed: false,
			labels: { active: "Tag ativa", inactive: "Tag inativa" },
			rewards: [
				{
					id: "tag-1",
					label: "Dinheiro no banco",
					amount: 25000,
					image: `${ITEMS_URL}dollar.png`,
					icon: "money",
				},
				{
					id: "tag-2",
					label: "Kit de Primeiros Socorros",
					amount: 5,
					image: `${ITEMS_URL}medkit.png`,
				},
			],
		},
	],
	language: {
		title: "Recompensas",
		subtitle: "Benefícios do Discord",
		close: "Fechar (ESC)",
		claim: "Coletar",
		claimed: "Já coletado",
		unavailable: "Indisponível",
		collected: "Coletado",
		rewardsLabel: "O que você recebe",
		viewAll: "Ver todas (%s)",
		linked: "Enquanto ativo",
		claimedMessage: "Você já coletou este benefício.",
		availableMessage: "Você pode coletar suas recompensas!",
		inactiveMessage: "Você não possui este benefício ativo.",
		empty: "Nenhuma recompensa configurada.",
	},
};
