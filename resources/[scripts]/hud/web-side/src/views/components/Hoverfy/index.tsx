import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { cn } from "@app/utils";
import type { CSSProperties } from "react";
import { useEffect, useState  } from "react";
import { Key } from "./components/Key";

interface IHoverfy {
    pressKey: string;
    action: string;
}

export function Hoverfy() {
    const [hoverfy, setHoverfy] = useState<IHoverfy | null>(null);
    const [lastHoverfy, setLastHoverfy] = useState<IHoverfy | null>(null);

    useNuiMessage("set:hoverfy", (data?: IHoverfy) => {
        if (!data) return setHoverfy(null);

        setHoverfy(data);
    });

    useEffect(() => {
        if (!hoverfy) return;

        setLastHoverfy(hoverfy);
    }, [hoverfy]);

    return (
        <div
            className={cn(
                "amd-shell -translate-x-1/2 absolute bottom-[8.3125rem] left-1/2 flex h-[2.1875rem] w-fit translate-y-full scale-[.85] items-center justify-center px-[2.1875rem] text-xs opacity-0 transition-all duration-300",
                { "translate-y-0 scale-[1] opacity-100": hoverfy },
            )}
            style={{
                "--amd-bg":
                    "linear-gradient(0deg, rgba(21, 21, 21, 0.7), rgba(21, 21, 21, 0.7)),linear-gradient(86deg, rgba(187, 1, 1, 0) 52.54%, rgba(187, 1, 1, 0.2) 103.15%),linear-gradient(263.23deg, rgba(187, 1, 1, 0) 56.05%, rgba(187, 1, 1, 0.2) 116.88%)",
            } as CSSProperties}
        >
            <Key pressKey={hoverfy?.pressKey || lastHoverfy?.pressKey || ""} />
            {hoverfy?.action || lastHoverfy?.action}
        </div>
    );
}

// debugData([
//     {
//         action: "set:hoverfy",
//         payload: {
//             pressKey: "P",
//             action: "Pressione a tecla",
//         },
//     },
// ]);
