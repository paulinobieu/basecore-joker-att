import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { type ISurvival, useMenu } from "@app/stores/Menu";
import { debugData } from "@app/utils/debugData";
import { ShieldIcon } from "@views/assets/icons/Shield";
import { type ComponentType, useMemo, useState } from "react";
import { useShallow } from "zustand/shallow";
import { Lonzege } from "../Lonzege";
import { Rounded } from "../Rounded";

export function Shield() {
    const [shield, setShield] = useState(0);
    const { survival, survivalSettings } = useMenu(
        useShallow((state) => ({
            survival: state.survival,
            survivalSettings: state.survivalSettings,
        })),
    );

    useNuiMessage("set:shield", setShield);

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

    if (!survivalSettings.shield) return;
    if (shield <= 0) return null;

    return (
        <div className="relative flex size-[3.125rem] items-center justify-center">
            <ShieldIcon />

            <Component percentage={shield} color="#0143BB" />
        </div>
    );
}

debugData([{ action: "set:shield", payload: 50 }]);
