import {
	formatCurrency,
	formatDateTime,
	parseAmount,
	sanitizeAmount,
} from "@app/utils/format";
import { useModalAction } from "@app/hooks/useModalAction";
import { type Invoice, useBankStore } from "@app/stores/Bank";
import { cn } from "@app/utils";
import {
	IconBuildingBank,
	IconFileInvoice,
	IconId,
	IconSend,
	IconWallet,
} from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Card } from "@views/components/Card";
import { Empty } from "@views/components/Empty";
import { Field } from "@views/components/Field";
import { Modal } from "@views/components/Modal";
import { Segmented } from "@views/components/Segmented";
import { Stat } from "@views/components/Stat";
import { useMemo, useState } from "react";
import { useShallow } from "zustand/shallow";

type Tab = "received" | "sent";

const STATUS: Record<Invoice["status"], { label: string; className: string }> =
	{
		pending: { label: "Em aberto", className: "text-primaryColor" },
		paid: { label: "Paga", className: "text-positive" },
		canceled: { label: "Cancelada", className: "text-white/25" },
	};

export function Invoices() {
	const { account, busy, run } = useBankStore(
		useShallow((state) => ({
			account: state.account,
			busy: state.busy,
			run: state.run,
		})),
	);

	const { feedback, submit, clear } = useModalAction();

	const [tab, setTab] = useState<Tab>("received");
	const [sending, setSending] = useState(false);
	const [target, setTarget] = useState("");
	const [amount, setAmount] = useState("");
	const [reason, setReason] = useState("");

	const balance = account?.balance ?? 0;
	const received = account?.invoices ?? [];
	const sent = account?.issued ?? [];
	const value = parseAmount(amount);

	const debt = useMemo(
		() =>
			received
				.filter((invoice) => invoice.status === "pending")
				.reduce((total, invoice) => total + invoice.amount, 0),
		[received],
	);

	const receivable = useMemo(
		() =>
			sent
				.filter((invoice) => invoice.status === "pending")
				.reduce((total, invoice) => total + invoice.amount, 0),
		[sent],
	);

	function closeSend() {
		setSending(false);
		clear();

		if (feedback?.kind === "success") {
			setTarget("");
			setAmount("");
			setReason("");
		}
	}

	const list = tab === "received" ? received : sent;

	return (
		<div className="flex h-full w-full flex-col gap-[.875rem] p-[1.25rem]">
			<div className="flex h-[8.5rem] flex-shrink-0 gap-[.875rem]">
				<Stat
					accent
					className="flex-1"
					label="Você está devendo"
					value={debt}
					icon={IconFileInvoice}
					footnote={
						debt > balance
							? "Saldo atual não cobre tudo"
							: "Seu saldo cobre todas as cobranças"
					}
				/>

				<Stat
					className="flex-1"
					label="Você tem a receber"
					value={receivable}
					icon={IconSend}
					footnote="Faturas que você emitiu e ainda não foram pagas"
				/>

				<Stat
					className="flex-1"
					label="Saldo disponível"
					value={balance}
					icon={IconWallet}
					footnote={account?.name}
				/>
			</div>

			<Card
				title="Faturas"
				icon={IconFileInvoice}
				className="min-h-0 flex-1"
				action={
					<div className="flex items-center gap-[.5rem]">
						<Segmented
							value={tab}
							onChange={setTab}
							className="h-[1.875rem]"
							options={[
								{ value: "received", label: "Recebidas" },
								{ value: "sent", label: "Enviadas" },
							]}
						/>

						<Button
							size="sm"
							variant="accent"
							icon={<IconSend stroke={2.5} className="size-[.75rem]" />}
							onClick={() => setSending(true)}
						>
							Enviar fatura
						</Button>
					</div>
				}
			>
				{list.length === 0 ? (
					<Empty
						icon={IconFileInvoice}
						label={
							tab === "received" ? "Nenhuma cobrança" : "Nenhuma fatura enviada"
						}
						hint={
							tab === "received"
								? "Cobranças de outros jogadores e impostos aparecem aqui"
								: "Use o botão acima para cobrar alguém"
						}
					/>
				) : (
					<div className="customScrollbar flex min-h-0 flex-1 flex-col gap-[.375rem] overflow-y-auto pr-[.25rem]">
						{list.map((invoice) => {
							const status = STATUS[invoice.status];
							const pending = invoice.status === "pending";

							return (
								<div
									key={invoice.id}
									className="row-surface flex flex-shrink-0 items-center gap-[.75rem] px-[.75rem] py-[.625rem]"
								>
									<span
										className={cn(
											"flex size-[2rem] flex-shrink-0 items-center justify-center rounded-[.25rem]",
											pending ? "bg-primaryColor/10" : "bg-white/[.04]",
										)}
									>
										{invoice.system ? (
											<IconBuildingBank
												stroke={2.5}
												className={cn(
													"size-[.9375rem]",
													pending ? "text-primaryColor" : "text-white/25",
												)}
											/>
										) : (
											<IconFileInvoice
												stroke={2.5}
												className={cn(
													"size-[.9375rem]",
													pending ? "text-primaryColor" : "text-white/25",
												)}
											/>
										)}
									</span>

									<div className="flex min-w-0 flex-1 flex-col">
										<span className="truncate font-black text-[.8125rem] text-ink leading-tight">
											{invoice.reason}
										</span>
										<span className="truncate font-semibold text-[.6875rem] text-ink-ghost leading-tight">
											{tab === "received"
												? `De ${invoice.issuer}`
												: `Para ${invoice.target}`}{" "}
											· {formatDateTime(invoice.date).date}
										</span>
									</div>

									<div className="flex w-[6rem] flex-shrink-0 flex-col items-end">
										<span className="font-black text-[.9375rem] text-ink leading-tight">
											{formatCurrency(invoice.amount)}
										</span>
										<span
											className={cn(
												"font-black text-[.625rem] uppercase",
												status.className,
											)}
										>
											{status.label}
										</span>
									</div>

									<div className="flex w-[6.5rem] flex-shrink-0 justify-end">
										{pending && tab === "received" && (
											<Button
												variant="accent"
												className="w-full"
												disabled={busy}
												onClick={() =>
													run("post:invoicePay", { invoice: invoice.id })
												}
											>
												Pagar
											</Button>
										)}

										{pending && tab === "sent" && !invoice.system && (
											<Button
												variant="danger"
												className="w-full"
												disabled={busy}
												onClick={() =>
													run("post:invoiceCancel", { invoice: invoice.id })
												}
											>
												Cancelar
											</Button>
										)}
									</div>
								</div>
							);
						})}
					</div>
				)}
			</Card>

			<Modal
				open={sending}
				title="Enviar uma fatura"
				subtitle="A cobrança cai na conta pessoal do passaporte"
				icon={IconSend}
				onClose={closeSend}
				feedback={feedback}
				footer={
					<>
						<Button size="lg" className="flex-1" onClick={closeSend}>
							Cancelar
						</Button>
						<Button
							size="lg"
							variant="accent"
							className="flex-1"
							disabled={
								busy ||
								value <= 0 ||
								target.length === 0 ||
								reason.trim().length < 3
							}
							onClick={() =>
								submit("post:invoice", {
									target,
									amount: value,
									reason: reason.trim(),
								})
							}
						>
							Enviar
						</Button>
					</>
				}
			>
				<Field
					label="Digite o passaporte"
					icon={IconId}
					placeholder="Ex: 123"
					inputMode="numeric"
					value={target}
					onChange={(event) => setTarget(event.target.value.replace(/\D/g, ""))}
				/>

				<Field
					label="Quanto você quer cobrar?"
					prefix="$"
					placeholder="0"
					inputMode="numeric"
					value={amount}
					onChange={(event) => setAmount(sanitizeAmount(event.target.value))}
				/>

				<Field
					label="Qual é o motivo da fatura?"
					placeholder="Ex: Serviço de reboque"
					maxLength={64}
					value={reason}
					onChange={(event) => setReason(event.target.value)}
				/>
			</Modal>
		</div>
	);
}
