import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { useMinimapDimensions } from "@app/stores/MinimapDimensions";
import { debugData } from "@app/utils/debugData";
import { LocationIcon } from "@views/assets/icons/Location";
import { useState } from "react";

interface ILocation {
    street: string;
    compassHeading: string;
}

export function Location() {
    const [location, setLocation] = useState<ILocation | null>(null);
    const [radarVisible, setRadarVisible] = useState(true);
    const { top, left, width, height } = useMinimapDimensions((state) => state);

    useNuiMessage("set:location", (data?: ILocation) => {
        setLocation(data ?? null);
    });

    useNuiMessage<boolean>("set:radar:visible", (data) => {
        setRadarVisible(data !== false);
    });

    if (!location) return null;

    const computedTop = radarVisible ? top : top + height;

    return (
        <div
            style={{
                top: `${computedTop}px`,
                left: `${left}px`,
                width: `${width}px`,
            }}
            className="-translate-y-[calc(180%+.3125rem)] absolute flex h-10 items-center gap-2 transition-[top] duration-200"
        >
            <LocationIcon />
            <span className="mr-auto ml-2 font-semibold text-sm">
                {location?.street}
            </span>
            <div className="flex h-[1.125rem] w-fit items-center justify-center rounded-[.3125rem] bg-white/20 px-[.5625rem] font-semibold text-white/80 text-xs">
                {location?.compassHeading}
            </div>
        </div>
    );
}

debugData([
    {
        action: "set:location",
        payload: {
            street: "Bay City Incine",
            compassHeading: "Sul",
        },
    },
]);
