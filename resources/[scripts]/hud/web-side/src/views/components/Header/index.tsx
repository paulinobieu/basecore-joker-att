import { Passport } from "./components/Passport";
import { Radio } from "./components/Radio";
import { Rest } from "./components/Rest";
import { Robbery } from "./components/Robbery";
import { Time } from "./components/Time";
import { Voice } from "./components/Voice";
import { Wanted } from "./components/Wanted";
import { Weapon } from "./components/Weapon";

export function Header() {
    return (
        <header
            style={{
                zoom: 1.2,
            }}
            className="pointer-events-none absolute top-[2.125rem] right-[2.125rem] flex w-fit flex-col items-end"
        >
            <div className="flex items-center justify-end gap-1.5">
                <Voice />
                <Time />
                <Passport />
            </div>
            <div className="mt-1.5 flex items-center justify-end gap-1.5">
                <Rest />
                <Wanted />
                <Radio />
            </div>
            <Robbery />
            <Weapon />
        </header>
    );
}
