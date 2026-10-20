import { cn } from "@app/utils";

interface ISelect {
    image: { src: string; className: string };
    title: string;
    selected: boolean;
    onClick(): void;
}

export function Select({ image, selected, title, onClick }: ISelect) {
    return (
        <button
            type="button"
            className={cn(
                "group relative grid h-[10.0625rem] w-full place-items-center rounded-[.75rem] border border-white/[.04] border-solid p-1",
                { "border-primaryColor": selected },
            )}
            onClick={onClick}
        >
            <div
                className={cn(
                    "pointer-events-none absolute left-1 z-10 flex h-[2.125rem] w-[9.625rem] items-center justify-center rounded-r-lg bg-white/[.03] font-medium text-sm transition-all duration-300",
                    { "-translate-x-1 bg-primaryColor": selected },
                )}
            >
                {title}
            </div>
            <div className="pointer-events-none relative z-10 flex size-full items-center rounded-lg bg-white/[.02] transition-all duration-300 group-hover:bg-transparent">
                <img
                    src={image.src}
                    alt=""
                    className={cn(
                        "opacity-20 transition-all duration-300 group-hover:opacity-100",
                        { "opacity-100": selected },
                        image.className,
                    )}
                />
                <div
                    className={cn(
                        "absolute inset-0 rounded-lg opacity-0 bg-blend-screen transition-all duration-300 group-hover:opacity-100",
                        { "opacity-100": selected },
                    )}
                    style={{
                        background:
                            "linear-gradient(0deg, rgba(255, 255, 255, 0.02), rgba(255, 255, 255, 0.02)),linear-gradient(90deg, rgba(var(--primaryColor), 0.2) 0%, rgba(var(--primaryColor), 0) 100%)",
                    }}
                />
            </div>
        </button>
    );
}
