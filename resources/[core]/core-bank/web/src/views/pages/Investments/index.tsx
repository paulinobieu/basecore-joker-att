import {
	formatCurrency,
	formatDateTime,
	parseAmount,
	sanitizeAmount,
} from "@app/utils/format";
import { useModalAction } from "@app/hooks/useModalAction";
import { type Product, useBankStore } from "@app/stores/Bank";
import { IconChartLine, IconPigMoney, IconWallet } from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Card } from "@views/components/Card";
import { Empty } from "@views/components/Empty";
import { Field } from "@views/components/Field";
import { Modal } from "@views/components/Modal";
import { Stat } from "@views/components/Stat";
import { useState } from "react";
import { useShallow } from "zustand/shallow";

function formatRate(rate: number) {
	return `${(rate * 100).toFixed(2).replace(".", ",")}%`;
}

function formatCycle(hours: number) {
	if (hours % 24 === 0) {
		const days = hours / 24;
		return days === 1 ? "por dia" : `a cada ${days} dias`;
	}

	return `a cada ${hours}h`;
}

export function Investments() {
	const { account, products, busy, run } = useBankStore(
		useShallow((state) => ({
			account: state.account,
			products: state.products,
			busy: state.busy,
			run: state.run,
		})),
	);

	const { feedback, submit, clear } = useModalAction();

	const [applying, setApplying] = useState<Product | null>(null);
	const [amount, setAmount] = useState("");

	const balance = account?.balance ?? 0;
	const positions = account?.positions ?? [];
	const value = parseAmount(amount);

	const principal = positions.reduce(
		(total, position) => total + position.amount,
		0,
	);
	const revenue = positions.reduce(
		(total, position) => total + position.revenue,
		0,
	);

	function closeApply() {
		setApplying(null);
		clear();

		if (feedback?.kind === "success") setAmount("");
	}

	return (
		<div className="flex h-full w-full flex-col gap-[.875rem] p-[1.25rem]">
			<div className="flex h-[8.5rem] flex-shrink-0 gap-[.875rem]">
				<Stat
					accent
					className="flex-1"
					label="Aplicado"
					value={principal}
					icon={IconPigMoney}
					footnote={`${positions.length} ${positions.length === 1 ? "aplicação" : "aplicações"} ativas`}
				/>

				<Stat
					className="flex-1"
					label="Rendimento acumulado"
					value={revenue}
					icon={IconChartLine}
					footnote="Creditado junto do principal no resgate"
				/>

				<Stat
					className="flex-1"
					label="Saldo disponível"
					value={balance}
					icon={IconWallet}
					footnote={account?.name}
				/>
			</div>

			<div className="flex min-h-0 flex-1 gap-[.875rem]">
				<Card
					title="Aplicações disponíveis"
					icon={IconPigMoney}
					className="min-w-0 flex-1"
				>
					<div className="customScrollbar flex min-h-0 flex-1 flex-col gap-[.375rem] overflow-y-auto pr-[.25rem]">
						{products.map((product) => (
							<div
								key={product.code}
								className="row-surface flex flex-shrink-0 items-center gap-[.75rem] px-[.75rem] py-[.75rem]"
							>
								<div className="flex min-w-0 flex-1 flex-col">
									<span className="truncate font-black text-[.8125rem] text-ink leading-tight">
										{product.name}
									</span>
									<span className="truncate font-semibold text-[.6875rem] text-ink-ghost leading-tight">
										{product.description}
									</span>
									<span className="mt-[.25rem] font-black text-[.6875rem] text-positive">
										{formatRate(product.rate)} {formatCycle(product.cycle)}
										<span className="text-ink-ghost">
											{" · "}mínimo {formatCurrency(product.minimum)}
											{product.lock > 0
												? ` · carência de ${product.lock / 24} dias`
												: " · sem carência"}
										</span>
									</span>
								</div>

								<div className="flex w-[6.5rem] flex-shrink-0 justify-end">
									<Button
										variant="accent"
										className="w-full"
										disabled={balance < product.minimum}
										onClick={() => {
											setApplying(product);
											setAmount("");
										}}
									>
										Aplicar
									</Button>
								</div>
							</div>
						))}
					</div>
				</Card>

				<Card
					title="Minhas aplicações"
					icon={IconChartLine}
					className="w-[30rem] flex-shrink-0"
				>
					{positions.length === 0 ? (
						<Empty
							icon={IconPigMoney}
							label="Nada aplicado"
							hint="Escolha uma aplicação ao lado para começar"
						/>
					) : (
						<div className="customScrollbar flex min-h-0 flex-1 flex-col gap-[.375rem] overflow-y-auto pr-[.25rem]">
							{positions.map((position) => (
								<div
									key={position.id}
									className="row-surface flex flex-shrink-0 flex-col gap-[.5rem] px-[.75rem] py-[.625rem]"
								>
									<div className="flex items-center gap-[.75rem]">
										<div className="flex min-w-0 flex-1 flex-col">
											<span className="truncate font-black text-[.8125rem] text-ink leading-tight">
												{position.name}
											</span>
											<span className="font-semibold text-[.6875rem] text-ink-ghost leading-tight">
												Aplicado em {formatDateTime(position.date).date}
											</span>
										</div>

										<div className="flex flex-shrink-0 flex-col items-end">
											<span className="font-black text-[.8125rem] text-ink leading-tight">
												{formatCurrency(position.amount)}
											</span>
											<span className="font-black text-[.6875rem] text-positive leading-tight">
												+ {formatCurrency(position.revenue)}
											</span>
										</div>
									</div>

									<div className="flex items-center gap-[.5rem]">
										<span className="flex-1 font-semibold text-[.625rem] text-white/25">
											{position.locked
												? `Libera em ${formatDateTime(position.unlockAt).date} · resgate antes perde ${Math.round(position.penalty * 100)}% do rendimento`
												: "Livre para resgate"}
										</span>

										<Button
											size="sm"
											variant={position.locked ? "danger" : "ghost"}
											disabled={busy}
											onClick={() =>
												run("post:redeem", { position: position.id })
											}
										>
											Resgatar
										</Button>
									</div>
								</div>
							))}
						</div>
					)}
				</Card>
			</div>

			<Modal
				open={applying !== null}
				title={applying?.name ?? ""}
				subtitle={
					applying
						? `${formatRate(applying.rate)} ${formatCycle(applying.cycle)}`
						: ""
				}
				icon={IconPigMoney}
				onClose={closeApply}
				feedback={feedback}
				footer={
					<>
						<Button
							size="lg"
							className="flex-1"
							onClick={() => setApplying(null)}
						>
							Cancelar
						</Button>
						<Button
							size="lg"
							variant="accent"
							className="flex-1"
							disabled={
								busy ||
								value <= 0 ||
								value > balance ||
								value < (applying?.minimum ?? 0) ||
								((applying?.maximum ?? 0) > 0 &&
									value > (applying?.maximum ?? 0))
							}
							onClick={() =>
								submit("post:invest", {
									code: applying?.code,
									amount: value,
								})
							}
						>
							Aplicar
						</Button>
					</>
				}
			>
				<Field
					label="Quanto aplicar"
					prefix="$"
					placeholder="0"
					inputMode="numeric"
					value={amount}
					onChange={(event) => setAmount(sanitizeAmount(event.target.value))}
					hint={`Mínimo ${formatCurrency(applying?.minimum ?? 0)}${
						(applying?.maximum ?? 0) > 0
							? ` · teto ${formatCurrency(applying?.maximum ?? 0)}`
							: ""
					} · disponível ${formatCurrency(balance)}`}
				/>

				{applying && applying.lock > 0 && (
					<span className="font-semibold text-[.6875rem] text-white/25 leading-relaxed">
						O dinheiro fica preso por {applying.lock / 24} dias. Resgatar antes
						disso custa {Math.round(applying.penalty * 100)}% do rendimento
						acumulado.
					</span>
				)}
			</Modal>
		</div>
	);
}
