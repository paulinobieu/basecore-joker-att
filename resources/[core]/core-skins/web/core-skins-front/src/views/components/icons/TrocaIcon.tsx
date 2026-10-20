const DEFAULT_CLASS = "h-[1.3125rem] w-[1.3125rem]";

interface IconProps {
	className?: string;
}

export function TrocaIcon({ className = DEFAULT_CLASS }: IconProps) {
	return (
		<svg className={className} viewBox="0 0 21 21" fill="none" xmlns="http://www.w3.org/2000/svg">
			<path
				d="M1.99957 5.59236L10.5 0.685669L19.0004 5.59236V15.4076L10.5 20.3143L1.99957 15.4076V5.59236Z"
				stroke="currentColor"
				strokeWidth="1.18696"
			/>
			<mask
				id="mask_troca"
				style={{ maskType: "luminance" }}
				maskUnits="userSpaceOnUse"
				x="5"
				y="6"
				width="11"
				height="9"
			>
				<path d="M5.90649 6.56293H15.7491V14.4379H5.90741L5.90649 6.56293Z" fill="white" />
			</mask>
			<g mask="url(#mask_troca)">
				<path
					d="M7.19486 10.5666H5.90747V7.84301H11.6733V6.56293C12.5763 7.20206 13.4538 7.82749 14.3513 8.4648L11.6788 10.3639V9.0948H7.19486V10.5666ZM9.99243 14.4379C9.07847 13.7897 8.20012 13.1624 7.30808 12.5297C8.20012 11.8978 9.07847 11.2733 9.97508 10.6324V11.8924H14.4526V10.4315H15.7492V13.1432H9.99243V14.4379Z"
					fill="currentColor"
				/>
			</g>
		</svg>
	);
}
