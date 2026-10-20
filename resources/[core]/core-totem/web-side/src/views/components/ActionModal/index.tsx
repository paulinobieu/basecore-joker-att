import { Detail } from "@views/components/Detail";
import { type ReactNode, useEffect, useRef } from "react";

interface ActionModalProps {
	open: boolean;
	title: string;
	description: ReactNode;
	children: ReactNode;
	onClose: () => void;
}

export function ActionModal({
	open,
	title,
	description,
	children,
	onClose,
}: ActionModalProps) {
	const overlayRef = useRef<HTMLDivElement>(null);

	useEffect(() => {
		if (!open) return;
		const closeOnEscape = (event: KeyboardEvent) => {
			if (event.key !== "Escape") return;
			event.stopImmediatePropagation();
			onClose();
		};
		window.addEventListener("keydown", closeOnEscape, true);
		return () => window.removeEventListener("keydown", closeOnEscape, true);
	}, [onClose, open]);

	if (!open) return null;

	return (
		<div
			ref={overlayRef}
			className="modal-overlay"
			onMouseDown={(event) => {
				if (event.target === overlayRef.current) onClose();
			}}
		>
			<dialog open className="modal-card group" aria-labelledby="modal-title">
				<Detail />
				<h2
					id="modal-title"
					className="relative z-30 font-black text-base text-white uppercase"
				>
					{title}
				</h2>
				<div className="relative z-30 text-center font-medium text-[#adadad] text-xs">
					{description}
				</div>
				<div className="relative z-30 w-full">{children}</div>
			</dialog>
		</div>
	);
}
