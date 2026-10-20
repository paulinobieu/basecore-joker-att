import { routes } from "@app/router/routes";
import { cn } from "@app/utils";
import { useLocation, useNavigate } from "react-router-dom";

const GearIcon = () => (
	<svg
		width="1.125rem"
		height="1.125rem"
		viewBox="0 0 18 18"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
	>
		<path
			d="M8.99988 11.625C8.30369 11.625 7.63601 11.3484 7.14372 10.8562C6.65144 10.3639 6.37488 9.69619 6.37488 9C6.37488 8.30381 6.65144 7.63613 7.14372 7.14385C7.63601 6.65156 8.30369 6.375 8.99988 6.375C9.69607 6.375 10.3638 6.65156 10.856 7.14385C11.3483 7.63613 11.6249 8.30381 11.6249 9C11.6249 9.69619 11.3483 10.3639 10.856 10.8562C10.3638 11.3484 9.69607 11.625 8.99988 11.625ZM14.5724 9.7275C14.6024 9.4875 14.6249 9.2475 14.6249 9C14.6249 8.7525 14.6024 8.505 14.5724 8.25L16.1549 7.0275C16.2974 6.915 16.3349 6.7125 16.2449 6.5475L14.7449 3.9525C14.6549 3.7875 14.4524 3.72 14.2874 3.7875L12.4199 4.5375C12.0299 4.245 11.6249 3.99 11.1524 3.8025L10.8749 1.815C10.8596 1.72666 10.8136 1.64657 10.745 1.58891C10.6764 1.53126 10.5895 1.49976 10.4999 1.5H7.49988C7.31238 1.5 7.15488 1.635 7.12488 1.815L6.84738 3.8025C6.37488 3.99 5.96988 4.245 5.57988 4.5375L3.71238 3.7875C3.54738 3.72 3.34488 3.7875 3.25488 3.9525L1.75488 6.5475C1.65738 6.7125 1.70238 6.915 1.84488 7.0275L3.42738 8.25C3.39738 8.505 3.37488 8.7525 3.37488 9C3.37488 9.2475 3.39738 9.4875 3.42738 9.7275L1.84488 10.9725C1.70238 11.085 1.65738 11.2875 1.75488 11.4525L3.25488 14.0475C3.34488 14.2125 3.54738 14.2725 3.71238 14.2125L5.57988 13.455C5.96988 13.755 6.37488 14.01 6.84738 14.1975L7.12488 16.185C7.15488 16.365 7.31238 16.5 7.49988 16.5H10.4999C10.6874 16.5 10.8449 16.365 10.8749 16.185L11.1524 14.1975C11.6249 14.0025 12.0299 13.755 12.4199 13.455L14.2874 14.2125C14.4524 14.2725 14.6549 14.2125 14.7449 14.0475L16.2449 11.4525C16.3349 11.2875 16.2974 11.085 16.1549 10.9725L14.5724 9.7275Z"
			fill="#DDDDDD"
			className="transition-all duration-500"
		/>
	</svg>
);

export function SettingsButton() {
	const { pathname } = useLocation();
	const navigate = useNavigate();

	return (
		<button
			type="button"
			className={cn(
				"relative mr-2 flex size-[2.375rem] items-center justify-center rounded-md border border-white/[.14] border-solid transition-all duration-500 hover:border-white/30 [&:hover>.coloredBackground]:opacity-50 [&:hover>.customBackground]:opacity-100 [&:hover>svg>path]:fill-white [&>svg>path]:fill-[#ddd]/70 [&>svg]:relative [&>svg]:z-10",
				pathname.includes(routes.settings) &&
					"[&>.coloredBackground]:opacity-50 [&>.customBackground]:opacity-100 [&>svg>path]:fill-white",
			)}
			style={{
				background:
					"linear-gradient(180deg, rgba(255, 255, 255, 0) 1.34%, rgba(255, 255, 255, 0.08) 59.6%)",
			}}
			onClick={() => {
				navigate(routes.settings);
			}}
		>
			<GearIcon />
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
