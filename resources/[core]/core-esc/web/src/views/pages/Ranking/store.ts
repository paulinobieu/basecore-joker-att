import { create } from "zustand";
import { fetchNui } from "@app/utils/fetchNui";

export interface Category {
	id: string;
	name: string;
	showValue: boolean;
}

export interface RankItem {
	rank: number;
	name: string;
	avatar: string;
	id: number;
	score: number;
}

export const categories: Category[] = [
	{ id: "combat", name: "Combate", showValue: true },
	{ id: "racing", name: "Corridas", showValue: true },
	{ id: "money", name: "Dinheiro", showValue: true },
	{ id: "crimes", name: "Crimes", showValue: true },
	{ id: "fishing", name: "Pesca", showValue: false },
];

export const rankMock: RankItem[] = [
	{
		rank: 1,
		name: "Miguel Facca",
		avatar: "https://i.pravatar.cc/64?img=1",
		id: 1001,
		score: 95420,
	},
	{
		rank: 2,
		name: "Maria Santos",
		avatar: "https://i.pravatar.cc/64?img=2",
		id: 1002,
		score: 89340,
	},
	{
		rank: 3,
		name: "Pedro Oliveira",
		avatar: "https://i.pravatar.cc/64?img=3",
		id: 1003,
		score: 82150,
	},
	{
		rank: 4,
		name: "Ana Costa",
		avatar: "https://i.pravatar.cc/64?img=4",
		id: 1004,
		score: 78900,
	},
	{
		rank: 5,
		name: "Carlos Ferreira",
		avatar: "https://i.pravatar.cc/64?img=5",
		id: 1005,
		score: 76230,
	},
	{
		rank: 6,
		name: "Beatriz Lima",
		avatar: "https://i.pravatar.cc/64?img=6",
		id: 1006,
		score: 73450,
	},
	{
		rank: 7,
		name: "Rafael Gomes",
		avatar: "https://i.pravatar.cc/64?img=7",
		id: 1007,
		score: 71880,
	},
	{
		rank: 8,
		name: "Juliana Alves",
		avatar: "https://i.pravatar.cc/64?img=8",
		id: 1008,
		score: 69320,
	},
	{
		rank: 9,
		name: "Gabriel Rodrigues",
		avatar: "https://i.pravatar.cc/64?img=9",
		id: 1009,
		score: 67540,
	},
	{
		rank: 10,
		name: "Camila Pereira",
		avatar: "https://i.pravatar.cc/64?img=10",
		id: 1010,
		score: 65780,
	},
	{
		rank: 11,
		name: "Bruno Martins",
		avatar: "https://i.pravatar.cc/64?img=11",
		id: 1011,
		score: 63920,
	},
	{
		rank: 12,
		name: "Larissa Soares",
		avatar: "https://i.pravatar.cc/64?img=12",
		id: 1012,
		score: 61850,
	},
	{
		rank: 13,
		name: "Diego Carvalho",
		avatar: "https://i.pravatar.cc/64?img=13",
		id: 1013,
		score: 59740,
	},
	{
		rank: 14,
		name: "Fernanda Ribeiro",
		avatar: "https://i.pravatar.cc/64?img=14",
		id: 1014,
		score: 57680,
	},
	{
		rank: 15,
		name: "Lucas Almeida",
		avatar: "https://i.pravatar.cc/64?img=15",
		id: 1015,
		score: 55620,
	},
	{
		rank: 16,
		name: "Natália Barbosa",
		avatar: "https://i.pravatar.cc/64?img=16",
		id: 1016,
		score: 53450,
	},
	{
		rank: 17,
		name: "Felipe Vieira",
		avatar: "https://i.pravatar.cc/64?img=17",
		id: 1017,
		score: 51290,
	},
	{
		rank: 18,
		name: "Carolina Lopes",
		avatar: "https://i.pravatar.cc/64?img=18",
		id: 1018,
		score: 49120,
	},
	{
		rank: 19,
		name: "Mateus Fernandes",
		avatar: "https://i.pravatar.cc/64?img=19",
		id: 1019,
		score: 46950,
	},
	{
		rank: 20,
		name: "Mariana Torres",
		avatar: "https://i.pravatar.cc/64?img=20",
		id: 1020,
		score: 44780,
	},
	{
		rank: 21,
		name: "Gustavo Mendes",
		avatar: "https://i.pravatar.cc/64?img=21",
		id: 1021,
		score: 42610,
	},
	{
		rank: 22,
		name: "Isabella Castro",
		avatar: "https://i.pravatar.cc/64?img=22",
		id: 1022,
		score: 40440,
	},
	{
		rank: 23,
		name: "Arthur Dias",
		avatar: "https://i.pravatar.cc/64?img=23",
		id: 1023,
		score: 38270,
	},
	{
		rank: 24,
		name: "Sophia Ramos",
		avatar: "https://i.pravatar.cc/64?img=24",
		id: 1024,
		score: 36100,
	},
	{
		rank: 25,
		name: "Eduardo Moreira",
		avatar: "https://i.pravatar.cc/64?img=25",
		id: 1025,
		score: 33930,
	},
	{
		rank: 26,
		name: "Valentina Cardoso",
		avatar: "https://i.pravatar.cc/64?img=26",
		id: 1026,
		score: 31760,
	},
	{
		rank: 27,
		name: "Leonardo Nunes",
		avatar: "https://i.pravatar.cc/64?img=27",
		id: 1027,
		score: 29590,
	},
	{
		rank: 28,
		name: "Alice Freitas",
		avatar: "https://i.pravatar.cc/64?img=28",
		id: 1028,
		score: 27420,
	},
	{
		rank: 29,
		name: "Heitor Campos",
		avatar: "https://i.pravatar.cc/64?img=29",
		id: 1029,
		score: 25250,
	},
	{
		rank: 30,
		name: "Helena Correia",
		avatar: "https://i.pravatar.cc/64?img=30",
		id: 1030,
		score: 23080,
	},
	{
		rank: 31,
		name: "Vitor Pinto",
		avatar: "https://i.pravatar.cc/64?img=31",
		id: 1031,
		score: 20910,
	},
	{
		rank: 32,
		name: "Manuela Teixeira",
		avatar: "https://i.pravatar.cc/64?img=32",
		id: 1032,
		score: 18740,
	},
	{
		rank: 33,
		name: "Samuel Monteiro",
		avatar: "https://i.pravatar.cc/64?img=33",
		id: 1033,
		score: 16570,
	},
	{
		rank: 34,
		name: "Laura Rocha",
		avatar: "https://i.pravatar.cc/64?img=34",
		id: 1034,
		score: 14400,
	},
	{
		rank: 35,
		name: "André Azevedo",
		avatar: "https://i.pravatar.cc/64?img=35",
		id: 1035,
		score: 12230,
	},
	{
		rank: 36,
		name: "Rebeca Cunha",
		avatar: "https://i.pravatar.cc/64?img=36",
		id: 1036,
		score: 10060,
	},
	{
		rank: 37,
		name: "Miguel Borges",
		avatar: "https://i.pravatar.cc/64?img=37",
		id: 1037,
		score: 7890,
	},
	{
		rank: 38,
		name: "Letícia Melo",
		avatar: "https://i.pravatar.cc/64?img=38",
		id: 1038,
		score: 5720,
	},
	{
		rank: 39,
		name: "Bernardo Faria",
		avatar: "https://i.pravatar.cc/64?img=39",
		id: 1039,
		score: 3550,
	},
	{
		rank: 40,
		name: "Gabriela Macedo",
		avatar: "https://i.pravatar.cc/64?img=40",
		id: 1040,
		score: 1380,
	},
];

export const weeklyRankMock: RankItem[] = [
	{
		rank: 1,
		name: "Ricardo Silva",
		avatar: "https://i.pravatar.cc/64?img=41",
		id: 2001,
		score: 8940,
	},
	{
		rank: 2,
		name: "Patrícia Costa",
		avatar: "https://i.pravatar.cc/64?img=42",
		id: 2002,
		score: 8320,
	},
	{
		rank: 3,
		name: "Rodrigo Santos",
		avatar: "https://i.pravatar.cc/64?img=43",
		id: 2003,
		score: 7890,
	},
	{
		rank: 4,
		name: "Carla Oliveira",
		avatar: "https://i.pravatar.cc/64?img=44",
		id: 2004,
		score: 7560,
	},
	{
		rank: 5,
		name: "Thiago Pereira",
		avatar: "https://i.pravatar.cc/64?img=45",
		id: 2005,
		score: 7230,
	},
	{
		rank: 6,
		name: "Amanda Lima",
		avatar: "https://i.pravatar.cc/64?img=46",
		id: 2006,
		score: 6890,
	},
	{
		rank: 7,
		name: "Daniel Ferreira",
		avatar: "https://i.pravatar.cc/64?img=47",
		id: 2007,
		score: 6540,
	},
	{
		rank: 8,
		name: "Priscila Gomes",
		avatar: "https://i.pravatar.cc/64?img=48",
		id: 2008,
		score: 6210,
	},
	{
		rank: 9,
		name: "Marcelo Alves",
		avatar: "https://i.pravatar.cc/64?img=49",
		id: 2009,
		score: 5880,
	},
	{
		rank: 10,
		name: "Vanessa Rodrigues",
		avatar: "https://i.pravatar.cc/64?img=50",
		id: 2010,
		score: 5540,
	},
	{
		rank: 11,
		name: "Fábio Martins",
		avatar: "https://i.pravatar.cc/64?img=51",
		id: 2011,
		score: 5200,
	},
	{
		rank: 12,
		name: "Tatiane Soares",
		avatar: "https://i.pravatar.cc/64?img=52",
		id: 2012,
		score: 4860,
	},
	{
		rank: 13,
		name: "Roberto Carvalho",
		avatar: "https://i.pravatar.cc/64?img=53",
		id: 2013,
		score: 4520,
	},
	{
		rank: 14,
		name: "Cristina Ribeiro",
		avatar: "https://i.pravatar.cc/64?img=54",
		id: 2014,
		score: 4180,
	},
	{
		rank: 15,
		name: "Henrique Almeida",
		avatar: "https://i.pravatar.cc/64?img=55",
		id: 2015,
		score: 3840,
	},
	{
		rank: 16,
		name: "Simone Barbosa",
		avatar: "https://i.pravatar.cc/64?img=56",
		id: 2016,
		score: 3500,
	},
	{
		rank: 17,
		name: "Júlio Vieira",
		avatar: "https://i.pravatar.cc/64?img=57",
		id: 2017,
		score: 3160,
	},
	{
		rank: 18,
		name: "Monica Lopes",
		avatar: "https://i.pravatar.cc/64?img=58",
		id: 2018,
		score: 2820,
	},
	{
		rank: 19,
		name: "Renato Fernandes",
		avatar: "https://i.pravatar.cc/64?img=59",
		id: 2019,
		score: 2480,
	},
	{
		rank: 20,
		name: "Sandra Torres",
		avatar: "https://i.pravatar.cc/64?img=60",
		id: 2020,
		score: 2140,
	},
	{
		rank: 21,
		name: "Paulo Mendes",
		avatar: "https://i.pravatar.cc/64?img=61",
		id: 2021,
		score: 1800,
	},
	{
		rank: 22,
		name: "Eliane Castro",
		avatar: "https://i.pravatar.cc/64?img=62",
		id: 2022,
		score: 1460,
	},
	{
		rank: 23,
		name: "Alexandre Dias",
		avatar: "https://i.pravatar.cc/64?img=63",
		id: 2023,
		score: 1320,
	},
	{
		rank: 24,
		name: "Denise Ramos",
		avatar: "https://i.pravatar.cc/64?img=64",
		id: 2024,
		score: 1180,
	},
	{
		rank: 25,
		name: "Márcio Moreira",
		avatar: "https://i.pravatar.cc/64?img=65",
		id: 2025,
		score: 1040,
	},
	{
		rank: 26,
		name: "Rosana Cardoso",
		avatar: "https://i.pravatar.cc/64?img=66",
		id: 2026,
		score: 900,
	},
	{
		rank: 27,
		name: "Jefferson Nunes",
		avatar: "https://i.pravatar.cc/64?img=67",
		id: 2027,
		score: 760,
	},
	{
		rank: 28,
		name: "Luciana Freitas",
		avatar: "https://i.pravatar.cc/64?img=68",
		id: 2028,
		score: 620,
	},
	{
		rank: 29,
		name: "Wagner Campos",
		avatar: "https://i.pravatar.cc/64?img=69",
		id: 2029,
		score: 480,
	},
	{
		rank: 30,
		name: "Adriana Correia",
		avatar: "https://i.pravatar.cc/64?img=70",
		id: 2030,
		score: 340,
	},
	{
		rank: 31,
		name: "Sérgio Pinto",
		avatar: "https://i.pravatar.cc/64?img=71",
		id: 2031,
		score: 300,
	},
	{
		rank: 32,
		name: "Regina Teixeira",
		avatar: "https://i.pravatar.cc/64?img=72",
		id: 2032,
		score: 280,
	},
	{
		rank: 33,
		name: "Wilson Monteiro",
		avatar: "https://i.pravatar.cc/64?img=73",
		id: 2033,
		score: 260,
	},
	{
		rank: 34,
		name: "Cláudia Rocha",
		avatar: "https://i.pravatar.cc/64?img=74",
		id: 2034,
		score: 240,
	},
	{
		rank: 35,
		name: "Nelson Azevedo",
		avatar: "https://i.pravatar.cc/64?img=75",
		id: 2035,
		score: 220,
	},
	{
		rank: 36,
		name: "Solange Cunha",
		avatar: "https://i.pravatar.cc/64?img=76",
		id: 2036,
		score: 200,
	},
	{
		rank: 37,
		name: "Edson Borges",
		avatar: "https://i.pravatar.cc/64?img=77",
		id: 2037,
		score: 180,
	},
	{
		rank: 38,
		name: "Vera Melo",
		avatar: "https://i.pravatar.cc/64?img=78",
		id: 2038,
		score: 160,
	},
	{
		rank: 39,
		name: "Antônio Faria",
		avatar: "https://i.pravatar.cc/64?img=79",
		id: 2039,
		score: 140,
	},
	{
		rank: 40,
		name: "Marlene Macedo",
		avatar: "https://i.pravatar.cc/64?img=80",
		id: 2040,
		score: 120,
	},
];

export const dailyRankMock: RankItem[] = [
	{
		rank: 1,
		name: "Fernando Costa",
		avatar: "https://i.pravatar.cc/64?img=81",
		id: 3001,
		score: 1250,
	},
	{
		rank: 2,
		name: "Lúcia Santos",
		avatar: "https://i.pravatar.cc/64?img=82",
		id: 3002,
		score: 1180,
	},
	{
		rank: 3,
		name: "José Oliveira",
		avatar: "https://i.pravatar.cc/64?img=83",
		id: 3003,
		score: 1120,
	},
	{
		rank: 4,
		name: "Márcia Silva",
		avatar: "https://i.pravatar.cc/64?img=84",
		id: 3004,
		score: 1060,
	},
	{
		rank: 5,
		name: "Luiz Pereira",
		avatar: "https://i.pravatar.cc/64?img=85",
		id: 3005,
		score: 980,
	},
	{
		rank: 6,
		name: "Sônia Lima",
		avatar: "https://i.pravatar.cc/64?img=86",
		id: 3006,
		score: 920,
	},
	{
		rank: 7,
		name: "Francisco Ferreira",
		avatar: "https://i.pravatar.cc/64?img=87",
		id: 3007,
		score: 860,
	},
	{
		rank: 8,
		name: "Ivone Gomes",
		avatar: "https://i.pravatar.cc/64?img=88",
		id: 3008,
		score: 800,
	},
	{
		rank: 9,
		name: "Raimundo Alves",
		avatar: "https://i.pravatar.cc/64?img=89",
		id: 3009,
		score: 740,
	},
	{
		rank: 10,
		name: "Terezinha Rodrigues",
		avatar: "https://i.pravatar.cc/64?img=90",
		id: 3010,
		score: 680,
	},
	{
		rank: 11,
		name: "Sebastião Martins",
		avatar: "https://i.pravatar.cc/64?img=91",
		id: 3011,
		score: 620,
	},
	{
		rank: 12,
		name: "Maria José Soares",
		avatar: "https://i.pravatar.cc/64?img=92",
		id: 3012,
		score: 560,
	},
	{
		rank: 13,
		name: "João Carlos",
		avatar: "https://i.pravatar.cc/64?img=93",
		id: 3013,
		score: 500,
	},
	{
		rank: 14,
		name: "Aparecida Ribeiro",
		avatar: "https://i.pravatar.cc/64?img=94",
		id: 3014,
		score: 440,
	},
	{
		rank: 15,
		name: "Antônio Carlos",
		avatar: "https://i.pravatar.cc/64?img=95",
		id: 3015,
		score: 380,
	},
	{
		rank: 16,
		name: "Conceição Barbosa",
		avatar: "https://i.pravatar.cc/64?img=96",
		id: 3016,
		score: 360,
	},
	{
		rank: 17,
		name: "Manoel Vieira",
		avatar: "https://i.pravatar.cc/64?img=97",
		id: 3017,
		score: 340,
	},
	{
		rank: 18,
		name: "Benedita Lopes",
		avatar: "https://i.pravatar.cc/64?img=98",
		id: 3018,
		score: 320,
	},
	{
		rank: 19,
		name: "Geraldo Fernandes",
		avatar: "https://i.pravatar.cc/64?img=99",
		id: 3019,
		score: 300,
	},
	{
		rank: 20,
		name: "Marta Torres",
		avatar: "https://i.pravatar.cc/64?img=100",
		id: 3020,
		score: 280,
	},
	{
		rank: 21,
		name: "Valdir Mendes",
		avatar: "https://i.pravatar.cc/64?img=1",
		id: 3021,
		score: 260,
	},
	{
		rank: 22,
		name: "Cleide Castro",
		avatar: "https://i.pravatar.cc/64?img=2",
		id: 3022,
		score: 240,
	},
	{
		rank: 23,
		name: "Osvaldo Dias",
		avatar: "https://i.pravatar.cc/64?img=3",
		id: 3023,
		score: 220,
	},
	{
		rank: 24,
		name: "Neusa Ramos",
		avatar: "https://i.pravatar.cc/64?img=4",
		id: 3024,
		score: 200,
	},
	{
		rank: 25,
		name: "Valdemar Moreira",
		avatar: "https://i.pravatar.cc/64?img=5",
		id: 3025,
		score: 180,
	},
	{
		rank: 26,
		name: "Odete Cardoso",
		avatar: "https://i.pravatar.cc/64?img=6",
		id: 3026,
		score: 160,
	},
	{
		rank: 27,
		name: "Expedito Nunes",
		avatar: "https://i.pravatar.cc/64?img=7",
		id: 3027,
		score: 140,
	},
	{
		rank: 28,
		name: "Zilda Freitas",
		avatar: "https://i.pravatar.cc/64?img=8",
		id: 3028,
		score: 120,
	},
	{
		rank: 29,
		name: "Domingos Campos",
		avatar: "https://i.pravatar.cc/64?img=9",
		id: 3029,
		score: 100,
	},
	{
		rank: 30,
		name: "Alzira Correia",
		avatar: "https://i.pravatar.cc/64?img=10",
		id: 3030,
		score: 95,
	},
	{
		rank: 31,
		name: "Joaquim Pinto",
		avatar: "https://i.pravatar.cc/64?img=11",
		id: 3031,
		score: 90,
	},
	{
		rank: 32,
		name: "Dirce Teixeira",
		avatar: "https://i.pravatar.cc/64?img=12",
		id: 3032,
		score: 85,
	},
	{
		rank: 33,
		name: "Waldemar Monteiro",
		avatar: "https://i.pravatar.cc/64?img=13",
		id: 3033,
		score: 80,
	},
	{
		rank: 34,
		name: "Palmira Rocha",
		avatar: "https://i.pravatar.cc/64?img=14",
		id: 3034,
		score: 75,
	},
	{
		rank: 35,
		name: "Dorival Azevedo",
		avatar: "https://i.pravatar.cc/64?img=15",
		id: 3035,
		score: 70,
	},
	{
		rank: 36,
		name: "Olinda Cunha",
		avatar: "https://i.pravatar.cc/64?img=16",
		id: 3036,
		score: 65,
	},
	{
		rank: 37,
		name: "Almir Borges",
		avatar: "https://i.pravatar.cc/64?img=17",
		id: 3037,
		score: 60,
	},
	{
		rank: 38,
		name: "Dalva Melo",
		avatar: "https://i.pravatar.cc/64?img=18",
		id: 3038,
		score: 55,
	},
	{
		rank: 39,
		name: "Benedito Faria",
		avatar: "https://i.pravatar.cc/64?img=19",
		id: 3039,
		score: 50,
	},
	{
		rank: 40,
		name: "Glória Macedo",
		avatar: "https://i.pravatar.cc/64?img=20",
		id: 3040,
		score: 45,
	},
];

interface RankingState {
	categories: Category[];
	rank: RankItem[];
	weeklyRank: RankItem[];
	dailyRank: RankItem[];
	selectedCategory: Category | null;
	filter: string;
	playerId: number;
	getCategories: () => Promise<void>;
	getPlayerId: () => Promise<void>;
	setSelectedCategory: (category: Category | null) => Promise<void>;
	setFilter: (filter: string) => void;
}

export const useRankingStore = create<RankingState>((set, get) => ({
	categories: [],
	rank: [],
	weeklyRank: [],
	dailyRank: [],
	selectedCategory: null,
	filter: "",
	playerId: 0,
	async getCategories() {
		const result = await fetchNui<Category[]>({
			path: "get:ranking:categories",
			payload: {},
			mockData: categories,
		});
		if (result) {
			set({ categories: result });
			get().setSelectedCategory(result[0]);
		}
	},
	async getPlayerId() {
		const result = await fetchNui<number>({
			path: "get:player:id",
			mockData: 1001,
		});
		if (result) set({ playerId: result });
	},
	async setSelectedCategory(category) {
		if (!category)
			return set({
				selectedCategory: null,
				rank: [],
				weeklyRank: [],
				dailyRank: [],
			});
		const result = await fetchNui<{
			rank: RankItem[];
			weeklyRank: RankItem[];
			dailyRank: RankItem[];
		}>({
			path: "get:ranking:byCategory",
			payload: { categoryId: category.id },
			mockData: {
				rank: rankMock,
				weeklyRank: weeklyRankMock,
				dailyRank: dailyRankMock,
			},
		});
		if (result)
			set({
				selectedCategory: category,
				rank: result.rank.map((item, index) => {
					const id = item.id ? item.id : -1;
					const rank = item.rank ? item.rank : index + 1;
					return { ...item, id, rank };
				}),
				weeklyRank: result.weeklyRank.map((item, index) => {
					const id = item.id ? item.id : -1;
					const rank = item.rank ? item.rank : index + 1;
					return { ...item, id, rank };
				}),
				dailyRank: result.dailyRank.map((item, index) => {
					const id = item.id ? item.id : -1;
					const rank = item.rank ? item.rank : index + 1;
					return { ...item, id, rank };
				}),
			});
	},
	setFilter(filter) {
		set({ filter });
	},
}));
