import { useMenu } from "@app/stores/Menu";
import { useVisibilityStore } from "@app/stores/Visibility";
import { AdjustmentsIcon } from "@views/assets/icons/Adjustments";
import { CloseIcon } from "@views/assets/icons/Close";
import { GearIcon } from "@views/assets/icons/Gear";
import { useShallow } from "zustand/shallow";

export function Header() {
    const fetchHideFrame = useVisibilityStore((state) => state.fetchHideFrame);
    const { selectedCategory, setVisible } = useMenu(
        useShallow((state) => ({
            selectedCategory: state.selectedCategory,
            setVisible: state.setVisible,
        })),
    );

    return (
        <header
            key={selectedCategory}
            className="flex w-full animate-fadeIn items-center font-semibold text-[1.0625rem]"
        >
            <div
                className="mr-[1.125rem] flex size-8 items-center justify-center rounded-md border border-primaryColor border-solid"
                style={{
                    background:
                        "linear-gradient(90.81deg, rgb(var(--primaryColor)) 1.74%, rgba(var(--primaryColor), 0.4) 105.09%)",
                }}
            >
                {selectedCategory === "hud" ? (
                    <GearIcon />
                ) : (
                    <AdjustmentsIcon />
                )}
            </div>
            {selectedCategory === "hud" ? "Menu HUD" : "Ajustes"}
            <button
                type="button"
                className="ml-auto grid size-8 place-items-center rounded-md border border-white/35 border-solid transition-all duration-300 hover:bg-white/10"
                onClick={() => fetchHideFrame().then(() => setVisible(false))}
            >
                <CloseIcon />
            </button>
        </header>
    );
}
