import { useImageValidation } from "@app/hooks/useImageValidation";
import type { IRecipe } from "@app/stores/Crafting";
import { cn } from "@app/utils";

interface RecipeRowProps {
	recipe: IRecipe;
	selected: boolean;
	onSelect(): void;
}

export function RecipeRow({ recipe, selected, onSelect }: RecipeRowProps) {
	const { imageUrl, onImageError } = useImageValidation(recipe.image);

	return (
		<button
			type="button"
			onClick={onSelect}
			title={recipe.name}
			className={cn(
				"surface-card flex flex-shrink-0 items-center gap-[.625rem] rounded-[.3125rem] border border-solid p-[.5rem] text-left transition-colors duration-300",
				selected ? "border-primaryColor/50" : "border-white/[.03]",
			)}
		>
			<div className={cn("accent-overlay", selected && "is-active")} />

			<img
				src={imageUrl}
				alt={recipe.name}
				loading="lazy"
				decoding="async"
				onError={onImageError}
				className="relative z-30 size-[2.5rem] flex-shrink-0 object-contain"
			/>

			<span className="relative z-30 min-w-0 flex-1 truncate font-black text-[#EDEAE5] text-[.75rem] uppercase">
				{recipe.name}
			</span>
		</button>
	);
}
