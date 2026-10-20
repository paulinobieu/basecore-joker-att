const DEFAULT_CLASS = "h-[1.3125rem] w-[1.3125rem]";

interface IconProps {
	className?: string;
}

export function AprimoramentoIcon({ className = DEFAULT_CLASS }: IconProps) {
	return (
		<svg className={className} viewBox="0 0 21 21" fill="none" xmlns="http://www.w3.org/2000/svg">
			<path
				d="M5.59 9.46L6.27 10.387L10.467 7.207L14.665 10.387L15.345 9.46L10.467 5.76L5.59 9.46ZM5.59 12.933L6.27 13.86L10.467 10.68L14.665 13.86L15.345 12.933L10.467 9.233L5.59 12.933ZM10.5 0.5L2 5.5V15.5L10.5 20.5L19 15.5V5.5L10.5 0.5ZM17.862 14.84L10.5 19.173L3.138 14.84V6.173L10.5 1.833L17.862 6.167V14.84Z"
				fill="currentColor"
			/>
		</svg>
	);
}
