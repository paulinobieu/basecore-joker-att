import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";

const CloseIcon = () => (
	<svg
		width="1.375rem"
		height="1.375rem"
		viewBox="0 0 22 22"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
	>
		<path
			d="M6.13818 16.0644L15.8617 5.93567M15.8617 16.0644L6.13818 5.93567"
			stroke="#DDDDDD"
			strokeWidth="1.3"
			strokeMiterlimit="10"
			strokeLinecap="round"
			strokeLinejoin="round"
			className="transition-all duration-500"
		/>
	</svg>
);

export function CloseButton() {
	const fetchHideFrame = useVisibilityStore((state) => state.fetchHideFrame);

	return (
		<button
			type="button"
			className={cn(
				"relative flex size-[2.375rem] items-center justify-center rounded-md border border-white/[.14] border-solid transition-all duration-500 hover:border-white/30 [&:hover>.coloredBackground]:opacity-50 [&:hover>.customBackground]:opacity-100 [&:hover>svg>path]:stroke-white [&>svg>path]:stroke-[#ddd]/70 [&>svg]:relative [&>svg]:z-10",
			)}
			style={{
				background:
					"linear-gradient(180deg, rgba(255, 255, 255, 0) 1.34%, rgba(255, 255, 255, 0.08) 59.6%)",
			}}
			onClick={fetchHideFrame}
		>
			<CloseIcon />
			<div
				className="customBackground absolute z-0 size-full rounded-md opacity-0 bg-blend-screen transition-all duration-500"
				style={{
					background:
						"linear-gradient(90deg, rgb(var(--primaryColor)) -37.37%, rgb(var(--secondaryColor)) 144.95%),radial-gradient(70.52% 166.67% at 71.91% -48.48%, rgb(var(--thirdyColor)) 33.32%, rgba(148, 146, 251, 0) 100%)",
				}}
			/>
		</button>
	);
}
