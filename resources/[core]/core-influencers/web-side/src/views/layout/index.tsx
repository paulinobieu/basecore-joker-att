import { useClickSound } from "@app/hooks/useClickSound";
import { useLayout } from "@app/hooks/useLayout";
import { ErrorBoundary } from "@views/components/ErrorBoundary";
import { CameraOverlay } from "@views/pages/Creator/components/CameraOverlay";
import { useCreatorBridge } from "@views/pages/Creator/hooks/useCreatorBridge";
import { Outlet } from "react-router-dom";

export function Layout() {
	useLayout();
	useClickSound();
	useCreatorBridge();

	return (
		<>
			<ErrorBoundary>
				<Outlet />
			</ErrorBoundary>
			<CameraOverlay />
		</>
	);
}
