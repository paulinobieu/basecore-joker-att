import { type SortMode, useShop } from "@app/stores/Shop";
import { cn } from "@app/utils";
import { IconSearch } from "@tabler/icons-react";
import { useShallow } from "zustand/shallow";

const SORT_OPTIONS: { value: SortMode; label: string }[] = [
	{ value: "cheapest", label: "Mais barato" },
	{ value: "expensive", label: "Mais caro" },
	{ value: "name", label: "A-Z" },
];

export function Toolbar({ total }: { total: number }) {
	const { search, sort, setSearch, setSort } = useShop(
		useShallow((state) => ({
			search: state.search,
			sort: state.sort,
			setSearch: state.setSearch,
			setSort: state.setSort,
		})),
	);

	return (
		<div className="flex h-[2.25rem] w-full flex-shrink-0 items-center gap-[.625rem]">
			<div className="filter-bar flex h-full flex-1 items-center gap-1.5 rounded-[.25rem] border border-white/[.08] border-solid px-[.5rem]">
				<IconSearch stroke={2} className="size-[.875rem] text-[#EDEAE54D]" />
				<input
					placeholder="Pesquisar produto"
					value={search}
					onChange={(event) => setSearch(event.target.value)}
					className="flex-1 bg-transparent font-extrabold text-[.75rem] text-white uppercase outline-none placeholder:text-[#EDEAE54D]"
				/>
			</div>

			<div className="flex h-full items-center gap-[.375rem]">
				{SORT_OPTIONS.map((option) => (
					<button
						key={option.value}
						type="button"
						onClick={() => setSort(option.value)}
						className={cn(
							"ghost-btn relative flex h-full items-center justify-center rounded-[.3125rem] border border-white/5 border-solid px-[.75rem] font-black text-[.6875rem] uppercase transition-all duration-300",
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
				<span className="font-black text-[.9375rem] text-white leading-none">
					{total}
				</span>
				<span className="font-black text-[.625rem] text-white/30 uppercase">
					produtos
				</span>
			</div>
		</div>
	);
}
