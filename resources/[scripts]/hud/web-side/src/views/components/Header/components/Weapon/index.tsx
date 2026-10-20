import { useImageValidation } from "@app/hooks/useImageValidation";
import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { cn } from "@app/utils";
import { debugData } from "@app/utils/debugData";
import { AmmoIcon } from "@views/assets/icons/Ammo";
import { WeaponHexagon } from "@views/assets/icons/WeaponHexagon";
import FallbackWeapon from "@views/assets/images/fallback-weapon.webp";
import { useState } from "react";

interface IWeapon {
    image: string;
    name: string;
    ammo: {
        current: number;
        loader: number;
    };
}

export function Weapon() {
    const [weapon, setWeapon] = useState<IWeapon | null>(null);
    const { imageUrl, isImageValid } = useImageValidation(weapon?.image || "");

    useNuiMessage("set:weapon", (data?: IWeapon) => {
        if (!data) return setWeapon(null);

        setWeapon(data);
    });

    return (
        <div
            className={cn(
                "mt-[1.3125rem] flex animate-fadeIn items-center justify-end gap-4",
                { hidden: !weapon },
                { "hidden animate-fadeOut": !weapon },
            )}
        >
            <div className="flex flex-col items-end">
                <span className="text-xs uppercase">{weapon?.name}</span>
                <div className="flex items-center gap-1">
                    <h1 className="font-semibold text-base">
                        {weapon?.ammo.current}
                    </h1>
                    <svg
                        width=".3125rem"
                        height=".9375rem"
                        viewBox="0 0 5 15"
                        fill="none"
                        xmlns="http://www.w3.org/2000/svg"
                    >
                        <path
                            d="M4.50012 0.500122L0.500122 14.5001"
                            stroke="white"
                            stroke-opacity="0.14"
                            stroke-linecap="round"
                        />
                    </svg>
                    <span className="mr-1.5 font-semibold text-xs">
                        {weapon?.ammo.loader}
                    </span>
                    <AmmoIcon />
                </div>
            </div>
            <div className="relative flex size-10 items-center justify-center">
                <WeaponHexagon />
                <img
                    src={isImageValid ? imageUrl : FallbackWeapon}
                    alt=""
                    className="absolute z-10 size-9 object-contain"
                />
            </div>
        </div>
    );
}

debugData([
    {
        action: "set:weapon",
        payload: {
            image: "",
            name: "Ak-47",
            ammo: { current: 48, loader: 320 },
        },
    },
]);
