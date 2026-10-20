import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { useSound } from "@app/hooks/useSound";
import { cn } from "@app/utils";
import { debugData } from "@app/utils/debugData";
import { sanitizeContent } from "@app/utils/sanitizeHtml";
import { RequestIcon } from "@views/assets/icons/Request";
import RequestSound from "@views/assets/sounds/request.wav";
import type { CSSProperties } from "react";
import { useEffect, useState  } from "react";
import { Key } from "./components/Key";

interface IRequest {
    title: string;
    message: string;
    acceptKey: string;
    refuseKey: string;
    timeout: number;
}

export function NotifyRequest() {
    const [notify, setNotify] = useState<IRequest | null>(null);
    const [lastNotify, setLastNotify] = useState<IRequest | null>(null);

    const { play: playRequest } = useSound(RequestSound, { volume: 0.8 });

    useNuiMessage("notify:request", (data?: IRequest) => {
        if (!data) {
            setNotify(null);
            return;
        }

        if (notify) return;

        setNotify(data);
        playRequest();

        const timeout = setTimeout(() => {
            setNotify(null);
        }, data.timeout || 5000);

        return () => clearTimeout(timeout);
    });

    useEffect(() => {
        if (!notify) return;

        setLastNotify(notify);
    }, [notify]);

    return (
        <div
            className={cn(
                "flex items-center gap-[.9375rem] transition-all duration-300",
                notify
                    ? "translate-y-0 scale-100 opacity-100"
                    : "-translate-y-full scale-[.85] opacity-0",
            )}
        >
            <div
                className="amd-shell flex w-[20.625rem] items-center gap-3 rounded-md py-4 pr-[1.625rem] pl-[.5625rem] outline outline-1 outline-white/10 outline-offset-[.1875rem]"
                style={{
                    "--amd-bg":
                        "linear-gradient(0deg, rgba(21, 21, 21, 0.7), rgba(21, 21, 21, 0.7)),linear-gradient(67.84deg, rgba(var(--primaryColor), 0.3) -39.69%, rgba(var(--primaryColor), 0) 41.87%)",
                    "--amd-blend": "screen",
                } as CSSProperties}
            >
                <RequestIcon />
                <div className="flex flex-col items-start">
                    <h1 className="text-sm">
                        {notify?.title || lastNotify?.title || "Request"}
                    </h1>
                    <span
                        className="text-[.625rem] text-white/70"
                        // biome-ignore lint/security/noDangerouslySetInnerHtml: <explanation>
                        dangerouslySetInnerHTML={{
                            __html: sanitizeContent(
                                notify?.message || lastNotify?.message || "",
                            ),
                        }}
                    />
                </div>
            </div>
            <div className="flex flex-col items-center justify-center">
                <Key
                    color="#76df0e"
                    pressKey={notify?.acceptKey || lastNotify?.acceptKey || "Y"}
                />
                <Key
                    color="#DF394F"
                    pressKey={notify?.refuseKey || lastNotify?.refuseKey || "N"}
                />
            </div>
        </div>
    );
}

debugData<IRequest>([
    {
        action: "notify:request",
        payload: {
            title: "TESTE",
            message:
                "Você recebeu uma <strong>solicitação de beijo</strong> enviada por <strong>Bieu [4964]</strong>. Deseja aceitar?",
            acceptKey: "Y",
            refuseKey: "N",
            timeout: 50000,
        },
    },
]);
