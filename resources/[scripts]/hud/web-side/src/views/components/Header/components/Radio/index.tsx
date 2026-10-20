import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { debugData } from "@app/utils/debugData";
import { WalkieTalkieIcon } from "@views/assets/icons/WalkieTalkie";
import { useState } from "react";
import { Block } from "../Block";

export function Radio() {
    const [radio, setRadio] = useState<number | null>(null);

    useNuiMessage("set:radio", (data?: number) => {
        setRadio(data ?? null);
    });

    if (!radio) return null;

    return (
        <Block>
            <WalkieTalkieIcon />
            {radio} Mhz
        </Block>
    );
}

debugData([
    {
        action: "set:radio",
        payload: 521,
    },
]);
