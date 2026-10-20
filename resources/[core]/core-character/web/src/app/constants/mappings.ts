import type { OptionPath } from "./options";

/**
 * Ponte entre o JSON plano do personagem (como o client guarda) e a
 * arvore de opcoes da interface.
 *
 * Cada grupo corresponde a um callback de preview: o que muda o rosto
 * nao precisa reenviar pele nem cabelo.
 */

export const FACE_MAPPING: Record<string, OptionPath> = {
	eyesColor: ["FACE", "eyes", "eyesColor"],
	eyesOpening: ["FACE", "eyes", "eyesOpening"],

	eyebrowsHeight: ["BARBER", "eyebrows", "eyebrowsHeight"],
	eyebrowsWidth: ["BARBER", "eyebrows", "eyebrowsWidth"],

	noseWidth: ["FACE", "nose", "noseWidth"],
	noseHeight: ["FACE", "nose", "noseHeight"],
	noseLength: ["FACE", "nose", "noseLength"],
	noseBridge: ["FACE", "nose", "noseBridge"],
	noseTip: ["FACE", "nose", "noseTip"],
	noseShift: ["FACE", "nose", "noseShift"],

	cheekboneHeight: ["FACE", "format", "cheekboneHeight"],
	cheekboneWidth: ["FACE", "format", "cheekboneWidth"],
	cheeksWidth: ["FACE", "format", "cheeksWidth"],

	lips: ["FACE", "lips", "lips"],

	jawWidth: ["FACE", "format", "jawWidth"],
	jawHeight: ["FACE", "format", "jawHeight"],

	chinLength: ["FACE", "format", "chinLength"],
	chinPosition: ["FACE", "format", "chinPosition"],
	chinWidth: ["FACE", "format", "chinWidth"],
	chinShape: ["FACE", "format", "chinShape"],

	neckWidth: ["FACE", "format", "neckWidth"],
};

export const SKIN_MAPPING: Record<string, OptionPath> = {
	fathersID: ["FACESETTINGS", "DNA", "patternId"],
	mothersID: ["FACESETTINGS", "DNA", "maternalId"],

	skinFirstID: ["FACESETTINGS", "DNA", "skinFirstID"],
	skinSecondID: ["FACESETTINGS", "DNA", "skinSecondID"],
	skinMix: ["FACESETTINGS", "DNA", "skinMix"],
	shapeMix: ["FACESETTINGS", "DNA", "shapeMix"],
};

export const HEAD_MAPPING: Record<string, OptionPath> = {
	hairModel: ["BARBER", "hair", "hairModel"],
	hairOverlay: ["BARBER", "hair", "hairOverlay"],
	firstHairColor: ["BARBER", "hair", "firstHairColor"],
	secondHairColor: ["BARBER", "hair", "secondHairColor"],

	eyebrowsModel: ["BARBER", "eyebrows", "eyebrowsModel"],
	eyebrowsIntensity: ["BARBER", "eyebrows", "eyebrowsIntensity"],
	eyebrowsColor: ["BARBER", "eyebrows", "eyebrowsColor"],

	beardModel: ["BARBER", "beard", "beardModel"],
	beardIntensity: ["BARBER", "beard", "beardIntensity"],
	beardColor: ["BARBER", "beard", "beardColor"],

	chestModel: ["BARBER", "bodyHair", "chestModel"],
	chestColor: ["BARBER", "bodyHair", "chestColor"],
	chestOpacity: ["BARBER", "bodyHair", "chestOpacity"],

	blemishesModel: ["BODY", "person", "blemishesModel"],
	ageingModel: ["BODY", "person", "ageingModel"],
	complexionModel: ["BODY", "person", "complexionModel"],
	sundamageModel: ["BODY", "person", "sundamageModel"],

	frecklesModel: ["BODY", "person", "frecklesModel"],
	frecklesIntensity: ["BODY", "person", "frecklesIntensity"],

	blushModel: ["FACE", "blush", "blushModel"],
	blushIntensity: ["FACE", "blush", "blushIntensity"],
	blushColor: ["FACE", "blush", "blushColor"],

	lipstickModel: ["FACE", "lips", "lipstickModel"],
	lipstickIntensity: ["FACE", "lips", "lipstickIntensity"],
	lipstickColor: ["FACE", "lips", "lipstickColor"],

	makeupModel: ["FACE", "make", "makeupModel"],
	makeupIntensity: ["FACE", "make", "makeupIntensity"],
	makeupColor: ["FACE", "make", "makeupColor"],
};

/** Uniao dos tres grupos — usada ao carregar um personagem inteiro. */
export const CHARACTER_MAPPING: Record<string, OptionPath> = {
	...FACE_MAPPING,
	...SKIN_MAPPING,
	...HEAD_MAPPING,
};
