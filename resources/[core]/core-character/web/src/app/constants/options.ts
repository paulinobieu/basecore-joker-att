import type { PaletteName } from "./palettes";

export type Gender = "mp_m_freemode_01" | "mp_f_freemode_01";

export interface LineageModel {
	index: string;
	name: string;
	image: string;
}

export interface SliderOption {
	kind: "slider";
	name: string;
	value: number;
	min: number;
	max: number;
	step: number;
	/** Rotulos nas pontas do trilho, quando a faixa e uma mistura. */
	helper?: [string, string];
}

export interface ColorOption {
	kind: "color";
	name: string;
	value: number;
	palette: PaletteName;
}

export interface LineageOption {
	kind: "lineage";
	name: string;
	value: number;
	side: "paternal" | "maternal";
	list: LineageModel[];
}

export interface HairOption {
	kind: "hair";
	name: string;
	value: number;
}

export interface TextOption {
	kind: "text";
	placeholder: string;
	info: string;
	value: string;
}

export interface GenderOption {
	kind: "gender";
	value: Gender;
}

export type CharacterOption =
	| SliderOption
	| ColorOption
	| LineageOption
	| HairOption
	| TextOption
	| GenderOption;

export interface OptionsCharacter {
	FACESETTINGS: {
		infos: { name: TextOption; name2: TextOption; gender: GenderOption };
		DNA: {
			patternId: LineageOption;
			maternalId: LineageOption;
			shapeMix: SliderOption;
			skinFirstID: SliderOption;
			skinSecondID: SliderOption;
			skinMix: SliderOption;
		};
	};
	FACE: {
		format: Record<string, SliderOption>;
		nose: Record<string, SliderOption>;
		lips: Record<string, SliderOption | ColorOption>;
		eyes: Record<string, SliderOption | ColorOption>;
		make: Record<string, SliderOption | ColorOption>;
		blush: Record<string, SliderOption | ColorOption>;
	};
	BARBER: {
		hair: Record<string, HairOption | SliderOption | ColorOption>;
		beard: Record<string, SliderOption | ColorOption>;
		eyebrows: Record<string, SliderOption | ColorOption>;
		bodyHair: Record<string, SliderOption | ColorOption>;
	};
	BODY: {
		person: Record<string, SliderOption>;
	};
}

export type OptionGroupName = keyof OptionsCharacter;

/** Caminho ate uma opcao: grupo, secao e chave. */
export type OptionPath = [OptionGroupName, string, string];

export const PATERNAL_MODELS: LineageModel[] = [
	{ index: "0", name: "Benjamin", image: "paterno/0.png" },
	{ index: "1", name: "Daniel", image: "paterno/1.png" },
	{ index: "2", name: "Joshua", image: "paterno/2.png" },
	{ index: "3", name: "Noah", image: "paterno/3.png" },
	{ index: "4", name: "Andrew", image: "paterno/4.png" },
	{ index: "5", name: "Joan", image: "paterno/5.png" },
	{ index: "6", name: "Alex", image: "paterno/6.png" },
	{ index: "7", name: "Isaac", image: "paterno/7.png" },
	{ index: "8", name: "Evan", image: "paterno/8.png" },
	{ index: "9", name: "Ethan", image: "paterno/9.png" },
	{ index: "10", name: "Vincent", image: "paterno/10.png" },
	{ index: "11", name: "Angel", image: "paterno/11.png" },
	{ index: "12", name: "Diego", image: "paterno/12.png" },
	{ index: "13", name: "Adrian", image: "paterno/13.png" },
	{ index: "14", name: "Gabriel", image: "paterno/14.png" },
	{ index: "15", name: "Michael", image: "paterno/15.png" },
	{ index: "16", name: "Santiago", image: "paterno/16.png" },
	{ index: "17", name: "Kevin", image: "paterno/17.png" },
	{ index: "18", name: "Louis", image: "paterno/18.png" },
	{ index: "19", name: "Samuel", image: "paterno/19.png" },
	{ index: "20", name: "Anthony", image: "paterno/20.png" },
	{ index: "42", name: "John", image: "paterno/42.png" },
	{ index: "43", name: "Niko", image: "paterno/43.png" },
	{ index: "44", name: "Claude", image: "paterno/44.png" },
];

export const MATERNAL_MODELS: LineageModel[] = [
	{ index: "21", name: "Hannah", image: "materno/21.png" },
	{ index: "22", name: "Audrey", image: "materno/22.png" },
	{ index: "23", name: "Jasmine", image: "materno/23.png" },
	{ index: "24", name: "Giselle", image: "materno/24.png" },
	{ index: "25", name: "Amelia", image: "materno/25.png" },
	{ index: "26", name: "Isabella", image: "materno/26.png" },
	{ index: "27", name: "Zoe", image: "materno/27.png" },
	{ index: "28", name: "Ava", image: "materno/28.png" },
	{ index: "29", name: "Camilla", image: "materno/29.png" },
	{ index: "30", name: "Violet", image: "materno/30.png" },
	{ index: "31", name: "Sophia", image: "materno/31.png" },
	{ index: "32", name: "Eveline", image: "materno/32.png" },
	{ index: "33", name: "Nicole", image: "materno/33.png" },
	{ index: "34", name: "Ashley", image: "materno/34.png" },
	{ index: "35", name: "Grace", image: "materno/35.png" },
	{ index: "36", name: "Brianna", image: "materno/36.png" },
	{ index: "37", name: "Natalie", image: "materno/37.png" },
	{ index: "38", name: "Olivia", image: "materno/38.png" },
	{ index: "39", name: "Elizabeth", image: "materno/39.png" },
	{ index: "40", name: "Charlotte", image: "materno/40.png" },
	{ index: "41", name: "Emma", image: "materno/41.png" },
	{ index: "45", name: "Misty", image: "materno/45.png" },
];

/** Lista completa, usada pelo botao "Mostrar todos" da heranca. */
export const ALL_LINEAGE_MODELS: LineageModel[] = [
	...PATERNAL_MODELS,
	...MATERNAL_MODELS,
].sort((a, b) => Number(a.index) - Number(b.index));

export const defaultOptions: OptionsCharacter = {
	FACESETTINGS: {
		infos: {
			name: {
				kind: "text",
				placeholder: "Digite um nome",
				info: "Nome do seu personagem",
				value: "",
			},
			name2: {
				kind: "text",
				placeholder: "Digite um sobrenome",
				info: "Sobrenome do seu personagem",
				value: "",
			},
			gender: { kind: "gender", value: "mp_m_freemode_01" },
		},

		DNA: {
			patternId: {
				kind: "lineage",
				name: "PATERNO",
				value: 0,
				side: "paternal",
				list: PATERNAL_MODELS,
			},
			maternalId: {
				kind: "lineage",
				name: "MATERNO",
				value: 21,
				side: "maternal",
				list: MATERNAL_MODELS,
			},
			shapeMix: {
				kind: "slider",
				name: "SEMELHANÇA",
				value: 0.5,
				min: 0,
				max: 1,
				step: 0.01,
				helper: ["PATERNO", "MATERNO"],
			},
			skinFirstID: {
				kind: "slider",
				name: "COR DO PAI",
				value: 0,
				min: 0,
				max: 45,
				step: 1,
			},
			skinSecondID: {
				kind: "slider",
				name: "COR DA MÃE",
				value: 0,
				min: 0,
				max: 45,
				step: 1,
			},
			skinMix: {
				kind: "slider",
				name: "TOM DE PELE",
				value: 0.8,
				min: 0,
				max: 1,
				step: 0.01,
				helper: ["PATERNO", "MATERNO"],
			},
		},
	},

	FACE: {
		format: {
			cheekboneHeight: {
				kind: "slider",
				name: "Altura da Bochechas",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			cheekboneWidth: {
				kind: "slider",
				name: "Largura da Bochechas",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			cheeksWidth: {
				kind: "slider",
				name: "Tamanho da bochecha",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},

			chinLength: {
				kind: "slider",
				name: "Comprimento do queixo",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			chinPosition: {
				kind: "slider",
				name: "Posição do queixo",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			chinWidth: {
				kind: "slider",
				name: "Largura do queixo",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			chinShape: {
				kind: "slider",
				name: "Formato do queixo",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},

			jawWidth: {
				kind: "slider",
				name: "Largura da mandíbula",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			jawHeight: {
				kind: "slider",
				name: "Altura da mandíbula",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},

			neckWidth: {
				kind: "slider",
				name: "Tamanho do pescoço",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
		},

		nose: {
			noseLength: {
				kind: "slider",
				name: "Tamanho nariz",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			noseHeight: {
				kind: "slider",
				name: "Altura nariz",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			noseWidth: {
				kind: "slider",
				name: "Comprimento nariz",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			noseBridge: {
				kind: "slider",
				name: "Ponte nasal",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			noseTip: {
				kind: "slider",
				name: "Ponta nariz",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			noseShift: {
				kind: "slider",
				name: "Deslocamento nariz",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
		},

		lips: {
			lips: {
				kind: "slider",
				name: "Labios",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			lipstickModel: {
				kind: "slider",
				name: "Batom",
				value: -1,
				min: -1,
				max: 9,
				step: 1,
			},
			lipstickIntensity: {
				kind: "slider",
				name: "Intensidade do Batom",
				value: 0.99,
				min: 0,
				max: 0.99,
				step: 0.01,
			},
			lipstickColor: {
				kind: "color",
				name: "Cor do Batom",
				value: 0,
				palette: "colors2",
			},
		},

		eyes: {
			eyesOpening: {
				kind: "slider",
				name: "Abertura dos Olhos",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			eyesColor: {
				kind: "color",
				name: "Cor dos Olhos",
				value: 0,
				palette: "colors3",
			},
		},

		make: {
			makeupModel: {
				kind: "slider",
				name: "Maquiagem",
				value: -1,
				min: -1,
				max: 71,
				step: 1,
			},
			makeupIntensity: {
				kind: "slider",
				name: "Intensidade da Maquiagem",
				value: 0.99,
				min: 0,
				max: 0.99,
				step: 0.01,
			},
			makeupColor: {
				kind: "color",
				name: "Cor da Maquiagem",
				value: 0,
				palette: "colors",
			},
		},

		blush: {
			blushModel: {
				kind: "slider",
				name: "Blush",
				value: -1,
				min: -1,
				max: 32,
				step: 1,
			},
			blushIntensity: {
				kind: "slider",
				name: "Intensidade do Blush",
				value: 0.99,
				min: 0,
				max: 0.99,
				step: 0.01,
			},
			blushColor: {
				kind: "color",
				name: "Cor do Blush",
				value: 0,
				palette: "colors2",
			},
		},
	},

	BARBER: {
		hair: {
			hairModel: { kind: "hair", name: "Cabelo", value: 0 },
			hairOverlay: {
				kind: "slider",
				name: "Sobreposição do Cabelo",
				value: 0,
				min: 0,
				max: 72,
				step: 1,
			},
			firstHairColor: {
				kind: "color",
				name: "Cor do Cabelo",
				value: 3,
				palette: "colors",
			},
			secondHairColor: {
				kind: "color",
				name: "Cor das Mechas",
				value: 6,
				palette: "colors",
			},
		},

		beard: {
			beardIntensity: {
				kind: "slider",
				name: "Intensidade da Barba",
				value: 0.99,
				min: 0,
				max: 0.99,
				step: 0.01,
			},
			beardModel: {
				kind: "slider",
				name: "Barba",
				value: -1,
				min: -1,
				max: 28,
				step: 1,
			},
			beardColor: {
				kind: "color",
				name: "Cor da Barba",
				value: 0,
				palette: "colors",
			},
		},

		eyebrows: {
			eyebrowsModel: {
				kind: "slider",
				name: "Sobrancelhas",
				value: 0,
				min: 0,
				max: 33,
				step: 1,
			},
			eyebrowsIntensity: {
				kind: "slider",
				name: "Intensidade das Sobrancelhas",
				value: 0.99,
				min: 0,
				max: 0.99,
				step: 0.01,
			},
			eyebrowsHeight: {
				kind: "slider",
				name: "Altura das Sobrancelhas",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			eyebrowsWidth: {
				kind: "slider",
				name: "Profundidade das Sobrancelhas",
				value: 0,
				min: -0.99,
				max: 0.99,
				step: 0.01,
			},
			eyebrowsColor: {
				kind: "color",
				name: "Cor das Sobrancelhas",
				value: 0,
				palette: "colors",
			},
		},

		bodyHair: {
			chestModel: {
				kind: "slider",
				name: "Pelos corporais",
				value: -1,
				min: -1,
				max: 16,
				step: 1,
			},
			chestOpacity: {
				kind: "slider",
				name: "Intensidade dos Pelos",
				value: 0.99,
				min: 0,
				max: 0.99,
				step: 0.01,
			},
			chestColor: {
				kind: "color",
				name: "Cor dos Pelos",
				value: 0,
				palette: "colors",
			},
		},
	},

	BODY: {
		person: {
			complexionModel: {
				kind: "slider",
				name: "Aspecto",
				value: -1,
				min: -1,
				max: 11,
				step: 1,
			},
			sundamageModel: {
				kind: "slider",
				name: "Danos solares",
				value: -1,
				min: -1,
				max: 10,
				step: 1,
			},

			frecklesModel: {
				kind: "slider",
				name: "Sardas",
				value: -1,
				min: -1,
				max: 17,
				step: 1,
			},
			frecklesIntensity: {
				kind: "slider",
				name: "Intensidade das Sardas",
				value: 0.99,
				min: 0,
				max: 0.99,
				step: 0.01,
			},

			ageingModel: {
				kind: "slider",
				name: "Rugas",
				value: -1,
				min: -1,
				max: 14,
				step: 1,
			},
			blemishesModel: {
				kind: "slider",
				name: "Manchas",
				value: -1,
				min: -1,
				max: 23,
				step: 1,
			},
		},
	},
};

/** Opcao de cor dos olhos, injetada na barbearia quando habilitada. */
export const EYES_COLOR_OPTION: ColorOption = {
	kind: "color",
	name: "Cor dos Olhos",
	value: 0,
	palette: "colors3",
};
