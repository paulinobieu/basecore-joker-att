import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { debugData } from "@app/utils/debugData";
import { StopwatchIcon } from "@views/assets/icons/Stopwatch";
import { useState } from "react";
import { Block } from "../Block";

export function Time() {
    const [time, setTime] = useState("00:00");

    useNuiMessage("set:time", setTime);

    return (
        <Block>
            <StopwatchIcon />
            {time}
        </Block>
    );
}

debugData([
    {
        action: "set:time",
        payload: "12:30",
    },
]);
