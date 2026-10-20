import type { IMaterials, IRecipe } from "@app/stores/Crafting";

/** Teto por fabricacao, para o jogador nao enfileirar uma fila infinita. */
export const MAX_CRAFT_AMOUNT = 50;

/** Quantas vezes a receita cabe nos materiais que o jogador tem agora. */
export const maxCraftable = (
	recipe: IRecipe,
	materials: IMaterials,
): number => {
	let max = MAX_CRAFT_AMOUNT;

	for (const ingredient of recipe.ingredients) {
		if (ingredient.amount <= 0) continue;

		const owned = materials[ingredient.id] ?? 0;

		max = Math.min(max, Math.floor(owned / ingredient.amount));
	}

	return Math.max(0, max);
};
