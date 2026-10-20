import { useKeyPress } from "@app/hooks/useKeyPress";
import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { useMenu } from "@app/stores/Menu";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { useEffect } from "react";
import { useShallow } from "zustand/shallow";
import { Adjustments } from "./components/Adjustments";
import { Footer } from "./components/Footer";
import { Header } from "./components/Header";
import { Hud } from "./components/Hud";

export function Menu() {
    const { selectedCategory, visible, getSavedCustomizations, setVisible } =
        useMenu(
            useShallow((state) => ({
                selectedCategory: state.selectedCategory,
                visible: state.visible,
                getSavedCustomizations: state.getSavedCustomizations,
                setVisible: state.setVisible,
            })),
        );
    const fetchHideFrame = useVisibilityStore((state) => state.fetchHideFrame);

    useKeyPress("Escape", () => {
        fetchHideFrame().then(() => setVisible(false));
    });

    useNuiMessage("set:menu:visible", setVisible);

    useEffect(() => {
        if (!visible) return;

        getSavedCustomizations();
    }, [visible, getSavedCustomizations]);

    return (
        <div
            className={cn(
                "menu-shell -translate-x-1/2 -translate-y-1/2 absolute top-1/2 left-1/2 z-[999] flex h-fit w-[35rem] flex-col rounded-[.9375rem] border border-white/30 border-solid p-[2.125rem] outline outline-1 outline-white/10 outline-offset-[.375rem] transition-all duration-300",
                visible
                    ? "-translate-y-1/2 scale-100 opacity-100"
                    : "-translate-y-[37.5%] pointer-events-none scale-[.85] opacity-0",
            )}
        >
            <Header />
            <main className="hideScroll relative z-[1] mt-[1.375rem] mb-[1.125rem] flex h-[34.875rem] w-full flex-col overflow-auto rounded-[.75rem] border border-white/[.04] border-solid p-1">
                {selectedCategory === "adjustments" && <Adjustments />}
                {selectedCategory === "hud" && <Hud />}
            </main>
            <Footer />
        </div>
    );
}

// debugData([{ action: "set:menu:visible", payload: true }]);
