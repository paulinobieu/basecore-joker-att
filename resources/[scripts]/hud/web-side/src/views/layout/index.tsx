import { useClickSound } from "@app/hooks/useClickSound";
import { useLayout } from "@app/hooks/useLayout";
import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { useMenu } from "@app/stores/Menu";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { Binds } from "@views/components/Binds";
import { Chat } from "@views/components/Chat";
import { ErrorBoundary } from "@views/components/ErrorBoundary";
import { Header } from "@views/components/Header";
import { Hoverfy } from "@views/components/Hoverfy";
import { Location } from "@views/components/Location";
import { Logo } from "@views/components/Logo";
import { Me } from "@views/components/Me";
import { Menu } from "@views/components/Menu";
import { NotifyAnnounce } from "@views/components/NotifyAnnounce";
import NotifyItem from "@views/components/NotifyItem";
import { NotifyMessage } from "@views/components/NotifyMessage";
import { NotifyPolice } from "@views/components/NotifyPolice";
import { NotifyRadar } from "@views/components/NotifyRadar";
import { Progressbar } from "@views/components/Progressbar";
import { Radio } from "@views/components/Radio";
import { Survival } from "@views/components/Survival";
import { Velocimeter } from "@views/components/Velocimeter";

export function Layout() {
    const visible = useVisibilityStore((state) => state.visible);
    const setVisible = useVisibilityStore((state) => state.setVisible);
    const hide = useMenu((state) => state.hide);

    useLayout();
    useClickSound();

    useNuiMessage<boolean>("set:hud:visible", setVisible);

    return (
        <>
            <div
                className={cn(
                    "fixed top-0 left-0 h-screen w-screen transition-all duration-500",
                    visible && !hide ? "opacity-100" : "opacity-0",
                )}
            >
                <ErrorBoundary>
                    <Binds />
                    <Chat />
                    <Me />
                    <Logo />
                    <Hoverfy />
                    <Header />
                    <Progressbar />
                    <NotifyItem />
                    <NotifyAnnounce />
                    <NotifyRadar />
                    <NotifyPolice />
                    <Location />
                    <Survival />
                    <div className="absolute top-[23.1875rem] right-[2.125rem] flex flex-col items-end gap-[.9375rem]">
                        <NotifyMessage />
                        <Radio />
                    </div>
                    <Velocimeter />
                </ErrorBoundary>
            </div>
            <Menu />
        </>
    );
}
