import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { debugData } from "@app/utils/debugData";
import { useCallback, useState } from "react";
import { Bubble } from "./components/Bubble";

export interface IMe {
    id: number;
    author: string;
    message: string;
    x: number;
    y: number;
    postit?: boolean;
}

export type IMeUpdate = Pick<IMe, "id" | "message" | "x" | "y">;

export function Me() {
    const [items, setItems] = useState<IMe[]>([]);

    const handleShow = useCallback((data: IMe) => {
        setItems((prev) => {
            if (prev.some((item) => item.id === data.id)) return prev;
            return [...prev, data];
        });
    }, []);

    const handleUpdate = useCallback((data: IMeUpdate) => {
        setItems((prev) =>
            prev.map((item) =>
                item.id === data.id
                    ? { ...item, message: data.message, x: data.x, y: data.y }
                    : item,
            ),
        );
    }, []);

    const handleRemove = useCallback((id: number) => {
        setItems((prev) => prev.filter((item) => item.id !== id));
    }, []);

    useNuiMessage<IMe>("chat:me:show", handleShow);
    useNuiMessage<IMeUpdate>("chat:me:update", handleUpdate);
    useNuiMessage<number>("chat:me:remove", handleRemove);

    if (items.length === 0) return null;

    return (
        <div className="pointer-events-none absolute inset-0 z-0 overflow-hidden">
            {items.map((item) => (
                <Bubble key={item.id} {...item} />
            ))}
        </div>
    );
}

debugData<IMe>([
    {
        action: "chat:me:show",
        payload: {
            id: 1,
            author: "Bieu Romanov",
            message: "está acendendo um cigarro com calma",
            x: 0.5,
            y: 0.5,
        },
    },
    {
        action: "chat:me:show",
        payload: {
            id: 2,
            author: "Postit",
            message: "Encontre o pacote no porta-malas",
            x: 0.3,
            y: 0.4,
            postit: true,
        },
    },
]);
