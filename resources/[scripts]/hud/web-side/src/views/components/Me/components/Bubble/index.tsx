import { cn } from "@app/utils";
import type { IMe } from "..";

export function Bubble({ author, message, postit, x, y }: IMe) {
    return (
        <div
            className="absolute"
            style={{
                top: `${y * 100}%`,
                left: `${x * 100 + (postit ? 0 : 3)}%`,
            }}
        >
            <div
                className={cn(
                    "absolute bottom-0 left-0 max-w-72 rounded bg-black/50 px-3 pt-1 pb-2",
                    postit
                        ? "-translate-x-1/2"
                        : "after:absolute after:top-full after:left-4 after:size-0 after:border-transparent after:border-b-[1rem] after:border-l-[2rem] after:border-solid after:border-l-black/50",
                )}
            >
                <div
                    className={cn(
                        "inline-block whitespace-nowrap rounded px-1.5 py-0.5 font-semibold text-xs",
                        postit
                            ? "bg-yellow-500 text-black"
                            : "bg-primaryColor text-white",
                    )}
                >
                    {author}
                </div>
                <p className="mt-1.5 break-words text-white text-xs leading-tight">
                    {message}
                </p>
            </div>
        </div>
    );
}
