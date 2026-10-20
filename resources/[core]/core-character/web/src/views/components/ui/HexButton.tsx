import { cn } from "@app/utils";
import { type ReactNode, useId, useState } from "react";

interface HexButtonProps {
	children: ReactNode;
	active?: boolean;
	/** Lado do hexagono em rem. Os dois SVGs escalam juntos, mantendo a geometria. */
	size?: number;
}

/**
 * Hexagono do tema. E so aparencia: quem clica e o elemento que o
 * envolve, porque em toda tela o alvo inclui o rotulo abaixo dele.
 */

export function HexButton({
	children,
	active = false,
	size = 4.125,
}: HexButtonProps) {
	const [hovered, setHovered] = useState(false);
	const uid = useId().replace(/:/g, "");

	const isActive = active || hovered;

	return (
		<span
			className="relative flex items-center justify-center"
			style={{ width: `${size}rem`, height: `${size}rem` }}
			onMouseEnter={() => setHovered(true)}
			onMouseLeave={() => setHovered(false)}
		>
			{/* icone */}
			<span
				className={cn(
					"pointer-events-none absolute z-10 flex items-center justify-center text-white transition-all duration-500",
					isActive ? "opacity-100" : "opacity-60",
				)}
			>
				{children}
			</span>

			{/* hexagono inativo */}
			<svg
				width={`${size}rem`}
				height={`${size}rem`}
				viewBox="0 0 66 66"
				fill="none"
				xmlns="http://www.w3.org/2000/svg"
				className={cn(
					"pointer-events-none absolute z-[2] transition-all duration-500",
					isActive ? "opacity-0" : "opacity-100",
				)}
			>
				<path
					d="M62.3916 29.75C63.4802 31.6355 63.5484 33.9314 62.5957 35.8682L62.3916 36.25L50.5107 56.8291C49.3496 58.8402 47.2031 60.0791 44.8809 60.0791L21.1191 60.0791C18.9419 60.0791 16.9197 58.9897 15.7187 57.1963L15.4893 56.8291L3.6084 36.25C2.51979 34.3645 2.45163 32.0686 3.4043 30.1318L3.6084 29.75L15.4893 9.1709C16.6504 7.15981 18.7969 5.9209 21.1191 5.9209L44.8809 5.9209C47.0581 5.9209 49.0803 7.01032 50.2812 8.80371L50.5107 9.1709L62.3916 29.75Z"
					stroke="#484848"
					strokeWidth="3"
				/>
				<path
					d="M58.5566 30.5C59.4498 32.047 59.4498 33.953 58.5566 35.5L47.9434 53.8827C47.0502 55.4297 45.3996 56.3827 43.6132 56.3827L22.3868 56.3827C20.6004 56.3827 18.9498 55.4297 18.0566 53.8827L7.44338 35.5C6.55022 33.953 6.55022 32.047 7.44338 30.5L18.0566 12.1173C18.9498 10.5703 20.6004 9.61731 22.3868 9.61731L43.6132 9.61731C45.3996 9.61731 47.0502 10.5703 47.9434 12.1173L58.5566 30.5Z"
					fill="#484848"
					fillOpacity="0.5"
				/>
			</svg>

			{/* hexagono ativo / hover */}
			<svg
				width={`${(size * 4.625) / 4.125}rem`}
				height={`${(size * 4.25) / 4.125}rem`}
				viewBox="0 0 74 68"
				fill="none"
				xmlns="http://www.w3.org/2000/svg"
				className={cn(
					"pointer-events-none absolute z-[1] transition-all duration-500",
					isActive ? "opacity-100" : "opacity-0",
				)}
			>
				<path
					d="M66.3916 30.75C67.4802 32.6355 67.5484 34.9314 66.5957 36.8682L66.3916 37.25L54.5107 57.8291C53.3496 59.8402 51.2031 61.0791 48.8809 61.0791L25.1191 61.0791C22.9419 61.0791 20.9197 59.9897 19.7187 58.1963L19.4893 57.8291L7.6084 37.25C6.51979 35.3645 6.45163 33.0686 7.4043 31.1318L7.6084 30.75L19.4893 10.1709C20.6504 8.15981 22.7969 6.9209 25.1191 6.9209L48.8809 6.9209C51.0581 6.9209 53.0803 8.01032 54.2812 9.80371L54.5107 10.1709L66.3916 30.75Z"
					stroke={`url(#paint0_linear_${uid})`}
					strokeWidth="3"
				/>
				<path
					d="M62.5566 31.5C63.4498 33.047 63.4498 34.953 62.5566 36.5L51.9434 54.8827C51.0502 56.4297 49.3996 57.3827 47.6132 57.3827L26.3868 57.3827C24.6004 57.3827 22.9498 56.4297 22.0566 54.8827L11.4434 36.5C10.5502 34.953 10.5502 33.047 11.4434 31.5L22.0566 13.1173C22.9498 11.5703 24.6004 10.6173 26.3868 10.6173L47.6132 10.6173C49.3996 10.6173 51.0502 11.5703 51.9434 13.1173L62.5566 31.5Z"
					fill={`url(#paint1_linear_${uid})`}
					fillOpacity="0.9"
				/>
				<path
					d="M62.5566 31.5C63.4498 33.047 63.4498 34.953 62.5566 36.5L51.9434 54.8827C51.0502 56.4297 49.3996 57.3827 47.6132 57.3827L26.3868 57.3827C24.6004 57.3827 22.9498 56.4297 22.0566 54.8827L11.4434 36.5C10.5502 34.953 10.5502 33.047 11.4434 31.5L22.0566 13.1173C22.9498 11.5703 24.6004 10.6173 26.3868 10.6173L47.6132 10.6173C49.3996 10.6173 51.0502 11.5703 51.9434 13.1173L62.5566 31.5Z"
					fill={`url(#paint2_radial_${uid})`}
					fillOpacity="0.3"
				/>
				<path
					d="M62.21 31.7002C62.9803 33.0345 63.0285 34.6587 62.3545 36.0293L62.21 36.2998L51.5967 54.6826C50.775 56.1058 49.2567 56.9824 47.6133 56.9824L26.3867 56.9824C24.8462 56.9824 23.4154 56.2122 22.5654 54.9434L22.4033 54.6826L11.79 36.2998C11.0197 34.9655 10.9715 33.3413 11.6455 31.9707L11.79 31.7002L22.4033 13.3174C23.225 11.8942 24.7433 11.0176 26.3867 11.0176L47.6133 11.0176C49.1538 11.0176 50.5846 11.7878 51.4346 13.0566L51.5967 13.3174L62.21 31.7002Z"
					stroke={`url(#paint3_linear_${uid})`}
					strokeOpacity="0.06"
					strokeWidth="0.8"
				/>
				{/* var() em atributo de apresentacao nao e confiavel no CEF;
				    por classe (CSS) sempre resolve. */}
				<path
					d="M62.21 31.7002C62.9803 33.0345 63.0285 34.6587 62.3545 36.0293L62.21 36.2998L51.5967 54.6826C50.775 56.1058 49.2567 56.9824 47.6133 56.9824L26.3867 56.9824C24.8462 56.9824 23.4154 56.2122 22.5654 54.9434L22.4033 54.6826L11.79 36.2998C11.0197 34.9655 10.9715 33.3413 11.6455 31.9707L11.79 31.7002L22.4033 13.3174C23.225 11.8942 24.7433 11.0176 26.3867 11.0176L47.6133 11.0176C49.1538 11.0176 50.5846 11.7878 51.4346 13.0566L51.5967 13.3174L62.21 31.7002Z"
					className="stroke-primaryColor"
					strokeWidth="0.8"
				/>
				<defs>
					<linearGradient
						id={`paint0_linear_${uid}`}
						x1="5.52308"
						y1="0.999997"
						x2="65.8511"
						y2="70.5964"
						gradientUnits="userSpaceOnUse"
					>
						<stop className="[stop-color:rgb(var(--secondaryColor))]" />
						<stop
							offset="0.622285"
							className="[stop-color:rgb(var(--primaryColor))]"
						/>
					</linearGradient>
					<linearGradient
						id={`paint1_linear_${uid}`}
						x1="11.2462"
						y1="7"
						x2="60.6054"
						y2="63.9425"
						gradientUnits="userSpaceOnUse"
					>
						<stop className="[stop-color:rgb(var(--secondaryColor))]" />
						<stop
							offset="0.622285"
							className="[stop-color:rgb(var(--primaryColor))]"
						/>
					</linearGradient>
					<radialGradient
						id={`paint2_radial_${uid}`}
						cx="0"
						cy="0"
						r="1"
						gradientUnits="userSpaceOnUse"
						gradientTransform="translate(37 34) rotate(90) scale(27 328.336)"
					>
						<stop />
						<stop
							offset="1"
							stopOpacity="0"
							className="[stop-color:rgb(var(--thirdyColor))]"
						/>
					</radialGradient>
					<linearGradient
						id={`paint3_linear_${uid}`}
						x1="37"
						y1="7"
						x2="37"
						y2="61"
						gradientUnits="userSpaceOnUse"
					>
						<stop stopColor="#EDEAE5" />
						<stop offset="1" stopColor="#999999" stopOpacity="0.9" />
					</linearGradient>
				</defs>
			</svg>
		</span>
	);
}
