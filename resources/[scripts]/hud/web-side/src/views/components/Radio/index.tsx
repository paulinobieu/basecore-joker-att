import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { debugData } from "@app/utils/debugData";
import { useRef, useState } from "react";
import { Player } from "./components/Player";

export interface IPlayer {
    id: number;
    name: string;
}

const LEAVE_DURATION = 350;

export function Radio() {
    const [users, setUsers] = useState<IPlayer[]>([]);
    const [leavingIds, setLeavingIds] = useState<Set<number>>(new Set());

    const usersRef = useRef<IPlayer[]>(users);
    usersRef.current = users;

    useNuiMessage<IPlayer[]>("radio:users", (data) => {
        const next = data ?? [];
        const prev = usersRef.current;

        const gone = prev
            .map((u) => u.id)
            .filter((id) => !next.find((u) => u.id === id));

        if (gone.length > 0) {
            setLeavingIds((s) => new Set([...s, ...gone]));

            setTimeout(() => {
                setLeavingIds((s) => {
                    const next = new Set(s);
                    // biome-ignore lint/complexity/noForEach: <explanation>
                    gone.forEach((id) => next.delete(id));
                    return next;
                });
                setUsers(next);
            }, LEAVE_DURATION);
        } else {
            setUsers(next);
        }
    });

    const visible = [
        ...users,
        ...usersRef.current.filter(
            (u) => leavingIds.has(u.id) && !users.find((x) => x.id === u.id),
        ),
    ];

    return (
        <div className="flex flex-col gap-3">
            {visible.map((user) => (
                <Player
                    key={user.id}
                    {...user}
                    isLeaving={leavingIds.has(user.id)}
                />
            ))}
        </div>
    );
}

debugData<IPlayer[]>([
    {
        action: "radio:users",
        payload: [{ id: 214, name: "Facca Dev" }],
    },
]);
