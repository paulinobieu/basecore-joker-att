import { type ToastMessage, useToastStore } from "@app/stores/Toast";
import { cn } from "@app/utils";
import {
	IconAlertTriangle,
	IconCircleCheck,
	IconCircleX,
	IconInfoCircle,
	IconX,
} from "@tabler/icons-react";
import { useEffect } from "react";
import { createPortal } from "react-dom";

const ICONS = {
	success: { Icon: IconCircleCheck, className: "text-primaryColor" },
	info: { Icon: IconInfoCircle, className: "text-primaryColor" },
	warn: { Icon: IconAlertTriangle, className: "text-[#ffb020]" },
	error: { Icon: IconCircleX, className: "text-[#f04438]" },
};

function ToastItem({ message }: { message: ToastMessage }) {
	const remove = useToastStore((state) => state.remove);
	const { Icon, className } = ICONS[message.severity];

	useEffect(() => {
		const timeoutId = setTimeout(() => remove(message.id), message.life);

		return () => clearTimeout(timeoutId);
	}, [message.id, message.life, remove]);

	return (
		<div className="flex w-[22rem] animate-rise items-start gap-3 rounded-surface border border-white/[.03] bg-toast p-4">
			<Icon size={20} stroke={2} className={cn("shrink-0", className)} />

			<div className="flex flex-1 flex-col gap-1">
				<h1 className="font-black text-[.8125rem] text-white uppercase">
					{message.summary}
				</h1>

				{message.detail && (
					<p className="font-medium text-[#adadad] text-xs">{message.detail}</p>
				)}
			</div>

			<button
				type="button"
				onClick={() => remove(message.id)}
				className="text-ink-muted transition-colors duration-300 hover:text-white"
			>
				<IconX size={14} stroke={2} />
			</button>
		</div>
	);
}

export function Toaster() {
	const messages = useToastStore((state) => state.messages);

	return createPortal(
		<div className="pointer-events-none fixed top-5 right-5 z-[1100] flex flex-col gap-2">
			{messages.map((message) => (
				<div key={message.id} className="pointer-events-auto">
					<ToastItem message={message} />
				</div>
			))}
		</div>,
		document.body,
	);
}
