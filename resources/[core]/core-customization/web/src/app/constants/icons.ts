import {
	IconBackpack,
	IconCircleDotted,
	IconDeviceWatch,
	IconEar,
	IconEyeglass,
	IconFaceMask,
	IconHandStop,
	IconShirt,
	IconShoe,
	IconSticker,
	IconUser,
} from "@tabler/icons-react";
import {
	IconArm,
	IconCoat,
	IconHat,
	IconLeg,
	IconNecklace,
	IconPants,
	IconTorso,
	IconVest,
} from "@views/components/icons";
import type { ComponentType } from "react";

/** Cobre os ícones do Tabler e os desenhados aqui. */
export type IconComponent = ComponentType<{
	size?: number | string;
	stroke?: number | string;
	className?: string;
}>;

/**
 * Os nomes de ícone vêm do client, então o mapa é chaveado pelas
 * mesmas strings que já chegam no catálogo ("chapeu", "oculos", ...).
 * Trocar o desenho não exige mexer no payload.
 */
export const itemIcons: Record<string, IconComponent> = {
	orelha: IconEar,
	chapeu: IconHat,
	mascara: IconFaceMask,
	oculos: IconEyeglass,
	acessorios: IconNecklace,

	camisas: IconShirt,
	jaqueta: IconCoat,
	coletes: IconVest,
	maos: IconHandStop,
	relogio: IconDeviceWatch,
	// Nenhum pack tem bracelete; círculo de contas é a metáfora mais
	// próxima de uma pulseira.
	bracelete: IconCircleDotted,
	mochila: IconBackpack,
	adesivo: IconSticker,

	calca: IconPants,
	sapato: IconShoe,
};

/** Fallback para qualquer nome que o client mande e não esteja mapeado. */
export const fallbackItemIcon: IconComponent = IconShirt;

/**
 * Zonas de tatuagem. Braço e perna usam o mesmo desenho espelhado para
 * o lado esquerdo — dois ícones no lugar de quatro, e a diferença fica
 * legível de imediato.
 */
export const tattooZoneIcons: Record<
	string,
	{ icon: IconComponent; flip: boolean }
> = {
	head: { icon: IconUser, flip: false },
	chest: { icon: IconTorso, flip: false },
	"arm-right": { icon: IconArm, flip: false },
	"arm-left": { icon: IconArm, flip: true },
	"leg-right": { icon: IconLeg, flip: false },
	"leg-left": { icon: IconLeg, flip: true },
};

export const fallbackZoneIcon = { icon: IconUser, flip: false };
