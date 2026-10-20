import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { debugData } from "@app/utils/debugData";
import { PassportIcon } from "@views/assets/icons/Passport";
import { useState } from "react";
import { Block } from "../Block";

export function Passport() {
    const [passport, setPassport] = useState<number>(0);

    useNuiMessage("set:passport", setPassport);

    return (
        <Block hide={passport === 0}>
            <PassportIcon />#{passport}
        </Block>
    );
}

debugData([
    {
        action: "set:passport",
        payload: 4964,
    },
]);
