import { useKeyPress } from "@app/hooks/useKeyPress";
import { cn } from "@app/utils";
import type { Icon } from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Detail } from "@views/components/Detail";
import { SpinLoader } from "@views/components/SpinLoader";
import type { ReactNode } from "react";

interface ModalProps {
	title: string;
	visible: boolean;
	icon?: Icon;
	description?: string;
	children?: ReactNode;
	width?: string;
	loading?: boolean;
	footerLabels?: { confirm: string; cancel: string };
	onConfirm(): void;
	onClose(): void;
}

export function Modal({
	title,
	visible,
	icon: HeadIcon,
	description,
	children,
	width = "26rem",
	loading = false,
	footerLabels,
	onConfirm,
	onClose,
}: ModalProps) {
	useKeyPress("Escape", onClose);

	return (
		<div
			className={cn(
				"-translate-y-1/2 -translate-x-1/2 fixed top-1/2 left-1/2 z-[9999] flex h-[50rem] w-[90rem] items-center justify-center rounded-[.625rem] bg-black/90 transition-all duration-500",
				visible ? "opacity-100" : "pointer-events-none opacity-0",
			)}
		>
			<div
				className="relative flex flex-col gap-3 rounded-[.3125rem] border border-white/[.03] border-solid p-7"
				style={{
					width,
					background:
						"linear-gradient(0deg, rgba(37, 37, 40, 0.6608), rgba(37, 37, 40, 0.6608)),linear-gradient(0deg, rgba(221, 221, 221, 0.02), rgba(221, 221, 221, 0.02)),radial-gradient(50% 50% at 50% 50%, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.02) 100%)",
				}}
			>
				<Detail full />

				<div className="relative z-30 flex items-center justify-center gap-2">
					{HeadIcon && (
						<HeadIcon
							stroke={2}
							className="size-[1.125rem] text-primaryColor"
						/>
					)}
					<h1 className="font-black text-[.9375rem] text-white uppercase">
						{title}
					</h1>
				</div>

				{description && (
					<p className="relative z-30 text-center font-semibold text-[#adadad] text-[.75rem] leading-relaxed">
						{description}
					</p>
				)}

				{children && (
					<div className="relative z-30 flex flex-col gap-2">{children}</div>
				)}

				<footer className="relative z-30 mt-1 flex w-full items-center gap-2.5">
					<Button
						size="lg"
						variant="ghost"
						className="flex-1"
						disabled={loading}
						onClick={onClose}
					>
						{footerLabels?.cancel || "Cancelar"}
					</Button>
					<Button
						size="lg"
						variant="accent"
						className="flex-1"
						disabled={loading}
						icon={
							loading ? <SpinLoader className="size-[.875rem]" /> : undefined
						}
						onClick={onConfirm}
					>
						{footerLabels?.confirm || "Confirmar"}
					</Button>
				</footer>
			</div>
		</div>
	);
}
