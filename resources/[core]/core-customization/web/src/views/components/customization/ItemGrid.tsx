import { useClothesItem } from "@app/hooks/useClothesItem";
import { useClothesStore } from "@app/stores/Clothes";
import { cn } from "@app/utils";
import { LazyImage } from "@views/components/ui/LazyImage";
import { useEffect, useRef } from "react";

interface ItemGridProps {
	className?: string;
}

/** Miniaturas da peça em edição. O índice fica no canto da célula. */
export function ItemGrid({ className }: ItemGridProps) {
	const activeItem = useClothesStore((state) => state.activeItem);
	const { variants, indexes, item, selectItem } = useClothesItem();

	const selectedRef = useRef<HTMLButtonElement>(null);
	// Clicar já traz a célula à vista; rolar em cima disso arrancaria a
	// grade do lugar sob o cursor.
	const skipScroll = useRef(false);

	// biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
	useEffect(() => {
		if (skipScroll.current) {
			skipScroll.current = false;
			return;
		}

		selectedRef.current?.scrollIntoView({ block: "start", inline: "nearest" });
	}, [item, activeItem]);

	return (
		<div className={cn("grid grid-cols-3 gap-4", className)}>
			{indexes.map((index) => (
				<button
					key={index}
					type="button"
					ref={index === item ? selectedRef : undefined}
					data-tooltip="Selecionar esse modelo"
					onClick={() => {
						skipScroll.current = true;
						selectItem(index);
					}}
					className="relative flex h-32 w-32"
				>
					<div className="absolute right-0 bottom-0 z-10 mr-4 mb-2 font-bold text-primaryColor">
						{index}
					</div>

					<LazyImage
						src={variants[String(index)].image}
						className={cn(
							"z-0 h-full w-full rounded-[.25rem] border-2 border-transparent object-contain",
							"hover:border-primaryColor",
							index === item && "!border-primaryColor",
						)}
					/>
				</button>
			))}
		</div>
	);
}
