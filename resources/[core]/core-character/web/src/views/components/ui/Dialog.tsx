import { cn } from "@app/utils";
import { IconX } from "@tabler/icons-react";
import type { CSSProperties, ReactNode } from "react";
import { createPortal } from "react-dom";

/**
 * Detalhe do creator: linhas internas recuadas + quatro pontos nos
 * cantos. Fica acima do conteudo, sem capturar o mouse.
 */
function DialogFrame() {
	const dot =
		"absolute h-[.4375rem] w-[.4375rem] rounded-full bg-[#303030] content-['']";

	return (
		<div className="pointer-events-none absolute inset-0 z-20 rounded-surface">
			<span className="absolute top-5 left-0 h-px w-full bg-[#D9D9D90A]" />
			<span className="absolute bottom-5 left-0 h-px w-full bg-[#D9D9D90A]" />
			<span className="absolute top-0 left-5 h-full w-px bg-[#D9D9D90A]" />
			<span className="absolute top-0 right-5 h-full w-px bg-[#D9D9D90A]" />

			<span className={cn(dot, "top-[.84375rem] left-[.84375rem]")} />
			<span className={cn(dot, "top-[.84375rem] right-[.84375rem]")} />
			<span className={cn(dot, "bottom-[.84375rem] left-[.84375rem]")} />
			<span className={cn(dot, "right-[.84375rem] bottom-[.84375rem]")} />
		</div>
	);
}

interface DialogProps {
	open: boolean;
	header: string;
	children: ReactNode;
	footer?: ReactNode;
	style?: CSSProperties;
	className?: string;
	onClose?: () => void;
}

export function Dialog({
	open,
	header,
	children,
	footer,
	style,
	className,
	onClose,
}: DialogProps) {
	if (!open) return null;

	// Fora da arvore da tela: um ancestral com transform ou filtro
	// viraria bloco de contencao e a mascara deixaria de cobrir o ecra.
	return createPortal(
		<div className="fixed inset-0 z-[1000] flex animate-fade-fast items-center justify-center bg-black/90">
			<div
				style={style}
				className={cn(
					"relative rounded-surface border border-white/[.03] bg-panel bg-blend-multiply",
					className,
				)}
			>
				<DialogFrame />

				<header className="flex items-center justify-between gap-4 px-6 pt-6 pb-2">
					<h1 className="font-black text-base text-white uppercase">
						{header}
					</h1>

					{onClose && (
						<button
							type="button"
							onClick={onClose}
							className="z-30 flex h-8 w-8 items-center justify-center rounded-surface text-ink-muted transition-all duration-500 hover:bg-[rgba(221,221,221,.17)] hover:text-white"
						>
							<IconX size={18} stroke={2} />
						</button>
					)}
				</header>

				<div className="px-6 pt-2 pb-6 text-[#adadad]">{children}</div>

				{footer && (
					<div className="flex items-center justify-end gap-2 px-6 pb-6">
						{footer}
					</div>
				)}
			</div>
		</div>,
		document.body,
	);
}
