import BattlePassBackground from "@views/assets/images/battlepass-background.png";

const ClockIcon = () => (
	<svg
		width="2.5rem"
		height="2.5rem"
		viewBox="0 0 24 24"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
	>
		<path
			d="M12 7v5l3 2m6-2a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
			stroke="rgb(var(--primaryColor))"
			strokeWidth="1.6"
			strokeLinecap="round"
			strokeLinejoin="round"
		/>
	</svg>
);

export function BattlePassCard() {
	return (
		<div
			className="flex h-[23.5rem] w-[14.375rem] flex-col items-center rounded-[1.25rem] p-[1.5625rem] outline outline-1 outline-white/25"
			style={{
				background: `url(${BattlePassBackground})`,
				backgroundSize: "cover",
				backgroundRepeat: "no-repeat",
			}}
		>
			<h1 className="font-bold text-[1.375rem]">Battle Pass</h1>
			<span className="mb-[2.125rem] font-semibold text-sm text-white/70">
				Disponível em breve
			</span>
			<div className="relative mb-[.9375rem] flex size-[6.5625rem] items-center justify-center">
				<ClockIcon />
				<svg
					width="6.5625rem"
					height="6.5625rem"
					viewBox="0 0 105 105"
					fill="none"
					xmlns="http://www.w3.org/2000/svg"
					className="absolute"
				>
					<mask id="path-1-inside-1_508_840" fill="white">
						<path d="M105 52.5C105 81.4949 81.4949 105 52.5 105C23.5051 105 0 81.4949 0 52.5C0 23.5051 23.5051 0 52.5 0C81.4949 0 105 23.5051 105 52.5ZM9.975 52.5C9.975 75.9859 29.0141 95.025 52.5 95.025C75.9859 95.025 95.025 75.9859 95.025 52.5C95.025 29.0141 75.9859 9.975 52.5 9.975C29.0141 9.975 9.975 29.0141 9.975 52.5Z" />
					</mask>
					<path
						d="M105 52.5C105 81.4949 81.4949 105 52.5 105C23.5051 105 0 81.4949 0 52.5C0 23.5051 23.5051 0 52.5 0C81.4949 0 105 23.5051 105 52.5ZM9.975 52.5C9.975 75.9859 29.0141 95.025 52.5 95.025C75.9859 95.025 95.025 75.9859 95.025 52.5C95.025 29.0141 75.9859 9.975 52.5 9.975C29.0141 9.975 9.975 29.0141 9.975 52.5Z"
						fill="url(#paint0_radial_508_840)"
						fill-opacity="0.3"
						stroke="white"
						stroke-opacity="0.12"
						stroke-width="1.6"
						mask="url(#path-1-inside-1_508_840)"
					/>
					<path
						d="M52.5 5C58.7378 5 64.9145 6.22862 70.6775 8.61572C76.4404 11.0028 81.6768 14.5016 86.0876 18.9124C90.4984 23.3232 93.9972 28.5596 96.3843 34.3225C98.7714 40.0855 100 46.2622 100 52.5C100 58.7378 98.7714 64.9145 96.3843 70.6775C93.9972 76.4404 90.4983 81.6768 86.0876 86.0876C81.6768 90.4984 76.4404 93.9972 70.6775 96.3843C64.9145 98.7714 58.7378 100 52.5 100C46.2622 100 40.0855 98.7714 34.3225 96.3843C28.5596 93.9972 23.3232 90.4983 18.9124 86.0876C14.5016 81.6768 11.0028 76.4404 8.61571 70.6774C6.22862 64.9145 5 58.7378 5 52.5C5 46.2622 6.22863 40.0855 8.61573 34.3225C11.0028 28.5595 14.5017 23.3232 18.9124 18.9124C23.3232 14.5016 28.5596 11.0028 34.3226 8.61571C40.0855 6.22862 46.2622 5 52.5 5L52.5 5Z"
						stroke="url(#paint1_linear_508_840)"
						stroke-width="10"
						pathLength={100.01}
						strokeDasharray={100.01}
						strokeDashoffset={35}
						className="transition-all duration-500"
					/>
					<defs>
						<radialGradient
							id="paint0_radial_508_840"
							cx="0"
							cy="0"
							r="1"
							gradientUnits="userSpaceOnUse"
							gradientTransform="translate(52.5 52.5) rotate(90) scale(52.5)"
						>
							<stop offset="0.753743" stop-color="#D9D9D9" stop-opacity="0" />
							<stop offset="1" stop-color="#D9D9D9" />
						</radialGradient>
						<linearGradient
							id="paint1_linear_508_840"
							x1="-50"
							y1="53"
							x2="149.5"
							y2="53"
							gradientUnits="userSpaceOnUse"
						>
							<stop stop-color="rgb(var(--primaryColor))" />
							<stop offset="1" stop-color="rgb(var(--secondaryColor))" />
						</linearGradient>
					</defs>
				</svg>
			</div>
			<div className="mb-auto font-bold text-[1.3125rem] uppercase tracking-wide">
				Em breve
			</div>
			<button
				type="button"
				disabled
				className="flex h-[1.875rem] w-full cursor-not-allowed items-center justify-center rounded-[.1875rem] border border-white/20 border-solid bg-white/[.06] font-bold text-[.8125rem] text-white/50"
			>
				Em breve
			</button>
		</div>
	);
}
