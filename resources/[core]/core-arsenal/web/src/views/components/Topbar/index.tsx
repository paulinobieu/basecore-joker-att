import { useIsRendered } from "@app/hooks/useIsRendered";
import { AnimationProvider } from "@app/providers/Animation";
import { ALL_CATEGORY, useArsenal } from "@app/stores/Arsenal";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { pad } from "@app/utils/misc";
import { IconCrosshair, IconX } from "@tabler/icons-react";
import { Hexagon } from "@views/components/Hexagon";
import { useShallow } from "zustand/shallow";

/**
 * Cabecalho do arsenal. O Lua nao manda o nome do posto -- o `setArsenal` leva
 * so o catalogo --, entao a identificacao e do proprio deposito, e o que varia
 * ao lado sao as secoes do armamento, numeradas como um dossie.
 */
export function Topbar() {
	const { isRendered } = useIsRendered();
	const fetchHideFrame = useVisibilityStore((state) => state.fetchHideFrame);

	const { categories, category, items, setCategory } = useArsenal(
		useShallow((state) => ({
			categories: state.categories,
			category: state.category,
			items: state.items,
			setCategory: state.setCategory,
		})),
	);

	const sections = [{ id: ALL_CATEGORY, label: "Geral" }, ...categories];

	return (
		<header className="relative flex h-[4.75rem] w-full flex-shrink-0 items-center gap-[1.25rem] border-[#D9D9D91A] border-b border-solid px-[1.25rem]">
			<AnimationProvider show={isRendered} className="flex items-center gap-3">
				<div className="relative flex size-[3.25rem] flex-shrink-0 items-center justify-center">
					<Hexagon active />
					<IconCrosshair
						stroke={2}
						className="relative z-10 size-[1.25rem] text-white"
					/>
				</div>

				<div className="flex flex-col">
					<h1 className="stencil whitespace-nowrap text-[1.0625rem] text-white leading-tight">
						Arsenal
					</h1>
					<span className="whitespace-nowrap font-semibold text-[.6875rem] text-white/35">
						Controle de armamento · acesso restrito
					</span>
				</div>
			</AnimationProvider>

			{sections.length > 1 && (
				<span className="h-[2.5rem] w-px flex-shrink-0 bg-white/[.08]" />
			)}

			<AnimationProvider
				show={isRendered}
				className="customScrollbar flex flex-1 items-center gap-[.5rem] overflow-x-auto"
			>
				{sections.map((section, index) => {
					const active = category === section.id;
					const total =
						section.id === ALL_CATEGORY
							? items.length
							: items.filter((item) => item.category === section.id).length;

					return (
						<button
							key={section.id}
							type="button"
							onClick={() => setCategory(section.id)}
							className={cn(
								"ghost-btn relative flex h-[2.5rem] flex-shrink-0 items-center gap-2 rounded-[.1875rem] border border-white/5 border-solid px-[1rem] transition-all duration-300",
								active && "is-active",
							)}
						>
							<span
								className={cn(
									"relative z-10 font-black text-[.5625rem] tabular-nums transition-all duration-300",
									active ? "text-white/50" : "text-white/20",
								)}
							>
								{pad(index)}
							</span>
							<span
								className={cn(
									"stencil relative z-10 text-[.75rem] transition-all duration-300",
									active ? "text-white" : "text-[#EDEAE599]",
								)}
							>
								{section.label}
							</span>
							<span
								className={cn(
									"relative z-10 font-black text-[.625rem] tabular-nums",
									active ? "text-white/60" : "text-white/25",
								)}
							>
								{total}
							</span>
						</button>
					);
				})}
			</AnimationProvider>

			<AnimationProvider show={isRendered}>
				<button
					type="button"
					title="Fechar (ESC)"
					onClick={fetchHideFrame}
					className="ghost-btn relative flex size-[2.5rem] items-center justify-center rounded-[.1875rem] border border-white/5 border-solid text-white/45 transition-all duration-300 hover:text-white"
				>
					<IconX stroke={2.5} className="relative z-10 size-[1.125rem]" />
				</button>
			</AnimationProvider>
		</header>
	);
}
