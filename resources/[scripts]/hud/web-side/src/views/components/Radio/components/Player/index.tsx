import type { CSSProperties } from "react";
import { TalkIcon } from "@views/assets/icons/Talk";
import type { IPlayer } from "../..";

export function Player({
    id,
    name,
    isLeaving,
}: IPlayer & { isLeaving: boolean }) {
    return (
        <div
            className="amd-shell flex h-[1.75rem] items-center justify-center gap-2 pr-5 pl-[1.6875rem]"
            style={{
                "--amd-bg":
                    "linear-gradient(90deg, rgba(21, 21, 21, 0.7) 0%, rgba(21, 21, 21, 0) 100%)",
                animation: isLeaving
                    ? "hideNotify 0.35s cubic-bezier(0.175,0.885,0.32,1.275) forwards"
                    : "showNotify 0.35s cubic-bezier(0.175,0.885,0.32,1.275) forwards",
            } as CSSProperties}
        >
            <TalkIcon />
            <h1 className="font-semibold text-xs">Falando</h1>
            <div className="h-2.5 w-[.0625rem] bg-white/20" />
            <span className="text-white/70 text-xs">
                {name} #{id}
            </span>
        </div>
    );
}
