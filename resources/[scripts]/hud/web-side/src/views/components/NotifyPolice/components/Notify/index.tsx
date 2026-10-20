import { fetchNui } from "@app/utils/fetchNui";
import { GpsMarkerIcon } from "@views/assets/icons/GpsMarker";
import { PersonIcon } from "@views/assets/icons/Person";
import { PoliceIcon } from "@views/assets/icons/Police";
import type { CSSProperties } from "react";
import { useCallback  } from "react";
import type { NotifyProps } from "../..";

export function Notify({
    author,
    cds,
    code,
    id,
    location,
    timestamp,
    title,
}: NotifyProps) {
    const handleMarkLocation = useCallback(() => {
        fetchNui({ path: "post:police:markLocation", payload: cds });
    }, [cds]);

    return (
        <button
            type="button"
            className="animate-fadeInAnnounce relative flex h-[6.75rem] w-[21rem] shrink-0 items-center justify-center gap-2 rounded-md border border-primaryColor border-solid p-1"
            onClick={handleMarkLocation}
        >
            <div
                className="amd-shell pointer-events-none flex size-full items-center gap-[.6875rem] rounded-md border border-white/[.04] border-solid p-2.5 pr-4"
                style={{
                    "--amd-bg":
                        "linear-gradient(0deg, rgba(21, 21, 21, 0.7), rgba(21, 21, 21, 0.7)),linear-gradient(67.84deg, rgba(var(--primaryColor), 0.3) -39.69%, rgba(var(--primaryColor), 0) 41.87%)",
                    "--amd-blend": "screen",
                } as CSSProperties}
            >
                <div className="flex min-w-[2.875rem] flex-col items-center">
                    <PoliceIcon />
                    <span className="font-medium text-[.625rem]">
                        {timestamp}
                    </span>
                </div>
                <div className="flex flex-1 flex-col items-start">
                    <div className="mb-3 flex items-center gap-[.6875rem] font-medium text-sm">
                        <div
                            className="flex h-[1.125rem] w-fit min-w-max items-center justify-center rounded-[.25rem] px-[.4375rem] font-semibold text-[.6875rem]"
                            style={{
                                background:
                                    "linear-gradient(90.81deg, rgb(var(--primaryColor)) 1.74%, rgba(var(--primaryColor), 0.4) 105.09%)",
                            }}
                        >
                            {code}
                        </div>
                        {title}
                    </div>
                    <div className="flex items-center gap-2 text-white/80 text-xs">
                        <PersonIcon />
                        {author}
                    </div>
                    <div className="mt-1.5 flex items-center gap-2 text-white/80 text-xs">
                        <GpsMarkerIcon />
                        {location}
                    </div>
                </div>
            </div>
        </button>
    );
}
