import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { cn } from "@app/utils";
import { debugData } from "@app/utils/debugData";
import { SafezoneIcon } from "@views/assets/icons/Safezone";
import type { CSSProperties } from "react";
import { useState  } from "react";

export function Safezone() {
    const [safezone, setSafezone] = useState<boolean>(false);

    useNuiMessage("set:safezone", setSafezone);

    return (
        <div
            className={cn(
                "amd-shell -translate-y-full flex h-[2.1875rem] w-fit scale-[.85] items-center justify-center px-[2.1875rem] pr-5 pl-[2.0625rem] text-xs opacity-0 transition-all duration-300",
                { "translate-y-0 scale-[1] opacity-100": safezone },
            )}
            style={{
                "--amd-bg":
                    "linear-gradient(90deg, rgba(21, 21, 21, 0.7) 0%, rgba(21, 21, 21, 0) 100%)",
            } as CSSProperties}
        >
            <SafezoneIcon />
            Área Segura
        </div>
    );
}

debugData([
    {
        action: "set:safezone",
        payload: true,
    },
]);
