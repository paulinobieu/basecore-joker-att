import { cn } from "@app/utils";
import { toRgba } from "@app/utils/colors";
import { MinusIcon } from "@views/assets/icons/Minus";
import { PlusIcon } from "@views/assets/icons/Plus";
import type { CSSProperties } from "react";
import { useMemo  } from "react";
import type { NotifyProps } from "../..";
import { Image } from "./components/Image";

export function Notify({ action, amount, image, name, isLeaving }: NotifyProps & { isLeaving: boolean }) {
    const color = useMemo(() => {
        const colors: Record<typeof action, string> = {
            add: "#9AFF35",
            remove: "#FF3535",
        };

        return colors[action];
    }, [action]);

    return (
        <div
            className="amd-shell flex h-[2.1875rem] items-center justify-center gap-2 pr-1.5 pl-[2.625rem] font-semibold text-xs"
            style={{
                "--amd-bg": `linear-gradient(88.3deg, rgba(21, 21, 21, 0.7) 15.15%, rgba(21, 21, 21, 0) 99.18%),linear-gradient(90deg, ${toRgba(color, 0.2)} -26.95%, ${toRgba(color, 0.0)} 43%)`,
                "--amd-blend": "screen",
                animation: isLeaving
                    ? "hideNotify 0.35s cubic-bezier(0.175,0.885,0.32,1.275) forwards"
                    : "showNotify 0.35s cubic-bezier(0.175,0.885,0.32,1.275) forwards",
            } as CSSProperties}
        >
            <Image image={image} action={action} />
            {action === "add" ? <PlusIcon /> : <MinusIcon />}
            {name}
            <div
                className={cn(
                    "flex h-4 items-center justify-center rounded-md px-1.5 font-semibold text-white text-xs",
                    { "text-black": action === "add" },
                )}
                style={{
                    background: color,
                }}
            >
                {amount}x
            </div>
        </div>
    );
}
