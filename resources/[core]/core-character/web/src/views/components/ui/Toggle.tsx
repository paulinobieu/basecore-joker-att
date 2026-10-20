import { cn } from "@app/utils";
import { type VariantProps, cva } from "class-variance-authority";
import type { ButtonHTMLAttributes } from "react";

/**
 * Aba / item selecionavel.
 *
 * Base apagada; quando ativo (ou no hover) acende duas camadas em
 * z-index negativo: `::after` com o gradiente de destaque e `::before`
 * com uma borda de 1px em primary, desenhada por mascara.
 *
 * `isolation: isolate` cria o contexto de empilhamento proprio — as
 * camadas ficam acima do fundo do botao e abaixo do conteudo, sem
 * precisar posicionar os filhos.
 */
const toggle = cva(
	[
		"relative isolate flex items-center justify-center gap-2",
		"rounded-surface border border-white/[.05] bg-raise bg-blend-screen",
		"font-black uppercase text-ink-faint transition-all duration-500",

		// Preenchimento em gradiente
		"after:absolute after:inset-0 after:z-[-2] after:rounded-surface after:content-['']",
		"after:bg-accent after:bg-blend-screen after:shadow-glow",
		"after:opacity-0 after:transition-all after:duration-500",

		// Borda de 1px em primary. O -webkit-* acompanha porque o CEF do
		// FiveM ainda nao entende mask-composite sem prefixo.
		"before:absolute before:inset-0 before:z-[-1] before:rounded-surface before:p-px before:content-['']",
		"before:bg-outline before:bg-blend-screen",
		"before:[mask:linear-gradient(#000_0_0)_content-box,linear-gradient(#000_0_0)]",
		"before:[mask-composite:exclude]",
		"before:[-webkit-mask:linear-gradient(#000_0_0)_content-box,linear-gradient(#000_0_0)]",
		"before:[-webkit-mask-composite:xor]",
		"before:opacity-0 before:transition-all before:duration-500",
	],
	{
		variants: {
			active: {
				true: "text-ink after:opacity-100 before:opacity-100",
				false: "",
			},
			// Mantem o tooltip funcionando, mas sem acender no hover.
			interactive: {
				true: "hover:text-ink hover:after:opacity-100 hover:after:brightness-75 hover:before:opacity-100 hover:before:brightness-75",
				false: "",
			},
		},
		defaultVariants: { active: false, interactive: true },
	},
);

export interface ToggleProps
	extends ButtonHTMLAttributes<HTMLButtonElement>,
		VariantProps<typeof toggle> {}

export function Toggle({
	className,
	active,
	interactive,
	...props
}: ToggleProps) {
	return (
		<button
			type="button"
			className={cn(toggle({ active, interactive }), className)}
			{...props}
		/>
	);
}
