import type { ReactNode } from "react";

interface IconProps {
	size?: number | string;
	stroke?: number | string;
	className?: string;
}

/**
 * Ícones que o Tabler não cobre. Os traçados são os mesmos do Iconify
 * que a referência importava (mingcute, hugeicons e iconoir), copiados
 * para cá em vez de virem por plugin de build.
 *
 * `stroke-width`, `stroke-linecap` e `stroke-linejoin` são propriedades
 * herdadas em SVG: ficam no <svg> e valem para todos os traçados. É o
 * que alinha os três packs ao desenho do Tabler — o iconoir usa traço
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

/** Chapéu — o Tabler só tem chef-hat. (mingcute/hat-line) */
export function IconHat(props: IconProps) {
	return (
		<Icon {...props}>
			<path d="m5.93 14.52l.802-6.386a2 2 0 0 1 2.377-1.712l2.499.5a2 2 0 0 0 .784 0l2.5-.5a2 2 0 0 1 2.376 1.712l.802 6.386M21 16c0 1.105-4.03 2-9 2s-9-.895-9-2s4.03-2 9-2s9 .895 9 2" />
		</Icon>
	);
}

/** Correntes e acessórios de pescoço. (hugeicons/necklace) */
export function IconNecklace(props: IconProps) {
	return (
		<Icon {...props}>
			<path d="m10.542 12l.39-3.124c.091-.728.422-.876 1.11-.876s1.018.148 1.11.876l.39 3.124" />
			<path d="M8.284 12.612c1.336-.812 2.501-.485 3.201.036c.287.214.43.32.515.32s.228-.106.515-.32c.7-.52 1.865-.848 3.2-.036c1.753 1.065 2.15 4.578-1.892 7.542c-.77.564-1.155.846-1.823.846s-1.053-.282-1.822-.846c-4.042-2.964-3.646-6.477-1.894-7.542Z" />
			<path d="M2.006 3c-.097 1.578.97 5.043 6.047 6.662M21.994 3c.097 1.578-.97 5.043-6.047 6.662" />
		</Icon>
	);
}

/** Jaqueta — o IconJacket do Tabler lê mais como colete. (mingcute/coat-line) */
export function IconCoat(props: IconProps) {
	return (
		<Icon {...props}>
			<path d="m7 18l-3.248-1.624a1 1 0 0 1-.51-1.182l2.261-7.539a4 4 0 0 1 2.043-2.428l2.032-1.016A2 2 0 0 1 10.472 4h3.056a2 2 0 0 1 .894.211l2.032 1.016a4 4 0 0 1 2.043 2.428l2.261 7.54a1 1 0 0 1-.51 1.181L17 18m-9.5-4l-.32 3.834A2 2 0 0 0 9.175 20h5.652a2 2 0 0 0 1.994-2.166L16.5 14M12 11v9m0-9L8.444 4.778M12 11l3.556-6.222" />
		</Icon>
	);
}

/** Colete — não existe no Tabler. (mingcute/vest-line) */
export function IconVest(props: IconProps) {
	return (
		<Icon {...props}>
			<path d="M9 4s0 6 3 6m0 0c3 0 3-6 3-6m-3 6v10m7.467-8.63A12.23 12.23 0 0 1 17.04 5c-.044-.55-.488-1-1.04-1H8c-.552 0-.996.45-1.04 1a12.23 12.23 0 0 1-2.427 6.37c-.322.42-.533.928-.533 1.458V18a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-5.172c0-.53-.211-1.037-.534-1.458" />
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

/** Torso, para a zona de tatuagem do tronco. (hugeicons/body-part-six-pack) */
export function IconTorso(props: IconProps) {
	return (
		<Icon {...props}>
			<path d="M22 6c0 1-1 3-5 3s-5-2-5-3c0 1-1 3-5 3S2 7 2 6m8-2.5C9.667 3 8.5 2 7 2m7 1.5C14.333 3 15.5 2 17 2M4 9v1c0 1.32.266 2.62.56 3.9c.54 2.346.81 5.68-.56 8.1M20 9v1c0 1.32-.266 2.62-.56 3.9c-.54 2.346-.81 5.68.56 8.1m-4-3c-1.485 1.179-2.356 1.369-3.677.282a.54.54 0 0 0-.664-.021C10.264 20.28 9.4 20.29 8 19m8-5c-1.485 1.179-2.356 1.369-3.677.282a.54.54 0 0 0-.664-.021C10.264 15.28 9.4 15.29 8 14m4 0v-2" />
		</Icon>
	);
}

/**
 * Braço. O lado esquerdo reaproveita o desenho espelhado.
 * (hugeicons/body-part-muscle)
 */
export function IconArm(props: IconProps) {
	return (
		<Icon {...props}>
			<path d="M2.018 20.305c1.129 1.615 6.041 2.882 8.362-.14c2.51 1.2 6.649.828 10.02-1.052c.468-.26.911-.59 1.183-1.054c.613-1.045.627-2.495-.491-4.634c-1.865-4.654-5.218-8.74-6.572-10.383c-.278-.253-2.051-.613-3.133-.96c-.478-.147-1.367-.245-2.43 1.157c-.505.664-2.796 2.297.11 3.394c.451.115.782.326 2.837-.049c.267-.046.935 0 1.406.826l.984 1.407a.96.96 0 0 1 .169.44c.172 1.499.166 3.375 1.002 4.326c-1.29-.934-4.664-2.042-7.206 1.112M2.002 12.94a6.714 6.714 0 0 1 8.416-.418" />
		</Icon>
	);
}

/**
 * Perna. O lado esquerdo reaproveita o desenho espelhado.
 * (hugeicons/body-part-leg)
 */
export function IconLeg(props: IconProps) {
	return (
		<Icon {...props}>
			<path d="M5.002 2c2.691.314 8.897 1.896 11.64 5.746c.337.47.69.804 1.27.95c.724.18 1.324.666 1.542 1.4c.232.798.66 1.64.524 2.494c-.052.327-.212.628-.532 1.23L15.099 22" />
			<path d="M4.002 12c1 1.726 4.164 2.596 8 1.726a10.1 10.1 0 0 0-2.685 2.225c-.559.646-.797 1.544-.836 2.452c-.052 1.212-.232 2.53-.854 3.597M5.002 7s1.959.29 3.5 1.5c1 .786 2.916 1.31 3.5 1.5" />
		</Icon>
	);
}
