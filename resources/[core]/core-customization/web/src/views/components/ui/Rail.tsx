import { cn } from "@app/utils";
import type { HTMLAttributes } from "react";
import { Panel } from "./Panel";

/**
 * Trilha lateral de hexágonos, centralizada na vertical.
 *
 * O `safe center` evita cortar o topo quando a lista passa da altura
 * da tela; onde não houver suporte, o `justify-center` anterior
 * prevalece. A barra de rolagem fica oculta para não competir com os
 * hexágonos.
 */
export function Rail({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
	return (
		<Panel
			className={cn(
				"flex h-full w-fit flex-col items-center justify-center px-3 py-4",
				"[justify-content:safe_center]",
				"overflow-y-auto [scrollbar-width:none] [&::-webkit-scrollbar]:hidden",
				className,
			)}
			{...props}
		/>
	);
}
