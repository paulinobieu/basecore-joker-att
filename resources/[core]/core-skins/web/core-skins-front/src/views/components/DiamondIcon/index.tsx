import { useId } from "react";

interface DiamondIconProps {
	color?: string;
}

export function DiamondIcon({ color = "rgb(var(--primaryColor))" }: DiamondIconProps) {
	const id = useId();
	const gradId1 = `${id}-grad1`;
	const gradId2 = `${id}-grad2`;
	const gradId3 = `${id}-grad3`;

	return (
		<svg width="66" height="66" viewBox="0 0 66 66" fill="none">
			<path
				d="M33 0L66 33L33 66L0 33L33 0Z"
				fill={`url(#${gradId1})`}
			/>
			<path
				d="M33 8L58 33L33 58L8 33L33 8Z"
				fill={`url(#${gradId2})`}
			/>
			<path
				d="M33 16L50 33L33 50L16 33L33 16Z"
				fill={`url(#${gradId3})`}
			/>
			<defs>
				<linearGradient id={gradId1} x1="33" y1="0" x2="33" y2="66" gradientUnits="userSpaceOnUse">
					<stop stopColor={color} stopOpacity="0.1" />
					<stop offset="1" stopColor={color} stopOpacity="0.3" />
				</linearGradient>
				<linearGradient id={gradId2} x1="33" y1="8" x2="33" y2="58" gradientUnits="userSpaceOnUse">
					<stop stopColor={color} stopOpacity="0.2" />
					<stop offset="1" stopColor={color} stopOpacity="0.5" />
				</linearGradient>
				<linearGradient id={gradId3} x1="33" y1="16" x2="33" y2="50" gradientUnits="userSpaceOnUse">
					<stop stopColor={color} stopOpacity="0.4" />
					<stop offset="1" stopColor={color} stopOpacity="0.8" />
				</linearGradient>
			</defs>
		</svg>
	);
}
