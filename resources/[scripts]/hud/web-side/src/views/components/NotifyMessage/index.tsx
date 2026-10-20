import { useEffect, useRef, useState } from "react";
import { v4 as uuidv4 } from "uuid";

import ErrorSound from "@views/assets/sounds/error.flac";
import InfoSound from "@views/assets/sounds/notify.mp3";
import SuccessSound from "@views/assets/sounds/success.wav";
import WarnSound from "@views/assets/sounds/warn.wav";

import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { useSound } from "@app/hooks/useSound";
import { debugData } from "@app/utils/debugData";
import { Notify } from "./components/Notify";

export interface NotifyProps {
    id: string;
    type: "success" | "error" | "warn" | "info";
    message: string;
    title?: string;
    timeout: number;
}

export function NotifyMessage() {
    const [notifys, setNotifys] = useState<NotifyProps[]>([]);
    const timersRef = useRef<{ [key: string]: ReturnType<typeof setTimeout> }>({});

    const { play: playSuccess } = useSound(SuccessSound, { volume: 0.15 });
    const { play: playWarn } = useSound(WarnSound, { volume: 0.15 });
    const { play: playError } = useSound(ErrorSound, { volume: 0.15 });
    const { play: playInfo } = useSound(InfoSound, { volume: 0.15 });

    useNuiMessage<NotifyProps>("notify:message", (data) => {
        const id = uuidv4();

        if (notifys.length > 7) {
            return;
        }

        setNotifys((prev) => [...prev, { ...data, id }]);

        const playSound = {
            success: playSuccess,
            warn: playWarn,
            error: playError,
            info: playInfo,
        };

        playSound[data.type || "info"]();
    });

    useEffect(() => {
        notifys.forEach((notify) => {
            if (!timersRef.current[notify.id]) {
                timersRef.current[notify.id] = setTimeout(() => {
                    setNotifys((prev) => prev.filter((n) => n.id !== notify.id));
                    delete timersRef.current[notify.id];
                }, notify.timeout);
            }
        });
    }, [notifys]);

    useEffect(() => {
        const ref = timersRef.current;
        return () => {
            Object.values(ref).forEach(clearTimeout);
        };
    }, []);

    if (notifys.length === 0) return null;

    return (
        <ul className="flex flex-col gap-1.5">
            {notifys.map((notify) => {
                return <Notify key={notify.id} {...notify} />;
            })}
        </ul>
    );
}

debugData<any>([
    {
        action: "notify:message",
        payload: {
            type: "error",
            message:
                "O servidor será reiniciado em <strong>30 segundos</strong>.",
            timeout: 15000,
        },
    },
    {
        action: "notify:message",
        payload: {
            type: "success",
            message:
                "O servidor será reiniciado em <strong>30 segundos</strong>.",
            timeout: 15000,
        },
    },
    {
        action: "notify:message",
        payload: {
            type: "warn",
            message:
                "O servidor será reiniciado em <strong>30 segundos</strong>.",
            timeout: 15000,
        },
    },
    {
        action: "notify:message",
        payload: {
            type: "info",
            message:
                "O servidor será reiniciado em <strong>30 segundos</strong>.",
            timeout: 15000,
        },
    },
]);
