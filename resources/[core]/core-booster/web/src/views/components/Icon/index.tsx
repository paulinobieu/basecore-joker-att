import {
	IconBolt,
	IconBox,
	IconCar,
	IconCash,
	IconCrown,
	IconGift,
	IconRocket,
	IconShield,
	IconSparkles,
	IconStar,
	IconTag,
} from "@tabler/icons-react";

/**
 * Catalogo fixo de icones. A config manda a chave, nunca um componente, entao
 * uma chave desconhecida cai no generico em vez de quebrar o card inteiro.
 */
const icons = {
	rocket: IconRocket,
	bolt: IconBolt,
	tag: IconTag,
	gift: IconGift,
	crown: IconCrown,
	star: IconStar,
	sparkles: IconSparkles,
	money: IconCash,
	vehicle: IconCar,
	box: IconBox,
	shield: IconShield,
} as const;

interface IconProps {
	icon?: string;
	className?: string;
}

export function Icon({ icon, className }: IconProps) {
	const Glyph = icons[icon as keyof typeof icons] ?? IconGift;

	return <Glyph stroke={2} className={className} />;
}
