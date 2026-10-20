import { formatCurrency, formatDateTime } from "@app/utils/format";
import { useBankStore } from "@app/stores/Bank";
import { cn } from "@app/utils";
import { IconScale, IconShieldCheck, IconWallet } from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Card } from "@views/components/Card";
import { Empty } from "@views/components/Empty";
import { Segmented } from "@views/components/Segmented";
import { Stat } from "@views/components/Stat";
import { useMemo, useState } from "react";
import { useShallow } from "zustand/shallow";

type Filter = "pending" | "paid";

export function Fines() {
	const { account, busy, run } = useBankStore(
		useShallow((state) => ({
			account: state.account,
			busy: state.busy,
			run: state.run,
		})),
	);

	const [filter, setFilter] = useState<Filter>("pending");

	const balance = account?.balance ?? 0;
	const fines = account?.fines ?? [];

	const pending = useMemo(() => fines.filter((fine) => !fine.paid), [fines]);
	const debt = pending.reduce((total, fine) => total + fine.amount, 0);
	const visible =
		filter === "pending" ? pending : fines.filter((fine) => fine.paid);

	return (
		<div className="flex h-full w-full flex-col gap-[.875rem] p-[1.25rem]">
			<div className="flex h-[8.5rem] flex-shrink-0 gap-[.875rem]">
				<Stat
					accent
					className="flex-1"
					label="Você está devendo"
					value={debt}
					icon={IconScale}
					footnote={
						pending.length === 0
							? "Nenhuma infração no seu nome"
							: `${pending.length} ${pending.length === 1 ? "multa" : "multas"} aguardando pagamento`
					}
				/>

				<Stat
					className="flex-1"
					label="Saldo disponível"
					value={balance}
					icon={IconWallet}
					footnote={
						debt > balance
							? "Saldo não cobre as multas"
							: "Dá para quitar tudo agora"
					}
				/>

				<Stat
					className="flex-1"
					label="Já pagas"
					value={fines
						.filter((fine) => fine.paid)
						.reduce((total, fine) => total + fine.amount, 0)}
					icon={IconShieldCheck}
					footnote="Somando o histórico do seu passaporte"
				/>
			</div>

			<Card
				title="Multas recebidas"
				icon={IconScale}
				className="min-h-0 flex-1"
				action={
					<Segmented
						value={filter}
						onChange={setFilter}
						className="h-[1.875rem]"
						options={[
							{ value: "pending", label: "Em aberto" },
							{ value: "paid", label: "Pagas" },
						]}
					/>
				}
			>
				{visible.length === 0 ? (
					<Empty
						icon={IconShieldCheck}
						label={filter === "pending" ? "Ficha limpa" : "Nada pago ainda"}
						hint="Multas aplicadas pela polícia aparecem aqui"
					/>
				) : (
					<div className="customScrollbar flex min-h-0 flex-1 flex-col gap-[.375rem] overflow-y-auto pr-[.25rem]">
						{visible.map((fine) => {
							const { date, time } = formatDateTime(fine.date);

							return (
								<div
									key={fine.id}
									className="row-surface flex flex-shrink-0 items-center gap-[.75rem] px-[.75rem] py-[.625rem]"
								>
									<span
										className={cn(
											"flex size-[2rem] flex-shrink-0 items-center justify-center rounded-[.25rem]",
											fine.paid ? "bg-white/[.04]" : "bg-negative/10",
										)}
									>
										<IconScale
											stroke={2.5}
											className={cn(
												"size-[.9375rem]",
												fine.paid ? "text-white/25" : "text-negative",
											)}
										/>
									</span>

									<div className="flex min-w-0 flex-1 flex-col">
										<span className="truncate font-black text-[.8125rem] text-ink leading-tight">
											{fine.description}
										</span>
										<span className="truncate font-semibold text-[.6875rem] text-ink-ghost leading-tight">
											Aplicada por {fine.officer} · {date} às {time}
										</span>
									</div>

									<span className="flex-shrink-0 font-black text-[.9375rem] text-ink">
										{formatCurrency(fine.amount)}
									</span>

									<div className="flex w-[6.5rem] flex-shrink-0 justify-end">
										{fine.paid ? (
											<span className="font-black text-[.6875rem] text-positive uppercase">
												Paga
											</span>
										) : (
											<Button
												variant="accent"
												className="w-full"
												disabled={busy}
												onClick={() => run("post:finePay", { fine: fine.id })}
											>
												Pagar
											</Button>
										)}
									</div>
								</div>
							);
						})}
					</div>
				)}
			</Card>
		</div>
	);
}
