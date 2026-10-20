import { formatCurrency, formatDateTime } from "@app/utils/format";
import type { Movement } from "@app/stores/Bank";
import { cn } from "@app/utils";
import {
	IconArrowDownLeft,
	IconArrowUpRight,
	IconReceipt,
} from "@tabler/icons-react";
import { Empty } from "@views/components/Empty";
import { Loading } from "@views/components/SpinLoader";

/** Rótulo curto de cada tipo de movimento gravado pelo servidor. */
const LABELS: Record<string, string> = {
	deposit: "Depósito",
	withdraw: "Saque",
	transfer: "Transferência",
	pix: "PIX",
	invoice: "Fatura",
	fine: "Multa",
	invest: "Aplicação",
	redeem: "Resgate",
	crypto: "Criptomoeda",
	business: "Abertura de empresa",
};

interface StatementListProps {
	movements: Movement[];
	loading?: boolean;
	emptyHint?: string;
}

export function StatementList({
	movements,
	loading,
	emptyHint,
}: StatementListProps) {
	if (loading) return <Loading label="Buscando extrato" />;

	if (movements.length === 0) {
		return (
			<Empty icon={IconReceipt} label="Sem movimentações" hint={emptyHint} />
		);
	}

	return (
		<div className="customScrollbar flex min-h-0 flex-1 flex-col gap-[.375rem] overflow-y-auto pr-[.25rem]">
			{movements.map((movement) => {
				const { date, time } = formatDateTime(movement.date);
				const Icon = movement.outgoing ? IconArrowUpRight : IconArrowDownLeft;

				return (
					<div
						key={movement.id}
						className="row-surface flex flex-shrink-0 items-center gap-[.75rem] px-[.75rem] py-[.5625rem]"
					>
						<span
							className={cn(
								"flex size-[1.875rem] flex-shrink-0 items-center justify-center rounded-[.25rem]",
								movement.outgoing ? "bg-negative/10" : "bg-positive/10",
							)}
						>
							<Icon
								stroke={2.5}
								className={cn(
									"size-[.875rem]",
									movement.outgoing ? "text-negative" : "text-positive",
								)}
							/>
						</span>

						<div className="flex min-w-0 flex-1 flex-col">
							<span className="truncate font-black text-[.75rem] text-ink leading-tight">
								{movement.description || LABELS[movement.type] || movement.type}
							</span>
							<span className="truncate font-semibold text-[.6875rem] text-ink-ghost leading-tight">
								{LABELS[movement.type] || movement.type}
								{movement.author ? ` · ${movement.author}` : ""}
							</span>
						</div>

						<div className="flex flex-shrink-0 flex-col items-end">
							<span
								className={cn(
									"font-black text-[.8125rem] leading-tight",
									movement.outgoing ? "text-negative" : "text-positive",
								)}
							>
								{movement.outgoing ? "−" : "+"}{" "}
								{formatCurrency(movement.amount)}
							</span>
							<span className="font-semibold text-[.625rem] text-white/25 leading-tight">
								{date} · {time}
							</span>
						</div>
					</div>
				);
			})}
		</div>
	);
}
