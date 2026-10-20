import { useCrafting } from "@app/stores/Crafting";
import { IconSearch } from "@tabler/icons-react";
import { Empty } from "@views/components/Empty";
import { Panel } from "@views/components/Panel";
import { useMemo } from "react";
import { useShallow } from "zustand/shallow";
import { RecipeRow } from "./components/RecipeRow";

export function RecipeList() {
	const { recipes, category, search, recipe, setSearch, selectRecipe } =
		useCrafting(
			useShallow((state) => ({
				recipes: state.recipes,
				category: state.category,
				search: state.search,
				recipe: state.recipe,
				setSearch: state.setSearch,
				selectRecipe: state.selectRecipe,
			})),
		);

	const visibleRecipes = useMemo(() => {
		const term = search.trim().toLowerCase();

		return recipes
			.filter((item) => category === "all" || item.category === category)
			.filter((item) => !term || item.name.toLowerCase().includes(term));
	}, [recipes, category, search]);

	return (
		<Panel
			title="Itens fabricáveis"
			subtitle="Selecione um item para fabricar"
			className="h-full w-[21rem] flex-shrink-0 border-[#D9D9D91A] border-r border-solid"
		>
			<div className="flex-shrink-0 p-[.75rem]">
				<div className="filter-bar flex h-[2.25rem] items-center gap-1.5 rounded-[.25rem] border border-white/[.08] border-solid px-[.5rem]">
					<IconSearch stroke={2} className="size-[.875rem] text-[#EDEAE54D]" />
					<input
						placeholder="Pesquisar item"
						value={search}
						onChange={(event) => setSearch(event.target.value)}
						className="w-full bg-transparent font-extrabold text-[.75rem] text-white uppercase outline-none placeholder:text-[#EDEAE54D]"
					/>
				</div>
			</div>

			<div className="customScrollbar flex min-h-0 flex-1 flex-col gap-[.5rem] overflow-y-auto px-[.75rem] pb-[.75rem]">
				{visibleRecipes.length === 0 ? (
					<Empty
						icon={IconSearch}
						label="Nenhum item encontrado"
						hint="Tente outro termo de busca"
					/>
				) : (
					visibleRecipes.map((item) => (
						<RecipeRow
							key={item.id}
							recipe={item}
							selected={item.id === recipe}
							onSelect={() => selectRecipe(item.id)}
						/>
					))
				)}
			</div>
		</Panel>
	);
}
