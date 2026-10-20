import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { debugData } from "@app/utils/debugData";
import { AlertIcon } from "@views/assets/icons/Alert";
import { useState } from "react";
import { Block } from "../Block";

export function Wanted() {
    const [wanted, setWanted] = useState<boolean | null>(null);

    useNuiMessage("set:wanted", setWanted);

    if (!wanted) return null;

    return (
        <Block
            gradientBorderGradient="linear-gradient(0deg, #0143BB, #0143BB),linear-gradient(90deg, rgba(187, 1, 1, 0) 41.29%, #BB0101 100%)"
        >
            <AlertIcon />
            Procurado
        </Block>
    );
}

debugData([
    {
        action: "set:wanted",
        payload: true,
    },
]);
