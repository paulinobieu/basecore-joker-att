import { useCrafting } from "@app/stores/Crafting";
import { clamp } from "@app/utils/misc";
import { maxCraftable } from "@app/utils/recipe";
import { Panel } from "@views/components/Panel";
import { useMemo } from "react";
import { useShallow } from "zustand/shallow";
import { Requirement } from "./components/Requirement";

/** Teto de ingredientes por receita -- a grade sempre mostra os 8 espacos. */
const SLOTS = 8;

export function Requirements() {
	const { recipes, selectedId, amount, materials } = useCrafting(
		useShallow((state) => ({
			recipes: state.recipes,
			selectedId: state.recipe,
			amount: state.amount,
			materials: state.materials,
		})),
	);

	const recipe = useMemo(
		() => recipes.find((item) => item.id === selectedId) ?? null,
		[recipes, selectedId],
	);

	const limit = recipe ? maxCraftable(recipe, materials) : 0;
	const multiplier = clamp(amount, 1, Math.max(1, limit));

	const slots = useMemo(() => {
		const ingredients = recipe?.ingredients ?? [];

		return Array.from({ length: SLOTS }, (_, index) => ({
			key: ingredients[index]?.id ?? `slot-${index}`,
			ingredient: ingredients[index] ?? null,
		}));
	}, [recipe]);

	return (
		<Panel
			title="Itens necessários"
			subtitle="Materiais gastos na fabricação"
			className="flex-shrink-0 border-white/[.05] border-b border-solid"
		>
			<div className="grid grid-cols-4 gap-[.5rem] p-[.75rem]">
				{slots.map((slot) => (
					<Requirement
						key={slot.key}
						ingredient={slot.ingredient}
						owned={slot.ingredient ? (materials[slot.ingredient.id] ?? 0) : 0}
						required={slot.ingredient ? slot.ingredient.amount * multiplier : 0}
					/>
				))}
			</div>
		</Panel>
	);
}
