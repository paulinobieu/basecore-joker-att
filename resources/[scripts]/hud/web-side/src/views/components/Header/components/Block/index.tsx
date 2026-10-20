import { cn } from "@app/utils";
import type { ClassValue } from "clsx";
import type { ReactNode } from "react";

interface BlockProps {
    children: ReactNode;
    hide?: boolean;
    className?: ClassValue;
    gradientBorderGradient?: string;
}

export function Block({
    children,
    className,
    gradientBorderGradient,
    hide,
}: BlockProps) {
    return (
        <div
            className={cn(
                "h-[1.75rem] animate-fadeIn rounded-lg bg-[#151515]/70 p-[.1875rem]",
                { "animate-fadeOut": hide },
            )}
        >
            <div
                className={cn(
                    "relative flex size-full items-center justify-center gap-1.5 rounded-md border border-[#404040] border-solid px-[.5625rem] font-semibold text-[.5625rem]",
                    className,
                    {
                        "border-transparent": gradientBorderGradient,
                    },
                )}
            >
                {children}
                {gradientBorderGradient && (
                    <div
                        className="gradientBorder absolute inset-0 rounded-md bg-blend-overlay"
                        style={{
                            background: gradientBorderGradient,
                        }}
                    />
                )}
            </div>
        </div>
    );
}
