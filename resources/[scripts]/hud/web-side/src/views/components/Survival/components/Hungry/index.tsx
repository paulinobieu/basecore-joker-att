import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { type ISurvival, useMenu } from "@app/stores/Menu";
import { debugData } from "@app/utils/debugData";
import { HungryIcon } from "@views/assets/icons/Hungry";
import { type ComponentType, useMemo, useState } from "react";
import { useShallow } from "zustand/shallow";
import { Lonzege } from "../Lonzege";
import { Rounded } from "../Rounded";

export function Hungry() {
    const [hungry, setHungry] = useState(0);
    const { survival, survivalSettings } = useMenu(
        useShallow((state) => ({
            survival: state.survival,
            survivalSettings: state.survivalSettings,
        })),
    );

    useNuiMessage("set:hungry", setHungry);

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

    if (!survivalSettings.hungry) return;

    return (
        <div className="relative flex size-[3.125rem] items-center justify-center">
            <HungryIcon />

            <Component percentage={hungry} color="#FFA237" />
        </div>
    );
}

debugData([{ action: "set:hungry", payload: 50 }]);
