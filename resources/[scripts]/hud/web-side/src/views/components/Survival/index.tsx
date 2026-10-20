import { Hungry } from "./components/Hungry";
import { Life } from "./components/Life";
import { Oxygen } from "./components/Oyxgen";
import { Shield } from "./components/Shield";
import { Stamina } from "./components/Stamina";
import { Stress } from "./components/Stress";
import { Thirst } from "./components/Thirst";

export function Survival() {
    return (
        <div className="absolute right-[2.125rem] bottom-[2.125rem] flex items-center">
            <Life />
            <Shield />
            <Hungry />
            <Thirst />
            <Stamina />
            <Stress />
            <Oxygen />
        </div>
    );
}
