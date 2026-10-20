import { useImageValidation } from "@app/hooks/useImageValidation";
import type { IQueueLine } from "@app/stores/Crafting";
import { clamp, formatNumber, formatTime } from "@app/utils/misc";
import { IconPackageImport, IconX } from "@tabler/icons-react";

interface QueueLineProps {
	entry: IQueueLine;
	/** Relogio compartilhado da fila, atualizado pelo painel. */
	now: number;
	onCollect(): void;
	onCancel(): void;
}

export function QueueLine({ entry, now, onCollect, onCancel }: QueueLineProps) {
	const { imageUrl, onImageError } = useImageValidation(entry.image);

	const remaining = Math.max(0, (entry.endsAt - now) / 1000);

	const ready = remaining <= 0;
	const waiting = remaining > entry.duration;

	const progress =
		entry.duration > 0 ? clamp(1 - remaining / entry.duration, 0, 1) : 1;

	return (
		<div className="relative flex-shrink-0">
			<div className="queue-bar flex flex-col gap-[.5rem] rounded-[.3125rem] border border-white/[.03] border-solid p-[.5rem]">
				<div className="flex items-center gap-[.5rem]">
					<img
						src={imageUrl}
						alt={entry.name}
						loading="lazy"
						decoding="async"
						onError={onImageError}
						className="size-[2.25rem] flex-shrink-0 object-contain"
					/>

					<div className="flex min-w-0 flex-1 flex-col">
						<span
							title={entry.name}
							className="truncate font-black text-[#EDEAE5] text-[.75rem] uppercase"
						>
							{entry.name}
						</span>
						<span className="truncate font-semibold text-[.625rem] text-white/30">
							{formatNumber(entry.amount)}x ·{" "}
							{waiting
								? `começa em ${formatTime(remaining - entry.duration)}`
								: `${formatTime(remaining)} restantes`}
						</span>
					</div>

					<button
						type="button"
						title="Cancelar fabricação"
						onClick={onCancel}
						className="flex size-[1.25rem] flex-shrink-0 items-center justify-center rounded-[.25rem] text-white/25 transition-all duration-300 hover:text-white"
					>
						<IconX stroke={2.5} className="size-[.875rem]" />
					</button>
				</div>

				<div className="progress-bar h-[.25rem] w-full overflow-hidden rounded-full">
					<div
						className="progress-bar-fill h-full rounded-full"
						style={{ width: `${progress * 100}%` }}
					/>
				</div>
			</div>

			{ready && (
				<button
					type="button"
					title={`Coletar ${entry.name}`}
					onClick={onCollect}
					className="collect-panel z-40 flex items-center justify-center gap-2"
				>
					<IconPackageImport stroke={2.5} className="size-[1rem] text-white" />
					<span className="font-black text-[.875rem] text-white uppercase tracking-[.15em]">
						Coletar
					</span>
				</button>
			)}
		</div>
	);
}
