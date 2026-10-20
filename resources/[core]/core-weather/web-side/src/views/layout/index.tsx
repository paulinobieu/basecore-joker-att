import { useClickSound } from "@app/hooks/useClickSound";
import { useLayout } from "@app/hooks/useLayout";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { isEnvBrowser } from "@app/utils/misc";
import { ErrorBoundary } from "@views/components/ErrorBoundary";
import { Header } from "@views/components/Header";
import { Outlet } from "react-router-dom";
import { useShallow } from "zustand/shallow";

export function Layout() {
	const { visible, closing } = useVisibilityStore(
		useShallow((state) => ({
			visible: state.visible,
			closing: state.closing,
		})),
	);

	useLayout();
	useClickSound();

	if (!visible && !closing) return null;

	return (
		<div className={cn("nui-wrapper", isEnvBrowser() && "browser-mode")}>
			<div className={cn("weather-frame", closing && "closing")}>
				<div className="weather-panel">
					<Header />
					<main className="panel-body">
						<ErrorBoundary>
							<Outlet />
						</ErrorBoundary>
					</main>
				</div>
			</div>
		</div>
	);
}
