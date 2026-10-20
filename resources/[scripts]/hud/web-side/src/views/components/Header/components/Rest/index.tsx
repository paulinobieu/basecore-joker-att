import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { debugData } from "@app/utils/debugData";
import { RestIcon } from "@views/assets/icons/Rest";
import { useState } from "react";
import { Block } from "../Block";

export function Rest() {
    const [rest, setRest] = useState<boolean | null>(null);

    useNuiMessage("set:rest", setRest);

    if (!rest) return null;

    return (
        <Block>
            <RestIcon />
            Repouso
        </Block>
    );
}

debugData([
    {
        action: "set:rest",
        payload: true,
    },
]);
