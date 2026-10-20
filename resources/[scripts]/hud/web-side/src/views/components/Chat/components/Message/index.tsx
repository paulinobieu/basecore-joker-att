import { cn } from "@app/utils";
import { sanitizeContent } from "@app/utils/sanitizeHtml";
import type { ClassValue } from "clsx";
import type { CSSProperties } from "react";

export interface MessageProps {
    context: string;
    author?: string;
    typeIcon?: { src: string; className?: ClassValue; style?: CSSProperties };
    content?: string;
    inlineMessage?: boolean;
    header?: {
        title: string;
        subtitle?: string;
        icon: { src: string; className?: ClassValue };
        textDirection: "row" | "column";
        className?: ClassValue;
    };
    footer?: {
        title: string;
        subtitle?: string;
        icon: { src: string; className?: ClassValue };
        textDirection: "row" | "column";
        className?: ClassValue;
    };
    typeStyles?: CSSProperties;
    containerStyles?: CSSProperties;
}

function extractVisualStyles(styles?: CSSProperties): CSSProperties {
    if (!styles) return {};
    const {
        background,
        backgroundBlendMode,
        border,
        borderColor,
        borderRadius,
        boxShadow,
        opacity,
        outline,
        outlineColor,
        outlineOffset,
    } = styles;
    return Object.fromEntries(
        Object.entries({
            background,
            backgroundBlendMode,
            border,
            borderColor,
            borderRadius,
            boxShadow,
            opacity,
            outline,
            outlineColor,
            outlineOffset,
        }).filter(([, v]) => v !== undefined),
    );
}

const baseStyle: CSSProperties = {
    background: "rgba(30, 27, 22, 0.82)",
    border: ".0625rem solid rgba(255,255,255,0.08)",
};

export function Message({
    author,
    typeIcon,
    content,
    header,
    footer,
    typeStyles,
    containerStyles,
    context,
    inlineMessage,
}: MessageProps) {
    const isInline = !header && !footer && !typeIcon && author && content;

    if (inlineMessage) {
        return (
            <li
                style={{ ...baseStyle, ...containerStyles }}
                className="flex w-full items-center rounded-md px-2.5 py-1.5"
            >
                {typeIcon && (
                    <i
                        className={cn(
                            "fa-fw",
                            typeIcon.src,
                            typeIcon.className,
                        )}
                        style={typeIcon.style}
                    />
                )}
                <span className="font-semibold text-white text-xs">
                    {author}:&nbsp;
                </span>
                <span className="text-white/60 text-xs">{content}</span>
            </li>
        );
    }

    if (isInline) {
        return (
            <li
                className="flex w-full shrink-0 items-center gap-2 rounded-lg px-[.6875rem] py-2"
                style={containerStyles ?? baseStyle}
            >
                <span className="shrink-0 whitespace-nowrap font-bold text-[.6875rem] text-white/75 after:content-[':']">
                    {author}
                </span>
                <p
                    className="break-words text-[.6875rem] text-white/55"
                    // biome-ignore lint/security/noDangerouslySetInnerHtml: sanitized
                    dangerouslySetInnerHTML={{
                        __html: sanitizeContent(content!),
                    }}
                />
            </li>
        );
    }

    if (header) {
        return (
            <li
                className="flex h-auto w-full shrink-0 flex-col overflow-hidden rounded-lg"
                style={{
                    ...baseStyle,
                    ...extractVisualStyles(containerStyles),
                }}
            >
                <div
                    className={cn(
                        "flex w-full shrink-0 items-center gap-2 px-3 py-[.5625rem]",
                        header.textDirection === "row"
                            ? "justify-between"
                            : "flex-col items-start",
                        header.className,
                    )}
                    style={typeStyles}
                >
                    <div className="flex items-center gap-2">
                        <i
                            className={cn(
                                header.icon.src,
                                header.icon.className,
                            )}
                        />
                        <span className="font-extrabold text-[.6875rem] text-white uppercase tracking-wide">
                            {header.title}
                        </span>
                    </div>
                    {header.subtitle && (
                        <span className="shrink-0 text-[.6875rem] text-white/85">
                            {header.subtitle}
                        </span>
                    )}
                </div>

                {footer && (
                    <div
                        className={cn(
                            "flex w-full shrink-0 items-start gap-2.5 px-3 py-[.625rem]",
                            footer.className,
                        )}
                    >
                        <div className="flex size-[2.125rem] shrink-0 items-center justify-center rounded-md bg-white/[.08]">
                            <i
                                className={cn(
                                    footer.icon.src,
                                    footer.icon.className,
                                )}
                            />
                        </div>
                        <div
                            className={cn(
                                "flex gap-1",
                                footer.textDirection === "column"
                                    ? "flex-col gap-[.1875rem]"
                                    : "flex-row items-center",
                            )}
                        >
                            <span className="font-extrabold text-[.6875rem] text-white uppercase tracking-wide">
                                {footer.title}
                            </span>
                            {footer.subtitle && (
                                <span className="text-[.6875rem] text-white/55 leading-[1.4]">
                                    {footer.subtitle}
                                </span>
                            )}
                        </div>
                    </div>
                )}
            </li>
        );
    }

    return (
        <li
            className="flex w-full shrink-0 flex-col gap-1 rounded-lg px-[.6875rem] py-[.5625rem]"
            style={containerStyles ?? baseStyle}
        >
            {(typeIcon || author) && (
                <div className="flex items-center gap-2">
                    {typeIcon && (
                        <i className={cn(typeIcon.src, typeIcon.className)} style={typeIcon.style} />
                    )}
                    {author && (
                        <span className="font-bold text-[.6875rem] text-white">
                            {author}
                        </span>
                    )}
                </div>
            )}

            {content && (
                <p
                    className="text-[.6875rem] text-white/60 leading-[1.45]"
                    style={{
                        overflowWrap: "break-word",
                        wordBreak: "break-word",
                    }}
                    // biome-ignore lint/security/noDangerouslySetInnerHtml: sanitized
                    dangerouslySetInnerHTML={{
                        __html: sanitizeContent(content),
                    }}
                />
            )}
        </li>
    );
}
