import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { useMinimapDimensions } from "@app/stores/MinimapDimensions";
import { debugData } from "@app/utils/debugData";
import { useEffect, useRef, useState } from "react";
import { v4 as uuidv4 } from "uuid";
import { Notify } from "./components/Notify";

export interface NotifyProps {
    id: string;
    action: "add" | "remove";
    image: string;
    amount: number;
    name: string;
}

const LEAVE_DURATION = 350;

export default function NotifyItem() {
    const [notifys, setNotifys] = useState<NotifyProps[]>([]);
    const [leavingIds, setLeavingIds] = useState<Set<string>>(new Set());
    const timersRef = useRef<{ [key: string]: ReturnType<typeof setTimeout> }>({});
    const { left, width } = useMinimapDimensions((state) => state);

    useNuiMessage<NotifyProps>("notify:item", (data) => {
        if (notifys.length >= 5) return;

        const id = uuidv4();
        setNotifys((prev) => [...prev, { ...data, id }]);
    });

    useEffect(() => {
        notifys.forEach((notify) => {
            if (!timersRef.current[notify.id]) {
                timersRef.current[notify.id] = setTimeout(() => {
                    setLeavingIds((s) => new Set([...s, notify.id]));
                    setTimeout(() => {
                        setNotifys((prev) => prev.filter((n) => n.id !== notify.id));
                        setLeavingIds((s) => {
                            const next = new Set(s);
                            next.delete(notify.id);
                            return next;
                        });
                        delete timersRef.current[notify.id];
                    }, LEAVE_DURATION);
                }, 4000);
            }
        });
    }, [notifys]);

    useEffect(() => {
        const ref = timersRef.current;
        return () => {
            Object.values(ref).forEach(clearTimeout);
        };
    }, []);

    return (
        <ul
            className="absolute bottom-[2.125rem] flex flex-col items-start gap-[1.8125rem]"
            style={{ left: `${left + width + 16}px` }}
        >
            {notifys.map((notify) => (
                <Notify key={notify.id} {...notify} isLeaving={leavingIds.has(notify.id)} />
            ))}
        </ul>
    );
}
debugData([
    {
        action: "notify:item",
        payload: {
            action: "remove",
            imaeg: "",
            amount: 821,
            name: "Celular",
        },
    },
    {
        action: "notify:item",
        payload: {
            action: "add",
            imaeg: "",
            amount: 821,
            name: "Celular",
        },
    },
]);
