import { useClickSound } from "@app/hooks/useClickSound";
import { useLayout } from "@app/hooks/useLayout";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { Background } from "@views/components/Background";
import { Header } from "@views/components/Header";
import { Notifications } from "@views/components/Notifications";
import { Outlet } from "react-router-dom";

export function Layout() {
	const visible = useVisibilityStore((state) => state.visible);

	useLayout();
	useClickSound();

	return (
		<div
			className={cn(
				"absolute top-0 left-0 flex h-screen w-screen flex-col transition-all duration-500",
				visible ? "opacity-100" : "opacity-0",
			)}
		>
			<div className="fixed top-0 left-0 z-[11] flex h-screen w-screen flex-col items-center overflow-hidden">
				<Header />
				<main className="relative mx-auto mt-[2.9375rem] flex h-[47.9375rem] w-full flex-col items-center px-[14.0625rem]">
					<Outlet />
				</main>
			</div>
			<Background />
			<Notifications />
		</div>
	);
}
