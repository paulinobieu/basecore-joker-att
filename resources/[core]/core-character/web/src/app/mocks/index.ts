import { MESSAGES, type Screen } from "@app/constants/callbacks";
import type { HairModels } from "@app/stores/Character";
import type { CharacterSlot, SpawnLocation } from "@app/stores/Screen";
import type { DebugEvent } from "@app/utils/debugData";

/**
 * Dados de desenvolvimento no navegador. Nada disso e enviado no
 * bundle de producao alem das constantes — o debugData so dispara
 * quando `isEnvBrowser()`.
 *
 * A tela emulada vem por query string: ?screen=character|select|spawn|barber
 */

const HAIR_BASE = "https://cdn.corenetwork.dev/CoreCharacter/Hair";

function hairRange(gender: "Male" | "Female", total: number) {
	return Array.from({ length: total }, (_, index) => ({
		image: `${HAIR_BASE}/${gender}/${index}.png`,
		index,
	}));
}

// Em producao a lista vem do client (GlobalState). Aqui os limites
// acompanham o que existe publicado no pacote de imagens.
export const mockHairs: HairModels = {
	Male: hairRange("Male", 286),
	Female: hairRange("Female", 451),
};

export const mockCharacter: Record<string, number> = {
	chestOpacity: 1,
	cheekboneWidth: -0.92,
	makeupColor: -1,
	lipstickColor: 2,
	blushIntensity: 1,
	lipstickModel: 1,
	chinShape: 0,
	eyebrowsIntensity: 1,
	hairOverlay: 0,
	lipstickIntensity: 0.4,
	blushColor: 0,
	shapeMix: 0,
	skinMix: 0,
	noseShift: 0,
	noseBridge: 0.34,
	chinWidth: 0.17,
	blemishesModel: -1,
	eyesColor: 2,
	jawWidth: -1,
	jawHeight: -1,
	fathersID: 45,
	chinPosition: -0.3,
	hairModel: 94,
	noseLength: 0.46,
	noseTip: -0.34,
	beardIntensity: 1,
	noseWidth: -0.54,
	chinLength: 0.02,
	firstHairColor: 29,
	eyebrowsHeight: 0,
	blushModel: -1,
	lips: -0.72,
	skinSecondID: 0,
	chestColor: 0,
	eyesOpening: 0,
	chestModel: -1,
	beardModel: -1,
	secondHairColor: 29,
	sundamageModel: -1,
	beardColor: 0,
	noseHeight: 0,
	eyebrowsModel: 4,
	neckWidth: -1,
	complexionModel: -1,
	mothersID: 7,
	makeupIntensity: 1,
	skinFirstID: 21,
	makeupModel: 0,
	eyebrowsWidth: -0.37,
	cheekboneHeight: -0.64,
	ageingModel: -1,
	cheeksWidth: 0.5,
	frecklesIntensity: 1,
	frecklesModel: -1,
};

const slotInfos = [
	{ title: "BANCO", value: "R$27.000,00" },
	{ title: "Nº DE CASAS", value: "2" },
	{ title: "Nº DE GARAGENS", value: "4" },
	{ title: "TEMPO DE JOGO", value: "2H 35MIN" },
];

export const mockSlots: CharacterSlot[] = [
	{ name: "Vinicius Hernández", id: "457549", infos: slotInfos },
	{ name: "Lucas Hernández", id: "46789", infos: slotInfos },
	{ createPerson: true },
	{ createPerson: false },
	{ createPerson: false },
	{ createPerson: false },
	{ createPerson: false },
	{ createPerson: false },
];

export const mockLocations: SpawnLocation[] = Array.from(
	{ length: 9 },
	(_, index) => ({
		hash: `spawn_${index}`,
		name: ["Centro", "Praia", "Montanha"][index % 3],
		text: "Los Santos",
		image: "",
		x: 0,
		y: 0,
		z: 0,
	}),
);

export const mockSetup = {
	colors: {
		primaryColor: "#df155b",
		secondaryColor: "#9e0e40",
		thirdyColor: "#660929",
	},
	paths: { face: "https://cdn.corenetwork.dev/CoreCharacter/Faces/" },
	config: { eyesBarber: true, buyPerson: true, buyPersonPrice: 100000 },
};

export function mockOpen(screen: Screen) {
	switch (screen) {
		case "select":
			return { screen, slots: mockSlots };
		case "spawn":
			return { screen, locations: mockLocations };
		case "barber":
			return {
				screen,
				hairs: mockHairs,
				gender: "mp_f_freemode_01",
				character: mockCharacter,
				admin: false,
			};
		default:
			return { screen, hairs: mockHairs, gender: "mp_m_freemode_01" };
	}
}

export function mockScreenFromQuery(): Screen {
	const screen = new URLSearchParams(window.location.search).get("screen");
	const allowed: Screen[] = ["character", "select", "spawn", "barber"];

	return allowed.includes(screen as Screen) ? (screen as Screen) : "character";
}

export const mockEvents: DebugEvent<unknown>[] = [
	{ action: MESSAGES.setup, payload: mockSetup },
	{ action: MESSAGES.open, payload: mockOpen(mockScreenFromQuery()) },
];
