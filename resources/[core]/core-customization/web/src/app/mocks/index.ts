import { MESSAGES, type Screen } from "@app/constants/callbacks";
import { CLOTHES_CONFIG } from "@app/constants/clothes";
import type { Tattoo, ZoneKey } from "@app/constants/tattoos";
import type { OpenPayload } from "@app/hooks/useLayout";
import type { SetupPayload } from "@app/stores/Config";
import type {
	PedType,
	TextureCatalog,
	TextureVariant,
} from "@app/stores/Textures";
import type { DebugEvent } from "@app/utils/debugData";

/**
 * Dados de desenvolvimento no navegador. Nada disso é enviado no
 * bundle de produção além das constantes — o debugData só dispara
 * quando `isEnvBrowser()`.
 *
 * A loja emulada vem por query string: ?screen=clothes|tattoos
 */

const CLOTHES_BASE = "https://cdn.corenetwork.dev/CoreCustomization/Clothes";
const TATTOO_BASE = "https://cdn.corenetwork.dev/CoreCustomization/Tatoos";

/**
 * Em produção o catálogo é medido pelo client, vestindo os dois
 * modelos. Aqui os limites acompanham os do config padrão.
 */
function catalogFor(pedType: PedType): TextureCatalog {
	const catalog: TextureCatalog = {};

	for (const category of Object.values(CLOTHES_CONFIG)) {
		for (const [key, entry] of Object.entries(category)) {
			const variants: Record<string, TextureVariant> = {};
			const first = entry.negative ? -1 : 0;

			for (let index = first; index <= entry.infos.maxItem; index++) {
				variants[String(index)] = {
					image: `${CLOTHES_BASE}/${pedType}/${key}/${index}.jpg`,
					max: entry.infos.maxTex,
				};
			}

			catalog[key] = variants;
		}
	}

	return catalog;
}

const MOCK_TATTOOS: Tattoo[] = [
	"MP_Airraces_Tattoo_003_F",
	"MP_Bea_F_LArm_000",
	"MP_Airraces_Tattoo_002_F",
].map((name) => ({
	name,
	part: "mpairraces_overlays",
	link: `${TATTOO_BASE}/Female/${name}.png`,
}));

const ZONES: ZoneKey[] = [
	"head",
	"torso",
	"leftarm",
	"rightarm",
	"leftleg",
	"rightleg",
];

const mockSetup: SetupPayload = {
	colors: {
		primaryColor: "#df155b",
		secondaryColor: "#9e0e40",
		thirdyColor: "#660929",
	},
};

const mockOpen: OpenPayload = {
	screen: (new URLSearchParams(window.location.search).get("screen") ??
		"clothes") as Screen,
	pedType: "Male",
	admin: false,
	clothes: CLOTHES_CONFIG,
	tattoos: {
		available: Object.fromEntries(ZONES.map((zone) => [zone, MOCK_TATTOOS])),
		active: [MOCK_TATTOOS[0].name],
	},
};

export const mockEvents: DebugEvent<unknown>[] = [
	{ action: MESSAGES.setup, payload: mockSetup },
	{
		action: MESSAGES.textures,
		payload: { Male: catalogFor("Male"), Female: catalogFor("Female") },
	},
	{ action: MESSAGES.open, payload: mockOpen },
];
