import { cn } from "@app/utils";
import { type VariantProps, cva } from "class-variance-authority";
import type { ButtonHTMLAttributes } from "react";

const button = cva(
	[
		"flex items-center justify-center gap-2",
		"rounded-surface px-5",
		"whitespace-nowrap font-black uppercase",
		"transition-all duration-300",
	],
	{
		variants: {
			variant: {
				primary:
					"border border-white/[.15] bg-accent bg-blend-multiply text-white hover:brightness-75",
				// Filme claro sobre base escura propria. So o translucido nao
				// serve: este botao flutua sobre a cena do jogo, nao sobre um
				// painel, entao precisa garantir o proprio contraste.
				ghost:
					"border border-white/[.08] bg-ghost text-[#EDEAE5DD] hover:bg-ghost-hover hover:text-white",
			},
			disabled: {
				true: "pointer-events-none cursor-default opacity-70",
				false: "",
			},
		},
		defaultVariants: { variant: "primary", disabled: false },
	},
);

export interface ButtonProps
	extends Omit<ButtonHTMLAttributes<HTMLButtonElement>, "disabled">,
		VariantProps<typeof button> {}

export function Button({
	className,
	variant,
	disabled,
	...props
}: ButtonProps) {
	return (
		<button
			type="button"
			disabled={!!disabled}
			className={cn(button({ variant, disabled }), className)}
			{...props}
		/>
	);
}
