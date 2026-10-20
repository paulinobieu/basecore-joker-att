import { useClickSound } from "@app/hooks/useClickSound";
import { useLayout } from "@app/hooks/useLayout";
import { useTotemStore } from "@app/stores/Totem";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { Header } from "@views/components/Header";
import { Outlet } from "react-router-dom";
import "@views/styles/index.css";

export function Layout() {
	const visible = useVisibilityStore((state) => state.visible);
	const config = useTotemStore((state) => state.config);

	useLayout();
	useClickSound();

	return (
		<div
			className={cn(
				"totem-stage",
				visible && config ? "totem-stage--visible" : "totem-stage--hidden",
			)}
		>
			<section className="totem-panel">
				{config ? <Header totemId={config.totemId} /> : null}
				<main className="min-h-0 flex-1">
					<Outlet />
				</main>
			</section>
		</div>
	);
}
