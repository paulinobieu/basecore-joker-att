import type { IRawCategory } from "@app/stores/Arsenal";

/**
 * Espelha o template `DEFAULT_POLICE` do `config/config.lua`: mesmas secoes,
 * mesmos itens e mesmos precos, no formato cru que o `Core.GetArsenalData`
 * devolve. Usado apenas no navegador -- em jogo os campos vem do Lua.
 */

/** Mesma CDN do `Arsenal.ImagesUrl`. */
const ITEMS_URL = "https://cdn.corenetwork.dev/Itens/";

const entry = (id: string, name: string, price: number) => ({
	id,
	key: id,
	item: name,
	name,
	label: name,
	price,
	value: price,
	index: id,
	icon: id,
	image: `${ITEMS_URL}${id}.png`,
});

const section = (name: string, items: ReturnType<typeof entry>[]) => ({
	name,
	label: name,
	category: name,
	items,
});

export const ARSENAL_MOCK: IRawCategory[] = [
	section("Rifles", [
		entry("WEAPON_POLICE_CARBINERIFLE", "Carabina Tática", 1500),
		entry("WEAPON_POLICE_CARBINERIFLE_MK2", "Carabina Tática MK2", 1500),
		entry("WEAPON_POLICE_TACTICALRIFLE", "Fuzil Tático", 1500),
		entry("WEAPON_POLICE_SPECIALCARBINE", "Carabina Especial", 1500),
		entry("WEAPON_POLICE_SPECIALCARBINE_MK2", "Carabina Especial MK2", 1500),
		entry("WEAPON_POLICE_PUMPSHOTGUN_MK2", "Escopeta Tática MK2", 1200),
		entry("WEAPON_POLICE_SAWNOFFSHOTGUN", "Escopeta Cano Serrado", 1200),
	]),
	section("Subs", [
		entry("WEAPON_POLICE_SMG_MK2", "Submetralhadora MK2", 1000),
	]),
	section("Pistolas", [
		entry("WEAPON_POLICE_COMBATPISTOL", "Pistola de Combate", 500),
		entry("WEAPON_STUNGUN", "Arma de Choque", 725),
	]),
	section("Munições", [
		entry("BOX_WEAPON_POLICE_AMMO", "Caixa de Munição", 500),
	]),
	section("Utilitários", [
		entry("armour", "Colete Balístico", 500),
		entry("handcuff", "Algemas", 125),
		entry("gsrkit", "Kit de Resíduo de Disparo", 25),
		entry("gdtkit", "Kit de Teste de Drogas", 25),
		entry("barrier", "Barreira de Contenção", 25),
		entry("spikestrips", "Cinto de Espinhos", 275),
		entry("tacticalbackpack", "Mochila Tática", 1000),
		entry("radio", "Rádio", 975),
		entry("cellphone", "Celular", 725),
		entry("energetic", "Energético", 150),
		entry("WEAPON_NIGHTSTICK", "Cassetete", 150),
		entry("ATTACH_POLICE_FLASHLIGHT", "Lanterna Tática", 200),
		entry("ATTACH_POLICE_MAGAZINE", "Carregador Estendido", 200),
		entry("ATTACH_POLICE_SILENCER", "Supressor", 400),
		entry("ATTACH_POLICE_GRIP", "Empunhadura", 150),
		entry("ATTACH_POLICE_CROSSHAIR", "Mira Tática", 250),
	]),
];
