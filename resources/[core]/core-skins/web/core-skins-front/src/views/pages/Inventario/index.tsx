import React, { useState, useEffect, useCallback, useId, Suspense } from "react";
import ReactDOM from "react-dom";
import { Canvas } from "@react-three/fiber";
import { OrbitControls, useGLTF, Center, Bounds } from "@react-three/drei";
import { fetchNui } from "@app/utils/fetchNui";
import { useMainStore } from "@app/stores/MainStore";
import { useVisibility } from "@app/stores/Visibility";
import { useDataCache } from "@app/stores/DataCache";
import { RARITY_MAP } from "@app/stores/constants";
import { SearchIcon } from "@views/components/SearchIcon";
import { SkinFallbackSVG } from "@views/components/SkinFallbackSVG";
import { DiamondIcon } from "@views/components/DiamondIcon";

import skinFallbackImage from "@views/assets/images/skin-item.png";
import inspectBg from "./assets/inspect-bg.png";
import equipBg from "./assets/equip-bg.png";

// ── Types ──────────────────────────────────────────────────────────────────────

interface Skin {
	model_name: string;
	weapon_hash: string;
	name: string;
	rarity: string;
	equipped: boolean;
	owned: boolean;
	image: string;
	viewer_url?: string;
	quantity?: number;
	price?: number;
	temporary?: boolean;
	daysLeft?: number | null;
	expiresAt?: number | null;
	durations?: { id?: string; label: string; days: number; price?: number | null }[];
}

interface WeaponCategory {
	id: string;
	name: string;
	image: string;
	skinsCount: number;
	skins: Skin[];
}

type WeaponType = "pistol" | "rifle" | "smg" | "sniper";

type InspectMode = false | "ingame" | "browser";

// ── Constants ──────────────────────────────────────────────────────────────────

const WEAPON_CATEGORY_MAP: Record<string, WeaponType> = {
	pistol_mk2: "pistol",
	combatpistol: "pistol",
	pistol50: "pistol",
	m9a3: "pistol",
	fajuta: "pistol",
	assaultrifle: "rifle",
	assaultrifle_mk2: "rifle",
	carbinerifle: "rifle",
	carbinerifle_mk2: "rifle",
	specialcarbine: "rifle",
	specialcarbine_mk2: "rifle",
	ak47: "rifle",
	scarh: "rifle",
	hk416: "rifle",
	fal: "rifle",
	militaryrifle: "rifle",
	navycarbine: "rifle",
	nsr: "sniper",
	m110: "sniper",
	sniperrifle: "sniper",
	assaultsmg: "smg",
	machinepistol: "smg",
	scorpionevo: "smg",
	mp5k: "smg",
	mp9: "smg",
	mtar: "smg",
};

const FILTER_TABS = ["Todos", "Equipadas"];

const MOCK_INVENTORY: WeaponCategory[] = [
	{
		id: "pistol_mk2",
		name: "Pistol MK2",
		image: "",
		skinsCount: 2,
		skins: [
			{
				model_name: "mock_1",
				weapon_hash: "WEAPON_PISTOL_MK2",
				name: "Mock Skin",
				rarity: "epico",
				equipped: false,
				owned: true,
				image: skinFallbackImage,
			},
			{
				model_name: "mock_2",
				weapon_hash: "WEAPON_PISTOL_MK2",
				name: "Mock Skin 2",
				rarity: "raro",
				equipped: false,
				owned: false,
				image: skinFallbackImage,
				price: 150,
			},
		],
	},
];

// ── Weapon Silhouette SVGs ─────────────────────────────────────────────────────

interface SilhouetteProps {
	color: string;
	gradId: string;
}

function PistolSilhouette({ color, gradId }: SilhouetteProps) {
	return (
		<svg viewBox="0 0 48 48" fill="none">
			<defs>
				<linearGradient
					id={gradId}
					x1="4"
					y1="10"
					x2="42"
					y2="40"
					gradientUnits="userSpaceOnUse"
				>
					<stop stopColor={color} stopOpacity="1" />
					<stop offset="1" stopColor={color} stopOpacity="0.4" />
				</linearGradient>
			</defs>
			<rect x="12" y="11" width="30" height="4" rx="1.2" fill={`url(#${gradId})`} />
			<rect
				x="12"
				y="15"
				width="30"
				height="6"
				rx="1"
				fill={`url(#${gradId})`}
				opacity="0.9"
			/>
			<rect x="24" y="12.5" width="6" height="1.5" rx="0.4" fill={color} opacity="0.2" />
			<rect x="38" y="13" width="6" height="3" rx="0.8" fill={color} opacity="0.5" />
			<path
				d="M12 21h22v4H20l-1.5 1.5H12V21z"
				fill={`url(#${gradId})`}
				opacity="0.85"
			/>
			<path
				d="M19 26.5c0 0 0 4 3 4.5h-4c-2 0-3-1.5-3-3v-1.5h4z"
				fill={color}
				opacity="0.5"
			/>
			<rect x="20" y="23" width="1" height="3.5" rx="0.3" fill={color} opacity="0.6" />
			<path
				d="M12 26.5h6.5l1 11a1.5 1.5 0 01-1.5 1.5h-4A1.5 1.5 0 0112.5 38l-.5-11.5z"
				fill={`url(#${gradId})`}
				opacity="0.8"
			/>
			<line
				x1="14"
				y1="29"
				x2="14"
				y2="35"
				stroke={color}
				strokeOpacity="0.15"
				strokeWidth="0.6"
			/>
			<line
				x1="15.5"
				y1="29"
				x2="15.5"
				y2="35.5"
				stroke={color}
				strokeOpacity="0.15"
				strokeWidth="0.6"
			/>
			<line
				x1="17"
				y1="29"
				x2="17"
				y2="36"
				stroke={color}
				strokeOpacity="0.15"
				strokeWidth="0.6"
			/>
			<rect x="39" y="9.5" width="1.5" height="2" rx="0.4" fill={color} opacity="0.6" />
			<rect x="16" y="9.5" width="3" height="1.8" rx="0.4" fill={color} opacity="0.4" />
			<line
				x1="14"
				y1="12"
				x2="14"
				y2="14.5"
				stroke={color}
				strokeOpacity="0.2"
				strokeWidth="0.5"
			/>
			<line
				x1="15.5"
				y1="12"
				x2="15.5"
				y2="14.5"
				stroke={color}
				strokeOpacity="0.2"
				strokeWidth="0.5"
			/>
			<line
				x1="17"
				y1="12"
				x2="17"
				y2="14.5"
				stroke={color}
				strokeOpacity="0.2"
				strokeWidth="0.5"
			/>
			<rect x="13" y="37" width="5.5" height="1.5" rx="0.5" fill={color} opacity="0.35" />
		</svg>
	);
}

function RifleSilhouette({ color, gradId }: SilhouetteProps) {
	return (
		<svg viewBox="0 0 48 48" fill="none">
			<defs>
				<linearGradient
					id={gradId}
					x1="0"
					y1="14"
					x2="48"
					y2="30"
					gradientUnits="userSpaceOnUse"
				>
					<stop stopColor={color} stopOpacity="0.5" />
					<stop offset="0.5" stopColor={color} stopOpacity="1" />
					<stop offset="1" stopColor={color} stopOpacity="0.6" />
				</linearGradient>
			</defs>
			<rect x="30" y="17.5" width="16" height="2.5" rx="0.8" fill={`url(#${gradId})`} />
			<rect x="44" y="16.5" width="3.5" height="4.5" rx="1" fill={color} opacity="0.5" />
			<line
				x1="45.5"
				y1="17"
				x2="45.5"
				y2="20.5"
				stroke={color}
				strokeOpacity="0.25"
				strokeWidth="0.5"
			/>
			<rect
				x="8"
				y="15"
				width="36"
				height="6"
				rx="1"
				fill={`url(#${gradId})`}
				opacity="0.9"
			/>
			<g opacity="0.35">
				<rect x="14" y="13.5" width="22" height="2" rx="0.4" fill={color} />
				{Array.from({ length: 8 }).map((_, i) => (
					<line
						key={i}
						x1={16 + i * 2.5}
						y1="13.5"
						x2={16 + i * 2.5}
						y2="15.5"
						stroke={color}
						strokeOpacity="0.4"
						strokeWidth="0.4"
					/>
				))}
			</g>
			<line
				x1="32"
				y1="17"
				x2="32"
				y2="20"
				stroke={color}
				strokeOpacity="0.15"
				strokeWidth="0.5"
			/>
			<line
				x1="34.5"
				y1="17"
				x2="34.5"
				y2="20"
				stroke={color}
				strokeOpacity="0.15"
				strokeWidth="0.5"
			/>
			<line
				x1="37"
				y1="17"
				x2="37"
				y2="20"
				stroke={color}
				strokeOpacity="0.15"
				strokeWidth="0.5"
			/>
			<rect
				x="8"
				y="21"
				width="26"
				height="3.5"
				rx="0.5"
				fill={`url(#${gradId})`}
				opacity="0.8"
			/>
			<path
				d="M22 24.5h6l0.5 10a1 1 0 01-1 1h-5a1 1 0 01-1-1l0.5-10z"
				fill={color}
				opacity="0.65"
			/>
			<line
				x1="24"
				y1="26"
				x2="24"
				y2="33"
				stroke={color}
				strokeOpacity="0.15"
				strokeWidth="0.5"
			/>
			<line
				x1="26"
				y1="26"
				x2="26"
				y2="33.5"
				stroke={color}
				strokeOpacity="0.15"
				strokeWidth="0.5"
			/>
			<path
				d="M16 24.5v4.5a2 2 0 002 2h2a2 2 0 002-2v-4.5"
				fill="none"
				stroke={color}
				strokeOpacity="0.45"
				strokeWidth="1"
			/>
			<rect x="19" y="25" width="1" height="3" rx="0.3" fill={color} opacity="0.5" />
			<path
				d="M8 24.5h5l0.5 9a1.5 1.5 0 01-1.5 1.5h-2A1.5 1.5 0 018.5 34L8 24.5z"
				fill={color}
				opacity="0.7"
			/>
			<rect
				x="1"
				y="17"
				width="8"
				height="3.5"
				rx="1.2"
				fill={`url(#${gradId})`}
				opacity="0.7"
			/>
			<path
				d="M0.5 16h5v8H2.5a2 2 0 01-2-2v-6z"
				fill={`url(#${gradId})`}
				opacity="0.85"
			/>
			<rect x="0" y="15.5" width="1.5" height="9" rx="0.5" fill={color} opacity="0.4" />
		</svg>
	);
}

function SmgSilhouette({ color, gradId }: SilhouetteProps) {
	return (
		<svg viewBox="0 0 48 48" fill="none">
			<defs>
				<linearGradient
					id={gradId}
					x1="0"
					y1="14"
					x2="48"
					y2="32"
					gradientUnits="userSpaceOnUse"
				>
					<stop stopColor={color} stopOpacity="0.5" />
					<stop offset="0.5" stopColor={color} stopOpacity="1" />
					<stop offset="1" stopColor={color} stopOpacity="0.6" />
				</linearGradient>
			</defs>
			<rect x="30" y="17" width="12" height="2.5" rx="0.8" fill={`url(#${gradId})`} />
			<rect x="40" y="15.5" width="7" height="5.5" rx="2.2" fill={color} opacity="0.45" />
			<line
				x1="42"
				y1="16.5"
				x2="42"
				y2="20"
				stroke={color}
				strokeOpacity="0.2"
				strokeWidth="0.4"
			/>
			<line
				x1="44"
				y1="16.5"
				x2="44"
				y2="20"
				stroke={color}
				strokeOpacity="0.2"
				strokeWidth="0.4"
			/>
			<rect
				x="6"
				y="14.5"
				width="36"
				height="5.5"
				rx="1"
				fill={`url(#${gradId})`}
				opacity="0.9"
			/>
			<rect x="14" y="13" width="16" height="2" rx="0.4" fill={color} opacity="0.3" />
			<rect x="28" y="12" width="4" height="2.5" rx="0.6" fill={color} opacity="0.45" />
			<rect
				x="6"
				y="20"
				width="30"
				height="3.5"
				rx="0.5"
				fill={`url(#${gradId})`}
				opacity="0.8"
			/>
			<path
				d="M20 23.5h5.5l1.5 12a1 1 0 01-1 1h-6a1 1 0 01-1-1l1-12z"
				fill={color}
				opacity="0.65"
			/>
			<path
				d="M13 23.5v4a1.5 1.5 0 001.5 1.5h2.5a1.5 1.5 0 001.5-1.5v-4"
				fill="none"
				stroke={color}
				strokeOpacity="0.45"
				strokeWidth="1"
			/>
			<path
				d="M6 23.5h5l0.5 8a1.5 1.5 0 01-1.5 1.5h-2A1.5 1.5 0 016.5 32L6 23.5z"
				fill={color}
				opacity="0.7"
			/>
			<path
				d="M1 16h6v3H3a1.5 1.5 0 01-1.5-1.5L1 16z"
				fill={`url(#${gradId})`}
				opacity="0.6"
			/>
			<line
				x1="1.5"
				y1="19"
				x2="1.5"
				y2="28"
				stroke={color}
				strokeOpacity="0.4"
				strokeWidth="1.5"
				strokeLinecap="round"
			/>
			<circle cx="1.5" cy="28" r="1" fill={color} opacity="0.3" />
			<rect x="22" y="15.5" width="4" height="1.5" rx="0.3" fill={color} opacity="0.15" />
		</svg>
	);
}

function SniperSilhouette({ color, gradId }: SilhouetteProps) {
	return (
		<svg viewBox="0 0 48 48" fill="none">
			<defs>
				<linearGradient
					id={gradId}
					x1="0"
					y1="16"
					x2="48"
					y2="28"
					gradientUnits="userSpaceOnUse"
				>
					<stop stopColor={color} stopOpacity="0.5" />
					<stop offset="0.5" stopColor={color} stopOpacity="1" />
					<stop offset="1" stopColor={color} stopOpacity="0.6" />
				</linearGradient>
			</defs>
			<rect x="24" y="19" width="22" height="2" rx="0.6" fill={`url(#${gradId})`} />
			<path d="M44 17.5h3.5v5H44z" fill={color} opacity="0.45" />
			<line
				x1="45"
				y1="18"
				x2="45"
				y2="22"
				stroke={color}
				strokeOpacity="0.25"
				strokeWidth="0.5"
			/>
			<line
				x1="46.5"
				y1="18"
				x2="46.5"
				y2="22"
				stroke={color}
				strokeOpacity="0.25"
				strokeWidth="0.5"
			/>
			<rect
				x="8"
				y="17"
				width="32"
				height="6"
				rx="1"
				fill={`url(#${gradId})`}
				opacity="0.9"
			/>
			<rect x="14" y="10.5" width="20" height="5" rx="2.5" fill={color} opacity="0.55" />
			<ellipse cx="34" cy="13" rx="2.5" ry="3" fill={color} opacity="0.4" />
			<ellipse cx="34" cy="13" rx="1.2" ry="1.5" fill={color} opacity="0.15" />
			<ellipse cx="14" cy="13" rx="1.5" ry="2.2" fill={color} opacity="0.35" />
			<rect x="20" y="15" width="2" height="2.5" rx="0.3" fill={color} opacity="0.3" />
			<rect x="28" y="15" width="2" height="2.5" rx="0.3" fill={color} opacity="0.3" />
			<circle cx="24" cy="11" r="1.2" fill={color} opacity="0.35" />
			<path d="M32 17v-2.5h2.5v2" fill={color} opacity="0.5" />
			<circle cx="34.5" cy="14.5" r="1" fill={color} opacity="0.4" />
			<path
				d="M16 23v4a2 2 0 002 2h2a2 2 0 002-2v-4"
				fill="none"
				stroke={color}
				strokeOpacity="0.4"
				strokeWidth="1"
			/>
			<rect x="22" y="23" width="5" height="7" rx="0.8" fill={color} opacity="0.55" />
			<path
				d="M0.5 17.5h8v6H3a2.5 2.5 0 01-2.5-2.5v-3.5z"
				fill={`url(#${gradId})`}
				opacity="0.85"
			/>
			<rect x="2" y="15.5" width="5" height="2.5" rx="0.8" fill={color} opacity="0.3" />
			<rect x="0" y="17" width="1.5" height="7" rx="0.5" fill={color} opacity="0.4" />
			<path
				d="M8 23h4.5l0.5 9a1.5 1.5 0 01-1.5 1.5h-2A1.5 1.5 0 018 32V23z"
				fill={color}
				opacity="0.7"
			/>
			<line
				x1="36"
				y1="23"
				x2="33.5"
				y2="35"
				stroke={color}
				strokeOpacity="0.5"
				strokeWidth="1.2"
				strokeLinecap="round"
			/>
			<line
				x1="38"
				y1="23"
				x2="40.5"
				y2="35"
				stroke={color}
				strokeOpacity="0.5"
				strokeWidth="1.2"
				strokeLinecap="round"
			/>
			<rect x="32" y="34.5" width="3" height="1" rx="0.3" fill={color} opacity="0.3" />
			<rect x="39.5" y="34.5" width="3" height="1" rx="0.3" fill={color} opacity="0.3" />
		</svg>
	);
}

const SILHOUETTE_MAP: Record<WeaponType, React.FC<SilhouetteProps>> = {
	pistol: PistolSilhouette,
	rifle: RifleSilhouette,
	smg: SmgSilhouette,
	sniper: SniperSilhouette,
};

// ── Sub-components ─────────────────────────────────────────────────────────────

function WeaponCategoryIcon({
	categoryId,
	isSelected = false,
	size = 36,
}: {
	categoryId: string;
	isSelected?: boolean;
	size?: number;
}) {
	const id = useId();
	const weaponType = WEAPON_CATEGORY_MAP[categoryId] || "rifle";
	const color = isSelected ? "rgb(var(--primaryColor))" : "rgba(255,255,255,0.55)";
	const SilhouetteComponent = SILHOUETTE_MAP[weaponType];

	return (
		<div
			style={{
				width: size,
				height: size,
				display: "flex",
				alignItems: "center",
				justifyContent: "center",
				filter: isSelected
					? "drop-shadow(0 0 8px rgba(var(--primaryColor), 0.45))"
					: "drop-shadow(0 1px 2px rgba(0,0,0,0.3))",
				transition: "filter 0.3s ease",
			}}
		>
			<SilhouetteComponent color={color} gradId={`wg-${id}`} />
		</div>
	);
}

function ActionCardIconWrapper({ children }: { children: React.ReactNode }) {
	return (
		<svg
			width="56"
			height="56"
			viewBox="0 0 56 56"
			fill="none"
			xmlns="http://www.w3.org/2000/svg"
		>
			{children}
		</svg>
	);
}

function TradeIcon() {
	return (
		<svg
			width="16"
			height="16"
			viewBox="0 0 21 21"
			fill="none"
			xmlns="http://www.w3.org/2000/svg"
		>
			<path
				d="M1.99957 5.59236L10.5 0.685669L19.0004 5.59236V15.4076L10.5 20.3143L1.99957 15.4076V5.59236Z"
				stroke="currentColor"
				strokeWidth="1.18696"
			/>
			<mask
				id="mask_troca_inv"
				style={{ maskType: "luminance" }}
				maskUnits="userSpaceOnUse"
				x="5"
				y="6"
				width="11"
				height="9"
			>
				<path d="M5.90649 6.56293H15.7491V14.4379H5.90741L5.90649 6.56293Z" fill="white" />
			</mask>
			<g mask="url(#mask_troca_inv)">
				<path
					d="M7.19486 10.5666H5.90747V7.84301H11.6733V6.56293C12.5763 7.20206 13.4538 7.82749 14.3513 8.4648L11.6788 10.3639V9.0948H7.19486V10.5666ZM9.99243 14.4379C9.07847 13.7897 8.20012 13.1624 7.30808 12.5297C8.20012 11.8978 9.07847 11.2733 9.97508 10.6324V11.8924H14.4526V10.4315H15.7492V13.1432H9.99243V14.4379Z"
					fill="currentColor"
				/>
			</g>
		</svg>
	);
}

function LockOverlay() {
	return (
		<div className="absolute inset-0 z-10 flex items-center justify-center" style={{ opacity: 1 }}>
			<svg
				width="80"
				height="80"
				viewBox="0 0 80 80"
				fill="none"
				xmlns="http://www.w3.org/2000/svg"
			>
				<g filter="url(#filter_lock_glow)">
					<rect
						x="40"
						y="12.2"
						width="39.3"
						height="39.3"
						rx="4"
						transform="rotate(45 40 12.2)"
						stroke="white"
						strokeOpacity="0.75"
						strokeWidth="1.6"
					/>
				</g>
				<defs>
					<filter
						id="filter_lock_glow"
						x="0"
						y="0"
						width="80"
						height="80"
						filterUnits="userSpaceOnUse"
						colorInterpolationFilters="sRGB"
					>
						<feFlood floodOpacity="0" result="BackgroundImageFix" />
						<feColorMatrix
							in="SourceAlpha"
							type="matrix"
							values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
							result="hardAlpha"
						/>
						<feOffset />
						<feGaussianBlur stdDeviation="5" />
						<feComposite in2="hardAlpha" operator="out" />
						<feColorMatrix
							type="matrix"
							values="0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0.45 0"
						/>
						<feBlend mode="normal" in2="BackgroundImageFix" result="effect1" />
						<feBlend mode="normal" in="SourceGraphic" in2="effect1" result="shape" />
					</filter>
				</defs>
			</svg>
			<svg
				className="absolute"
				width="22"
				height="22"
				viewBox="0 0 24 24"
				fill="none"
				stroke="white"
				strokeWidth="2"
				strokeLinecap="round"
				strokeLinejoin="round"
			>
				<rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
				<path d="M7 11V7a5 5 0 0 1 10 0v4" />
				<circle cx="12" cy="16.5" r="1.5" fill="white" stroke="none" />
			</svg>
		</div>
	);
}

function EquippedBadge({ rgb }: { rgb: string }) {
	return (
		<div
			className="absolute right-[8px] top-[8px] z-10 flex h-[24px] items-center justify-center rounded-[4px] p-[3px]"
			style={{ border: `0.7px solid rgb(${rgb})` }}
		>
			<div
				className="flex items-center justify-center gap-[3px] self-stretch rounded-[3px] px-[8px]"
				style={{
					border: `0.7px solid rgb(${rgb})`,
					background: `rgba(${rgb}, 0.90)`,
				}}
			>
				<span
					className="text-center font-bold text-[11px] uppercase tracking-[-0.44px] text-white"
					style={{ fontFamily: "Montserrat, sans-serif" }}
				>
					EQUIPADO
				</span>
			</div>
		</div>
	);
}

// ── 3D Model Viewer ────────────────────────────────────────────────────────────

function ModelScene({ url, onLoaded }: { url: string; onLoaded: () => void }) {
	const { scene } = useGLTF(url);
	onLoaded();
	return (
		<Bounds fit clip observe margin={1.4}>
			<Center>
				<primitive object={scene} />
			</Center>
		</Bounds>
	);
}

function ModelViewer({ viewerUrl, className }: { viewerUrl: string; className?: string }) {
	const [loading, setLoading] = useState(true);

	return (
		<div className={className} style={{ position: "relative" }}>
			{loading && (
				<div
					style={{
						position: "absolute",
						inset: 0,
						display: "flex",
						alignItems: "center",
						justifyContent: "center",
						zIndex: 10,
					}}
				>
					<span
						style={{
							fontFamily: "Montserrat, sans-serif",
							fontSize: 13,
							color: "#7A7A7A",
						}}
					>
						Carregando modelo...
					</span>
				</div>
			)}
			<Canvas
				camera={{ position: [0, 0.15, 0.8], fov: 50 }}
				style={{ width: "100%", height: "100%" }}
			>
				<ambientLight intensity={1} />
				<directionalLight position={[5, 5, 5]} intensity={1.5} />
				<directionalLight position={[-3, -2, -3]} intensity={0.5} />
				<directionalLight position={[0, 5, -5]} intensity={0.3} />
				<Suspense fallback={null}>
					<ModelScene url={viewerUrl} onLoaded={() => setLoading(false)} />
				</Suspense>
				<OrbitControls
					enableZoom
					minDistance={0.3}
					maxDistance={3}
					enablePan={false}
					autoRotate
					autoRotateSpeed={2}
					minPolarAngle={Math.PI / 3}
					maxPolarAngle={Math.PI / 1.5}
				/>
			</Canvas>
		</div>
	);
}

// ── Inventory SkinCard ─────────────────────────────────────────────────────────

function InventorySkinCard({ skin, onClick }: { skin: Skin; onClick: () => void }) {
	const rarityData = RARITY_MAP[skin.rarity] || RARITY_MAP.comum;
	const color = `rgb(${rarityData.rgb})`;
	const image = skin.image || skinFallbackImage;

	return (
		<div
			onClick={onClick}
			className="group relative flex cursor-pointer flex-col items-center overflow-hidden rounded-[6px] transition-colors"
			style={{
				opacity: skin.owned ? undefined : 0.5,
				background: skin.owned
					? `linear-gradient(180deg, rgba(${rarityData.rgb}, 0.24) -17.86%, rgba(${rarityData.rgb}, 0) 53.57%), rgba(12, 12, 12, 0.24)`
					: `radial-gradient(120.23% 120.23% at 50% 128.24%, rgba(255, 255, 255, 0.11) 0%, rgba(153, 153, 153, 0.00) 86.08%), linear-gradient(180deg, rgba(${rarityData.rgb}, 0.32) -17.86%, rgba(${rarityData.rgb}, 0.00) 53.57%), rgba(12, 12, 12, 0.24)`,
				boxShadow: skin.equipped
					? undefined
					: `inset 0 -2px 0 0 rgba(0, 0, 0, 0.6), inset 0 -2px 0 0 ${color}`,
				border: skin.equipped ? `1px solid ${color}` : "1px solid transparent",
			}}
		>
			{!skin.equipped && <div className="h-[1px] w-full" style={{ background: color }} />}
			{skin.equipped && <EquippedBadge rgb={rarityData.rgb} />}
			{skin.owned && skin.quantity && skin.quantity > 1 && (
				<div
					className="absolute left-[8px] top-[8px] z-10 flex h-[22px] items-center justify-center rounded-[4px] px-[6px]"
					style={{
						background: "rgba(0, 0, 0, 0.60)",
						border: "0.7px solid rgba(255, 255, 255, 0.20)",
					}}
				>
					<span
						className="font-bold text-[11px] tracking-[-0.44px] text-white/80"
						style={{ fontFamily: "Montserrat, sans-serif" }}
					>
						x{skin.quantity}
					</span>
				</div>
			)}
			<div className="relative flex h-[120px] w-full items-center justify-center py-[8px]">
				<div className="scale-[1.3]">
					<DiamondIcon color={color} />
				</div>
				<img
					src={image}
					alt={skin.name}
					className="absolute max-h-[100px] w-[85%] object-contain transition-transform group-hover:scale-105"
					onError={(e) => {
						(e.target as HTMLImageElement).src = skinFallbackImage;
					}}
				/>
				{!skin.owned && <LockOverlay />}
			</div>
			<div className="flex flex-col items-center gap-[3px] pb-[10px]">
				<span
					className="w-full truncate px-[4px] text-center font-semibold text-[16px] tracking-[-0.64px] text-[#F2F2F2]"
					style={{ fontFamily: "Montserrat, sans-serif" }}
				>
					{skin.name}
				</span>
				{skin.owned && skin.temporary && typeof skin.daysLeft === "number" && (
					<span
						className="rounded-[3px] px-[7px] py-[1px] font-bold text-[10px] uppercase tracking-[-0.2px]"
						style={{
							fontFamily: "Montserrat, sans-serif",
							color: skin.daysLeft <= 3 ? "#FF6B6B" : "#FFC65C",
							background: skin.daysLeft <= 3 ? "rgba(255, 107, 107, 0.12)" : "rgba(255, 198, 92, 0.12)",
							border: `0.7px solid ${skin.daysLeft <= 3 ? "rgba(255, 107, 107, 0.5)" : "rgba(255, 198, 92, 0.5)"}`,
						}}
					>
						{skin.daysLeft <= 0 ? "Expira hoje" : `⏳ ${skin.daysLeft} ${skin.daysLeft === 1 ? "dia" : "dias"}`}
					</span>
				)}
			</div>
		</div>
	);
}

// ── Helpers ────────────────────────────────────────────────────────────────────

function groupByRarity(skins: Skin[]): Record<string, Skin[]> {
	const order = ["lendario", "epico", "raro", "comum"];
	const groups: Record<string, Skin[]> = {};
	for (const rarity of order) {
		const items = skins.filter((s) => s.rarity === rarity);
		if (items.length > 0) groups[rarity] = items;
	}
	return groups;
}

function resolveSelectedCategory(weapons: WeaponCategory[], preferredId?: string): string {
	const trimmed = (preferredId || "").trim();
	if (trimmed && weapons.some((w) => w.id === trimmed)) return trimmed;
	return weapons[0]?.id ?? "";
}

// ── Main Component ─────────────────────────────────────────────────────────────

export function Inventario() {
	const setPreviewMode = useVisibility((s) => s.setPreviewMode);
	const setCanCloseUi = useVisibility((s) => s.setCanCloseUi);
	const cache = useDataCache();

	const [weapons, setWeapons] = useState<WeaponCategory[]>([]);
	const [selectedCategory, setSelectedCategory] = useState("");
	const [activeTab, setActiveTab] = useState("Todos");
	const [search, setSearch] = useState("");
	const [selectedSkin, setSelectedSkin] = useState<Skin | null>(null);
	const [isClosing, setIsClosing] = useState(false);
	const [modalVisible, setModalVisible] = useState(false);
	const [isReady, setIsReady] = useState(false);
	const [isLoading, setIsLoading] = useState(true);
	const [inspectMode, setInspectMode] = useState<InspectMode>(false);
	const [weaponTestEnabled, setWeaponTestEnabled] = useState(false);
	const [isEquipping, setIsEquipping] = useState(false);
	const [isBuying, setIsBuying] = useState(false);
	const setSkinsCoins = useMainStore((s) => s.setSkinsCoins);
	const durations = useMainStore((s) => s.durations);

	// ── Data loading ───────────────────────────────────────────────────────

	const loadInventory = useCallback(
		async (forceRefresh?: boolean) => {
			const savedCategory = await fetchNui<string>({
				path: "get:inventoryWeaponCategory",
				mockData: "",
			});

			if (!forceRefresh) {
				const cached = cache.get("inventory", 5_000) as WeaponCategory[] | null;
				if (cached) {
					setWeapons(cached);
					setSelectedCategory(resolveSelectedCategory(cached, savedCategory));
					setIsLoading(false);
					return;
				}
			}

			setIsLoading(true);
			const data = await fetchNui<WeaponCategory[]>({
				path: "get:inventory",
				mockData: MOCK_INVENTORY,
			});
			if (data && data.length > 0) {
				setWeapons(data);
				setSelectedCategory(resolveSelectedCategory(data, savedCategory));
				cache.set("inventory", data);
			}
			setIsLoading(false);
		},
		[],
	);

	useEffect(() => {
		loadInventory().then(() => {
			requestAnimationFrame(() => setIsReady(true));
		});
	}, [loadInventory]);

	// Whether the weapon test (teleport to firing range) is enabled server-side.
	// When off, only 3D inspection is available and the "Testar" button is hidden.
	useEffect(() => {
		fetchNui<boolean>({ path: "get:weaponTestEnabled", mockData: true }).then((enabled) => {
			setWeaponTestEnabled(enabled === true);
		});
	}, []);

	// Show modal animation after selectedSkin changes
	useEffect(() => {
		if (selectedSkin) requestAnimationFrame(() => setModalVisible(true));
	}, [selectedSkin]);

	// ── Modal close handler ────────────────────────────────────────────────

	const closeModal = () => {
		if (inspectMode === "ingame") {
			fetchNui({ path: "post:stopPreview3D" });
			setPreviewMode(false);
		}
		setIsClosing(true);
		setModalVisible(false);
		setTimeout(() => {
			setSelectedSkin(null);
			setIsClosing(false);
			setInspectMode(false);
		}, 400);
	};

	// ESC handler for modal (non-ingame)
	useEffect(() => {
		if (!selectedSkin || inspectMode === "ingame") return;
		const handler = (e: KeyboardEvent) => {
			if (e.key === "Escape") {
				e.stopPropagation();
				closeModal();
			}
		};
		window.addEventListener("keydown", handler, true);
		return () => window.removeEventListener("keydown", handler, true);
	}, [selectedSkin, inspectMode]);

	// ── Equip / Unequip ────────────────────────────────────────────────────

	const handleEquip = async (skin: Skin) => {
		if (!skin.owned || isEquipping) return;
		setIsEquipping(true);
		try {
			const path = skin.equipped ? "post:unequip" : "post:equip";
			await fetchNui({ path, payload: { modelName: skin.model_name } });
			await loadInventory(true);
			closeModal();
		} finally {
			setIsEquipping(false);
		}
	};

	// ── Buy ────────────────────────────────────────────────────────────────

	const handleBuy = async (skin: Skin, durationId?: string) => {
		if (skin.owned || isBuying || (skin.price ?? 0) <= 0) return;
		setIsBuying(true);
		try {
			const result = await fetchNui<{ skinsCoins?: number } | false>({
				path: "post:purchaseSkin",
				payload: { modelName: skin.model_name, durationId },
				mockData: { skinsCoins: 0 },
			});
			if (!result) return;
			if (typeof result.skinsCoins === "number") setSkinsCoins(result.skinsCoins);
			await loadInventory(true);
			closeModal();
		} finally {
			setIsBuying(false);
		}
	};

	// ── Derived state ──────────────────────────────────────────────────────

	const currentWeapon = weapons.find((w) => w.id === selectedCategory) || weapons[0];
	const hasOwnedSkins = weapons.some((w) => w.skins.some((s) => s.owned));

	const hasEquippedInCategory =
		selectedCategory === "__colecao__"
			? weapons.some((w) => w.skins.some((s) => s.equipped))
			: (currentWeapon?.skins || []).some((s) => s.equipped);

	// Reset tab when no equipped skins in category
	useEffect(() => {
		if (activeTab === "Equipadas" && !hasEquippedInCategory) setActiveTab("Todos");
	}, [selectedCategory, hasEquippedInCategory, activeTab]);

	// Filter skins
	let filteredSkins: Skin[] = [];
	if (selectedCategory === "__colecao__") {
		filteredSkins = weapons.flatMap((w) => w.skins.filter((s) => s.owned));
	} else {
		filteredSkins = currentWeapon?.skins || [];
	}
	if (activeTab === "Equipadas") {
		filteredSkins = filteredSkins.filter((s) => s.equipped);
	}
	if (search) {
		filteredSkins = filteredSkins.filter((s) =>
			s.name.toLowerCase().includes(search.toLowerCase()),
		);
	}

	const groupedSkins = groupByRarity(filteredSkins);

	// ── In-game preview escape handler ─────────────────────────────────────

	const exitPreview = useCallback(() => {
		setPreviewMode(false);
		setInspectMode(false);
		setModalVisible(false);
		setIsClosing(true);
		setTimeout(() => {
			fetchNui({ path: "post:stopPreview3D" });
			setSelectedSkin(null);
			setIsClosing(false);
		}, 500);
	}, [setPreviewMode]);

	useEffect(() => {
		if (inspectMode !== "ingame") {
			setCanCloseUi(true);
			return;
		}
		setCanCloseUi(false);
		const handler = (e: KeyboardEvent) => {
			if (e.key === "Escape") {
				e.stopImmediatePropagation();
				exitPreview();
			}
		};
		window.addEventListener("keydown", handler, true);
		return () => window.removeEventListener("keydown", handler, true);
	}, [inspectMode, setCanCloseUi, exitPreview]);

	// ── Loading state ──────────────────────────────────────────────────────

	if (isLoading && weapons.length === 0) {
		return (
			<div className="flex h-full w-full items-center justify-center">
				<span
					className="text-[14px] text-[#7A7A7A]"
					style={{ fontFamily: "Montserrat, sans-serif" }}
				>
					Carregando inventário...
				</span>
			</div>
		);
	}

	// ── Action cards for modal ─────────────────────────────────────────────

	const actionCards = [
		{
			title: "Inspecionar",
			description: "Visualize a skin aplicada na arma.",
			image: inspectBg,
			onClick: () => {
				if (selectedSkin) {
					fetchNui({
						path: "post:preview3D",
						payload: { modelName: selectedSkin.model_name },
					});
					setPreviewMode(true);
				}
				setInspectMode("ingame");
			},
			icon: (
				<g transform="translate(27.5, 28.5)">
					<path
						d="M9 4.5C5.4 4.5 2.3 6.6 0.6 9.5C2.3 12.4 5.4 14.5 9 14.5C12.6 14.5 15.7 12.4 17.4 9.5C15.7 6.6 12.6 4.5 9 4.5Z"
						stroke="white"
						strokeWidth="1.5"
						fill="none"
					/>
					<circle cx="9" cy="9.5" r="3" stroke="white" strokeWidth="1.5" fill="none" />
					<circle cx="9" cy="9.5" r="1" fill="white" />
				</g>
			),
		},
		...(selectedSkin?.owned
			? [
					{
						title: selectedSkin?.equipped ? "Desequipar" : "Equipar",
						description: selectedSkin?.equipped
							? "Remova a skin e volte ao visual original."
							: "Aplique esta skin na sua arma.",
						image: equipBg,
						icon: (
							<g transform="translate(27, 26)">
								<path
									d="M9.5 2L2 5.5V12C2 15.5 5.3 18.5 9.5 20C13.7 18.5 17 15.5 17 12V5.5L9.5 2Z"
									stroke="white"
									strokeWidth="1.5"
									fill="none"
									strokeLinejoin="round"
								/>
								{selectedSkin?.equipped ? (
									<path
										d="M6.5 11L8.5 13L12.5 9"
										stroke="white"
										strokeWidth="1.8"
										strokeLinecap="round"
										strokeLinejoin="round"
										fill="none"
										opacity="0.5"
									/>
								) : (
									<path
										d="M6.5 11L8.5 13L12.5 9"
										stroke="white"
										strokeWidth="1.8"
										strokeLinecap="round"
										strokeLinejoin="round"
										fill="none"
									/>
								)}
							</g>
						),
						onClick: () => {
							if (!isEquipping && selectedSkin) handleEquip(selectedSkin);
						},
					},
				]
			: []),
		...(!selectedSkin?.owned && (selectedSkin?.price ?? 0) > 0
			? (() => {
					const perSkin = selectedSkin?.durations;
					const opts =
						perSkin && perSkin.length > 0
							? perSkin
							: durations.length > 0
								? durations
								: [{ id: undefined as string | undefined, label: "Permanente", days: 0, price: null }];
					return opts;
				})().map((dur) => {
					const price = dur.price ?? selectedSkin?.price ?? 0;
					const isPerm = (dur.days ?? 0) <= 0;
					return {
						title: isPerm ? "Comprar" : `Comprar · ${dur.label}`,
						description: isPerm
							? `Permanente por ${price} SkinsCoins.`
							: `${dur.label} por ${price} SkinsCoins.`,
						image: equipBg,
						icon: (
							<g transform="translate(27, 27)">
								<path
									d="M2 2H4L5.6 12H15L17 5H6"
									stroke="white"
									strokeWidth="1.5"
									fill="none"
									strokeLinecap="round"
									strokeLinejoin="round"
								/>
								<circle cx="7" cy="16" r="1.4" fill="white" />
								<circle cx="14" cy="16" r="1.4" fill="white" />
							</g>
						),
						onClick: () => {
							if (!isBuying && selectedSkin) handleBuy(selectedSkin, dur.id);
						},
					};
				})
			: []),
	];

	// ── Render ─────────────────────────────────────────────────────────────

	return (
		<div className="flex h-full w-full flex-col pb-[32px]">
			{/* Header */}
			<div
				className="flex items-center gap-[10px] py-[16px] transition-opacity duration-300 ease-out"
				style={{ opacity: isReady ? 1 : 0 }}
			>
				<DiamondIcon />
				<span
					className="font-semibold text-[19px] tracking-[-0.95px] text-white"
					style={{
						fontFamily: "Montserrat, sans-serif",
						textShadow: "0 0 18px rgba(255, 255, 255, 0.35)",
					}}
				>
					Seu inventário
				</span>
			</div>

			<div className="flex min-h-0 flex-1 gap-[8px]">
				{/* ── Weapon Category Sidebar ───────────────────────────────── */}
				<div
					className="flex w-[340px] shrink-0 flex-col gap-[6px] transition-all duration-[450ms] ease-out"
					style={{
						opacity: isReady ? 1 : 0,
						transform: isReady ? "translateX(0)" : "translateX(-24px)",
						transitionDelay: "0.1s",
					}}
				>
					<div className="scrollbar-custom flex flex-1 flex-col gap-[4px] overflow-y-auto pr-[10px]">
						{/* Coleção button */}
						{hasOwnedSkins &&
							(() => {
								const isActive = selectedCategory === "__colecao__";
								return (
									<button
										key="__colecao__"
										type="button"
										onClick={() => {
											setSelectedCategory("__colecao__");
											setSearch("");
										}}
										className="group flex h-[64px] shrink-0 cursor-pointer items-center justify-center self-stretch rounded-[6px] p-[4px] transition-colors"
										style={
											isActive
												? { border: "0.7px solid rgb(var(--primaryColor))" }
												: { border: "0.7px solid rgba(255, 255, 255, 0.16)" }
										}
									>
										<div
											className={`flex flex-1 items-center self-stretch rounded-[5px] px-[14px] transition-all duration-300 ${
												isActive
													? ""
													: "border-[0.7px] border-white/[.06] bg-white/[.08] group-hover:border-white/[.16] group-hover:bg-white/[.14]"
											}`}
											style={
												isActive
													? {
															border: "0.7px solid rgba(var(--primaryColor), 0.60)",
															background:
																"linear-gradient(144deg, rgba(var(--primaryColor), 0.30) -1.71%, rgba(var(--primaryColor), 0.00) 88.86%), rgba(255, 255, 255, 0.02)",
															boxShadow: "0 0 11.4px 0 rgba(0, 0, 0, 0.30)",
														}
													: undefined
											}
										>
											<div
												className={`flex h-[40px] w-[40px] shrink-0 items-center justify-center ${
													isActive
														? ""
														: "transition-transform duration-300 group-hover:translate-x-[6px]"
												}`}
											>
												<svg
													width="28"
													height="28"
													viewBox="0 0 24 24"
													fill="none"
													xmlns="http://www.w3.org/2000/svg"
												>
													<path
														d="M4 4H10V10H4V4Z"
														fill={isActive ? "rgb(var(--primaryColor))" : "#ADADAD"}
													/>
													<path
														d="M14 4H20V10H14V4Z"
														fill={isActive ? "rgb(var(--primaryColor))" : "#ADADAD"}
													/>
													<path
														d="M4 14H10V20H4V14Z"
														fill={isActive ? "rgb(var(--primaryColor))" : "#ADADAD"}
													/>
													<path
														d="M14 14H20V20H14V14Z"
														fill={isActive ? "rgb(var(--primaryColor))" : "#ADADAD"}
													/>
												</svg>
											</div>
											<div
												className={`ml-[10px] flex flex-col items-start justify-center gap-[2px] ${
													isActive
														? ""
														: "transition-transform duration-300 group-hover:translate-x-[6px]"
												}`}
											>
												<span
													className={`whitespace-nowrap font-semibold text-[14px] tracking-[-0.56px] ${
														isActive ? "text-white" : "text-[#F2F2F2]"
													}`}
													style={{ fontFamily: "Montserrat, sans-serif" }}
												>
													Coleção
												</span>
												<span
													className="whitespace-nowrap font-normal text-[11px] tracking-[-0.44px] text-white/50"
													style={{ fontFamily: "Montserrat, sans-serif" }}
												>
													Minhas skins
												</span>
											</div>
										</div>
									</button>
								);
							})()}

						{/* Weapon categories */}
						{weapons.map((weapon) => {
							const isActive = weapon.id === selectedCategory;
							return (
								<button
									key={weapon.id}
									type="button"
									onClick={() => {
										setSelectedCategory(weapon.id);
										setSearch("");
									}}
									className="group flex h-[64px] shrink-0 cursor-pointer items-center justify-center self-stretch rounded-[6px] p-[4px] transition-colors"
									style={
										isActive
											? { border: "0.7px solid rgb(var(--primaryColor))" }
											: { border: "0.7px solid rgba(255, 255, 255, 0.16)" }
									}
								>
									<div
										className={`flex flex-1 items-center self-stretch rounded-[5px] px-[14px] transition-all duration-300 ${
											isActive
												? ""
												: "border-[0.7px] border-white/[.06] bg-white/[.08] group-hover:border-white/[.16] group-hover:bg-white/[.14]"
										}`}
										style={
											isActive
												? {
														border: "0.7px solid rgba(var(--primaryColor), 0.60)",
														background:
															"linear-gradient(144deg, rgba(var(--primaryColor), 0.30) -1.71%, rgba(var(--primaryColor), 0.00) 88.86%), rgba(255, 255, 255, 0.02)",
														boxShadow: "0 0 11.4px 0 rgba(0, 0, 0, 0.30)",
													}
												: undefined
										}
									>
										<div
											className={`flex h-[40px] w-[40px] shrink-0 items-center justify-center ${
												isActive
													? ""
													: "transition-transform duration-300 group-hover:translate-x-[6px]"
											}`}
										>
											<WeaponCategoryIcon
												categoryId={weapon.id}
												isSelected={isActive}
												size={34}
											/>
										</div>
										<div
											className={`ml-[10px] flex flex-col items-start justify-center gap-[2px] ${
												isActive
													? ""
													: "transition-transform duration-300 group-hover:translate-x-[6px]"
											}`}
										>
											<span
												className={`whitespace-nowrap font-semibold text-[14px] tracking-[-0.56px] ${
													isActive ? "text-white" : "text-[#F2F2F2]"
												}`}
												style={{ fontFamily: "Montserrat, sans-serif" }}
											>
												{weapon.name}
											</span>
											<span
												className="whitespace-nowrap font-normal text-[11px] tracking-[-0.44px] text-white/50"
												style={{ fontFamily: "Montserrat, sans-serif" }}
											>
												{weapon.skinsCount} skins
											</span>
										</div>
									</div>
								</button>
							);
						})}
					</div>
				</div>

				{/* ── Main Content Area ─────────────────────────────────────── */}
				<div
					className="flex min-h-0 flex-1 flex-col gap-[16px] transition-all duration-[450ms] ease-out"
					style={{
						opacity: isReady ? 1 : 0,
						transform: isReady ? "translateX(0)" : "translateX(24px)",
						transitionDelay: "0.15s",
					}}
				>
					{/* Filter bar */}
					<div className="flex shrink-0 items-center justify-between">
						<div className="flex items-center gap-[6px]">
							{FILTER_TABS.filter((tab) => tab !== "Equipadas" || hasEquippedInCategory).map(
								(tab) => {
									const isActive = activeTab === tab;
									return (
										<button
											key={tab}
											type="button"
											onClick={() => setActiveTab(tab)}
											className={`flex h-[34px] cursor-pointer items-center justify-center rounded-[6px] border-[0.7px] p-[2px] transition-all ${
												isActive
													? "border-[rgb(var(--primaryColor))]"
													: "border-white/[.16] hover:border-white/[.25] hover:brightness-125"
											}`}
										>
											<div
												className="flex h-full items-center justify-center self-stretch rounded-[4px] px-[16px]"
												style={
													isActive
														? {
																border: "0.7px solid rgba(var(--primaryColor), 0.60)",
																background:
																	"linear-gradient(135deg, rgb(var(--primaryColor)) -47.65%, rgba(var(--primaryColor), 0.50) 122.65%)",
															}
														: {
																border: "0.7px solid rgba(255, 255, 255, 0.06)",
																background: "rgba(255, 255, 255, 0.08)",
															}
												}
											>
												<span
													className={`font-medium text-[13px] tracking-[-0.52px] ${
														isActive ? "text-white" : "text-[#BFBFBF]"
													}`}
													style={{ fontFamily: "Montserrat, sans-serif" }}
												>
													{tab}
												</span>
											</div>
										</button>
									);
								},
							)}
						</div>

						<div className="flex items-center gap-[12px]">
							{/* Search */}
							<div className="h-[34px] w-[260px] rounded-[6px] border-[0.7px] border-white/[.16] p-[2px] transition-colors hover:border-white/[.25]">
								<div className="flex h-full items-center gap-[8px] rounded-[4px] border-[0.7px] border-white/[.06] bg-[#080808]/[.38] px-[8px]">
									<input
										type="text"
										placeholder="Pesquisar item..."
										value={search}
										onChange={(e) => setSearch(e.target.value)}
										className="flex-1 bg-transparent text-[12px] tracking-[-0.48px] text-[#ADADAD] placeholder-[#ADADAD] outline-none"
										style={{ fontFamily: "Montserrat, sans-serif" }}
									/>
									<SearchIcon />
								</div>
							</div>

							{/* Trade button (disabled) */}
							<button
								type="button"
								disabled
								className="flex h-[34px] cursor-not-allowed items-center justify-center rounded-[6px] p-[2px] opacity-50"
								style={{ border: "0.7px solid rgb(var(--primaryColor))" }}
							>
								<div
									className="flex h-full items-center justify-center gap-[6px] self-stretch rounded-[4px] px-[14px]"
									style={{
										border: "0.7px solid rgba(var(--primaryColor), 0.60)",
										background:
											"linear-gradient(135deg, rgb(var(--primaryColor)) -47.65%, rgba(var(--primaryColor), 0.50) 122.65%)",
									}}
								>
									<TradeIcon />
									<span
										className="font-semibold text-[13px] tracking-[-0.52px] text-white"
										style={{ fontFamily: "Montserrat, sans-serif" }}
									>
										Troca
									</span>
								</div>
							</button>
						</div>
					</div>

					{/* Skin grid */}
					<div
						className="scrollbar-custom flex-1 overflow-y-auto rounded-[6px] p-[16px]"
						style={{ border: "0.7px solid rgba(255, 255, 255, 0.16)" }}
					>
						{Object.entries(groupedSkins).map(([rarity, skins]) => {
							const rarityData = RARITY_MAP[rarity] || RARITY_MAP.comum;
							return (
								<div key={rarity} className="mb-[20px]">
									<span
										className="mb-[10px] block font-semibold text-[15px] tracking-[-0.6px] text-[#F2F2F2]"
										style={{ fontFamily: "Montserrat, sans-serif" }}
									>
										{rarityData.label}
									</span>
									<div className="grid grid-cols-[repeat(auto-fill,minmax(220px,1fr))] gap-[12px]">
										{skins.map((skin) => (
											<InventorySkinCard
												key={skin.model_name}
												skin={skin}
												onClick={() => setSelectedSkin(skin)}
											/>
										))}
									</div>
								</div>
							);
						})}
						{Object.keys(groupedSkins).length === 0 && (
							<div className="flex h-[200px] items-center justify-center">
								<span
									className="font-medium text-[14px] tracking-[-0.56px] text-[#7A7A7A]"
									style={{ fontFamily: "Montserrat, sans-serif" }}
								>
									Nenhuma skin encontrada
								</span>
							</div>
						)}
					</div>
				</div>
			</div>

			{/* ── Detail Modal ──────────────────────────────────────────────── */}
			{(selectedSkin || isClosing) && (
				<div
					data-modal-open
					className="fixed inset-0 z-50 flex items-center justify-center"
					onClick={closeModal}
				>
					<div
						className="absolute inset-0 bg-[#141414]/85 transition-opacity duration-300"
						style={{ opacity: modalVisible ? 1 : 0 }}
					/>
					<div
						className="relative flex flex-col items-stretch gap-[12px] rounded-[12px] p-[12px]"
						style={{
							border: "0.7px solid rgba(255, 255, 255, 0.16)",
							opacity: modalVisible ? 1 : 0,
							transform: modalVisible ? "translateY(0)" : "translateY(-100vh)",
							transition: isClosing
								? "opacity 0.3s ease-in, transform 0.35s ease-in"
								: "opacity 0.4s cubic-bezier(0.16,1,0.3,1), transform 0.4s cubic-bezier(0.16,1,0.3,1)",
						}}
						onClick={(e) => e.stopPropagation()}
					>
						{inspectMode === "browser" && selectedSkin ? (
							<>
								<div
									className="relative h-[350px] w-[430px] overflow-hidden"
									style={{
										border: "1px solid rgba(255, 255, 255, 0.10)",
										background: "rgba(12, 12, 12, 0.6)",
									}}
								>
									{selectedSkin.viewer_url ? (
										<ModelViewer
											viewerUrl={selectedSkin.viewer_url}
											className="h-full w-full"
										/>
									) : (
										<div className="flex h-full w-full items-center justify-center p-[24px]">
											<img
												src={selectedSkin.image || skinFallbackImage}
												alt={selectedSkin.name}
												className="max-h-full max-w-full object-contain"
												onError={(e) => {
													(e.target as HTMLImageElement).src = skinFallbackImage;
												}}
											/>
										</div>
									)}
									<div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-[16px]">
										<span
											className="font-bold text-[20px] tracking-[-0.8px] text-white"
											style={{ fontFamily: "Rajdhani, sans-serif" }}
										>
											{selectedSkin.name}
										</span>
									</div>
								</div>
								<button
									type="button"
									onClick={() => setInspectMode(false)}
									className="flex h-[40px] cursor-pointer self-stretch border border-white/[.10] p-[3px] transition-colors hover:border-white/[.20]"
								>
									<div
										className="flex flex-1 items-center justify-center gap-[4px] self-stretch px-[9px]"
										style={{ background: "rgba(255, 255, 255, 0.05)" }}
									>
										<span
											className="font-semibold text-[14px] tracking-[-0.56px] text-[#F2F2F2]/80"
											style={{ fontFamily: "Barlow, sans-serif" }}
										>
											Voltar
										</span>
									</div>
								</button>
							</>
						) : (
							<>
								{actionCards.map((card) => (
									<div
										key={card.title}
										onClick={"onClick" in card ? card.onClick : undefined}
										className="group flex cursor-pointer rounded-[9px] border-[0.7px] border-white/[.12] p-[5px] transition-all hover:border-[1.5px] hover:border-primaryColor"
										style={
											(isEquipping || isBuying) && "onClick" in card
												? { opacity: 0.5, pointerEvents: "none" as const }
												: undefined
										}
									>
										<button
											type="button"
											className="relative flex h-[150px] w-[430px] flex-col items-center justify-center overflow-hidden rounded-[8px] px-[32px]"
											style={{
												background: `url(${card.image}) center / cover no-repeat`,
											}}
										>
											<div className="relative flex w-full items-center gap-[10px]">
												<div className="flex flex-1 flex-col items-start gap-[2px] transition-transform duration-300 group-hover:translate-x-[10px]">
													<span
														className="font-bold text-[24px] tracking-[-0.96px] text-white"
														style={{
															fontFamily: "Montserrat, sans-serif",
															textShadow: "0 0 18px rgba(255, 255, 255, 0.19)",
														}}
													>
														{card.title}
													</span>
													<span
														className="font-normal text-[14px] tracking-[-0.56px] text-[#ADADAD]"
														style={{ fontFamily: "Montserrat, sans-serif" }}
													>
														{card.description}
													</span>
												</div>
												<ActionCardIconWrapper>{card.icon}</ActionCardIconWrapper>
											</div>
										</button>
									</div>
								))}
								<button
									type="button"
									onClick={closeModal}
									className="flex h-[40px] cursor-pointer self-stretch rounded-[6px] border-[0.7px] border-white/[.16] p-[3px] transition-colors hover:border-white/[.25]"
								>
									<div
										className="flex flex-1 items-center justify-center gap-[4px] self-stretch rounded-[5px] px-[9px]"
										style={{
											border: "0.8px solid rgba(255, 255, 255, 0.04)",
											background:
												"linear-gradient(0deg, rgba(255, 255, 255, 0.07) 0%, rgba(255, 255, 255, 0.07) 100%), linear-gradient(90deg, rgba(173, 173, 173, 0.07) 0%, rgba(71, 71, 71, 0.07) 100%)",
										}}
									>
										<span
											className="font-semibold text-[14px] tracking-[-0.56px] text-[#F2F2F2]/80"
											style={{ fontFamily: "Montserrat, sans-serif" }}
										>
											Cancelar
										</span>
									</div>
								</button>
							</>
						)}
					</div>
				</div>
			)}

			{/* ── In-game Preview Portal ────────────────────────────────────── */}
			{inspectMode === "ingame" &&
				selectedSkin &&
				ReactDOM.createPortal(
					(() => {
						const rarityData = RARITY_MAP[selectedSkin.rarity] || RARITY_MAP.comum;
						return (
							<div
								className="fixed inset-0 z-[9999]"
								style={{ cursor: "grab" }}
								onMouseMove={(e) => {
									if (e.buttons === 1) {
										fetchNui({
											path: "post:rotatePreview",
											payload: { x: e.movementX, y: e.movementY },
										});
									}
								}}
								onWheel={(e) => {
									fetchNui({
										path: "post:zoomPreview",
										payload: { delta: e.deltaY > 0 ? 3 : -3 },
									});
								}}
							>
								<style>
									{
										"@keyframes previewSlideUp { from { opacity: 0; transform: translateY(16px); } to { opacity: 1; transform: translateY(0); } }"
									}
								</style>

								{/* Skin info (bottom-left) */}
								<div
									className="absolute bottom-[24px] left-[24px] flex flex-col gap-[4px]"
									style={{ animation: "previewSlideUp 0.4s ease-out both" }}
								>
									<span
										className="font-semibold text-[13px] uppercase tracking-[0.1em]"
										style={{
											fontFamily: "Montserrat, sans-serif",
											color: `rgb(${rarityData.rgb})`,
										}}
									>
										{rarityData.label}
									</span>
									<span
										className="font-bold text-[26px] leading-none tracking-[-0.02em] text-white"
										style={{ fontFamily: "Montserrat, sans-serif" }}
									>
										{selectedSkin.name}
									</span>
								</div>

								{/* Controls bar (bottom-center) */}
								<div
									className="absolute bottom-[28px] left-0 right-0 flex items-center justify-center"
									style={{ animation: "previewSlideUp 0.4s ease-out 0.05s both" }}
								>
									<div className="flex items-center gap-[24px] rounded-[6px] border border-white/[.15] bg-black/60 px-[20px] py-[8px] backdrop-blur-sm">
										{/* Rotate hint */}
										<div className="flex items-center gap-[8px]">
											<div className="flex h-[30px] items-center justify-center rounded-[4px] border border-white/25 bg-white/[.08] px-[10px]">
												<svg
													width="16"
													height="16"
													viewBox="0 0 24 24"
													fill="none"
													xmlns="http://www.w3.org/2000/svg"
												>
													<path
														d="M5 9C5 9 7 4 12 4C17 4 19 9 19 9"
														stroke="white"
														strokeOpacity="0.85"
														strokeWidth="1.5"
														strokeLinecap="round"
													/>
													<rect
														x="9"
														y="8"
														width="6"
														height="10"
														rx="3"
														stroke="white"
														strokeOpacity="0.85"
														strokeWidth="1.5"
													/>
													<line
														x1="12"
														y1="11"
														x2="12"
														y2="13"
														stroke="white"
														strokeOpacity="0.85"
														strokeWidth="1.5"
														strokeLinecap="round"
													/>
												</svg>
											</div>
											<span
												className="text-[13px] font-medium text-white/60"
												style={{ fontFamily: "Montserrat, sans-serif" }}
											>
												Rotacionar
											</span>
										</div>

										<div className="h-[20px] w-[1px] bg-white/15" />

										{/* Zoom hint */}
										<div className="flex items-center gap-[8px]">
											<div className="flex h-[30px] items-center justify-center rounded-[4px] border border-white/25 bg-white/[.08] px-[10px]">
												<svg
													width="16"
													height="16"
													viewBox="0 0 24 24"
													fill="none"
													xmlns="http://www.w3.org/2000/svg"
												>
													<path
														d="M12 4L12 8M12 4L9 7M12 4L15 7"
														stroke="white"
														strokeOpacity="0.85"
														strokeWidth="1.5"
														strokeLinecap="round"
														strokeLinejoin="round"
													/>
													<path
														d="M12 20L12 16M12 20L9 17M12 20L15 17"
														stroke="white"
														strokeOpacity="0.85"
														strokeWidth="1.5"
														strokeLinecap="round"
														strokeLinejoin="round"
													/>
													<rect
														x="9"
														y="8"
														width="6"
														height="10"
														rx="3"
														stroke="white"
														strokeOpacity="0.85"
														strokeWidth="1.5"
													/>
												</svg>
											</div>
											<span
												className="text-[13px] font-medium text-white/60"
												style={{ fontFamily: "Montserrat, sans-serif" }}
											>
												Zoom
											</span>
										</div>

										{/* Test button (only when the weapon test is enabled in config) */}
										{weaponTestEnabled && (
											<>
												<div className="h-[20px] w-[1px] bg-white/15" />
												<button
													type="button"
													onClick={() => {
														if (selectedSkin) {
															exitPreview();
															fetchNui({
																path: "post:startWeaponTest",
																payload: { modelName: selectedSkin.model_name },
															});
														}
													}}
													className="flex h-[30px] cursor-pointer items-center justify-center rounded-[4px] border px-[14px] transition-colors hover:brightness-125"
													style={{
														borderColor: "rgba(var(--primaryColor), 0.6)",
														background: "rgba(var(--primaryColor), 0.12)",
													}}
												>
													<span
														className="text-[12px] font-semibold"
														style={{
															fontFamily: "Montserrat, sans-serif",
															color: "rgb(var(--primaryColor))",
														}}
													>
														Testar
													</span>
												</button>
											</>
										)}

										<div className="h-[20px] w-[1px] bg-white/15" />

										{/* ESC hint */}
										<div className="flex items-center gap-[8px]">
											<div className="flex h-[30px] items-center justify-center rounded-[4px] border border-white/25 bg-white/[.08] px-[10px]">
												<span
													className="text-[12px] font-semibold text-white/80"
													style={{ fontFamily: "Montserrat, sans-serif" }}
												>
													ESC
												</span>
											</div>
											<span
												className="text-[13px] font-medium text-white/60"
												style={{ fontFamily: "Montserrat, sans-serif" }}
											>
												Voltar
											</span>
										</div>
									</div>
								</div>

								{/* Back button (bottom-right) */}
								<button
									type="button"
									onClick={exitPreview}
									className="group absolute bottom-[24px] right-[24px] flex h-[38px] cursor-pointer items-center gap-[8px] rounded-[6px] border-[0.7px] border-white/[.16] p-[3px] transition-colors hover:border-white/[.25]"
									style={{ animation: "previewSlideUp 0.4s ease-out 0.1s both" }}
								>
									<div className="flex h-full items-center gap-[6px] rounded-[5px] border-[0.7px] border-white/[.06] bg-[#080808]/[.70] px-[14px] transition-colors group-hover:bg-[#080808]/[.90]">
										<svg
											width="14"
											height="14"
											viewBox="0 0 24 24"
											fill="none"
											xmlns="http://www.w3.org/2000/svg"
											className="transition-transform duration-200 group-hover:-translate-x-[2px]"
										>
											<path
												d="M19 12H5M5 12L12 19M5 12L12 5"
												stroke="#ADADAD"
												strokeWidth="2"
												strokeLinecap="round"
												strokeLinejoin="round"
											/>
										</svg>
										<span
											className="font-medium text-[13px] tracking-[-0.52px] text-[#F2F2F2]"
											style={{ fontFamily: "Montserrat, sans-serif" }}
										>
											Voltar
										</span>
									</div>
								</button>
							</div>
						);
					})(),
					document.body,
				)}
		</div>
	);
}
