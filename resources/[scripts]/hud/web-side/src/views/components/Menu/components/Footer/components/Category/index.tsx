import { type ICategory, useMenu } from "@app/stores/Menu";
import { cn } from "@app/utils";
import type { ReactNode } from "react";
import { useShallow } from "zustand/shallow";

interface ICategoryProps {
    category: ICategory;
    title: string;
    icon: ReactNode;
}

export function Category({ category, icon, title }: ICategoryProps) {
    const { selectedCategory, setSelectedCategory } = useMenu(
        useShallow((state) => ({
            selectedCategory: state.selectedCategory,
            setSelectedCategory: state.setSelectedCategory,
        })),
    );

    return (
        <button
            type="button"
            className={cn(
                "group relative flex h-full w-1/2 items-center justify-center gap-3 rounded-lg bg-white/[.08] transition-all duration-300 hover:bg-transparent",
                {
                    "[&>div>svg>path]:fill-white":
                        selectedCategory === category,
                },
            )}
            onClick={() => setSelectedCategory(category)}
        >
            <div className="relative z-10">{icon}</div>
            <span
                className={cn(
                    "relative z-10 font-bold text-base text-white/45 uppercase transition-all duration-300 group-hover:text-white",
                    { "text-white": selectedCategory === category },
                )}
            >
                {title}
            </span>

            <div
                className={cn(
                    "pointer-events-none absolute inset-0 z-0 rounded-lg opacity-0 outline outline-1 outline-primaryColor transition-all duration-300 group-hover:opacity-100",
                    { "opacity-100": selectedCategory === category },
                )}
                style={{
                    background:
                        "linear-gradient(90.81deg, rgb(var(--primaryColor)) 1.74%, rgba(var(--primaryColor), 0.4) 105.09%)",
                }}
            />
        </button>
    );
}
