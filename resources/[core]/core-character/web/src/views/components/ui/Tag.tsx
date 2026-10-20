import { cn } from "@app/utils";
import { type VariantProps, cva } from "class-variance-authority";
import type { HTMLAttributes } from "react";

const tag = cva(
	"rounded-field px-2 py-[.125rem] font-black text-[.625rem] uppercase",
	{
		variants: {
			severity: {
				info: "bg-accent-solid text-white",
				warning: "bg-[rgba(221,221,221,.17)] text-ink-muted",
			},
		},
		defaultVariants: { severity: "info" },
	},
);

export interface TagProps
	extends HTMLAttributes<HTMLSpanElement>,
		VariantProps<typeof tag> {
	value: string;
}

export function Tag({ className, severity, value, ...props }: TagProps) {
	return (
		<span className={cn(tag({ severity }), className)} {...props}>
			{value}
		</span>
	);
}
