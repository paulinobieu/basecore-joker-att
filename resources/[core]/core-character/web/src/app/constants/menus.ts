import type { OptionGroupName } from "./options";

export type MenuIcon = "dna" | "face" | "barber" | "body";

export interface SubMenuItem {
	name: string;
	/** Secao dentro do grupo de opcoes. */
	index: string;
	/** Colunas que o botao ocupa na grade do submenu. */
	span?: string;
	/** Na barbearia, algumas secoes so expoem as cores. */
	colorsOnly?: boolean;
}

export interface MenuSection {
	name: string;
	icon: MenuIcon;
	group: OptionGroupName;
	grid: string;
	menus: SubMenuItem[];
	defaultMenu: string;
}

export const CREATOR_MENUS: Record<string, MenuSection> = {
	dna: {
		name: "DNA",
		icon: "dna",
		group: "FACESETTINGS",
		grid: "grid grid-cols-4",
		menus: [
			{ name: "INFORMAÇÕES", index: "infos", span: "col-start-1 col-end-3" },
			{ name: "PARENTESCO", index: "DNA", span: "col-start-3 col-end-5" },
		],
		defaultMenu: "infos",
	},
	face: {
		name: "ROSTO",
		icon: "face",
		group: "FACE",
		grid: "grid grid-cols-3",
		menus: [
			{ name: "FORMATO", index: "format" },
			{ name: "NARIZ", index: "nose" },
			{ name: "BOCA", index: "lips" },
			{ name: "OLHOS", index: "eyes" },
			{ name: "MAQUIAGEM", index: "make" },
			{ name: "BLUSH", index: "blush" },
		],
		defaultMenu: "format",
	},
	barber: {
		name: "BARBEIRO",
		icon: "barber",
		group: "BARBER",
		grid: "grid grid-cols-4",
		menus: [
			{ name: "CABELO", index: "hair", span: "col-start-1 col-end-3" },
			{ name: "BARBA", index: "beard", span: "col-start-3 col-end-5" },
			{ name: "SOBRANCELHA", index: "eyebrows", span: "col-span-2" },
			{ name: "PELOS CORPORAIS", index: "bodyHair", span: "col-span-2" },
		],
		defaultMenu: "hair",
	},
	body: {
		name: "CORPO",
		icon: "body",
		group: "BODY",
		grid: "grid grid-cols-3",
		menus: [{ name: "PELE", index: "person", span: "col-span-3" }],
		defaultMenu: "person",
	},
};

/**
 * A barbearia nao mexe em DNA nem no formato do rosto — so no que da
 * para trocar numa cadeira. A cor dos olhos entra quando o servidor
 * habilita `eyesBarber`.
 */
export function barberMenus(eyesBarber: boolean): Record<string, MenuSection> {
	return {
		barber: CREATOR_MENUS.barber,
		face: {
			name: "ROSTO",
			icon: "face",
			group: "FACE",
			grid: "grid grid-cols-4",
			menus: eyesBarber
				? [
						{ name: "BOCA", index: "lips", span: "col-start-1 col-end-3" },
						{ name: "MAQUIAGEM", index: "make", span: "col-start-3 col-end-5" },
						{ name: "BLUSH", index: "blush", span: "col-span-2" },
						{
							name: "OLHOS",
							index: "eyes",
							span: "col-span-2",
							colorsOnly: true,
						},
					]
				: [
						{ name: "BOCA", index: "lips", span: "col-start-1 col-end-3" },
						{ name: "MAQUIAGEM", index: "make", span: "col-start-3 col-end-6" },
						{ name: "BLUSH", index: "blush", span: "col-span-5" },
					],
			defaultMenu: "lips",
		},
		body: CREATOR_MENUS.body,
	};
}
