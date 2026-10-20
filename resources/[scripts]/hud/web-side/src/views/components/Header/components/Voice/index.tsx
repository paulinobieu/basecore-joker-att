import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { debugData } from "@app/utils/debugData";
import { MicIcon } from "@views/assets/icons/Mic";
import { useState } from "react";
import { Block } from "../Block";

export function Voice() {
    const [level, setLevel] = useState<1 | 2 | 3 | 4>(2);
    const [isTalking, setIsTalking] = useState(false);

    useNuiMessage("set:voice:level", setLevel);
    useNuiMessage("set:voice:isTalking", setIsTalking);

    return (
        <Block>
            <MicIcon active={isTalking} />
            <div className="ml-0.5 flex items-center gap-0.5">
                {new Array(4).fill("").map((_, index) => (
                    <svg
                        width=".3125rem"
                        height=".5625rem"
                        viewBox="0 0 5 9"
                        fill="none"
                        xmlns="http://www.w3.org/2000/svg"
                        key={`voice-${index + 1}`}
                    >
                        <path
                            d="M1.31392 1.19012C1.46223 0.496033 2.07545 0 2.78521 0C3.74268 0 4.45656 0.882542 4.25649 1.81888L2.97636 7.80988C2.82805 8.50397 2.21483 9 1.50508 9C0.547606 9 -0.166281 8.11746 0.0337903 7.18112L1.31392 1.19012Z"
                            fill="white"
                            fill-opacity={level >= index + 1 ? 1 : 0.1}
                            className="transition-all duration-300"
                        />
                    </svg>
                ))}
            </div>
        </Block>
    );
}

debugData<any>([
    {
        action: "set:voice:level",
        payload: 2,
    },
    {
        action: "set:voice:isTalking",
        payload: true,
    },
]);
