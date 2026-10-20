import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { debugData } from "@app/utils/debugData";
import { fetchNui } from "@app/utils/fetchNui";
import { useEffect, useState } from "react";
import { v4 } from "uuid";
import { Notify } from "./components/Notify";

export interface NotifyProps {
    id: string;
    cds: string;
    code: string;
    title: string;
    author: string;
    location: string;
    timestamp: string;
}

const MAX_VISIBLE_NOTIFYS = 3;

export function NotifyPolice() {
    const [notifys, setNotifys] = useState<NotifyProps[]>([]);
    const [history, setHistory] = useState<NotifyProps[]>([]);
    const [historyOpen, setHistoryOpen] = useState(false);
    const [expireHistoryTimeout, setExpireHistoryTimeout] = useState(60000);

    const visible = useVisibilityStore((state) => state.visible);

    useNuiMessage<NotifyProps>("notify:police", (data) => {
        const id = v4();

        setNotifys((prev) => [...prev, { ...data, id }].slice(-MAX_VISIBLE_NOTIFYS));
        setHistory((prev) => [...prev, { ...data, id }]);
    });

    useNuiMessage("notify:police:historyVisibility", setHistoryOpen);

    useEffect(() => {
        if (!historyOpen) return;
        const onKey = (e: KeyboardEvent) => {
            if (e.key === "Escape") {
                fetchNui({ path: "post:police:closeHistory" });
            }
        };
        window.addEventListener("keydown", onKey);
        return () => window.removeEventListener("keydown", onKey);
    }, [historyOpen]);

    // biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
    useEffect(() => {
        const timers: { [key: string]: NodeJS.Timeout } = {};

        // biome-ignore lint/complexity/noForEach: <explanation>
        history.forEach((notify) => {
            if (!timers[`history-${notify.id}`]) {
                timers[`history-${notify.id}`] = setTimeout(() => {
                    setHistory((prev) =>
                        prev.filter((n) => n.id !== notify.id),
                    );
                    delete timers[notify.id];
                }, expireHistoryTimeout);
            }
        });
        // biome-ignore lint/complexity/noForEach: <explanation>
        notifys.forEach((notify) => {
            if (!timers[notify.id]) {
                timers[notify.id] = setTimeout(() => {
                    setNotifys((prev) =>
                        prev.filter((n) => n.id !== notify.id),
                    );
                    delete timers[notify.id];
                }, 5000);
            }
        });

        return () => {
            Object.values(timers).forEach(clearTimeout);
        };
    }, [notifys]);

    useEffect(() => {
        if (!visible) return;

        (async () => {
            const response = await fetchNui({
                path: "get:police:expireHistoryTimeout",
                mockData: 2 * 60 * 1000,
            });

            if (!response) return;

            setExpireHistoryTimeout(response);
        })();
    }, [visible]);

    return (
        <div
            className={cn(
                "hideScroll absolute bottom-[21rem] left-[2.125rem] flex h-[21.75rem] w-[21rem] flex-col gap-3 overflow-auto",
            )}
        >
            {notifys?.length > 0 &&
                notifys.map((data) => <Notify key={data.id} {...data} />)}
            {historyOpen &&
                history?.length > 0 &&
                history.map((data) => <Notify key={data.id} {...data} />)}
        </div>
    );
}

debugData<NotifyProps>([
    {
        action: "notify:police",
        payload: {
            author: "Suspeito de tráfico de drogas",
            cds: "123,456,789",
            code: "10-31",
            id: Math.random().toString(),
            location: "Rua Oswaldo Cruz 123 - Sul",
            timestamp: "13:45",
            title: "Homicidio em Andamento",
        },
    },
    {
        action: "notify:police",
        payload: {
            author: "Suspeito de tráfico de drogas",
            cds: "123,456,789",
            code: "10-31",
            id: Math.random().toString(),
            location: "Rua Oswaldo Cruz 123 - Sul",
            timestamp: "13:46",
            title: "Roubo",
        },
    },
]);
