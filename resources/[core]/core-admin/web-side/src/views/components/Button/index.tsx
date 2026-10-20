import { cn } from "@app/utils";
import type { ButtonHTMLAttributes, ReactNode } from "react";

type Variant = "accent" | "ghost" | "danger";
type Size = "sm" | "md" | "lg";

const variants: Record<Variant, string> = {
  accent: "accent-btn border border-white/15 text-white",
  ghost: "ghost-btn border border-white/5 text-[#EDEAE599] hover:text-[#EDEAE5]",
  danger: "danger-btn border border-white/15 text-white",
};

const sizes: Record<Size, string> = {
  sm: "h-[1.75rem] px-2.5 text-[.6875rem]",
  md: "h-[2.125rem] px-3 text-[.75rem]",
  lg: "h-[2.625rem] px-4 text-[.8125rem]",
};

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  size?: Size;
  active?: boolean;
  icon?: ReactNode;
}

export function Button({
  variant = "ghost",
  size = "md",
  active = false,
  icon,
  className,
  children,
  ...props
}: ButtonProps) {
  return (
    <button
      type="button"
      {...props}
      className={cn(
        "relative flex items-center justify-center gap-1.5 rounded-[.3125rem] font-black uppercase transition-all duration-300",
        variants[variant],
        sizes[size],
        active && "is-active text-white",
        className
      )}
    >
      {icon}
      {children && <span className="relative z-10">{children}</span>}
    </button>
  );
}
