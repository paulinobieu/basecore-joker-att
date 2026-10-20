interface TalkerToggleIconProps {
	className?: string;
}

export function TalkerToggleIcon({ className }: TalkerToggleIconProps) {
	return (
		<svg className={className} fill="none" viewBox="0 0 11 8" xmlns="http://www.w3.org/2000/svg">
			<path
				d="M0.599976 0.600006H9.59998M2.09998 3.60001H8.09998M3.59998 6.60001H6.59998"
				stroke="white"
				strokeLinecap="round"
				strokeLinejoin="round"
				strokeOpacity="0.5"
				strokeWidth="1.2"
			/>
		</svg>
	);
}
