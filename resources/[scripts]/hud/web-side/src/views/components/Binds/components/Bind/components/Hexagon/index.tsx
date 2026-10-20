import { memo } from "react";

export const Hexagon = memo(() => (
	<svg
		width="2.8125rem"
		height="2.6875rem"
		viewBox="0 0 45 43"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
		className="absolute z-[-1]"
	>
		<g filter="url(#filter0_d_56_331)">
			<path
				d="M34.2264 19.2583C34.9409 20.4959 34.9409 22.0207 34.2264 23.2583L30.0358 30.5166C29.3213 31.7542 28.0008 32.5166 26.5717 32.5166L18.1905 32.5166C16.7614 32.5166 15.4409 31.7542 14.7264 30.5166L10.5358 23.2583C9.82127 22.0207 9.82127 20.4959 10.5358 19.2583L14.7264 12C15.4409 10.7624 16.7614 9.99997 18.1905 9.99997L26.5717 9.99997C28.0008 9.99997 29.3213 10.7624 30.0358 12L34.2264 19.2583Z"
				fill="url(#paint0_linear_56_331)"
			/>
		</g>
		<defs>
			<filter
				id="filter0_d_56_331"
				x="0"
				y="0"
				width="44.7625"
				height="42.5166"
				filterUnits="userSpaceOnUse"
				color-interpolation-filters="sRGB"
			>
				<feFlood flood-opacity="0" result="BackgroundImageFix" />
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
					values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.2 0"
				/>
				<feBlend
					mode="normal"
					in2="BackgroundImageFix"
					result="effect1_dropShadow_56_331"
				/>
				<feBlend
					mode="normal"
					in="SourceGraphic"
					in2="effect1_dropShadow_56_331"
					result="shape"
				/>
			</filter>
			<linearGradient
				id="paint0_linear_56_331"
				x1="22.3811"
				y1="8.2583"
				x2="22.3811"
				y2="34.2583"
				gradientUnits="userSpaceOnUse"
			>
				<stop stop-color="rgb(var(--secondaryColor))" />
				<stop offset="1" stop-color="rgb(var(--primaryColor))" />
			</linearGradient>
		</defs>
	</svg>
));
