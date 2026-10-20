export const ColorPresets: Record<
	string,
	{ primaryColor: string; secondaryColor: string; thirdColor: string }
> = {
	red: {
		primaryColor: "245, 12, 12",
		secondaryColor: "229, 16, 127",
		thirdColor: "126, 54, 214",
	},
	blue: {
		primaryColor: "12, 100, 245",
		secondaryColor: "16, 127, 229",
		thirdColor: "54, 86, 214",
	},
	green: {
		primaryColor: "12, 200, 80",
		secondaryColor: "16, 180, 120",
		thirdColor: "54, 214, 150",
	},
	purple: {
		primaryColor: "140, 50, 255",
		secondaryColor: "180, 60, 220",
		thirdColor: "100, 40, 200",
	},
	orange: {
		primaryColor: "245, 130, 12",
		secondaryColor: "229, 80, 16",
		thirdColor: "214, 160, 54",
	},
	pink: {
		primaryColor: "245, 60, 150",
		secondaryColor: "220, 40, 180",
		thirdColor: "180, 50, 200",
	},
	cyan: {
		primaryColor: "12, 210, 245",
		secondaryColor: "16, 180, 229",
		thirdColor: "54, 150, 214",
	},
	yellow: {
		primaryColor: "245, 200, 12",
		secondaryColor: "229, 170, 16",
		thirdColor: "214, 180, 54",
	},
};

function isRgb(str: string): boolean {
	return str.includes(",");
}

function hexToRgb(hex: string): string {
	const bigint = Number.parseInt(hex.replace("#", ""), 16);
	const r = (bigint >> 16) & 255;
	const g = (bigint >> 8) & 255;
	const b = bigint & 255;
	return `${r}, ${g}, ${b}`;
}

function ensureRgb(color: string): string {
	return isRgb(color) ? color : hexToRgb(color);
}

function setColorVars(
	primaryColor: string,
	secondaryColor: string,
	thirdColor: string,
) {
	document.documentElement.style.setProperty(
		"--primaryColor",
		ensureRgb(primaryColor),
	);
	document.documentElement.style.setProperty(
		"--secondaryColor",
		ensureRgb(secondaryColor),
	);
	document.documentElement.style.setProperty(
		"--thirdColor",
		ensureRgb(thirdColor),
	);
}

export function applyColors(
	color:
		| string
		| { primaryColor: string; secondaryColor: string; thirdColor: string },
) {
	if (typeof color === "string") {
		const preset = ColorPresets[color];
		if (!preset) return;
		setColorVars(preset.primaryColor, preset.secondaryColor, preset.thirdColor);
		return;
	}

	if (
		typeof color === "object" &&
		color.primaryColor &&
		color.secondaryColor &&
		color.thirdColor
	) {
		setColorVars(color.primaryColor, color.secondaryColor, color.thirdColor);
	}
}

export function hexToRgba(hex: string, alpha: number): string {
	hex = hex.replace("#", "");
	let r: number;
	let g: number;
	let b: number;
	if (hex.length === 3) {
		r = Number.parseInt(hex[0] + hex[0], 16);
		g = Number.parseInt(hex[1] + hex[1], 16);
		b = Number.parseInt(hex[2] + hex[2], 16);
	} else if (hex.length === 6) {
		r = Number.parseInt(hex.substring(0, 2), 16);
		g = Number.parseInt(hex.substring(2, 4), 16);
		b = Number.parseInt(hex.substring(4, 6), 16);
	} else {
		throw new Error("Invalid hex color format");
	}
	alpha = Math.max(0, Math.min(1, alpha));
	return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}
