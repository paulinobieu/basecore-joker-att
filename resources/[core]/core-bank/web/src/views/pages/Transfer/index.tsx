import { useModalAction } from "@app/hooks/useModalAction";
import { useBankStore } from "@app/stores/Bank";
import { formatCurrency, parseAmount, sanitizeAmount } from "@app/utils/format";
import { IconArrowsLeftRight, IconId, IconWallet } from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Card } from "@views/components/Card";
import { Field } from "@views/components/Field";
import { Modal } from "@views/components/Modal";
import { StatementList } from "@views/components/StatementList";
import { Stat } from "@views/components/Stat";
import { useState } from "react";
import { useShallow } from "zustand/shallow";

export function Transfer() {
	const { account, loading, busy } = useBankStore(
		useShallow((state) => ({
			account: state.account,
			loading: state.loading,
			busy: state.busy,
		})),
	);

	const { feedback, submit, clear } = useModalAction();

	const [sending, setSending] = useState(false);
	const [target, setTarget] = useState("");
	const [amount, setAmount] = useState("");

	const balance = account?.balance ?? 0;
	const value = parseAmount(amount);
	const remaining = balance - value;
	const ready = value > 0 && value <= balance && target.length > 0;

	function close() {
		setSending(false);
		clear();

		if (feedback?.kind === "success") {
			setTarget("");
			setAmount("");
		}
	}

	return (
		<div className="flex h-full w-full gap-[.875rem] p-[1.25rem]">
			<div className="flex w-[26rem] flex-shrink-0 flex-col gap-[.875rem]">
				<Stat
					accent
					className="h-[8.5rem] flex-shrink-0"
					label="Saldo disponível"
					value={balance}
					icon={IconWallet}
					footnote={account?.name}
				/>

				<Button
					size="lg"
					variant="accent"
					className="w-full flex-shrink-0"
					icon={<IconArrowsLeftRight stroke={2.5} className="size-[.875rem]" />}
					onClick={() => setSending(true)}
				>
					Realizar transferência
				</Button>

				<Card title="Como funciona" icon={IconId} className="min-h-0 flex-1">
					<p className="font-semibold text-[.75rem] text-ink-faint leading-relaxed">
						A transferência vai direto para a conta pessoal do passaporte
						informado. O valor sai na hora e aparece no extrato dos dois lados.
					</p>

					<p className="mt-[.75rem] font-semibold text-[.75rem] text-ink-ghost leading-relaxed">
						Para enviar a uma empresa, ou a quem só te passou uma chave, use a
						aba PIX.
					</p>
				</Card>
			</div>

			<Card
				title="Transferências desta conta"
				icon={IconArrowsLeftRight}
				className="min-w-0 flex-1"
			>
				<StatementList
					movements={account?.transfers ?? []}
					loading={loading}
					emptyHint="Nada enviado ou recebido por passaporte ainda"
				/>
			</Card>

			<Modal
				open={sending}
				title="Realizar transferência"
				subtitle="Envio direto para o passaporte"
				icon={IconArrowsLeftRight}
				onClose={close}
				feedback={feedback}
				footer={
					<>
						<Button size="lg" className="flex-1" onClick={close}>
							Cancelar
						</Button>
						<Button
							size="lg"
							variant="accent"
							className="flex-1"
							disabled={busy || !ready}
							onClick={() => submit("post:transfer", { target, amount: value })}
						>
							Confirmar
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
					label="Quanto você quer transferir?"
					prefix="$"
					placeholder="0"
					inputMode="numeric"
					value={amount}
					onChange={(event) => setAmount(sanitizeAmount(event.target.value))}
					hint={`Disponível: ${formatCurrency(balance)}`}
				/>

				{value > 0 && (
					<div className="row-surface flex items-center justify-between p-[.75rem]">
						<span className="font-semibold text-[.75rem] text-ink-faint">
							Depois da transferência
						</span>
						<span
							className={`font-black text-[.75rem] ${remaining < 0 ? "text-negative" : "text-positive"}`}
						>
							{formatCurrency(Math.max(remaining, 0))}
						</span>
					</div>
				)}
			</Modal>
		</div>
	);
}
