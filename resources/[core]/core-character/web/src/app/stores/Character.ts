import { CHARACTER_MAPPING } from "@app/constants/mappings";
import {
	type CharacterOption,
	type Gender,
	type OptionPath,
	type OptionsCharacter,
	defaultOptions,
} from "@app/constants/options";
import { create } from "zustand";

export interface HairModel {
	image: string;
	index: number;
}

export interface HairModels {
	Male: HairModel[];
	Female: HairModel[];
}

interface CharacterStore {
	options: OptionsCharacter;
	hairs: HairModels;
}

interface CharacterActions {
	setValue: (path: OptionPath, value: number | string) => void;
	setHairs: (hairs: Partial<HairModels>) => void;
	setGender: (gender: Gender) => void;

	/**
	 * Preenche nome e sobrenome. Personagem que volta ao criador ja tem
	 * identidade: os campos precisam abrir preenchidos, senao o jogador
	 * redigita o proprio nome.
	 */
	setIdentity: (name: string, lastname: string) => void;

	/**
	 * Carrega um personagem inteiro no formato plano do client.
	 * Valores fora da faixa da opcao sao presos no limite: um JSON de
	 * outro criador pode trazer escalas maiores que as nossas.
	 */
	applyCharacter: (character: Record<string, number>) => void;

	reset: () => void;
}

/**
 * A arvore e JSON puro, e o CEF do FiveM nem sempre traz
 * `structuredClone` — o round-trip funciona em qualquer versao.
 */
function clone<T>(value: T): T {
	return JSON.parse(JSON.stringify(value));
}

function cloneOptions(): OptionsCharacter {
	return clone(defaultOptions);
}

/** Le uma opcao pelo caminho, sem espalhar cast pelo resto do codigo. */
export function getOption(
	options: OptionsCharacter,
	[group, section, key]: OptionPath,
): CharacterOption {
	return (options as any)[group][section][key];
}

export const useCharacterStore = create<CharacterStore & CharacterActions>()(
	(set) => ({
		options: cloneOptions(),
		hairs: { Male: [], Female: [] },

		setValue: ([group, section, key], value) =>
			set((state) => {
				const groupData = (state.options as any)[group];
				const sectionData = groupData[section];

				return {
					options: {
						...state.options,
						[group]: {
							...groupData,
							[section]: {
								...sectionData,
								[key]: { ...sectionData[key], value },
							},
						},
					},
				};
			}),

		setHairs: (hairs) =>
			set((state) => ({ hairs: { ...state.hairs, ...hairs } })),

		setGender: (gender) =>
			set((state) => ({
				options: {
					...state.options,
					FACESETTINGS: {
						...state.options.FACESETTINGS,
						infos: {
							...state.options.FACESETTINGS.infos,
							gender: { kind: "gender", value: gender },
						},
					},
				},
			})),

		setIdentity: (name, lastname) =>
			set((state) => ({
				options: {
					...state.options,
					FACESETTINGS: {
						...state.options.FACESETTINGS,
						infos: {
							...state.options.FACESETTINGS.infos,
							name: { ...state.options.FACESETTINGS.infos.name, value: name },
							name2: {
								...state.options.FACESETTINGS.infos.name2,
								value: lastname,
							},
						},
					},
				},
			})),

		applyCharacter: (character) =>
			set((state) => {
				const options = clone(state.options);

				// Sem recorte contra a faixa do config: um cabelo ou sobreposição
				// de addon vive fora dela, e limitar aqui apagaria o visual do
				// jogador só por abrir a tela. A faixa vale para o slider, não
				// para o que já está gravado.
				for (const [key, path] of Object.entries(CHARACTER_MAPPING)) {
					const incoming = character[key];

					if (incoming === undefined || incoming === null) continue;

					getOption(options, path).value = Number(incoming);
				}

				return { options };
			}),

		reset: () => set({ options: cloneOptions() }),
	}),
);
