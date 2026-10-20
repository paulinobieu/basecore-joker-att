import { type IKeyOption, useMenu } from "@app/stores/Menu";
import { cn } from "@app/utils";
import { AboutIcon } from "@views/assets/icons/About";
import type { ReactNode } from "react";

export function Option({
    keyOption,
    active,
    icon,
    title,
    tooltip,
}: {
    keyOption: IKeyOption;
    active: boolean;
    icon: ReactNode;
    title: string;
    tooltip: string;
}) {
    const toggleOption = useMenu((state) => state.toggleOption);

    return (
        <div
            className={cn(
                "group relative z-20 flex h-[2.875rem] w-full items-center rounded-lg bg-white/[.02] p-[.4375rem] transition-all duration-300 hover:bg-transparent",
                { "bg-transparent": active },
                {
                    "[&>.icon>svg>path]:fill-white":
                        active &&
                        [
                            "thirst",
                            "stamina",
                            "stress",
                            "notify",
                            "hide",
                        ].includes(keyOption),
                },
                {
                    "[&>.icon>svg>path]:stroke-white":
                        active &&
                        ![
                            "thirst",
                            "stamina",
                            "stress",
                            "notify",
                            "hide",
                        ].includes(keyOption),
                },
            )}
        >
            <div
                className={cn(
                    "absolute inset-0 z-40 rounded-lg opacity-0 bg-blend-screen transition-all duration-300 group-hover:opacity-100",
                    { "opacity-100": active },
                )}
                style={{
                    background:
                        "linear-gradient(0deg, rgba(255, 255, 255, 0.05), rgba(255, 255, 255, 0.05)),linear-gradient(90.24deg, rgba(255, 255, 255, 0.07) -2.29%, rgba(255, 255, 255, 0) 18.58%)",
                }}
            />
            <div
                className={cn(
                    "icon relative z-10 grid size-8 place-items-center rounded-md bg-white/5 group-hover:bg-transparent",
                    { "bg-transparent": active },
                )}
            >
                <div
                    className={cn(
                        "absolute inset-0 rounded-md border border-primaryColor border-solid opacity-0 transition-all duration-300 group-hover:opacity-100 ",
                        { "opacity-100": active },
                    )}
                    style={{
                        background:
                            "linear-gradient(90.81deg, rgb(var(--primaryColor)) 1.74%, rgba(var(--primaryColor), 0.4) 105.09%)",
                    }}
                />
                {icon}
            </div>
            <span className="mx-3 font-medium text-sm">{title}</span>
            <div className="flex size-3.5 items-center justify-center bg-transparent outline-none [&>svg>path]:stroke-white/50">
                <AboutIcon />
            </div>
            <button
                type="button"
                className={cn(
                    "relative z-40 ml-auto flex h-[1.375rem] w-11 items-center rounded-[.1875rem] border border-white/[.08] border-solid bg-white/[.02] p-[.1875rem] transition-all duration-300 group-hover:bg-white/5",
                )}
                onClick={() => toggleOption(keyOption)}
            >
                <div
                    className={cn(
                        "pointer-events-none size-4 rounded-sm bg-white/10 transition-all duration-300 group-hover:bg-white",
                        { "translate-x-[calc(100%+.25rem)] bg-white": active },
                    )}
                />
            </button>
        </div>
    );
}
