export interface ThemeColors {
  primaryColor?: string;
  secondaryColor?: string;
  thirdyColor?: string;
}

const DEFAULT_COLORS: Required<ThemeColors> = {
  primaryColor: "#df1553",
  secondaryColor: "#9e0f3c",
  thirdyColor: "#670a27",
};

function hexToRgb(hex?: string): string | null {
  if (typeof hex !== "string") return null;

  let value = hex.replace("#", "").trim();
  if (value.length === 3) {
    value = value
      .split("")
      .map((char) => char + char)
      .join("");
  }
  if (value.length !== 6) return null;

  const num = Number.parseInt(value, 16);
  if (Number.isNaN(num)) return null;

  return [(num >> 16) & 255, (num >> 8) & 255, num & 255].join(", ");
}

export function applyThemeColors(colors?: ThemeColors | string | null) {
  const palette =
    typeof colors === "string" ? { primaryColor: colors } : colors || {};

  const root = document.documentElement;

  for (const key of Object.keys(DEFAULT_COLORS) as (keyof ThemeColors)[]) {
    const rgb = hexToRgb(palette[key]) || hexToRgb(DEFAULT_COLORS[key]);
    if (rgb) root.style.setProperty(`--${key}`, rgb);
  }
}
