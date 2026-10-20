import type {
	ICraftingData,
	IIngredient,
	IMaterials,
} from "@app/stores/Crafting";

/**
 * Bancada de armas do resource antigo (`Crafting.Recipes.Armas` e
 * `Crafting.Recipes.Municao`): mesmas receitas, mesmos custos e os nomes vindos
 * do `Item.lua` do vRP. Usado apenas no navegador -- em jogo o Lua manda os
 * mesmos campos.
 */

/** Mesma CDN do `ItemsURL` do `vrp/config/Global.lua`. */
const ITEMS_URL = "https://cdn.corenetwork.dev/Itens/";

const image = (index: string) => `${ITEMS_URL}${index}.png`;

/** Materiais que o jogador tem na mochila neste cenario de teste. */
const OWNED: IMaterials = {
	canopistola: 6,
	canosub: 9,
	canofuzil: 2,
	gatilhofarm: 95,
	molafarm: 95,
	polvorafarm: 1990,
	capsula: 240,
	capsulasub: 120,
};

const NAMES: Record<string, string> = {
	canopistola: "Cano de Pistola",
	canosub: "Cano de SMG",
	canofuzil: "Cano de Fuzil",
	gatilhofarm: "Gatilho de Arma",
	molafarm: "Mola de Arma",
	polvorafarm: "Polvora",
	capsula: "Capsula de Pistola",
	capsulasub: "Capsula de SMG",
	capsulafuzil: "Capsula de Fuzil",
};

const ingredient = (id: string, amount: number): IIngredient => ({
	id,
	amount,
	name: NAMES[id],
	image: image(id),
});

export const CRAFTING_MOCK: ICraftingData = {
	station: {
		label: "Bancada de Armas",
		description: "Armamento e munição",
	},
	categories: [
		{ id: "all", label: "Tudo" },
		{ id: "armas", label: "Armas" },
		{ id: "municao", label: "Munição" },
	],
	recipes: [
		{
			id: "BOX_WEAPON_PISTOL_MK2",
			name: "Caixa de FN Five Seven",
			category: "armas",
			image: image("BOX_WEAPON_PISTOL_MK2"),
			amount: 1,
			time: 30,
			weight: 2.5,
			ingredients: [
				ingredient("canopistola", 20),
				ingredient("gatilhofarm", 40),
				ingredient("molafarm", 40),
			],
		},
		{
			id: "BOX_WEAPON_SNSPISTOL_MK2",
			name: "Caixa de SNS Pistol MK2",
			category: "armas",
			image: image("BOX_WEAPON_SNSPISTOL_MK2"),
			amount: 1,
			time: 30,
			weight: 2.5,
			ingredients: [
				ingredient("canopistola", 15),
				ingredient("gatilhofarm", 30),
				ingredient("molafarm", 30),
			],
		},
		{
			id: "BOX_WEAPON_MACHINEPISTOL",
			name: "Caixa de Machine Pistol",
			category: "armas",
			image: image("BOX_WEAPON_MACHINEPISTOL"),
			amount: 1,
			time: 30,
			weight: 2.5,
			ingredients: [
				ingredient("canosub", 50),
				ingredient("gatilhofarm", 100),
				ingredient("molafarm", 100),
			],
		},
		{
			id: "BOX_WEAPON_SMG_MK2",
			name: "Caixa de SMG MK2",
			category: "armas",
			image: image("BOX_WEAPON_SMG_MK2"),
			amount: 1,
			time: 30,
			weight: 3,
			ingredients: [
				ingredient("canosub", 75),
				ingredient("gatilhofarm", 150),
				ingredient("molafarm", 150),
			],
		},
		{
			id: "BOX_WEAPON_ASSAULTSMG",
			name: "Caixa de Assault SMG",
			category: "armas",
			image: image("BOX_WEAPON_ASSAULTSMG"),
			amount: 1,
			time: 30,
			weight: 3,
			ingredients: [
				ingredient("canosub", 100),
				ingredient("gatilhofarm", 200),
				ingredient("molafarm", 200),
			],
		},
		{
			id: "BOX_WEAPON_COMPACTRIFLE",
			name: "Caixa de Compact Rifle",
			category: "armas",
			image: image("BOX_WEAPON_COMPACTRIFLE"),
			amount: 1,
			time: 30,
			weight: 3.5,
			ingredients: [
				ingredient("canofuzil", 150),
				ingredient("gatilhofarm", 250),
				ingredient("molafarm", 250),
			],
		},
		{
			id: "BOX_WEAPON_SPECIALCARBINE",
			name: "Caixa de Special Carbine",
			category: "armas",
			image: image("BOX_WEAPON_SPECIALCARBINE"),
			amount: 1,
			time: 30,
			weight: 3.5,
			ingredients: [
				ingredient("canofuzil", 200),
				ingredient("gatilhofarm", 300),
				ingredient("molafarm", 300),
			],
		},
		{
			id: "BOX_WEAPON_SPECIALCARBINE_MK2",
			name: "Caixa de Special Carbine MK2",
			category: "armas",
			image: image("BOX_WEAPON_SPECIALCARBINE_MK2"),
			amount: 1,
			time: 30,
			weight: 3.5,
			ingredients: [
				ingredient("canofuzil", 250),
				ingredient("gatilhofarm", 350),
				ingredient("molafarm", 350),
			],
		},
		{
			id: "caixapistolammo",
			name: "Caixa de Munição de Pistola",
			category: "municao",
			image: image("caixapistolammo"),
			amount: 1,
			time: 1,
			weight: 1.5,
			ingredients: [ingredient("polvorafarm", 50), ingredient("capsula", 50)],
		},
		{
			id: "caixasubammo",
			name: "Caixa de Munição de SMG",
			category: "municao",
			image: image("caixasubammo"),
			amount: 1,
			time: 1,
			weight: 1.6,
			ingredients: [
				ingredient("polvorafarm", 100),
				ingredient("capsulasub", 100),
			],
		},
		{
			id: "caixarifleammo",
			name: "Caixa de Munição de Rifle",
			category: "municao",
			image: image("caixarifleammo"),
			amount: 1,
			time: 1,
			weight: 1.8,
			ingredients: [
				ingredient("polvorafarm", 150),
				ingredient("capsulafuzil", 150),
			],
		},
	],
	materials: OWNED,
	queue: [
		{
			id: 1,
			name: "Caixa de SMG MK2",
			image: image("BOX_WEAPON_SMG_MK2"),
			amount: 1,
			duration: 30,
			remaining: 0,
		},
		{
			id: 2,
			name: "Caixa de Munição de Pistola",
			image: image("caixapistolammo"),
			amount: 20,
			duration: 20,
			remaining: 20,
		},
	],
};
