import type { CSSProperties } from "react";

export const isEnvBrowser = (): boolean => !(window as any).invokeNative;

export const sleep = (delay: number) =>
	new Promise((resolve) => {
		setTimeout(() => {
			resolve(true);
		}, delay);
	});

export function formatTimestampToHHMM(
	timestamp: number | string | Date,
): string {
	const date = new Date(timestamp);
	const hours = date.getHours().toString().padStart(2, "0");
	const minutes = date.getMinutes().toString().padStart(2, "0");
	return `${hours}:${minutes}`;
}

export function extractVisualStyles(styles?: CSSProperties): CSSProperties {
	if (!styles) return {};
	const {
		background,
		backgroundBlendMode,
		border,
		borderColor,
		borderRadius,
		boxShadow,
		opacity,
		outline,
		outlineColor,
		outlineOffset,
	} = styles;
	return Object.fromEntries(
		Object.entries({
			background,
			backgroundBlendMode,
			border,
			borderColor,
			borderRadius,
			boxShadow,
			opacity,
			outline,
			outlineColor,
			outlineOffset,
		}).filter(([, v]) => v !== undefined),
	);
}
