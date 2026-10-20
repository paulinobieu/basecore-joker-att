import { useClickSound } from "@app/hooks/useClickSound";
import { useLayout } from "@app/hooks/useLayout";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { Topbar } from "@views/components/Topbar";
import { Arsenal } from "@views/pages/Arsenal";

export function Layout() {
	const visible = useVisibilityStore((state) => state.visible);

	useLayout();
	useClickSound();

	return (
		<div
			className={cn(
				"arsenal-shell -translate-x-1/2 absolute top-1/2 left-1/2 z-[2] flex h-[50rem] w-[90rem] flex-col overflow-hidden rounded-[.625rem] bg-[#0F1112F5] outline outline-[#13161669] outline-[.5625rem] transition-all duration-500",
				visible
					? "-translate-y-1/2 opacity-100"
					: "-translate-y-[200%] pointer-events-none opacity-0",
			)}
		>
			<Topbar />

			<main className="flex h-[calc(100%-4.75rem)] w-full">
				<Arsenal />
			</main>
		</div>
	);
}
