import { useLayout } from "@app/hooks/useLayout";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { ErrorBoundary } from "@views/components/ErrorBoundary";
import { Logo } from "@views/components/Logo";
import { ConfirmDialog } from "@views/components/ui/ConfirmDialog";
import { Toaster } from "@views/components/ui/Toast";
import { Tooltip } from "@views/components/ui/Tooltip";
import { Outlet } from "react-router-dom";

export function Layout() {
	const visible = useVisibilityStore((state) => state.visible);

	useLayout();

	return (
		<>
			<div
				className={cn(
					"relative h-screen w-screen transition-opacity duration-200",
					visible ? "opacity-100" : "pointer-events-none opacity-0",
				)}
			>
				{/* Desmontar quando escondido zera o estado das telas e evita
				    que listeners de teclado continuem ativos no jogo. */}
				{visible && (
					<ErrorBoundary>
						<Logo />
						<Outlet />
					</ErrorBoundary>
				)}
			</div>

			<Toaster />
			<ConfirmDialog />
			<Tooltip />
		</>
	);
}
