import { useClickSound } from "@app/hooks/useClickSound";
import { useLayout } from "@app/hooks/useLayout";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { ErrorBoundary } from "@views/components/ErrorBoundary";
import { Notifys } from "@views/components/Notifys";
import { Outlet } from "react-router-dom";

export function Layout() {
	const visible = useVisibilityStore((state) => state.visible);

	useLayout();
	useClickSound();

	return (
		<div
			className={cn(
				"flex h-screen w-screen items-center justify-center antialiased transition-all duration-300",
				// `invisible` entra só no fim da transição: sem ele o CEF
				// continuava desenhando pedaços do painel depois do ESC.
				visible ? "opacity-100" : "pointer-events-none invisible opacity-0",
			)}
		>
			<Notifys />

			<ErrorBoundary>
				<Outlet />
			</ErrorBoundary>
		</div>
	);
}
