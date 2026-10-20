import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { cn } from "@app/utils";
import { debugData } from "@app/utils/debugData";
import RobberImage from "@views/assets/images/robber.webp";
import type { CSSProperties } from "react";
import { useState  } from "react";

export function Robbery() {
    const [robbery, setRobbery] = useState<string | null>(null);

    useNuiMessage("set:robbery", (data?: string) => {
        if (!data) return setRobbery(null);

        setRobbery(data);
    });

    return (
        <div
            className={cn(
                "amd-shell mt-[.9375rem] h-[2.625rem] animate-fadeIn rounded-lg p-[.1875rem]",
                { hidden: !robbery },
                { "hidden animate-fadeOut": !robbery },
            )}
            style={{
                "--amd-bg":
                    "linear-gradient(0deg, rgba(21, 21, 21, 0.7), rgba(21, 21, 21, 0.7)),linear-gradient(86deg, rgba(187, 1, 1, 0) 52.54%, rgba(187, 1, 1, 0.2) 103.15%),linear-gradient(263.23deg, rgba(187, 1, 1, 0) 56.05%, rgba(187, 1, 1, 0.2) 116.88%)",
                "--amd-blend": "screen",
            } as CSSProperties}
        >
            <div
                className={cn(
                    "relative flex size-full flex-col justify-center rounded-md border border-[#BB0101] border-solid px-[.5625rem] pr-[3.1875rem] font-semibold text-[.5625rem]",
                )}
            >
                <span className="text-[.5625rem]">Assalto Liberado</span>
                <h1 className="font-extrabold text-[.625rem]">{robbery}</h1>
                <img
                    src={RobberImage}
                    className="absolute right-1.5 bottom-0 size-11"
                    alt="robber"
                />
            </div>
        </div>
    );
}

debugData([
    {
        action: "set:robbery",
        payload: "22-06H Sul",
    },
]);
