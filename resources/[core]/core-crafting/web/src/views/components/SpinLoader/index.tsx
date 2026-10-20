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

export function Loading({ label = "Carregando" }: { label?: string }) {
	return (
		<div className="flex h-full w-full flex-col items-center justify-center gap-3">
			<SpinLoader />
			<span className="font-black text-[.75rem] text-white/40 uppercase">
				{label}
			</span>
		</div>
	);
}
