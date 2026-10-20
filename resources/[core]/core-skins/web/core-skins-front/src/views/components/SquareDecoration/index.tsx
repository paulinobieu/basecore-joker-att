interface SquareDecorationProps {
	className?: string;
}

export function SquareDecoration({ className }: SquareDecorationProps) {
	return (
		<svg
			className={className}
			viewBox="-30 -30 361 361"
			fill="none"
			xmlns="http://www.w3.org/2000/svg"
		>
			<g filter="url(#filter0_d_stroke)">
				<path
					d="M91.0703 73.5469C93.6789 63.8111 103.685 58.0339 113.421 60.6426L226.979 91.0703C236.714 93.6789 242.492 103.685 239.883 113.421L209.455 226.979C206.847 236.714 196.84 242.492 187.104 239.883L73.5469 209.455C63.8111 206.847 58.0339 196.84 60.6426 187.104L91.0703 73.5469Z"
					stroke="rgb(var(--primaryColor))"
					strokeWidth="1.5"
				/>
			</g>
			<path
				d="M105.683 99.424C108.349 89.4748 118.576 83.5706 128.525 86.2365L201.102 105.683C211.051 108.349 216.955 118.576 214.289 128.525L194.842 201.102C192.176 211.051 181.95 216.955 172.001 214.289L99.424 194.842C89.4748 192.176 83.5706 181.95 86.2365 172.001L105.683 99.424Z"
				stroke="rgb(var(--primaryColor))"
				strokeOpacity="0.4"
				strokeWidth="0.7"
			/>
			<defs>
				<filter
					id="filter0_d_stroke"
					x="28.2654"
					y="28.2654"
					width="243.995"
					height="243.995"
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
					<feGaussianBlur stdDeviation="15.5" />
					<feComposite in2="hardAlpha" operator="out" result="shadowShape" />
					<feFlood
						floodColor="rgb(var(--primaryColor))"
						floodOpacity="1"
						result="colorFill"
					/>
					<feComposite in="colorFill" in2="shadowShape" operator="in" />
					<feBlend mode="normal" in2="BackgroundImageFix" result="effect1_dropShadow" />
					<feBlend mode="normal" in="SourceGraphic" in2="effect1_dropShadow" result="shape" />
				</filter>
			</defs>
		</svg>
	);
}
