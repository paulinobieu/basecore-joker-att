interface KeyProps {
	pressKey: string;
	color: string;
}

export function Key({ color, pressKey }: KeyProps) {
	return (
		<div className="relative flex size-[2.875rem] items-center justify-center">
			<h1 className="absolute z-10 font-semibold text-sm uppercase">
				{pressKey}
			</h1>
			<svg
				width="2.625rem"
				height="2.625rem"
				viewBox="0 0 42 42"
				fill="none"
				xmlns="http://www.w3.org/2000/svg"
			>
				<path
					d="M16.2721 1.75735C18.6153 -0.585795 22.4143 -0.585796 24.7574 1.75735L39.2721 16.2721C41.6153 18.6152 41.6153 22.4142 39.2721 24.7573L24.7574 39.2721C22.4143 41.6152 18.6153 41.6152 16.2721 39.2721L1.75741 24.7574C-0.585734 22.4142 -0.585735 18.6152 1.75741 16.2721L16.2721 1.75735Z"
					fill={`url(#paint0_linear_4_2-${color})`}
					fill-opacity="0.3"
				/>
				<path
					d="M19.2419 5.9704C19.9449 5.26745 21.0849 5.26745 21.7878 5.9704L35.0593 19.2419C35.7622 19.9448 35.7623 21.0849 35.0593 21.7878L21.7878 35.0593C21.0849 35.7622 19.9449 35.7622 19.2419 35.0593L5.97046 21.7878C5.26752 21.0848 5.26752 19.9448 5.97046 19.2419L19.2419 5.9704Z"
					fill={`url(#paint1_linear_4_2-${color})`}
					stroke={color}
					stroke-width="0.4"
				/>
				<path
					d="M18.0399 4.14636C19.4066 2.77986 21.6223 2.77999 22.9891 4.14636L36.8827 18.0399C38.2494 19.4067 38.2493 21.6223 36.8827 22.9891L22.9891 36.8827C21.6223 38.2493 19.4067 38.2494 18.0399 36.8827L4.14636 22.9891C2.77999 21.6223 2.77986 19.4066 4.14636 18.0399L18.0399 4.14636Z"
					stroke={`url(#paint2_linear_4_2-${color})`}
					stroke-opacity="0.7"
				/>
				<defs>
					<linearGradient
						id={`paint0_linear_4_2-${color}`}
						x1="-4.78523"
						y1="-0.76029"
						x2="28.0148"
						y2="50.0147"
						gradientUnits="userSpaceOnUse"
					>
						<stop offset="0.208399" stop-color={color} stop-opacity="0.7" />
						<stop offset="0.919052" stop-color={color} stop-opacity="0" />
					</linearGradient>
					<linearGradient
						id={`paint1_linear_4_2-${color}`}
						x1="7.7295"
						y1="4.41473"
						x2="26.8398"
						y2="39.4897"
						gradientUnits="userSpaceOnUse"
					>
						<stop offset="0.238476" stop-color={color} />
						<stop offset="0.845384" stop-color={color} stop-opacity="0.2" />
					</linearGradient>
					<linearGradient
						id={`paint2_linear_4_2-${color}`}
						x1="20.5147"
						y1="0.964722"
						x2="20.5147"
						y2="40.0647"
						gradientUnits="userSpaceOnUse"
					>
						<stop offset="0.0721073" stop-color={color} stop-opacity="0" />
						<stop offset="0.5" stop-color={color} />
						<stop offset="0.937911" stop-color={color} stop-opacity="0" />
					</linearGradient>
				</defs>
			</svg>
		</div>
	);
}
