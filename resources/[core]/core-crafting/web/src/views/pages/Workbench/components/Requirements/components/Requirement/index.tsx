import { useImageValidation } from "@app/hooks/useImageValidation";
import type { IIngredient } from "@app/stores/Crafting";
import { cn } from "@app/utils";
import { formatNumber } from "@app/utils/misc";

interface RequirementProps {
	/** `null` desenha o espaco vazio da grade. */
	ingredient: IIngredient | null;
	/** Quanto o jogador tem do material. */
	owned: number;
	/** Quanto a fabricacao vai consumir na quantidade escolhida. */
	required: number;
}

export function Requirement({ ingredient, owned, required }: RequirementProps) {
	const { imageUrl, onImageError } = useImageValidation(ingredient?.image);

	if (!ingredient) {
		return (
			<div className="aspect-square rounded-[.3125rem] border border-white/[.03] border-dashed bg-white/[.01]" />
		);
	}

	const enough = owned >= required;

	return (
		<div
			title={`${ingredient.name} — ${formatNumber(owned)}/${formatNumber(required)}`}
			className={cn(
				"surface-card flex aspect-square flex-col items-center justify-center gap-[.25rem] rounded-[.3125rem] border border-solid p-[.375rem]",
				enough ? "border-white/[.03]" : "border-[#E24040]/40",
			)}
		>
			<img
				src={imageUrl}
				alt={ingredient.name}
				loading="lazy"
				decoding="async"
				onError={onImageError}
				className="relative z-30 size-[2rem] object-contain"
			/>

			<span
				className={cn(
					"relative z-30 font-black text-[.625rem] leading-none",
					enough ? "text-white" : "text-[#E24040]",
				)}
			>
				{formatNumber(owned)}
				<span className="text-white/25">/{formatNumber(required)}</span>
			</span>
		</div>
	);
}
