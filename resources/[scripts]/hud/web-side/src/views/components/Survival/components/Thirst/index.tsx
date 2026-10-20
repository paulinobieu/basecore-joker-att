import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { type ISurvival, useMenu } from "@app/stores/Menu";
import { debugData } from "@app/utils/debugData";
import { ThirstIcon } from "@views/assets/icons/Thirst";
import { type ComponentType, useMemo, useState } from "react";
import { useShallow } from "zustand/shallow";
import { Lonzege } from "../Lonzege";
import { Rounded } from "../Rounded";

export function Thirst() {
    const [thirst, setThirst] = useState(0);
    const { survival, survivalSettings } = useMenu(
        useShallow((state) => ({
            survival: state.survival,
            survivalSettings: state.survivalSettings,
        })),
    );

    useNuiMessage("set:thirst", setThirst);

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

    if (!survivalSettings.thirst) return;

    return (
        <div className="relative flex size-[3.125rem] items-center justify-center">
            <ThirstIcon />

            <Component percentage={thirst} color="#35A4FF" />
        </div>
    );
}

debugData([{ action: "set:thirst", payload: 50 }]);
