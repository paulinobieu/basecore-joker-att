import { formatCurrency, parseAmount, sanitizeAmount } from "@app/utils/format";
import { useModalAction } from "@app/hooks/useModalAction";
import { routes } from "@app/router/routes";
import { useBankStore } from "@app/stores/Bank";
import {
	IconArrowDownLeft,
	IconArrowUpRight,
	IconChartLine,
	IconCoinBitcoin,
	IconReceipt,
	IconScale,
	IconWallet,
} from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Card } from "@views/components/Card";
import { Chart } from "@views/components/Chart";
import { Empty } from "@views/components/Empty";
import { Field } from "@views/components/Field";
import { Modal } from "@views/components/Modal";
import { StatementList } from "@views/components/StatementList";
import { CRYPTO_ICONS } from "@views/assets/crypto";
import { Stat } from "@views/components/Stat";
import { useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useShallow } from "zustand/shallow";

type Cash = "deposit" | "withdraw" | null;

export function Dashboard() {
	const navigate = useNavigate();

	const { account, loading, busy } = useBankStore(
		useShallow((state) => ({
			account: state.account,
			loading: state.loading,
			busy: state.busy,
		})),
	);

	const { feedback, submit, clear } = useModalAction();

	const [cash, setCash] = useState<Cash>(null);
	const [amount, setAmount] = useState("");

	const value = parseAmount(amount);
	const balance = account?.balance ?? 0;

	const chart = useMemo(
		() =>
			(account?.chart ?? []).map((point) => {
				const date = new Date(point.day * 86400000);

				return {
					label: `${String(date.getUTCDate()).padStart(2, "0")}/${String(date.getUTCMonth() + 1).padStart(2, "0")}`,
					value: point.balance,
				};
			}),
		[account],
	);

	const wallet = account?.wallet ?? [];
	const invested = (account?.positions ?? []).reduce(
		(total, position) => total + position.amount + position.revenue,
		0,
	);
	const cryptoValue = wallet.reduce(
		(total, holding) => total + holding.value,
		0,
	);
	const pending =
		(account?.invoices ?? []).filter((invoice) => invoice.status === "pending")
			.length + (account?.fines ?? []).filter((fine) => !fine.paid).length;

	function closeCash() {
		setCash(null);
		clear();

		if (feedback?.kind === "success") setAmount("");
	}

	return (
		<div className="flex h-full w-full flex-col gap-[.875rem] p-[1.25rem]">
			<div className="flex h-[8.5rem] flex-shrink-0 gap-[.875rem]">
				<Stat
					accent
					className="flex-1"
					label="Saldo disponível"
					value={balance}
					icon={IconWallet}
					footnote={account?.name}
				/>

				<Stat
					className="flex-1"
					label="Aplicado"
					value={invested}
					icon={IconChartLine}
					footnote="Principal mais rendimento acumulado"
				/>

				<Stat
					className="flex-1"
					label="Em criptomoedas"
					value={cryptoValue}
					icon={IconCoinBitcoin}
					footnote={
						wallet.length > 0
							? `${wallet.length} ${wallet.length === 1 ? "moeda" : "moedas"} na carteira`
							: "Carteira vazia"
					}
				/>
			</div>

			<div className="flex min-h-0 flex-1 gap-[.875rem]">
				<Card
					title="Evolução do saldo"
					icon={IconChartLine}
					className="min-w-0 flex-1"
					bodyClassName="pb-[1.25rem]"
				>
					{chart.length === 0 ? (
						<Empty
							icon={IconChartLine}
							label="Sem histórico"
							hint="O saldo é fechado a cada movimentação"
						/>
					) : (
						<Chart data={chart} />
					)}
				</Card>

				<div className="flex w-[22rem] flex-shrink-0 flex-col gap-[.875rem]">
					<Card title="Caixa" icon={IconWallet} className="flex-shrink-0">
						<div className="flex gap-[.5rem]">
							<Button
								size="lg"
								variant="accent"
								className="flex-1"
								icon={
									<IconArrowDownLeft stroke={3} className="size-[.875rem]" />
								}
								onClick={() => setCash("deposit")}
							>
								Depositar
							</Button>
							<Button
								size="lg"
								variant="danger"
								className="flex-1"
								icon={
									<IconArrowUpRight stroke={3} className="size-[.875rem]" />
								}
								onClick={() => setCash("withdraw")}
							>
								Sacar
							</Button>
						</div>
					</Card>

					<Card
						title="Carteira de cripto"
						icon={IconCoinBitcoin}
						className="min-h-0 flex-1"
					>
						{wallet.length === 0 ? (
							<Empty
								icon={IconCoinBitcoin}
								label="Nada na carteira"
								hint="Negocie na aba Criptomoedas"
							/>
						) : (
							<div className="customScrollbar flex min-h-0 flex-1 flex-col gap-[.375rem] overflow-y-auto pr-[.25rem]">
								{wallet.map((holding) => (
									<div
										key={holding.asset}
										className="row-surface flex flex-shrink-0 items-center gap-[.625rem] px-[.75rem] py-[.5rem]"
									>
										<img
											src={CRYPTO_ICONS[holding.asset]}
											alt={holding.name}
											className="size-[1.75rem] flex-shrink-0 rounded-full"
										/>

										<div className="flex min-w-0 flex-1 flex-col">
											<span className="truncate font-black text-[.75rem] text-ink leading-tight">
												{holding.name}
											</span>
											<span className="font-semibold text-[.625rem] text-ink-ghost leading-tight">
												{holding.amount} {holding.symbol}
											</span>
										</div>

										<span className="flex-shrink-0 font-black text-[.75rem] text-ink-faint">
											{formatCurrency(holding.value)}
										</span>
									</div>
								))}
							</div>
						)}
					</Card>
				</div>
			</div>

			<Card
				title="Movimentações recentes"
				icon={IconReceipt}
				className="h-[13.5rem] flex-shrink-0"
				action={
					<div className="flex gap-[.375rem]">
						<Button
							size="sm"
							icon={<IconReceipt stroke={2.5} className="size-[.75rem]" />}
							onClick={() => navigate(`/${routes.invoices}`)}
						>
							Faturas
						</Button>
						<Button
							size="sm"
							icon={<IconScale stroke={2.5} className="size-[.75rem]" />}
							onClick={() => navigate(`/${routes.fines}`)}
						>
							Multas
						</Button>
						{pending > 0 && (
							<span className="flex h-[1.75rem] items-center rounded-[.25rem] bg-primaryColor/15 px-[.625rem] font-black text-[.6875rem] text-primaryColor uppercase">
								{pending} em aberto
							</span>
						)}
					</div>
				}
			>
				<StatementList
					movements={(account?.statement ?? []).slice(0, 20)}
					loading={loading}
					emptyHint="Depósitos, saques e transferências aparecem aqui"
				/>
			</Card>

			<Modal
				open={cash !== null}
				title={cash === "deposit" ? "Depositar" : "Sacar"}
				subtitle={
					cash === "deposit"
						? "Sai do dinheiro em mãos e entra na conta"
						: "Sai da conta e vira dinheiro em mãos"
				}
				icon={cash === "deposit" ? IconArrowDownLeft : IconArrowUpRight}
				onClose={closeCash}
				feedback={feedback}
				footer={
					<>
						<Button size="lg" className="flex-1" onClick={closeCash}>
							Cancelar
						</Button>
						<Button
							size="lg"
							variant={cash === "deposit" ? "accent" : "danger"}
							className="flex-1"
							disabled={
								busy || value <= 0 || (cash === "withdraw" && value > balance)
							}
							onClick={() =>
								submit(cash === "deposit" ? "post:deposit" : "post:withdraw", {
									amount: value,
								})
							}
						>
							Confirmar
						</Button>
					</>
				}
			>
				<Field
					label="Valor"
					prefix="$"
					placeholder="0"
					inputMode="numeric"
					value={amount}
					onChange={(event) => setAmount(sanitizeAmount(event.target.value))}
					hint={
						cash === "withdraw"
							? `Disponível: ${formatCurrency(balance)}`
							: undefined
					}
				/>
			</Modal>
		</div>
	);
}
