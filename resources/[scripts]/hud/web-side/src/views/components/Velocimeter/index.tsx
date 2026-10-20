import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { type IVelocimeter, useMenu } from "@app/stores/Menu";
import { cn } from "@app/utils";
import { debugData } from "@app/utils/debugData";
import { useMemo, useState } from "react";
import { DigitalVelocimeter } from "./components/Digital";
import { RoundedVelocimeter } from "./components/Rounded";

export interface IVelocimeterData {
    speed: number;
    headlight: boolean;
    seatbelt: boolean;
    lock: boolean;
    fuel: number;
    nitro: number;
    rpm: number;

    gear: string;

    engine: number;
}

interface IVelocimeterState {
    data: IVelocimeterData;
    visible: boolean;
}

const initialState: IVelocimeterState = {
    data: {
        speed: 0,
        headlight: false,
        seatbelt: false,
        lock: false,
        fuel: 0,
        nitro: 0,
        rpm: 0,
        gear: "N",
        engine: 0,
    },
    visible: false,
};

export function Velocimeter() {
    const [state, setState] = useState<IVelocimeterState>(initialState);
    const velocimeter = useMenu((state) => state.velocimeter);

    const VelocimeterComponent = useMemo(() => {
        const velocimeters: Record<IVelocimeter, React.ElementType> = {
            rounded: RoundedVelocimeter,
            digital: DigitalVelocimeter,
        };

        const Component = velocimeters[velocimeter];

        if (!Component) {
            return RoundedVelocimeter;
        }

        return Component;
    }, [velocimeter]);

    useNuiMessage("set:velocimeter", (data?: IVelocimeterData) => {
        setState((current) => {
            if (!data) {
                return current.visible ? { ...current, visible: false } : current;
            }

            return { data, visible: true };
        });
    });

    if (!velocimeter) return null;

    return (
        <div
            key={velocimeter}
            className={cn(
                "velocimeter-runtime absolute flex items-center justify-center",
                state.visible
                    ? "visible opacity-100"
                    : "invisible opacity-0",
                {
                    "-translate-x-1/2 bottom-0 left-1/2":
                        velocimeter === "digital",
                },
                {
                    "right-[2.125rem] bottom-[6.25rem]":
                        velocimeter === "rounded",
                },
            )}
            aria-hidden={!state.visible}
        >
            <VelocimeterComponent {...state.data} />
        </div>
    );
}

debugData([
    {
        action: "set:velocimeter",
        payload: {
            speed: 80,
            headlight: true,
            seatbelt: false,
            lock: false,
            fuel: 50,
            nitro: 100,
            rpm: 100,
            engine: 50,
            gear: "R",
        },
    },
]);
