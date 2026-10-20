export function SpinLoader() {
	return (
		<div className="spin-loader">
			<svg
				viewBox="0 0 100 100"
				fill="none"
				xmlns="http://www.w3.org/2000/svg"
				aria-hidden
			>
				<circle
					cx="50"
					cy="50"
					r="40"
					stroke="currentColor"
					strokeOpacity="0.2"
					strokeWidth="6"
				/>
				<path
					d="M50 10 a 40 40 0 0 1 0 80"
					stroke="currentColor"
					strokeWidth="6"
					strokeLinecap="round"
					fill="none"
				>
					<animateTransform
						attributeName="transform"
						type="rotate"
						from="0 50 50"
						to="360 50 50"
						dur="1s"
						repeatCount="indefinite"
					/>
				</path>
			</svg>
		</div>
	);
}
