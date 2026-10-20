import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { type ISurvival, useMenu } from "@app/stores/Menu";
import { debugData } from "@app/utils/debugData";
import { OxygenIcon } from "@views/assets/icons/Oxygen";
import { type ComponentType, useMemo, useState } from "react";
import { useShallow } from "zustand/shallow";
import { Lonzege } from "../Lonzege";
import { Rounded } from "../Rounded";

export function Oxygen() {
    const [oxygen, setOxygen] = useState(0);
    const { survival, survivalSettings } = useMenu(
        useShallow((state) => ({
            survival: state.survival,
            survivalSettings: state.survivalSettings,
        })),
    );

    useNuiMessage("set:oxygen", setOxygen);

    const Component = useMemo(() => {
        const variants: Record<
            ISurvival,
            ComponentType<{
                percentage: number;
                color: string;
            }>
        > = {
            lonzege: Lonzege,
            rounded: Rounded,
        };

        return variants[survival];
    }, [survival]);

    if (!survivalSettings.oxygen) return;
    if (oxygen >= 100) return null;

    return (
        <div className="relative flex size-[3.125rem] items-center justify-center">
            <OxygenIcon />

            <Component percentage={oxygen} color="#ff7e70" />
        </div>
    );
}

debugData([{ action: "set:oxygen", payload: 50 }]);
