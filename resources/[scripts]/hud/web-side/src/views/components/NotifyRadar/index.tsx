import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { useEffect, useState } from "react";
import { Vehicle } from "./components/Vehicle";

export interface IVehicle {
    speed: number;
    plate: string;
    vehicle: string;
}
interface IRadar {
    front: IVehicle;
    rear: IVehicle;
}

export function NotifyRadar() {
    const [radar, setRadar] = useState<IRadar | null>(null);
    const [lastRadar, setLastRadar] = useState<IRadar | null>(null);

    useNuiMessage("set:radar", (data?: IRadar) => {
        if (!data) {
            setRadar(null);
            setLastRadar(null);
            return;
        }
        setRadar(data);
    });

    useEffect(() => {
        if (!radar) return;

        setLastRadar(radar);
    }, [radar]);

    return (
        <div className="absolute bottom-[18.0625rem] left-[2.125rem] flex w-[16.75rem] flex-col gap-2">
            {(radar || lastRadar) && (
                //@ts-expect-error
                <Vehicle
                    {...(radar?.front || lastRadar?.front)}
                    direction="D"
                />
            )}
            {(radar || lastRadar) && (
                //@ts-expect-error
                <Vehicle {...(radar?.rear || lastRadar?.rear)} direction="T" />
            )}
        </div>
    );
}

// debugData([
//     {
//         action: "set:radar",
//         payload: {
//             front: {
//                 vehicle: "Zentorno",
//                 speed: 120,
//                 plate: "ABC-1234",
//             },
//             rear: {
//                 vehicle: "Panto",
//                 speed: 80,
//                 plate: "ABC-1234",
//             },
//         },
//     },
// ]);
