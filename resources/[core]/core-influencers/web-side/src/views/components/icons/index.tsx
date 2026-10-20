type IconProps = React.SVGProps<SVGSVGElement>;

export function GroupIcon(props: IconProps) {
	return (
		<svg viewBox="0 0 24 24" aria-hidden="true" {...props}>
			<path
				d="M16 11c1.66 0 3-1.79 3-4s-1.34-4-3-4-3 1.79-3 4 1.34 4 3 4Zm-8 0c1.66 0 3-1.79 3-4S9.66 3 8 3 5 4.79 5 7s1.34 4 3 4Zm0 2c-2.33 0-7 1.17-7 3.5V20h14v-3.5C15 14.17 10.33 13 8 13Zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.95 1.97 3.45V20h6v-3.5c0-2.33-4.67-3.5-7-3.5Z"
				fill="currentColor"
			/>
		</svg>
	);
}

export function PlayIcon(props: IconProps) {
	return (
		<svg viewBox="0 0 24 24" aria-hidden="true" {...props}>
			<path d="M8 5v14l11-7z" fill="currentColor" />
		</svg>
	);
}

export function PauseIcon(props: IconProps) {
	return (
		<svg viewBox="0 0 24 24" aria-hidden="true" {...props}>
			<path d="M6 6h4v12H6zm8 0h4v12h-4z" fill="currentColor" />
		</svg>
	);
}

export function CameraIcon(props: IconProps) {
	return (
		<svg viewBox="0 0 24 24" aria-hidden="true" {...props}>
			<path
				d="M9 4.5h6l1.4 2H20a2 2 0 0 1 2 2v8.5a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V8.5a2 2 0 0 1 2-2h3.6L9 4.5Zm3 4A4.5 4.5 0 1 0 12 17.5 4.5 4.5 0 0 0 12 8.5Zm0 2A2.5 2.5 0 1 1 12 15.5 2.5 2.5 0 0 1 12 10.5Z"
				fill="currentColor"
			/>
		</svg>
	);
}

export function SoundOnIcon(props: IconProps) {
	return (
		<svg viewBox="0 0 24 24" aria-hidden="true" {...props}>
			<path
				d="M14 3.23v17.54c0 .45-.54.67-.85.35L8.57 16H5a2 2 0 0 1-2-2v-4a2 2 0 0 1 2-2h3.57l4.58-5.12c.31-.32.85-.1.85.35ZM16.5 8.5a1 1 0 0 1 1.41 0 5 5 0 0 1 0 7.07 1 1 0 1 1-1.41-1.41 3 3 0 0 0 0-4.24 1 1 0 0 1 0-1.42Zm2.83-2.82a1 1 0 0 1 1.41 0 9 9 0 0 1 0 12.72 1 1 0 1 1-1.41-1.41 7 7 0 0 0 0-9.9 1 1 0 0 1 0-1.41Z"
				fill="currentColor"
			/>
		</svg>
	);
}

export function SoundOffIcon(props: IconProps) {
	return (
		<svg viewBox="0 0 24 24" aria-hidden="true" {...props}>
			<path
				d="M14 3.23v17.54c0 .45-.54.67-.85.35L8.57 16H5a2 2 0 0 1-2-2v-4a2 2 0 0 1 2-2h3.57l4.58-5.12c.31-.32.85-.1.85.35Z"
				fill="currentColor"
			/>
			<path
				d="M19.07 7.51a1 1 0 0 1 1.42 1.41L17.41 12l3.08 3.07a1 1 0 0 1-1.42 1.42L16 13.41l-3.07 3.08a1 1 0 0 1-1.42-1.42L14.59 12l-3.08-3.07a1 1 0 1 1 1.42-1.42L16 10.59l3.07-3.08Z"
				fill="currentColor"
			/>
		</svg>
	);
}

export function CloseIcon(props: IconProps) {
	return (
		<svg viewBox="0 0 24 24" aria-hidden="true" {...props}>
			<path
				d="M18.3 5.71a1 1 0 0 0-1.41 0L12 10.59 7.11 5.7A1 1 0 0 0 5.7 7.12L10.59 12 5.7 16.89a1 1 0 1 0 1.41 1.41L12 13.41l4.89 4.89a1 1 0 0 0 1.41-1.41L13.41 12l4.89-4.88a1 1 0 0 0 0-1.41Z"
				fill="currentColor"
			/>
		</svg>
	);
}

export function StarIcon(props: IconProps) {
	return (
		<svg viewBox="0 0 24 24" aria-hidden="true" {...props}>
			<path
				d="m12 3.5 2.72 5.51 6.08.88-4.4 4.29 1.04 6.05L12 17.37l-5.44 2.86 1.04-6.05-4.4-4.29 6.08-.88L12 3.5Z"
				fill="currentColor"
			/>
		</svg>
	);
}

export function MusicIcon(props: IconProps) {
	return (
		<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" {...props}>
			<path d="M12 3v10.55A4 4 0 1 0 14 17V7h6V3h-8Z" />
		</svg>
	);
}

export function SearchIcon(props: IconProps) {
	return (
		<svg
			viewBox="0 0 24 24"
			fill="none"
			stroke="currentColor"
			strokeWidth={2}
			strokeLinecap="round"
			strokeLinejoin="round"
			aria-hidden="true"
			{...props}
		>
			<circle cx="11" cy="11" r="7" />
			<path d="m20 20-3.5-3.5" />
		</svg>
	);
}

export function BrandLogo() {
	return (
		<div className="brand-logo">
			<svg
				className="pointer-events-none absolute inset-0 h-full w-full"
				viewBox="0 0 40 40"
				fill="none"
				aria-hidden="true"
			>
				<rect
					x="20"
					y="2"
					width="25.46"
					height="25.46"
					rx="5"
					transform="rotate(45 20 2)"
					fill="rgb(var(--primaryColor))"
					fillOpacity="0.18"
					stroke="rgb(var(--primaryColor))"
					strokeWidth="1.2"
				/>
				<rect
					x="20"
					y="7"
					width="18.38"
					height="18.38"
					rx="4"
					transform="rotate(45 20 7)"
					fill="rgb(var(--primaryColor))"
					fillOpacity="0.5"
				/>
			</svg>
			<svg
				viewBox="0 0 24 24"
				width="13"
				height="13"
				className="relative z-[1]"
				aria-hidden="true"
			>
				<path d="M0 0h24v24H0z" fill="none" />
				<path
					fill="#ffffff"
					d="M16.6 5.82s.51.5 0 0A4.28 4.28 0 0 1 15.54 3h-3.09v12.4a2.59 2.59 0 0 1-2.59 2.5c-1.42 0-2.6-1.16-2.6-2.6c0-1.72 1.66-3.01 3.37-2.48V9.66c-3.45-.46-6.47 2.22-6.47 5.64c0 3.33 2.76 5.7 5.69 5.7c3.14 0 5.69-2.55 5.69-5.7V9.01a7.35 7.35 0 0 0 4.3 1.38V7.3s-1.88.09-3.24-1.48"
				/>
			</svg>
		</div>
	);
}

export function InfluencerIcon(props: IconProps) {
	return (
		<svg viewBox="0 0 24 24" aria-hidden="true" {...props}>
			<path
				d="M12 2.5l1.9 3.85 4.25.62-3.07 3 .72 4.23L12 16.6l-3.8 2-.73-4.23-3.07-3 4.25-.62L12 2.5Z"
				fill="currentColor"
			/>
			<path
				d="M12 14.6c-3.6 0-6.5 1.83-6.5 4.08V21h13v-2.32c0-2.25-2.9-4.08-6.5-4.08Z"
				fill="currentColor"
				opacity="0.55"
			/>
		</svg>
	);
}
