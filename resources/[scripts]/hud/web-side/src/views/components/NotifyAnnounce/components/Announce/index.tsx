import { useImageValidation } from "@app/hooks/useImageValidation";
import { cn } from "@app/utils";
import { toRgba } from "@app/utils/colors";
import { sanitizeContent } from "@app/utils/sanitizeHtml";
import type { CSSProperties } from "react";
import { useEffect, useState  } from "react";
import type { IAnnounce } from "../..";
import { Lonzege } from "./components/Lonzege";

export function Announce({
    id,
    image,
    text,
    timeout,
    footer,
    color,
    header,
}: IAnnounce) {
    const [isLeaving, setIsLeaving] = useState(false);

    const { imageUrl, isImageValid } = useImageValidation(image.src);

    useEffect(() => {
        const leaveTimeout = setTimeout(() => {
            setIsLeaving(true);
        }, timeout - 350);

        return () => {
            clearTimeout(leaveTimeout);
        };
    }, [timeout]);

    return (
        <div
            style={{
                zoom: 1.25,
            }}
            className={cn(
                "relative flex w-[13.9375rem] animate-fadeInAnnounce animate-fadeInAnnounce items-center justify-center rounded-lg p-[.1875rem] transition-all duration-[350ms]",
                { "-translate-x-full scale-[.8] opacity-0": isLeaving },
            )}
        >
            <div
                className="amd-shell flex size-full items-center gap-[.8125rem] rounded-md border border-white/[.04] border-solid pt-3 pr-[1.3125rem] pb-2.5 pl-[.8125rem]"
                style={{
                    "--amd-bg": `linear-gradient(0deg, rgba(21, 21, 21, 0.7), rgba(21, 21, 21, 0.7)),linear-gradient(67.84deg, ${toRgba(color, 0.3)} -39.69%, ${toRgba(color, 0.0)} 41.87%),linear-gradient(259.54deg, ${toRgba(color, 0.3)} -87.14%, ${toRgba(color, 0.0)} 26.94%)`,
                    "--amd-blend": "screen",
                } as CSSProperties}
            >
                <div
                    className="pointer-events-none absolute top-0 left-0 h-full w-[6.875rem] rounded-[.25rem]"
                    style={{
                        background: `linear-gradient(67.84deg, ${toRgba(color, 0.3)} -39.69%, ${toRgba(color, 0.0)} 41.87%)`,
                    }}
                />
                {isImageValid && (
                    <img
                        src={imageUrl}
                        alt=""
                        className="relative z-10 size-[2.25rem] object-contain"
                        style={image.dimensions ? image.dimensions : undefined}
                    />
                )}
                <div className="relative z-10 flex flex-col items-start gap-1">
                    <header className="flex items-center gap-2 font-medium text-[.625rem]">
                        <i
                            className={cn("text-[.625rem]", header.icon)}
                            style={{ color: color }}
                        />
                        {header.text}
                    </header>
                    <span
                        className="text-[.4375rem] text-white/60"
                        // biome-ignore lint/security/noDangerouslySetInnerHtml: <explanation>
                        dangerouslySetInnerHTML={{
                            __html: sanitizeContent(text),
                        }}
                    />
                    {footer && (
                        <footer className="flex items-center gap-1 font-light text-[.5625rem]">
                            <Lonzege pressKey={footer.pressKey} color={color} />
                            {footer.action}
                        </footer>
                    )}
                </div>
            </div>

            <div
                style={{
                    background: `linear-gradient(90deg, ${toRgba(color, 0.0)} 0%, ${toRgba(color, 0.4)} 51.92%, ${toRgba(color, 0.0)} 100%)`,
                }}
                className="gradientBorder absolute inset-0 rounded-lg bg-blend-screen"
            />
        </div>
    );
}
