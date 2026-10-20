/**
 * Importacao de personagem vindo de outro servidor.
 *
 * Cada criador nomeia os mesmos atributos de um jeito; o mapa traduz
 * as chaves de origem para as do core-character. `null` marca um
 * atributo que existe la e nao tem equivalente aqui — e descartado
 * sem invalidar o JSON.
 */

type ForeignMap = Record<string, string | null>;

const CORE: ForeignMap = {
	chestOpacity: "chestOpacity",
	complexionModel: "complexionModel",
	chinPosition: "chinPosition",
	cheeksWidth: "cheeksWidth",
	chinWidth: "chinWidth",
	makeupColor: "makeupColor",
	eyebrowsModel: "eyebrowsModel",
	sundamageModel: "sundamageModel",
	lipstickModel: "lipstickModel",
	lipstickColor: "lipstickColor",
	lipstickIntensity: "lipstickIntensity",
	lips: "lips",

	eyebrowsIntensity: "eyebrowsIntensity",
	skinSecondID: "skinSecondID",
	fathersID: "fathersID",
	frecklesModel: "frecklesModel",
	hairOverlay: "hairOverlay",

	blemishesModel: "blemishesModel",
	makeupModel: "makeupModel",
	neckWidth: "neckWidth",
	firstHairColor: "firstHairColor",
	chinLength: "chinLength",
	beardColor: "beardColor",
	jawHeight: "jawHeight",

	noseBridge: "noseBridge",
	noseTip: "noseTip",
	noseLength: "noseLength",
	noseHeight: "noseHeight",
	noseShift: "noseShift",

	hairModel: "hairModel",
	blushColor: "blushColor",
	eyebrowsWidth: "eyebrowsWidth",
	beardIntensity: "beardIntensity",
	blushModel: "blushModel",
	chestColor: "chestColor",
	chestModel: "chestModel",
	jawWidth: "jawWidth",
	shapeMix: "shapeMix",
	makeupIntensity: "makeupIntensity",
	chinShape: "chinShape",
	frecklesIntensity: "frecklesIntensity",
	skinFirstID: "skinFirstID",
	cheekboneHeight: "cheekboneHeight",
	secondHairColor: "secondHairColor",
	blushIntensity: "blushIntensity",
	eyebrowsColor: "eyebrowsColor",
	eyebrowsHeight: "eyebrowsHeight",
	skinMix: "skinMix",
	beardModel: "beardModel",
	ageingModel: "ageingModel",
	noseWidth: "noseWidth",
	eyesColor: "eyesColor",
	mothersID: "mothersID",
	eyesOpening: "eyesOpening",
	cheekboneWidth: "cheekboneWidth",
};

const NATION: ForeignMap = {
	gender: null,
	tattoos: null,

	"chestHair-opacity": "chestOpacity",
	thirdMix: null,
	complexion: "complexionModel",
	chinBoneLowering: "chinPosition",
	cheeksWidth: "cheeksWidth",
	"complexion-color": null,
	chinBoneWidth: "chinWidth",
	"makeup-color": "makeupColor",
	eyebrows: "eyebrowsModel",
	"freckles-color": null,
	sunDamage: "sundamageModel",
	lipstick: "lipstickModel",
	"lipstick-color": "lipstickColor",
	"lipstick-opacity": "lipstickIntensity",
	lipsThickness: "lips",

	"eyebrows-opacity": "eyebrowsIntensity",
	skinSecond: "skinSecondID",
	shapeFirst: "fathersID",
	freckles: "frecklesModel",
	overlay: "hairOverlay",

	addBodyBlemishes: null,
	"addBodyBlemishes-color": null,
	"addBodyBlemishes-opacity": null,

	bodyBlemishes: null,
	"bodyBlemishes-color": null,
	"bodyBlemishes-opacity": null,
	blemishes: "blemishesModel",
	"blemishes-color": null,
	"blemishes-opacity": null,
	makeup: "makeupModel",
	"sunDamage-opacity": null,
	"complexion-opacity": null,
	neckThickness: "neckWidth",
	"hair-color": "firstHairColor",
	chinBoneLength: "chinLength",
	"facialHair-color": "beardColor",
	"sunDamage-color": null,
	jawBoneBackLength: "jawHeight",

	noseBoneHigh: "noseBridge",
	nosePeakLowering: "noseTip",
	nosePeakLength: "noseLength",
	nosePeakHeight: "noseHeight",
	noseBoneTwist: "noseShift",

	hair: "hairModel",
	"blush-color": "blushColor",
	eyeBrownForward: "eyebrowsWidth",
	"facialHair-opacity": "beardIntensity",
	blush: "blushModel",
	"chestHair-color": "chestColor",
	chestHair: "chestModel",
	jawBoneWidth: "jawWidth",
	skinThird: null,
	"ageing-opacity": null,
	shapeMix: "shapeMix",
	"makeup-opacity": "makeupIntensity",
	chinHole: "chinShape",
	"freckles-opacity": "frecklesIntensity",
	skinFirst: "skinFirstID",
	cheeksBoneHigh: "cheekboneHeight",
	"hair-highlightcolor": "secondHairColor",
	"blush-opacity": "blushIntensity",
	shapeThird: null,
	"eyebrows-color": "eyebrowsColor",
	eyeBrownHigh: "eyebrowsHeight",
	skinMix: "skinMix",
	facialHair: "beardModel",
	ageing: "ageingModel",
	noseWidth: "noseWidth",
	eyes: "eyesColor",
	"ageing-color": null,
	shapeSecond: "mothersID",
	eyesOpenning: "eyesOpening",
	cheeksBoneWidth: "cheekboneWidth",
};

/**
 * O Guardian Character usa exatamente o mesmo formato do core, entao
 * aponta para o mesmo mapa em vez de duplicar as ~70 chaves.
 */
export const IMPORT_SOURCES = {
	Core: CORE,
	Guardian: CORE,
	Nation: NATION,
} as const;

export type ImportSource = keyof typeof IMPORT_SOURCES;

export const IMPORT_OPTIONS: { index: ImportSource; name: string }[] = [
	{ index: "Core", name: "Core Character" },
	{ index: "Guardian", name: "Guardian Character" },
	{ index: "Nation", name: "Nation Character" },
];

/**
 * Traduz o JSON de origem para as chaves do core-character.
 *
 * Uma chave desconhecida significa que o JSON nao e daquele criador —
 * importar assim aplicaria valores em atributos errados, entao para.
 */
export function convertCharacter(
	source: Record<string, unknown>,
	type: ImportSource,
): Record<string, number> {
	const map = IMPORT_SOURCES[type];
	const converted: Record<string, number> = {};

	for (const [key, value] of Object.entries(source)) {
		const target = map[key];

		if (target === undefined) {
			throw new Error(`Esse JSON não é de uma criação de personagem ${type}!`);
		}

		if (target === null) continue;

		converted[target] = Number(value);
	}

	return converted;
}
