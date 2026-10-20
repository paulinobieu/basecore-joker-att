import { toRgba } from "@app/utils/colors";
import { sanitizeContent } from "@app/utils/sanitizeHtml";
import { AboutIcon } from "@views/assets/icons/About";
import { ErrorIcon } from "@views/assets/icons/Error";
import { SuccessIcon } from "@views/assets/icons/Success";
import { WarnIcon } from "@views/assets/icons/Warn";
import type { CSSProperties } from "react";
import { useEffect, useState  } from "react";
import type { NotifyProps } from "../..";
import { IconBackground } from "./components/IconBackground";

const variants = {
    success: {
        title: "Sucesso",
        color: "#9AFF35",
        icon: <SuccessIcon />,
    },
    error: {
        title: "Erro",
        color: "#DF394F",
        icon: <ErrorIcon />,
    },
    warn: {
        title: "Aviso",
        color: "#FFA237",
        icon: <WarnIcon />,
    },
    info: {
        title: "Informação",
        color: "#0143BB",
        icon: <AboutIcon />,
    },
};

export function Notify({ id, title, message, timeout, type }: NotifyProps) {
    const style = variants[type];
    const [isLeaving, setIsLeaving] = useState(false);

    useEffect(() => {
        const leaveTimeout = setTimeout(() => {
            setIsLeaving(true);
        }, timeout - 350);

        return () => {
            clearTimeout(leaveTimeout);
        };
    }, [timeout]);

    return (
        <li
            className={
                "flew relative w-[16.625rem] items-center justify-center rounded-lg p-[.1875rem]"
            }
            style={{
                animation: isLeaving
                    ? "hideNotify 0.35s cubic-bezier(0.175,0.885,0.32,1.275) forwards"
                    : "showNotify 0.35s cubic-bezier(0.175,0.885,0.32,1.275) forwards",
            }}
        >
            <div
                className="gradientBorder absolute inset-0 rounded-lg bg-blend-screen"
                style={{
                    background: `linear-gradient(0deg, ${toRgba(style.color, 0.4)}, ${toRgba(style.color, 0.4)}),linear-gradient(90deg, ${style.color} 0%, ${toRgba(style.color, 0.0)} 35.08%)`,
                }}
            />
            <div
                className="amd-shell flex size-full items-center gap-2.5 rounded-md px-2.5 py-3.5 outline-1 outline-solid outline-white/[.04]"
                style={{
                    "--amd-bg": `linear-gradient(0deg, rgba(21, 21, 21, 0.7), rgba(21, 21, 21, 0.7)),linear-gradient(67.84deg, ${toRgba(style.color, 0.3)} -39.69%, ${toRgba(style.color, 0.0)} 41.87%),linear-gradient(259.54deg, ${toRgba(style.color, 0.3)} -87.14%, ${toRgba(style.color, 0.0)} 26.94%)`,
                    "--amd-blend": "screen",
                } as CSSProperties}
            >
                <div className="relative flex size-[2.875rem] items-center justify-center">
                    <IconBackground color={style.color} timeout={timeout} />
                    <div className="absolute z-10">{style.icon}</div>
                </div>
                <div className="flex flex-col">
                    <h1 className="text-sm">{title || style.title}</h1>
                    <span
                        className="text-[.625rem] text-white/70"
                        // biome-ignore lint/security/noDangerouslySetInnerHtml: <explanation>
                        dangerouslySetInnerHTML={{
                            __html: sanitizeContent(message),
                        }}
                    />
                </div>
            </div>
        </li>
    );
}
