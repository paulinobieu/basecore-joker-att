import { cn } from "@app/utils";
import { type ConfigItem, useEscStore } from "@app/stores/Esc";

import { settingsArrowImage } from "./arrowImage";

const Arrow = ({ flip }: { flip?: boolean }) => (
	<svg
		width=".5625rem"
		height=".75rem"
		viewBox="0 0 9 12"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
		xmlnsXlink="http://www.w3.org/1999/xlink"
		className={cn("transition-all duration-500", flip && "-scale-x-100")}
	>
		<path
			d="M6.64792 11.7907L0.477704 6.73255C0.33586 6.61627 0.236571 6.49999 0.179833 6.38372C0.123096 6.26744 0.0947266 6.13953 0.0947266 6C0.0947266 5.86046 0.123096 5.73255 0.179833 5.61628C0.236571 5.5 0.33586 5.38372 0.477704 5.26744L6.64792 0.209302C6.73302 0.139535 6.82551 0.0874419 6.92536 0.0530234C7.02522 0.0186048 7.13132 0.000930232 7.24366 0C7.47061 0 7.6692 0.064186 7.83941 0.192558C8.00962 0.32093 8.09473 0.489302 8.09473 0.697674V11.3023C8.09473 11.5116 8.00962 11.6805 7.83941 11.8088C7.6692 11.9372 7.47061 12.0009 7.24366 12C7.18692 12 6.98834 11.9302 6.64792 11.7907Z"
			fill="url(#paint0_linear_2892_1095)"
		/>
		<path
			d="M6.64792 11.7907L0.477704 6.73255C0.33586 6.61627 0.236571 6.49999 0.179833 6.38372C0.123096 6.26744 0.0947266 6.13953 0.0947266 6C0.0947266 5.86046 0.123096 5.73255 0.179833 5.61628C0.236571 5.5 0.33586 5.38372 0.477704 5.26744L6.64792 0.209302C6.73302 0.139535 6.82551 0.0874419 6.92536 0.0530234C7.02522 0.0186048 7.13132 0.000930232 7.24366 0C7.47061 0 7.6692 0.064186 7.83941 0.192558C8.00962 0.32093 8.09473 0.489302 8.09473 0.697674V11.3023C8.09473 11.5116 8.00962 11.6805 7.83941 11.8088C7.6692 11.9372 7.47061 12.0009 7.24366 12C7.18692 12 6.98834 11.9302 6.64792 11.7907Z"
			fill="url(#paint1_radial_2892_1095)"
		/>
		<path
			d="M6.64792 11.7907L0.477704 6.73255C0.33586 6.61627 0.236571 6.49999 0.179833 6.38372C0.123096 6.26744 0.0947266 6.13953 0.0947266 6C0.0947266 5.86046 0.123096 5.73255 0.179833 5.61628C0.236571 5.5 0.33586 5.38372 0.477704 5.26744L6.64792 0.209302C6.73302 0.139535 6.82551 0.0874419 6.92536 0.0530234C7.02522 0.0186048 7.13132 0.000930232 7.24366 0C7.47061 0 7.6692 0.064186 7.83941 0.192558C8.00962 0.32093 8.09473 0.489302 8.09473 0.697674V11.3023C8.09473 11.5116 8.00962 11.6805 7.83941 11.8088C7.6692 11.9372 7.47061 12.0009 7.24366 12C7.18692 12 6.98834 11.9302 6.64792 11.7907Z"
			fill="url(#pattern0_2892_1095)"
			fillOpacity="0.6"
		/>
		<defs>
			<pattern
				id="pattern0_2892_1095"
				patternContentUnits="objectBoundingBox"
				width="1"
				height="1"
			>
				<use
					xlinkHref="#image0_2892_1095"
					transform="matrix(0.00416667 0 0 0.00277778 -0.833333 0)"
				/>
			</pattern>
			<linearGradient
				id="paint0_linear_2892_1095"
				x1="-2.89517"
				y1="6"
				x2="11.6907"
				y2="6"
				gradientUnits="userSpaceOnUse"
			>
				<stop stopColor="rgb(var(--primaryColor))" />
				<stop offset="1" stopColor="rgb(var(--secondaryColor))" />
			</linearGradient>
			<radialGradient
				id="paint1_radial_2892_1095"
				cx="0"
				cy="0"
				r="1"
				gradientUnits="userSpaceOnUse"
				gradientTransform="translate(5.8473 -5.81818) rotate(90) scale(20 5.64135)"
			>
				<stop offset="0.333211" stopColor="rgb(var(--thirdyColor))" />
				<stop offset="1" stopColor="rgb(var(--thirdyColor))" stopOpacity="0" />
			</radialGradient>
			<image
				id="image0_2892_1095"
				width="640"
				height="360"
				preserveAspectRatio="none"
				xlinkHref={settingsArrowImage}
			/>
		</defs>
	</svg>
);

interface MultiSelectProps {
	selectedValue?: string;
	values: { id: string; label: string }[];
	title: string;
	category: string;
}

function MultiSelect({
	selectedValue,
	values,
	title,
	category,
}: MultiSelectProps) {
	const setConfig = useEscStore((state) => state.setConfig);
	const currentIndex = values.findIndex((value) => value.id === selectedValue);
	const label =
		values[currentIndex]?.label || values[0]?.label || "";

	const handlePrev = () => {
		const nextIndex = currentIndex > 0 ? currentIndex - 1 : values.length - 1;
		const next = values[nextIndex];
		setConfig((config) => ({
			...config,
			[category]: config[category].map((item) =>
				item.title === title ? { ...item, selectedValue: next.id } : item,
			),
		}));
	};

	const handleNext = () => {
		const nextIndex = currentIndex < values.length - 1 ? currentIndex + 1 : 0;
		const next = values[nextIndex];
		setConfig((config) => ({
			...config,
			[category]: config[category].map((item) =>
				item.title === title ? { ...item, selectedValue: next.id } : item,
			),
		}));
	};

	return (
		<div className="flex w-[10.625rem] flex-col items-center gap-2.5">
			<div className="flex w-full items-center justify-between">
				<button
					type="button"
					className="bg-transparent outline-none transition-all duration-500 hover:scale-105 active:scale-100"
					onClick={handlePrev}
				>
					<Arrow />
				</button>
				<span className="mx-2 min-w-0 flex-1 truncate text-center font-semibold text-sm">
					{label}
				</span>
				<button
					type="button"
					className="bg-transparent outline-none transition-all duration-500 hover:scale-105 active:scale-100"
					onClick={handleNext}
				>
					<Arrow flip />
				</button>
			</div>
			<div className="flex w-full justify-center gap-1">
				{values.map((value, index) => (
					<div
						key={value.id}
						className="relative h-1 flex-1 bg-[#d9d9d9]/10"
					>
						<div
							className={`customBackground absolute z-0 size-full bg-blend-screen transition-all duration-500 ${index === currentIndex ? "opacity-100" : "opacity-0"}`}
							style={{
								background:
									"linear-gradient(90deg, rgb(var(--primaryColor)) -37.37%, rgb(var(--secondaryColor)) 144.95%),radial-gradient(70.52% 166.67% at 71.91% -48.48%, rgb(var(--thirdyColor)) 33.32%, rgba(148, 146, 251, 0) 100%)",
							}}
						/>
					</div>
				))}
			</div>
		</div>
	);
}

interface ToggleProps {
	toggle?: boolean;
	title: string;
	category: string;
}

function Toggle({ toggle, title, category }: ToggleProps) {
	const setConfig = useEscStore((state) => state.setConfig);

	const handleToggle = (value: boolean) => {
		console.log(`Toggling ${title} in ${category} to ${value}`);
		setConfig((config) => {
			const next = {
				...config,
				[category]: config[category].map((item) =>
					item.title === title ? { ...item, toggle: value } : item,
				),
			};
			console.log("Previous state:", config);
			console.log("New state:", next);
			return next;
		});
	};

	return (
		<div className="flex h-[1.875rem] items-center">
			<button
				type="button"
				className={cn(
					"relative flex h-[1.875rem] w-[4.375rem] items-center justify-center rounded-tl-[.3125rem] rounded-bl-[.3125rem] border border-white/[.14] border-solid transition-all duration-500 hover:border-white/30 [&:hover>.coloredBackground]:opacity-50 [&:hover>.customBackground]:opacity-100 [&:hover>svg>path]:fill-white [&>svg>path]:fill-[#ddd]/70 [&>svg]:relative [&>svg]:z-10",
					toggle &&
						"[&>.coloredBackground]:opacity-50 [&>.customBackground]:opacity-100 [&>svg>path]:fill-white",
				)}
				style={{
					background:
						"linear-gradient(180deg, rgba(255, 255, 255, 0) 1.34%, rgba(255, 255, 255, 0.08) 59.6%)",
				}}
				onClick={() => handleToggle(true)}
			>
				<span className="relative z-10 font-semibold text-sm">Sim</span>
				<div
					className="customBackground absolute z-0 size-full rounded-tl-[.3125rem] rounded-bl-[.3125rem] opacity-0 bg-blend-screen transition-all duration-500"
					style={{
						background:
							"linear-gradient(90deg, rgb(var(--primaryColor)) -37.37%, rgb(var(--secondaryColor)) 144.95%),radial-gradient(70.52% 166.67% at 71.91% -48.48%, rgb(var(--thirdyColor)) 33.32%, rgba(148, 146, 251, 0) 100%)",
					}}
				/>
			</button>
			<button
				type="button"
				className={cn(
					"relative flex h-[1.875rem] w-[4.375rem] items-center justify-center rounded-tr-[.3125rem] rounded-br-[.3125rem] border border-white/[.14] border-solid transition-all duration-500 hover:border-white/30 [&:hover>.coloredBackground]:opacity-50 [&:hover>.customBackground]:opacity-100 [&:hover>svg>path]:fill-white [&>svg>path]:fill-[#ddd]/70 [&>svg]:relative [&>svg]:z-10",
					!toggle &&
						"[&>.coloredBackground]:opacity-50 [&>.customBackground]:opacity-100 [&>svg>path]:fill-white",
				)}
				style={{
					background:
						"linear-gradient(180deg, rgba(255, 255, 255, 0) 1.34%, rgba(255, 255, 255, 0.08) 59.6%)",
				}}
				onClick={() => handleToggle(false)}
			>
				<span className="relative z-10 font-semibold text-sm">Não</span>
				<div
					className="customBackground absolute z-0 size-full rounded-tr-[.3125rem] rounded-br-[.3125rem] opacity-0 bg-blend-screen transition-all duration-500"
					style={{
						background:
							"linear-gradient(90deg, rgb(var(--primaryColor)) -37.37%, rgb(var(--secondaryColor)) 144.95%),radial-gradient(70.52% 166.67% at 71.91% -48.48%, rgb(var(--thirdyColor)) 33.32%, rgba(148, 146, 251, 0) 100%)",
					}}
				/>
			</button>
		</div>
	);
}

interface ConfigRowProps {
	description: string;
	title: string;
	type: "toggle" | "multi-select";
	selectValues?: { id: string; label: string }[];
	toggle?: boolean;
	category: string;
	selectedValue?: string;
}

function ConfigRow({
	description,
	title,
	type,
	selectValues,
	toggle = false,
	category,
	selectedValue,
}: ConfigRowProps) {
	return (
		<div className="flex items-center justify-between">
			<div className="flex flex-col gap-1">
				<h1 className="font-bold text-base">{title}</h1>
				<span className="text-white/80 text-xs">{description}</span>
			</div>
			{type === "toggle" && (
				<Toggle toggle={toggle} title={title} category={category} />
			)}
			{type === "multi-select" && selectValues && (
				<MultiSelect
					selectedValue={selectedValue}
					values={selectValues}
					title={title}
					category={category}
				/>
			)}
		</div>
	);
}

interface CategorySectionProps {
	category: string;
	options: ConfigItem[];
}

function CategorySection({ category, options }: CategorySectionProps) {
	return (
		<div className="flex w-1/2 flex-col gap-[.9375rem]">
			<h1 className="font-semibold text-[1.0625rem] text-white/60 capitalize">
				{category}
			</h1>
			{options.map((option) => (
				<ConfigRow key={option.title} {...option} category={category} />
			))}
		</div>
	);
}

export function Settings() {
	const config = useEscStore((state) => state.config);
	return (
		<div className="hideScroll flex h-[47.9375rem] w-full gap-10 overflow-auto">
			{Object.entries(config).map(([category, options]) => (
				<CategorySection
					key={category}
					category={category}
					options={options}
				/>
			))}
		</div>
	);
}
