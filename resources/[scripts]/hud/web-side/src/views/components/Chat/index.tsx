import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { useChatStore } from "@app/stores/Chat";
import { useMenu } from "@app/stores/Menu";
import { cn } from "@app/utils";
import { debugData } from "@app/utils/debugData";
import type { ClassValue } from "clsx";
import { type CSSProperties, useEffect, useRef } from "react";
import { Message } from "./components/Message";

export interface MessageProps {
    context: string;
    author?: string;
    typeIcon?: { src: string; className?: ClassValue };
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

export function Chat() {
    const {
        text,
        messages,
        selectedCategory,
        categories,
        getCategories,
        isChatVisible,
        chatTimeout,
        isInputVisible,
        hideChat,
        setText,
        addMessage,
        setSelectedCategory,
        handleSendMessage,
        handleInputFocus,
        handleEscape,
        navigateHistory,
        setChatTimeout,
        setIsChatVisible,
    } = useChatStore((state) => state);
    const showChatMenu = useMenu((state) => state.chat);

    const messagesRef = useRef<HTMLUListElement>(null);

    useNuiMessage<MessageProps>("chat:message", addMessage);
    useNuiMessage<{ open: boolean; categories: string[] } | boolean>("chat:inputfocus", handleInputFocus);

    // biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
    useEffect(() => {
        const keyHandler = (event: KeyboardEvent): void => {
            const keyHandlers: Record<string, () => void> = {
                Escape: handleEscape,
                Enter: handleSendMessage,
                ArrowUp: () => navigateHistory("up"),
                ArrowDown: () => navigateHistory("down"),
            };

            keyHandlers[event.code]?.();
        };

        window.addEventListener("keydown", keyHandler);
        return () => {
            window.removeEventListener("keydown", keyHandler);
        };
    }, [isInputVisible, isChatVisible, text]);

    // biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
    useEffect(() => {
        if (chatTimeout <= 0) {
            if (isInputVisible) return;
            return setIsChatVisible(false);
        }

        const interval = setInterval(() => {
            setChatTimeout(chatTimeout - 1);
        }, 1000);

        return () => clearInterval(interval);
    }, [useChatStore.getState().chatTimeout]);

    // biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
    useEffect(() => {
        function scrollToBottom() {
            if (messagesRef.current) {
                messagesRef.current.scrollTop =
                    messagesRef.current.scrollHeight;
            }
        }

        scrollToBottom();
    }, [messages, selectedCategory]);

    if (hideChat || !showChatMenu) return null;

    return (
        <div
            className={cn(
                "absolute top-[2.125rem] left-[2.125rem] flex w-[25.625rem] flex-col gap-3.5",
                isChatVisible
                    ? "animate-[showChat_0.4s_ease_forwards]"
                    : "animate-[hideChat_0.4s_ease_forwards]",
            )}
        >
            <ul
                ref={messagesRef}
                className="hideScroll flex h-[11.25rem] w-full flex-col items-start gap-3 overflow-y-auto rounded-[.4375rem]"
            >
                {messages
                    .filter((message) => message.context === selectedCategory)
                    .map((message, _) => (
                        <Message
                            key={`${message.content}-${message.context}-${message.author}`}
                            {...message}
                        />
                    ))}
            </ul>

            <div
                className={`relative flex h-8 items-center rounded-md border border-white/[.04] border-solid bg-[#151515]/70 p-1 ${isInputVisible ? "opacity-100" : "opacity-0"}`}
                style={{
                    background:
                        "linear-gradient(270deg, rgba(10, 10, 10, 0.28) 0%, rgba(10, 10, 10, 0.4) 100%),linear-gradient(0deg, rgba(86, 86, 86, 0.2), rgba(86, 86, 86, 0.2))",
                }}
            >
                <div className="flex h-full w-fit items-center justify-center rounded-[.25rem] bg-white/[.08] px-2 font-medium text-xs uppercase">
                    Chat
                </div>
                <div className="mx-2 h-3 w-[.0625rem] bg-white/15" />
                <input
                    id="chat-input"
                    type="text"
                    placeholder="Escreva sua mensagem aqui..."
                    value={text}
                    onChange={(event) => setText(event.target.value)}
                    className="h-full w-[calc(100%-1.1875rem)] bg-transparent font-normal text-xs placeholder:text-white/40 focus:outline-none"
                />

                <button
                    type="button"
                    disabled={text === ""}
                    onClick={handleSendMessage}
                    className="flex size-5 min-w-5 items-center justify-center rounded-[.25rem] bg-primaryColor"
                >
                    <svg
                        width=".625rem"
                        height=".625rem"
                        viewBox="0 0 10 10"
                        fill="none"
                        xmlns="http://www.w3.org/2000/svg"
                    >
                        <path
                            d="M0.316375 3.90246L4.3371 5.66116L6.09485 9.68407C6.17906 9.87889 6.36852 10 6.57902 10H6.60534C6.71177 9.99454 6.81404 9.95689 6.89861 9.89201C6.98319 9.82714 7.04609 9.7381 7.07898 9.63667L9.97349 0.685194C10.0366 0.495633 9.98401 0.290275 9.84718 0.15337C9.7793 0.0846189 9.69348 0.0363219 9.59951 0.0139795C9.50554 -0.00836291 9.40718 -0.00385268 9.31565 0.0269966L0.363739 2.9178C0.15323 2.98625 0.0111363 3.17581 0.00061088 3.3917C-0.00991458 3.61285 0.116391 3.81295 0.316375 3.90246ZM8.6578 1.34339L6.50535 7.99382L5.22124 5.05036C5.16861 4.92925 5.07388 4.83447 4.94758 4.77655L2.00571 3.49175L8.65254 1.33813L8.6578 1.34339Z"
                            fill="white"
                        />
                    </svg>
                </button>
            </div>

            <ul
                className={`flex w-full flex-wrap content-start items-center gap-2 ${isInputVisible ? "opacity-100" : "opacity-0"}
        `}
            >
                {categories?.length > 0 &&
                    categories.map((data) => (
                        <button
                            key={data}
                            type="button"
                            className={cn(
                                "flex h-5 items-center justify-center rounded-[.25rem] border border-transparent border-solid p-1.5 px-2 font-medium text-white text-xs transition-all duration-300 hover:cursor-pointer",
                                selectedCategory === data
                                    ? "bg-primaryColor"
                                    : "border-transparent bg-[#151515]/50 text-[#adadad]",
                            )}
                            onClick={() => setSelectedCategory(data)}
                        >
                            {data}
                        </button>
                    ))}
            </ul>
        </div>
    );
}

debugData<MessageProps>([
    {
        action: "chat:message",
        payload: {
            context: "global",
            typeIcon: {
                src: "fa-solid fa-crown",
                className: "text-xs text-[#FFA237] mr-2.5",
            },
            author: "Bieu Romanov #46",
            content:
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum",
            containerStyles: {
                backgroundBlendMode: "screen",
                border: ".025rem solid #FFFFFF0A",
                background:
                    "linear-gradient(0deg, rgba(21, 21, 21, 0.7), rgba(21, 21, 21, 0.7)),linear-gradient(90.59deg, rgba(255, 162, 55, 0.2) -7.28%, rgba(255, 162, 55, 0) 51.21%)",
            },
        },
    },
    {
        action: "chat:message",
        payload: {
            context: "global",
            typeIcon: {
                src: "fa-regular fa-globe",
                className: "text-xs text-[#FFFFFF59] mr-2.5",
            },
            inlineMessage: true,
            author: "Bieu Romanov #46",
            content: "Olá tudo bem, somos muito gratos por isso.",
        },
    },
    {
        action: "chat:message",
        payload: {
            context: "global",
            containerStyles: {
                padding: ".125rem",
                border: ".025rem solid #FFFFFF0A",
                backgroundBlendMode: "screen",
                background:
                    "linear-gradient(0deg, rgba(21, 21, 21, 0.7), rgba(21, 21, 21, 0.7)),linear-gradient(92deg, rgba(var(--primaryColor), 0.18) -0.38%, rgba(var(--primaryColor), 0) 29.58%)",
            },
            header: {
                icon: {
                    src: "fa-solid fa-basket-shopping-minus",
                    className: "text-xs text-white",
                },
                title: "Vip com desconto",
                subtitle: "Acesse nosso site para ver os planos",
                textDirection: "row",
                className:
                    "bg-primaryColor min-h-[1.125rem] px-1.5 text-[.5625rem]",
            },
            footer: {
                className:
                    "mt-3.5 min-h-[3rem] w-full flex items-center gap-3.5",
                icon: {
                    src: "fa-utility fa-semibold fa-bag-shopping",
                    className: "text-sm text-primaryColor",
                },
                title: "PROMOÇÃO",
                subtitle:
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem",
                textDirection: "column",
            },
        },
    },
    {
        action: "chat:message",
        payload: {
            context: "global",
            typeIcon: {
                src: "fa-solid fa-crown",
                className: "text-xs text-[#FFA237] mr-2.5",
            },
            author: "Bieu Romanov #46",
            content:
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum",
            containerStyles: {
                backgroundBlendMode: "screen",
                border: ".025rem solid #FFFFFF0A",
                background:
                    "linear-gradient(0deg, rgba(21, 21, 21, 0.7), rgba(21, 21, 21, 0.7)),linear-gradient(90.59deg, rgba(255, 162, 55, 0.2) -7.28%, rgba(255, 162, 55, 0) 51.21%)",
            },
        },
    },
    {
        action: "chat:message",
        payload: {
            context: "global",
            containerStyles: {
                padding: ".125rem",
                border: ".025rem solid #FFFFFF0A",
                backgroundBlendMode: "screen",
                background:
                    "linear-gradient(0deg, rgba(21, 21, 21, 0.7), rgba(21, 21, 21, 0.7)),linear-gradient(92deg, rgba(var(--primaryColor), 0.18) -0.38%, rgba(var(--primaryColor), 0) 29.58%)",
                minHeight: "4.0625rem",
            },
            header: {
                icon: {
                    src: "fa-solid fa-basket-shopping-minus",
                    className: "text-xs text-white",
                },
                title: "Vip com desconto",
                subtitle: "Acesse nosso site para ver os planos",
                textDirection: "row",
                className:
                    "bg-primaryColor h-[1.125rem] px-1.5 text-[.5625rem]",
            },
            footer: {
                className: "mt-3.5 w-full flex items-center gap-3.5",
                icon: {
                    src: "fa-utility fa-semibold fa-bag-shopping",
                    className: "text-sm text-primaryColor",
                },
                title: "PROMOÇÃO",
                subtitle:
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem",
                textDirection: "column",
            },
        },
    },
    {
        action: "chat:message",
        payload: {
            context: "global",
            containerStyles: {
                padding: ".125rem",
                border: ".025rem solid #FFFFFF0A",
                backgroundBlendMode: "screen",
                background:
                    "linear-gradient(0deg, rgba(21, 21, 21, 0.7), rgba(21, 21, 21, 0.7)),linear-gradient(92deg, rgba(var(--primaryColor), 0.18) -0.38%, rgba(var(--primaryColor), 0) 29.58%)",
            },
            header: {
                icon: {
                    src: "fa-solid fa-basket-shopping-minus",
                    className: "text-xs text-white",
                },
                title: "Vip com desconto",
                subtitle: "Acesse nosso site para ver os planos",
                textDirection: "row",
                className:
                    "bg-primaryColor h-[1.125rem] px-1.5 text-[.5625rem]",
            },
            footer: {
                className: "mt-3.5 w-full flex items-center gap-3.5",
                icon: {
                    src: "fa-utility fa-semibold fa-bag-shopping",
                    className: "text-sm text-primaryColor",
                },
                title: "PROMOÇÃO",
                subtitle:
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem",
                textDirection: "column",
            },
        },
    },
]);
