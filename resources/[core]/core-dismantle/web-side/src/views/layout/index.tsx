import { useClickSound } from "@app/hooks/useClickSound";
import { useLayout } from "@app/hooks/useLayout";
import { useVisibilityStore } from "@app/stores/Visibility";
import { useDismantleStore } from "@app/stores/Dismantle";
import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { ErrorBoundary } from "@views/components/ErrorBoundary";
import { Sidebar } from "@views/components/Sidebar";
import { InfoPage } from "@views/pages/Info";
import { StoragePage } from "@views/pages/Storage";

export function Layout() {
    const { visible, setVisible } = useVisibilityStore();
    const setData = useDismantleStore(state => state.setData);
    const tab = useDismantleStore(state => state.tab);

    useLayout();
    useClickSound();

    useNuiMessage("openPanel", (data: any) => {
        setData(data);
        setVisible(true);
        if (data.primaryColor) {
            const hex = data.primaryColor.replace("#", "");
            const r = parseInt(hex.substring(0, 2), 16);
            const g = parseInt(hex.substring(2, 4), 16);
            const b = parseInt(hex.substring(4, 6), 16);
            document.documentElement.style.setProperty("--primaryColor", `${r}, ${g}, ${b}`);
        }
    });

    return (
        <div
            id="app"
            className={visible ? "show" : ""}
        >
            <div className="dm-frame">
                <div className="effect-circle effect-circle--a" />
                <div className="effect-circle effect-circle--b" />
                <div className="dm-container">
                    <Sidebar />
                    <div className="dm-separator" />
                    <main className="dm-main">
                        <ErrorBoundary>
                            {tab === "info" ? <InfoPage /> : <StoragePage />}
                        </ErrorBoundary>
                    </main>
                </div>
            </div>
        </div>
    );
}
