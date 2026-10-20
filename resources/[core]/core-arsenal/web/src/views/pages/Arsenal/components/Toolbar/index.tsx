import { type SortMode, useArsenal } from "@app/stores/Arsenal";
import { cn } from "@app/utils";
import { IconSearch } from "@tabler/icons-react";
import { useShallow } from "zustand/shallow";

const SORT_OPTIONS: { value: SortMode; label: string }[] = [
	{ value: "cheapest", label: "Menor custo" },
	{ value: "expensive", label: "Maior custo" },
	{ value: "name", label: "A-Z" },
];

export function Toolbar({ total }: { total: number }) {
	const { search, sort, setSearch, setSort } = useArsenal(
		useShallow((state) => ({
			search: state.search,
			sort: state.sort,
			setSearch: state.setSearch,
			setSort: state.setSort,
		})),
	);

	return (
		<div className="flex h-[2.25rem] w-full flex-shrink-0 items-center gap-[.625rem]">
			<div className="filter-bar flex h-full flex-1 items-center gap-1.5 rounded-[.1875rem] border border-white/[.08] border-solid px-[.5rem]">
				<IconSearch stroke={2} className="size-[.875rem] text-[#EDEAE54D]" />
				<input
					placeholder="Localizar armamento"
					value={search}
					onChange={(event) => setSearch(event.target.value)}
					className="stencil flex-1 bg-transparent text-[.75rem] text-white outline-none placeholder:text-[#EDEAE54D]"
				/>
			</div>

			<div className="flex h-full items-center gap-[.375rem]">
				{SORT_OPTIONS.map((option) => (
					<button
						key={option.value}
						type="button"
						onClick={() => setSort(option.value)}
						className={cn(
							"ghost-btn stencil relative flex h-full items-center justify-center rounded-[.1875rem] border border-white/5 border-solid px-[.75rem] text-[.6875rem] transition-all duration-300",
							sort === option.value
								? "is-active text-white"
								: "text-[#EDEAE599] hover:text-[#EDEAE5]",
						)}
					>
						<span className="relative z-10">{option.label}</span>
					</button>
				))}
			</div>

			<span className="h-[1.25rem] w-px flex-shrink-0 bg-white/[.08]" />

			<div className="flex flex-shrink-0 items-baseline gap-1.5">
				<span className="font-black text-[.9375rem] text-white tabular-nums leading-none">
					{total}
				</span>
				<span className="stencil text-[.625rem] text-white/30">itens</span>
			</div>
		</div>
	);
}
