import { cn } from "@app/utils";

export function SpinLoader({ className }: { className?: string }) {
	return (
		<span
			className={cn(
				"block size-[1.25rem] animate-spin rounded-full border-2 border-white/20 border-t-primaryColor",
				className,
			)}
		/>
	);
}
