import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { type ISurvival, useMenu } from "@app/stores/Menu";
import { debugData } from "@app/utils/debugData";
import { StaminaIcon } from "@views/assets/icons/Stamina";
import { type ComponentType, useMemo, useState } from "react";
import { useShallow } from "zustand/shallow";
import { Lonzege } from "../Lonzege";
import { Rounded } from "../Rounded";

export function Stamina() {
    const [stamina, setStamina] = useState(0);
    const { survival, survivalSettings } = useMenu(
        useShallow((state) => ({
            survival: state.survival,
            survivalSettings: state.survivalSettings,
        })),
    );

    useNuiMessage("set:stamina", setStamina);

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

    if (!survivalSettings.stamina) return;

    return (
        <div className="relative flex size-[3.125rem] items-center justify-center">
            <StaminaIcon />

            <Component percentage={stamina} color="#9AFF35" />
        </div>
    );
}

debugData([{ action: "set:stamina", payload: 50 }]);
