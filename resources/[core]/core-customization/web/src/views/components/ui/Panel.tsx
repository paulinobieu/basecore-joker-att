import { cn } from "@app/utils";
import { type VariantProps, cva } from "class-variance-authority";
import type { HTMLAttributes } from "react";

// `relative` na base: badges e controles de pagina sao posicionados
// contra o painel que os contem, nao contra a tela.
const panel = cva(
	"relative rounded-surface border border-white/[.03] bg-panel",
	{
		variants: {
			// Painel que reage ao hover, como os cards de opcao do creator:
			// acende um veu do gradiente de destaque e sobe o rotulo.
			interactive: {
				true: [
					"isolate transition-all duration-500",
					"after:absolute after:inset-0 after:z-[-1] after:rounded-surface after:content-['']",
					"after:bg-accent-faint after:opacity-0 after:transition-opacity after:duration-500",
					"hover:after:opacity-100",
				],
				false: "",
			},
		},
		defaultVariants: { interactive: false },
	},
);

export interface PanelProps
	extends HTMLAttributes<HTMLDivElement>,
		VariantProps<typeof panel> {}

export function Panel({ className, interactive, ...props }: PanelProps) {
	return <div className={cn(panel({ interactive }), className)} {...props} />;
}
