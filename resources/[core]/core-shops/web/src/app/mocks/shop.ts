import type { IShopData } from "@app/stores/Shop";

/**
 * Catalogo real da loja de departamentos (`List.Departament` do resource
 * `shops`): mesmos itens, mesmos precos e os nomes vindos do `Item.lua` do vRP.
 * Usado apenas no navegador -- em jogo o Lua manda os mesmos campos.
 */

/** Mesma CDN do `ItemsURL` do `vrp/config/Global.lua`. */
const ITEMS_URL = "https://cdn.corenetwork.dev/Itens/";

const image = (index: string) => `${ITEMS_URL}${index}.png`;

export const SHOP_MOCK: IShopData = {
	shop: {
		id: "departament",
		label: "Loja de Conveniência",
		subtitle: "Departamento · Los Santos",
	},
	categories: [
		{ id: "all", label: "Tudo" },
		{ id: "mercearia", label: "Mercearia" },
		{ id: "tabacaria", label: "Tabacaria" },
		{ id: "eletronico", label: "Eletrônicos" },
		{ id: "utilidade", label: "Utilidades" },
	],
	products: [
		{
			id: "ryebread",
			name: "Pão de Centeio",
			category: "mercearia",
			price: 20,
			stock: -1,
			image: image("ryebread"),
		},
		{
			id: "mayonnaise",
			name: "Pote de Maionese",
			category: "mercearia",
			price: 20,
			stock: -1,
			image: image("mayonnaise"),
		},
		{
			id: "condensedmilk",
			name: "Leite Condensado",
			category: "mercearia",
			price: 25,
			stock: -1,
			image: image("condensedmilk"),
		},
		{
			id: "sugarbox",
			name: "Caixa de Açúcar",
			category: "mercearia",
			price: 35,
			stock: -1,
			image: image("sugarbox"),
		},
		{
			id: "ricebag",
			name: "Saco de Arroz",
			category: "mercearia",
			price: 105,
			stock: -1,
			image: image("ricebag"),
		},
		{
			id: "cigarette",
			name: "Maço de Cigarros",
			category: "tabacaria",
			price: 15,
			stock: -1,
			image: image("cigarette"),
		},
		{
			id: "lighter",
			name: "Isqueiro",
			category: "tabacaria",
			price: 225,
			stock: -1,
			image: image("lighter"),
		},
		{
			id: "vape",
			name: "Vape",
			category: "tabacaria",
			price: 4750,
			stock: -1,
			image: image("vape"),
		},
		{
			id: "camera",
			name: "Câmera",
			category: "eletronico",
			price: 425,
			stock: -1,
			image: image("camera"),
		},
		{
			id: "binoculars",
			name: "Binóculos",
			category: "eletronico",
			price: 425,
			stock: -1,
			image: image("binoculars"),
		},
		{
			id: "cellphone",
			name: "Celular",
			category: "eletronico",
			price: 725,
			stock: -1,
			image: image("cellphone"),
		},
		{
			id: "radio",
			name: "Rádio",
			category: "eletronico",
			price: 975,
			stock: -1,
			image: image("radio"),
		},
		{
			id: "mapgps",
			name: "Mapa Adaptativo",
			category: "eletronico",
			price: 50000,
			stock: -1,
			image: image("mapgps"),
		},
		{
			id: "postit",
			name: "Post-It",
			category: "utilidade",
			price: 20,
			stock: -1,
			image: image("postit"),
		},
		{
			id: "emptypurifiedwater",
			name: "Regador Vazio",
			category: "utilidade",
			price: 1275,
			stock: -1,
			image: image("emptypurifiedwater"),
		},
	],
};
