import { cn } from "@app/utils";
import { type VariantProps, cva } from "class-variance-authority";
import type { HTMLAttributes } from "react";

const card = cva(
	[
		"relative isolate rounded-surface border border-white/[.03] bg-card transition-all duration-500",
		"before:absolute before:inset-0 before:z-[-1] before:rounded-surface before:content-['']",
		"before:bg-accent-soft before:bg-blend-screen",
		"before:opacity-0 before:transition-all before:duration-500",
		"hover:before:opacity-100",
	],
	{
		variants: {
			active: { true: "before:opacity-100", false: "" },
		},
		defaultVariants: { active: false },
	},
);

export interface CardProps
	extends HTMLAttributes<HTMLDivElement>,
		VariantProps<typeof card> {}

export function Card({ className, active, ...props }: CardProps) {
	return <div className={cn(card({ active }), className)} {...props} />;
}
