import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { useSound } from "@app/hooks/useSound";
import { useCallback, useEffect, useState } from "react";
import { v4 } from "uuid";
import { Announce } from "./components/Announce";

import { debugData } from "@app/utils/debugData";
import AnnounceSound from "@views/assets/sounds/announce.mp3";

export interface IAnnounce {
    image: { src: string; dimensions?: { width: string; height: string } };
    header: { text: string; icon: string };
    text: string;
    id: string;
    timeout: number;
    color: string;
    footer?: { pressKey: string; action: string };
}

export function NotifyAnnounce() {
    const [announces, setAnnounces] = useState<IAnnounce[]>([]);

    const { play } = useSound(AnnounceSound, { volume: 0.15 });
    const handleAddAnnounce = useCallback((data: IAnnounce) => {
        const id = v4();
        play();
        setAnnounces((prevState) => prevState.concat({ ...data, id }));

        setTimeout(() => {
            setAnnounces((prevState) =>
                prevState.filter((data) => data.id !== id),
            );
        }, data.timeout || 5000);
    }, []);

    useNuiMessage("set:announces:add", handleAddAnnounce);

    useEffect(() => {
        const timers: { [key: string]: NodeJS.Timeout } = {};

        // biome-ignore lint/complexity/noForEach: <explanation>
        announces.forEach((notify) => {
            if (!timers[notify.id]) {
                timers[notify.id] = setTimeout(() => {
                    setAnnounces((prev) =>
                        prev.filter((n) => n.id !== notify.id),
                    );
                    delete timers[notify.id];
                }, notify.timeout);
            }
        });

        return () => {
            Object.values(timers).forEach(clearTimeout);
        };
    }, [announces]);

    return (
        <div className="absolute top-[21.375rem] left-[1.625rem] flex flex-col items-start gap-3.5">
            {announces?.length > 0 &&
                announces.map((data) => <Announce key={data.id} {...data} />)}
        </div>
    );
}

debugData<IAnnounce>([
    {
        action: "set:announces:add",
        payload: {
            color: "#00FFEA",
            header: { icon: "fa-solid fa-bell-ring", text: "North Hospital" },
            id: Math.random().toString(),
            image: {
                dimensions: { height: "2.625rem", width: "2.8125rem" },
                src: "https://media.discordapp.net/attachments/1438780604115320965/1495646161011347476/c9d1e5160606549.Y3JvcCw4MzEsNjUwLDEyNSww_1.png?ex=69e70088&is=69e5af08&hm=962b67d22b9114ae33c704e1f940c1a286772b701ba3535cd1bbd82cd41dfdc0&=&format=webp&quality=lossless&width=50&height=46",
            },
            text: "O hospital chegou até aqui para cuidar de você! Procure atendimento",
            timeout: 7500,
        },
    },
    {
        action: "set:announces:add",
        payload: {
            color: "#0059FF",
            header: {
                icon: "fa-notdog fa-solid fa-shield",
                text: "Police Departament",
            },
            id: Math.random().toString(),
            image: {
                src: "https://media.discordapp.net/attachments/1438780604115320965/1495646159719632967/image_77.png?ex=69e70088&is=69e5af08&hm=6a74fdfa9bf1c065aa21caea2d3be47c53990bea97639fdcdf9d1a66718874b7&=&format=webp&quality=lossless&width=39&height=39",
            },
            text: "O hospital chegou até aqui para cuidar de você! Procure atendimento",
            timeout: 7500,
        },
    },
    {
        action: "set:announces:add",
        payload: {
            color: "#0059FF",
            header: {
                icon: "fa-notdog fa-solid fa-shield",
                text: "Police Departament",
            },
            id: Math.random().toString(),
            image: {
                src: "https://media.discordapp.net/attachments/1438780604115320965/1495646159719632967/image_77.png?ex=69e70088&is=69e5af08&hm=6a74fdfa9bf1c065aa21caea2d3be47c53990bea97639fdcdf9d1a66718874b7&=&format=webp&quality=lossless&width=39&height=39",
            },
            text: "O hospital chegou até aqui para cuidar de você! Procure atendimento",
            timeout: 7500,
            footer: {
                action: "Ir para a festa",
                pressKey: "F3",
            },
        },
    },
]);
