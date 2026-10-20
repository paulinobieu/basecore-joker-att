import { useImageValidation } from "@app/hooks/useImageValidation";
import { useCrafting } from "@app/stores/Crafting";
import { useNotify } from "@app/stores/Notify";
import { clamp, formatNumber, formatTime } from "@app/utils/misc";
import { maxCraftable } from "@app/utils/recipe";
import {
	IconClockHour4,
	IconHammer,
	IconPackage,
	IconTool,
	IconWeight,
} from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Empty } from "@views/components/Empty";
import { Quantity } from "@views/components/Quantity";
import { SpinLoader } from "@views/components/SpinLoader";
import type { ReactNode } from "react";
import { useMemo } from "react";
import { useShallow } from "zustand/shallow";

function Meta({ icon, label }: { icon: ReactNode; label: string }) {
	return (
		<span className="filter-bar flex h-[1.75rem] items-center gap-1.5 rounded-[.25rem] border border-white/[.06] border-solid px-[.625rem] font-black text-[.6875rem] text-white/60 uppercase">
			{icon}
			{label}
		</span>
	);
}

export function RecipeDetails() {
	const { recipes, selectedId, amount, materials, sending, setAmount, craft } =
		useCrafting(
			useShallow((state) => ({
				recipes: state.recipes,
				selectedId: state.recipe,
				amount: state.amount,
				materials: state.materials,
				sending: state.sending,
				setAmount: state.setAmount,
				craft: state.craft,
			})),
		);

	const pushNotify = useNotify((state) => state.pushNotify);

	const recipe = useMemo(
		() => recipes.find((item) => item.id === selectedId) ?? null,
		[recipes, selectedId],
	);

	const { imageUrl, onImageError } = useImageValidation(recipe?.image);

	if (!recipe) {
		return (
			<section className="flex h-full flex-1 items-center justify-center">
				<Empty
					icon={IconTool}
					label="Nenhum item selecionado"
					hint="Escolha um item na lista ao lado"
				/>
			</section>
		);
	}

	const limit = maxCraftable(recipe, materials);
	const value = clamp(amount, 1, Math.max(1, limit));
	const canCraft = limit > 0 && !sending;

	const onCraft = async () => {
		const result = await craft(recipe, value);

		pushNotify(result.success ? "success" : "error", result.message);

		if (result.success) setAmount(1);
	};

	return (
		<section className="flex h-full min-w-0 flex-1 flex-col items-center gap-[1.25rem] p-[1.5rem]">
			<div className="relative flex min-h-0 w-full flex-1 items-center justify-center">
				<span className="preview-glow" />

				<img
					src={imageUrl}
					alt={recipe.name}
					decoding="async"
					onError={onImageError}
					className="relative z-10 h-full max-w-[55%] object-contain"
				/>
			</div>

			<div className="flex w-full flex-shrink-0 flex-col items-center gap-[.625rem]">
				<h1 className="text-center font-black text-[1.5rem] text-white uppercase leading-tight">
					{recipe.name}
				</h1>

				<div className="flex items-center gap-[.375rem]">
					<Meta
						icon={
							<IconPackage
								stroke={2.5}
								className="size-[.75rem] text-white/35"
							/>
						}
						label={`Rende ${formatNumber(recipe.amount)}x`}
					/>
					<Meta
						icon={
							<IconClockHour4
								stroke={2.5}
								className="size-[.75rem] text-white/35"
							/>
						}
						label={formatTime(recipe.time)}
					/>
					<Meta
						icon={
							<IconWeight
								stroke={2.5}
								className="size-[.75rem] text-white/35"
							/>
						}
						label={`${recipe.weight.toFixed(2).replace(".", ",")} kg`}
					/>
				</div>
			</div>

			<div className="flex w-full flex-shrink-0 flex-col items-center gap-[.5rem]">
				<div className="flex w-full items-center justify-center gap-[.625rem]">
					<Quantity
						value={value}
						max={Math.max(1, limit)}
						onChange={(next) => setAmount(clamp(next, 1, Math.max(1, limit)))}
					/>

					<Button
						size="lg"
						variant="ghost"
						disabled={limit <= 1}
						onClick={() => setAmount(limit)}
					>
						Máx
					</Button>

					<Button
						size="lg"
						variant="accent"
						className="w-[20rem]"
						disabled={!canCraft}
						icon={
							sending ? (
								<SpinLoader className="size-[.875rem]" />
							) : (
								<IconHammer
									stroke={2.5}
									className="relative z-10 size-[.9375rem] text-white"
								/>
							)
						}
						onClick={onCraft}
					>
						{sending ? "Enviando" : "Fabricar"}
					</Button>
				</div>

				<span className="font-semibold text-[.6875rem] text-white/30">
					{limit > 0
						? `Produz ${formatNumber(recipe.amount * value)}x em ${formatTime(recipe.time * value)}`
						: "Faltam materiais para fabricar"}
				</span>
			</div>
		</section>
	);
}
