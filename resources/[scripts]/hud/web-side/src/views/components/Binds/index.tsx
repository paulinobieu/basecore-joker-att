import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { cn } from "@app/utils";
import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { useEffect, useState } from "react";
import { Bind } from "./components/Bind";

export interface ItemProps {
    slot_id: number;
    image: string;
    name: string;
    amount: number;
}

export function Binds() {
    const [visible, setVisible] = useState(isEnvBrowser());
    const [items, setItems] = useState<ItemProps[]>([]);

    useNuiMessage<boolean>("inventory:binds", (data) => setVisible(data));

    useEffect(() => {
        if (!visible) return;

        async function fetchBinds() {
            const response = await fetchNui<ItemProps[]>({
                path: "fetch:binds",
                mockData: [
                    {
                        slot_id: 1,
                        image: "https://media.discordapp.net/attachments/1438780604115320965/1495920350263906515/8076404e44fbd4e7604c917e8c1dc61050084baa.png?ex=69e7ffe4&is=69e6ae64&hm=48e0fd62491556cbd8eda0f1aaef63c2fb472c8a28e5b9c011c2dd34d67c285f&=&format=webp&quality=lossless&width=110&height=110",
                        name: "Celular",
                        amount: 1,
                    },
                    {
                        slot_id: 2,
                        image: "celular",
                        name: "Celular",
                        amount: 1,
                    },
                    {
                        slot_id: 3,
                        image: "celular",
                        name: "Celular",
                        amount: 1,
                    },
                    {
                        slot_id: 4,
                        image: "celular",
                        name: "Celular",
                        amount: 1,
                    },
                    {
                        slot_id: 5,
                        image: "celular",
                        name: "Celular",
                        amount: 1,
                    },
                ],
            });

            setItems(response);
        }

        fetchBinds();
    }, [visible]);

    return (
        <div
            className={cn(
                "-translate-x-1/2 absolute bottom-[8.75rem] left-1/2 flex items-center gap-2 transition-all duration-500",
                visible ? "scale-100 opacity-100" : "scale-0 opacity-0",
            )}
        >
            {items?.length > 0 &&
                items.map((data) => <Bind key={data.slot_id} {...data} />)}
        </div>
    );
}
