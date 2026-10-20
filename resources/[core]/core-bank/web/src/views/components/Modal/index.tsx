import { cn } from "@app/utils";
import { IconX } from "@tabler/icons-react";
import type { Icon } from "@tabler/icons-react";
import type { ReactNode } from "react";
import { Button } from "@views/components/Button";

export interface ModalFeedback {
	kind: "success" | "error";
	message: string;
}

interface ModalProps {
	open: boolean;
	title: string;
	subtitle?: string;
	icon: Icon;
	onClose: () => void;
	className?: string;
	children: ReactNode;
	footer?: ReactNode;
	/** Resultado da operação. Quando existe, o modal vira a tela de resposta. */
	feedback?: ModalFeedback | null;
}

/**
 * Caixa central com fundo escurecido. Fecha no X ou clicando fora.
 *
 * Depois de uma operação o modal não some: ele se transforma no aviso do
 * resultado, com o traço do certo ou do erro sendo desenhado — é o que um app
 * de banco faz, e evita o jogador ficar em dúvida se a ação passou.
 */
export function Modal({
	open,
	title,
	subtitle,
	icon: ModalIcon,
	onClose,
	className,
	children,
	footer,
	feedback,
}: ModalProps) {
	if (!open) return null;

	const success = feedback?.kind === "success";

	return (
		<div className="absolute inset-0 z-40 flex items-center justify-center">
			<button
				type="button"
				aria-label="Fechar"
				onClick={onClose}
				className="absolute inset-0 bg-black/70"
			/>

			<div
				className={cn(
					"modal-panel relative flex w-[26rem] flex-col rounded-[.3125rem] border border-white/[.08] border-solid bg-[#151519] p-[1.25rem]",
					className,
				)}
			>
				{feedback ? (
					<div className="flex flex-col items-center py-[1.5rem]">
						<span
							className={cn(
								"feedback-ring flex size-[5.5rem] items-center justify-center rounded-full",
								success ? "bg-positive/15" : "bg-negative/15",
							)}
						>
							<svg
								viewBox="0 0 52 52"
								fill="none"
								className={cn(
									"size-[2.75rem]",
									success ? "text-positive" : "text-negative",
								)}
							>
								<title>{success ? "Concluído" : "Recusado"}</title>
								<path
									className="feedback-stroke"
									d={
										success
											? "M14 27.5 L22.5 36 L38 17"
											: "M17 17 L35 35 M35 17 L17 35"
									}
									stroke="currentColor"
									strokeWidth="4"
									strokeLinecap="round"
									strokeLinejoin="round"
								/>
							</svg>
						</span>

						<p className="mt-[1.25rem] text-center font-bold text-[.9375rem] text-ink leading-snug">
							{feedback.message}
						</p>

						<Button
							size="lg"
							variant={success ? "accent" : "ghost"}
							className="mt-[1.5rem] w-full"
							onClick={onClose}
						>
							Fechar
						</Button>
					</div>
				) : (
					<>
						<header className="flex flex-shrink-0 items-start justify-between gap-[.75rem]">
							<div className="flex min-w-0 items-center gap-[.625rem]">
								<span className="flex size-[2.25rem] flex-shrink-0 items-center justify-center rounded-[.25rem] bg-primaryColor/10">
									<ModalIcon
										stroke={2.5}
										className="size-[1rem] text-primaryColor"
									/>
								</span>

								<div className="flex min-w-0 flex-col">
									<h2 className="truncate font-black text-[.875rem] text-ink uppercase leading-tight">
										{title}
									</h2>
									{subtitle && (
										<span className="truncate font-semibold text-[.6875rem] text-ink-ghost leading-tight">
											{subtitle}
										</span>
									)}
								</div>
							</div>

							<button
								type="button"
								title="Fechar"
								onClick={onClose}
								className="flex size-[1.75rem] flex-shrink-0 items-center justify-center rounded-[.25rem] text-white/25 transition-all duration-300 hover:bg-white/[.05] hover:text-white"
							>
								<IconX stroke={2.5} className="size-[.875rem]" />
							</button>
						</header>

						<div className="mt-[1rem] flex flex-col gap-[.875rem]">
							{children}
						</div>

						{footer && (
							<div className="mt-[1.25rem] flex gap-[.5rem]">{footer}</div>
						)}
					</>
				)}
			</div>
		</div>
	);
}
