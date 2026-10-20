import { useLayout } from "@app/hooks/useLayout";
import { useKeyPress } from "@app/hooks/useKeyPress";
import { useCallsStore } from "@app/stores/Calls";
import { useVisibilityStore } from "@app/stores/Visibility";
import { ErrorBoundary } from "@views/components/ErrorBoundary";
import { Outlet } from "react-router-dom";
import { useShallow } from "zustand/shallow";

export function Layout() {
	const { visible, closing, fetchHideFrame } = useVisibilityStore(
		useShallow((state) => ({
			visible: state.visible,
			closing: state.closing,
			fetchHideFrame: state.fetchHideFrame,
		})),
	);

	const { surface, closeSurface } = useCallsStore(
		useShallow((s) => ({
			surface: s.surface,
			closeSurface: s.closeSurface,
		})),
	);

	useLayout();

	useKeyPress("Escape", () => {
		if (surface === "feedback") return;
		if (surface !== "none") {
			closeSurface();
			fetchHideFrame();
		}
	});

	return (
		<div
			id="app"
			className={`${visible || closing ? "show" : ""} ${closing ? "closing" : ""}`.trim()}
		>
			<div className="app-frame">
				<ErrorBoundary>
					<Outlet />
				</ErrorBoundary>
			</div>
		</div>
	);
}
