import { useEscStore } from "@app/stores/Esc";
import { cn } from "@app/utils";
import { isEnvBrowser } from "@app/utils/misc";

const CartIcon = () => (
	<svg
		width="1rem"
		height=".875rem"
		viewBox="0 0 16 14"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
		className="relative z-10"
	>
		<path
			d="M6.27935 1L5.30644 5.12267C5.23862 5.41028 5.25786 5.71342 5.3614 5.98865L7.9971 13H8.00269L10.6381 5.98865C10.7415 5.71338 10.7606 5.41025 10.6927 5.12267L9.72011 1M1.08794 5.56514H14.9115M14.872 4.86843L13.1105 1.53588C13.0245 1.37325 12.8996 1.23793 12.7485 1.14377C12.5973 1.04961 12.4255 0.999995 12.2505 1H3.74898C3.57404 1.00006 3.40225 1.0497 3.25119 1.14386C3.10014 1.23802 2.97524 1.37331 2.88928 1.53588L1.12744 4.86843C1.02147 5.06882 0.979902 5.30071 1.00908 5.52867C1.03827 5.75663 1.13659 5.96814 1.28904 6.13087L7.53434 12.7942C7.65778 12.9259 7.82518 12.9999 7.99973 12.9999C8.17428 12.9999 8.34168 12.9259 8.46512 12.7942L14.7107 6.13052C14.8633 5.96783 14.9616 5.75635 14.9909 5.52838C15.0201 5.30041 14.9786 5.0685 14.8727 4.86808L14.872 4.86843Z"
			stroke="#DDDDDD"
			strokeOpacity="0.7"
			strokeWidth="0.9"
			strokeLinecap="round"
			strokeLinejoin="round"
		/>
	</svg>
);

export function BuyButton() {
	const links = useEscStore((state) => state.links);

	return (
		<button
			type="button"
			className={cn(
				"relative mr-2 flex h-[2.375rem] w-[10rem] items-center gap-2.5 rounded-md border border-white/[.14] border-solid px-1.5 transition-all duration-500 hover:border-white/40 [&:hover>div>.coloredBackground]:opacity-50 [&:hover>div>.customBackground]:opacity-100 [&:hover>svg>path]:fill-white [&>svg>path]:fill-[#ddd]/70 [&>svg]:relative [&>svg]:z-10",
			)}
			style={{
				background:
					"linear-gradient(180deg, rgba(255, 255, 255, 0) 1.34%, rgba(255, 255, 255, 0.08) 59.6%)",
			}}
			onClick={() => {
				if (isEnvBrowser()) return window.open(links.shop, "_blank");
				(window as any).invokeNative("openUrl", links.shop);
			}}
		>
			<div className="relative z-10 flex size-[1.625rem] items-center justify-center rounded-[.25rem] bg-white/[.12]">
				<CartIcon />
				<div
					className="customBackground absolute left-0 z-0 size-full rounded-[.25rem] opacity-0 bg-blend-screen transition-all duration-500"
					style={{
						background:
							"linear-gradient(90deg, rgb(var(--primaryColor)) -37.37%, rgb(var(--secondaryColor)) 144.95%),radial-gradient(70.52% 166.67% at 71.91% -48.48%, rgb(var(--thirdyColor)) 33.32%, rgba(148, 146, 251, 0) 100%)",
					}}
				/>
			</div>
			<span className="relative z-10 font-semibold text-[.8125rem]">
				Comprar
			</span>
		</button>
	);
}
