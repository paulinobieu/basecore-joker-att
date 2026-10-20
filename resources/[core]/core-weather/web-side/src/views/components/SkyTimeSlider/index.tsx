import { useWeatherStore } from "@app/stores/Weather";
import { useShallow } from "zustand/shallow";

type RGB = [number, number, number];

function pad(n: number) {
	return n.toString().padStart(2, "0");
}

function hexToRgb(hex: string): RGB {
	const h = hex.replace("#", "");
	return [
		Number.parseInt(h.slice(0, 2), 16),
		Number.parseInt(h.slice(2, 4), 16),
		Number.parseInt(h.slice(4, 6), 16),
	];
}

function mix(a: RGB, b: RGB, t: number): RGB {
	return [
		a[0] + (b[0] - a[0]) * t,
		a[1] + (b[1] - a[1]) * t,
		a[2] + (b[2] - a[2]) * t,
	];
}

function rgb(c: RGB) {
	return `rgb(${Math.round(c[0])}, ${Math.round(c[1])}, ${Math.round(c[2])})`;
}

function rgba(c: RGB, a: number) {
	return `rgba(${Math.round(c[0])}, ${Math.round(c[1])}, ${Math.round(c[2])}, ${a.toFixed(3)})`;
}

interface ISkyFrame {
	h: number;
	top: RGB;
	bottom: RGB;
	glow: RGB;
	glowAlpha: number;
	stars: number;
}

const RAW_FRAMES: Array<{
	h: number;
	top: string;
	bottom: string;
	glow: string;
	glowAlpha: number;
	stars: number;
}> = [
	{ h: 0, top: "#0b1026", bottom: "#1d2748", glow: "#d4708c", glowAlpha: 0.14, stars: 1 },
	{ h: 4.5, top: "#0b1026", bottom: "#1d2748", glow: "#d4708c", glowAlpha: 0.14, stars: 1 },
	{ h: 6, top: "#2c3b6c", bottom: "#c97a55", glow: "#ff9d5c", glowAlpha: 0.42, stars: 0.35 },
	{ h: 7.5, top: "#8ecfe8", bottom: "#f2ddcc", glow: "#ffb894", glowAlpha: 0.36, stars: 0 },
	{ h: 11, top: "#a9dff0", bottom: "#e4f5fa", glow: "#f4c3bb", glowAlpha: 0.32, stars: 0 },
	{ h: 15, top: "#a2d8ee", bottom: "#e0f1f8", glow: "#f4beb4", glowAlpha: 0.32, stars: 0 },
	{ h: 17, top: "#8cbde4", bottom: "#f4cdb0", glow: "#ffa878", glowAlpha: 0.38, stars: 0 },
	{ h: 18.5, top: "#3d4884", bottom: "#e07f52", glow: "#ff8a50", glowAlpha: 0.46, stars: 0.2 },
	{ h: 20, top: "#151c40", bottom: "#4a3a68", glow: "#d4708c", glowAlpha: 0.22, stars: 0.75 },
	{ h: 21.5, top: "#0b1026", bottom: "#1d2748", glow: "#d4708c", glowAlpha: 0.14, stars: 1 },
	{ h: 24, top: "#0b1026", bottom: "#1d2748", glow: "#d4708c", glowAlpha: 0.14, stars: 1 },
];

const FRAMES: ISkyFrame[] = RAW_FRAMES.map((f) => ({
	h: f.h,
	top: hexToRgb(f.top),
	bottom: hexToRgb(f.bottom),
	glow: hexToRgb(f.glow),
	glowAlpha: f.glowAlpha,
	stars: f.stars,
}));

function getSkyColors(hourFrac: number) {
	let i = 0;
	while (i < FRAMES.length - 2 && FRAMES[i + 1].h <= hourFrac) i++;
	const a = FRAMES[i];
	const b = FRAMES[i + 1];
	const span = b.h - a.h || 1;
	const t = Math.min(1, Math.max(0, (hourFrac - a.h) / span));
	return {
		top: mix(a.top, b.top, t),
		bottom: mix(a.bottom, b.bottom, t),
		glow: mix(a.glow, b.glow, t),
		glowAlpha: a.glowAlpha + (b.glowAlpha - a.glowAlpha) * t,
		stars: a.stars + (b.stars - a.stars) * t,
	};
}

const ARC_CX = 50;
const ARC_RX = 44;
const ARC_EDGE_Y = 88;
const ARC_APEX_Y = 30;

function getAstro(hourFrac: number, riseHour: number) {
	let t = ((((hourFrac - riseHour) % 24) + 24) % 24) / 12;
	if (t > 1.14) t -= 2;
	const visible = t >= -0.14 && t <= 1.14;
	const angle = t * Math.PI;
	const left = ARC_CX - ARC_RX * Math.cos(angle);
	const top = ARC_EDGE_Y - (ARC_EDGE_Y - ARC_APEX_Y) * Math.sin(angle);
	const height = Math.max(0, Math.sin(angle));
	return { visible, left, top, height };
}

const STARS = [
	{ x: 5, y: 12, s: 2 }, { x: 11, y: 34, s: 1.4 }, { x: 17, y: 7, s: 1.6 },
	{ x: 21, y: 48, s: 2.2 }, { x: 28, y: 20, s: 1.3 }, { x: 34, y: 40, s: 1.7 },
	{ x: 41, y: 10, s: 1.5 }, { x: 47, y: 30, s: 1.2 }, { x: 54, y: 8, s: 1.9 },
	{ x: 60, y: 38, s: 1.3 }, { x: 67, y: 16, s: 2 }, { x: 73, y: 46, s: 1.4 },
	{ x: 79, y: 27, s: 1.7 }, { x: 85, y: 9, s: 1.4 }, { x: 91, y: 36, s: 1.9 },
	{ x: 95, y: 16, s: 1.3 }, { x: 38, y: 58, s: 1.2 }, { x: 63, y: 56, s: 1.4 },
];

const CLOUDS = [
	{ x: 8, y: 24, w: 110, h: 26, o: 0.5, dur: 9 },
	{ x: 48, y: 12, w: 140, h: 30, o: 0.4, dur: 12 },
	{ x: 72, y: 46, w: 95, h: 22, o: 0.45, dur: 10 },
];

function SunDisc({ size = 64 }: { size?: number }) {
	return (
		<svg width={size} height={size} viewBox="0 0 64 64" fill="none">
			<circle cx="32" cy="32" r="30" fill="url(#sunRing)" />
			<circle cx="32" cy="32" r="22" fill="url(#sunBody)" />
			<ellipse cx="25" cy="24" rx="8" ry="6" fill="rgba(255,255,255,0.22)" />
			<defs>
				<radialGradient id="sunRing" cx="38%" cy="30%" r="80%">
					<stop offset="0%" stopColor="#eb8a5e" />
					<stop offset="100%" stopColor="#d66a44" />
				</radialGradient>
				<radialGradient id="sunBody" cx="38%" cy="30%" r="80%">
					<stop offset="0%" stopColor="#f4ad7d" />
					<stop offset="100%" stopColor="#e88d5d" />
				</radialGradient>
			</defs>
		</svg>
	);
}

function MoonDisc({ size = 58 }: { size?: number }) {
	return (
		<svg width={size} height={size} viewBox="0 0 64 64" fill="none">
			<circle cx="32" cy="32" r="30" fill="url(#moonBody)" />
			<circle cx="24" cy="18" r="4" fill="rgba(140,155,200,0.30)" />
			<circle cx="43" cy="30" r="2.6" fill="rgba(140,155,200,0.26)" />
			<circle cx="30" cy="42" r="3.4" fill="rgba(140,155,200,0.22)" />
			<circle cx="45" cy="45" r="5" fill="rgba(140,155,200,0.18)" />
			<circle cx="15" cy="32" r="2" fill="rgba(140,155,200,0.2)" />
			<defs>
				<radialGradient id="moonBody" cx="36%" cy="28%" r="85%">
					<stop offset="0%" stopColor="#ffffff" />
					<stop offset="70%" stopColor="#eef1fb" />
					<stop offset="100%" stopColor="#cdd5ef" />
				</radialGradient>
			</defs>
		</svg>
	);
}

export function SkyTimeSlider() {
	const { pendingHour, pendingMinute, setPendingTime } = useWeatherStore(
		useShallow((state) => ({
			pendingHour: state.pendingHour,
			pendingMinute: state.pendingMinute,
			setPendingTime: state.setPendingTime,
		})),
	);

	const hourFrac = pendingHour + pendingMinute / 60;
	const sky = getSkyColors(hourFrac);
	const sun = getAstro(hourFrac, 6);
	const moon = getAstro(hourFrac, 18);
	const totalMinutes = pendingHour * 60 + pendingMinute;
	const trackPercent = (totalMinutes / 1439) * 100;
	const cloudAlpha = 1 - sky.stars;

	const domeColor = mix([255, 255, 255], [110, 140, 220], sky.stars);
	const domeAlpha = 0.14 + sky.stars * 0.14;

	return (
		<div className="sky-widget">
			<div
				className="sky-band"
				style={{
					background: `linear-gradient(180deg, ${rgb(sky.top)} 0%, ${rgb(sky.bottom)} 100%)`,
				}}
			>
				<div
					className="sky-corner-glow sky-corner-glow--left"
					style={{
						background: `radial-gradient(closest-side, ${rgba(sky.glow, sky.glowAlpha)}, transparent 75%)`,
					}}
				/>
				<div
					className="sky-corner-glow sky-corner-glow--right"
					style={{
						background: `radial-gradient(closest-side, ${rgba(sky.glow, sky.glowAlpha)}, transparent 75%)`,
					}}
				/>

				{sky.stars > 0.02 && (
					<div className="sky-stars" style={{ opacity: sky.stars }}>
						{STARS.map((star, i) => (
							<span
								key={`${star.x}-${star.y}`}
								className="sky-star"
								style={{
									left: `${star.x}%`,
									top: `${star.y}%`,
									width: star.s,
									height: star.s,
									animationDelay: `${((i * 0.53) % 3).toFixed(2)}s`,
								}}
							/>
						))}
					</div>
				)}

				{cloudAlpha > 0.02 &&
					CLOUDS.map((cloud) => (
						<div
							key={`${cloud.x}-${cloud.y}`}
							className="sky-cloud"
							style={{
								left: `${cloud.x}%`,
								top: `${cloud.y}%`,
								width: cloud.w,
								height: cloud.h,
								opacity: cloud.o * cloudAlpha,
								animationDuration: `${cloud.dur}s`,
							}}
						/>
					))}

				<div
					className="sky-dome"
					style={{
						background: `radial-gradient(closest-side, ${rgba(domeColor, domeAlpha)}, ${rgba(domeColor, domeAlpha * 0.5)} 82%, transparent 100%)`,
					}}
				/>

				{sun.visible && (
					<div
						className="sky-marker"
						style={{ left: `${sun.left}%`, top: `${sun.top}%` }}
					>
						<div
							className="sky-halo"
							style={{
								background: `radial-gradient(closest-side, rgba(255, 176, 110, ${0.3 + sun.height * 0.3}), transparent 75%)`,
							}}
						/>
						<SunDisc />
					</div>
				)}

				{moon.visible && (
					<div
						className="sky-marker"
						style={{ left: `${moon.left}%`, top: `${moon.top}%` }}
					>
						<div
							className="sky-halo"
							style={{
								background: `radial-gradient(closest-side, rgba(160, 182, 240, ${0.26 + moon.height * 0.26}), transparent 75%)`,
							}}
						/>
						<MoonDisc />
					</div>
				)}
			</div>

			<div className="sky-readout-row">
				<span className="sky-edge-label">00h</span>
				<div className="sky-readout">
					{pad(pendingHour)}:{pad(pendingMinute)}
				</div>
				<span className="sky-edge-label">24h</span>
			</div>

			<input
				className="sky-slider"
				type="range"
				min={0}
				max={1439}
				step={1}
				value={totalMinutes}
				onChange={(e) => {
					const val = Number.parseInt(e.target.value, 10);
					setPendingTime(Math.floor(val / 60), val % 60);
				}}
				style={{
					background: `linear-gradient(to right, rgb(var(--primary-rgb)) 0%, rgb(var(--primary-rgb)) ${trackPercent}%, rgba(255,255,255,0.1) ${trackPercent}%, rgba(255,255,255,0.1) 100%)`,
				}}
			/>
		</div>
	);
}
