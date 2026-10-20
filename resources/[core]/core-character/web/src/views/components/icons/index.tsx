import type { ReactNode } from "react";

interface IconProps {
	size?: number | string;
	stroke?: number | string;
	className?: string;
}

/**
 * Ícones que o Tabler não cobre. Os traçados são os mesmos do Iconify
 * que a referência importava (mingcute e iconoir), copiados para cá em
 * vez de virem por plugin de build.
 *
 * `stroke-width`, `stroke-linecap` e `stroke-linejoin` são propriedades
 * herdadas em SVG: ficam no <svg> e valem para todos os traçados. É o
 * que alinha os dois packs ao desenho do Tabler — o iconoir usa traço
 * 1.5 e o mingcute não arredonda as pontas.
 */
function Icon({
	size = 24,
	stroke = 2,
	className,
	children,
}: IconProps & { children: ReactNode }) {
	return (
		<svg
			width={size}
			height={size}
			viewBox="0 0 24 24"
			fill="none"
			stroke="currentColor"
			strokeWidth={stroke}
			strokeLinecap="round"
			strokeLinejoin="round"
			className={className}
			xmlns="http://www.w3.org/2000/svg"
		>
			{children}
		</svg>
	);
}

/** Cabelo — o Tabler não tem (e o Phosphor só tem secador). (mingcute/hair-line) */
export function IconHair(props: IconProps) {
	return (
		<Icon {...props}>
			<path d="m8.828 18.344l-.552 1.103a1 1 0 0 1-.894.553H6a2 2 0 0 1-2-2v-6a8 8 0 1 1 16 0v6a2 2 0 0 1-2 2h-1.382a1 1 0 0 1-.894-.553l-.552-1.103M12 9.664a5.5 5.5 0 0 1-4.676 2.333A6.5 6.5 0 0 0 7 14c0 3.818 3.125 6 5 6s5-2.182 5-6c0-.68-.115-1.358-.324-2.003L16.5 12A5.5 5.5 0 0 1 12 9.663Z" />
		</Icon>
	);
}

/** Calças — o Tabler não tem. (iconoir/pants) */
export function IconPants(props: IconProps) {
	return (
		<Icon {...props}>
			<path d="M12 19h4.436a.6.6 0 0 0 .6-.563l.924-14.8A.6.6 0 0 0 17.361 3H6.634a.6.6 0 0 0-.599.633l.934 16.8a.6.6 0 0 0 .599.567H11.4a.6.6 0 0 0 .6-.6V8" />
		</Icon>
	);
}
