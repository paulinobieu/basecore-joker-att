import { GearIcon } from "@views/assets/icons/Gear";
import { HudIcon } from "@views/assets/icons/Hud";
import { Category } from "./components/Category";

export function Footer() {
    return (
        <footer className="flex h-11 w-full items-center justify-center gap-1 p-1">
            <Category title="Hud" category="hud" icon={<HudIcon />} />
            <Category
                title="Ajustes"
                category="adjustments"
                icon={<GearIcon />}
            />
        </footer>
    );
}
