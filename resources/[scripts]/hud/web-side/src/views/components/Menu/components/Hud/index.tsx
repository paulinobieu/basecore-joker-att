import { useMenu } from "@app/stores/Menu";
import { MenuBellIcon } from "@views/assets/icons/MenuBell";
import { MenuChatIcon } from "@views/assets/icons/MenuChat";
import { MenuHideIcon } from "@views/assets/icons/MenuHide";
import { MenuRadarIcon } from "@views/assets/icons/MenuRadar";
import DigitalVelocimeter from "@views/assets/images/digital-velocimeter.webp";
import RoundedVelocimeter from "@views/assets/images/rounded-velocimeter.webp";
import { useShallow } from "zustand/shallow";
import { Option } from "../Option";
import { Select } from "../Select";

export function Hud() {
    const {
        chat,
        hide,
        notify,
        radar,
        survivalSettings,
        velocimeter,
        setVelocimeter,
    } = useMenu(
        useShallow((state) => ({
            notify: state.notify,
            radar: state.radar,
            chat: state.chat,
            hide: state.hide,
            velocimeter: state.velocimeter,
            survivalSettings: state.survivalSettings,
            setVelocimeter: state.setVelocimeter,
        })),
    );

    return (
        <div className="flex w-full flex-col gap-1">
            <Option
                active={notify}
                icon={<MenuBellIcon />}
                keyOption="notify"
                title="Notificações"
                tooltip="Mostra/esconde todas as notificações"
            />
            <Option
                active={radar}
                icon={<MenuRadarIcon />}
                keyOption="radar"
                title="Radar"
                tooltip="Mostra/esconde o radar"
            />
            <Option
                active={chat}
                icon={<MenuChatIcon />}
                keyOption="chat"
                title="Chat"
                tooltip="Mostra/esconde o chat"
            />
            <Option
                active={hide}
                icon={<MenuHideIcon />}
                keyOption="hide"
                title="Desativar"
                tooltip="Desativa toda a hud"
            />

            <Select
                selected={velocimeter === "rounded"}
                image={{
                    src: RoundedVelocimeter,
                    className:
                        "absolute right-[5rem] size-[8.5rem] object-contain",
                }}
                onClick={() => setVelocimeter("rounded")}
                title="Circular"
            />
            <Select
                selected={velocimeter === "digital"}
                image={{
                    src: DigitalVelocimeter,
                    className:
                        "absolute right-[1.9375rem] w-[15.5625rem] h-[4.8125rem] object-contain",
                }}
                onClick={() => setVelocimeter("digital")}
                title="Digital"
            />
        </div>
    );
}
