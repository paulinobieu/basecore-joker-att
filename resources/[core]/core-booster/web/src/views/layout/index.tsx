import { useClickSound } from "@app/hooks/useClickSound";
import { useLayout } from "@app/hooks/useLayout";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { RewardsModal } from "@views/components/RewardsModal";
import { Topbar } from "@views/components/Topbar";
import { Rewards } from "@views/pages/Rewards";

export function Layout() {
	const visible = useVisibilityStore((state) => state.visible);

	useLayout();
	useClickSound();

	return (
		<div
			className={cn(
				"-translate-x-1/2 absolute top-1/2 left-1/2 z-[2] flex h-[39rem] w-[76rem] flex-col rounded-[.625rem] bg-[#111114F5] outline outline-[#14141769] outline-[.5625rem] transition-all duration-500",
				visible
					? "-translate-y-1/2 opacity-100"
					: "-translate-y-[200%] pointer-events-none opacity-0",
			)}
		>
			<Topbar />
			<Rewards />

			<RewardsModal />
		</div>
	);
}
