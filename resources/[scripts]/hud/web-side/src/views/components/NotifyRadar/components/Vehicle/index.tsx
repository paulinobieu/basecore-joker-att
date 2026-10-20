import type { CSSProperties } from "react";
import type { IVehicle } from "../..";
import { Indicator } from "./components/Indicator";
import { Speed } from "./components/Speed";

export function Vehicle({
    plate,
    speed,
    vehicle,
    direction,
}: IVehicle & { direction: "D" | "T" }) {
    return (
        <div className="grid h-[6.125rem] w-[16.75rem] place-items-center rounded-lg border border-white/10 border-solid p-[.1875rem]">
            <div
                className="amd-shell flex size-full items-center gap-6 rounded-md border border-white/[.04] border-solid py-3 pr-3.5 pl-[2.3125rem]"
                style={{
                    "--amd-bg":
                        "linear-gradient(0deg, rgba(21, 21, 21, 0.7), rgba(21, 21, 21, 0.7)),linear-gradient(67.84deg, rgba(var(--primaryColor), 0.3) -39.69%, rgba(var(--primaryColor), 0) 41.87%),linear-gradient(259.54deg, rgba(var(--primaryColor), 0.3) -87.14%, rgba(var(--primaryColor), 0) 26.94%)",
                    "--amd-blend": "screen",
                } as CSSProperties}
            >
                <Indicator direction={direction} />

                <div className="flex flex-col items-center justify-center gap-1">
                    <Speed speed={speed} />
                    <span className="text-xs">Velocidade</span>
                </div>
                <div className="flex h-full w-[6.625rem] flex-col items-start">
                    <div className="flex w-full items-center justify-between">
                        <div className="flex h-3.5 w-fit items-center justify-center rounded-[.25rem] bg-white px-1.5 font-semibold text-[#151515]/70 text-[.625rem]">
                            {plate}
                        </div>
                        <div className="flex size-4 items-center justify-center rounded-[.25rem] bg-primaryColor font-semibold text-[.625rem] text-white uppercase">
                            {direction}
                        </div>
                    </div>
                    <span className="mt-3 text-[.8125rem]">{vehicle}</span>
                </div>
            </div>
        </div>
    );
}
