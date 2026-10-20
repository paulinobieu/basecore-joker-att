import { formatCurrency, parseAmount, sanitizeAmount } from "@app/utils/format";
import { useModalAction } from "@app/hooks/useModalAction";
import { useBankStore } from "@app/stores/Bank";
import { IconKey, IconPlus, IconTrash, IconWallet } from "@tabler/icons-react";
import { IconPix } from "@views/assets/icons/Pix";
import { Button } from "@views/components/Button";
import { Card } from "@views/components/Card";
import { Empty } from "@views/components/Empty";
import { Field } from "@views/components/Field";
import { Modal } from "@views/components/Modal";
import { StatementList } from "@views/components/StatementList";
import { Stat } from "@views/components/Stat";
import { useState } from "react";
import { useShallow } from "zustand/shallow";

export function Pix() {
	const { account, loading, busy, run } = useBankStore(
		useShallow((state) => ({
			account: state.account,
			loading: state.loading,
			busy: state.busy,
			run: state.run,
		})),
	);

	const { feedback, submit, clear } = useModalAction();

	const [sending, setSending] = useState(false);
	const [registering, setRegistering] = useState(false);
	const [key, setKey] = useState("");
	const [target, setTarget] = useState("");
	const [amount, setAmount] = useState("");

	const balance = account?.balance ?? 0;
	const keys = account?.pix ?? [];
	const value = parseAmount(amount);

	function closeSend() {
		setSending(false);
		clear();

		if (feedback?.kind === "success") {
			setTarget("");
			setAmount("");
		}
	}

	function closeRegister() {
		setRegistering(false);
		clear();

		if (feedback?.kind === "success") setKey("");
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
					icon={<IconPix className="size-[.875rem]" />}
					onClick={() => setSending(true)}
				>
					Realizar transferência
				</Button>

				<Card
					title="Minhas chaves PIX"
					icon={IconKey}
					className="min-h-0 flex-1"
					action={
						<Button
							size="sm"
							icon={<IconPlus stroke={3} className="size-[.75rem]" />}
							onClick={() => setRegistering(true)}
						>
							Cadastrar
						</Button>
					}
				>
					{keys.length === 0 ? (
						<Empty
							icon={IconKey}
							label="Nenhuma chave"
							hint="Cadastre uma chave para receber PIX"
						/>
					) : (
						<div className="customScrollbar flex min-h-0 flex-1 flex-col gap-[.375rem] overflow-y-auto pr-[.25rem]">
							{keys.map((entry) => (
								<div
									key={entry.key}
									className="row-surface flex flex-shrink-0 items-center gap-[.625rem] px-[.75rem] py-[.625rem]"
								>
									<IconKey
										stroke={2.5}
										className="size-[.875rem] flex-shrink-0 text-primaryColor"
									/>

									<span className="min-w-0 flex-1 truncate font-black text-[.8125rem] text-ink tracking-[.05em]">
										{entry.key}
									</span>

									<button
										type="button"
										title="Excluir"
										disabled={busy}
										onClick={() => run("post:pixKeyRemove", { key: entry.key })}
										className="flex size-[1.5rem] flex-shrink-0 items-center justify-center rounded-[.25rem] text-white/25 transition-all duration-300 hover:bg-negative/10 hover:text-negative"
									>
										<IconTrash stroke={2.5} className="size-[.8125rem]" />
									</button>
								</div>
							))}
						</div>
					)}
				</Card>
			</div>

			<Card
				title="Últimas transações PIX"
				icon={IconPix}
				className="min-w-0 flex-1"
			>
				<StatementList
					movements={account?.pixLog ?? []}
					loading={loading}
					emptyHint="Envios e recebimentos por chave aparecem aqui"
				/>
			</Card>

			<Modal
				open={sending}
				title="Realizar transferência"
				subtitle="Envio instantâneo por chave PIX"
				icon={IconPix}
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
								value > balance ||
								target.trim().length < 3
							}
							onClick={() =>
								submit("post:pix", { key: target.trim(), amount: value })
							}
						>
							Confirmar
						</Button>
					</>
				}
			>
				<Field
					label="Digite a chave"
					icon={IconKey}
					placeholder="A chave que te passaram"
					value={target}
					onChange={(event) => setTarget(event.target.value)}
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
			</Modal>

			<Modal
				open={registering}
				title="Cadastrar chave"
				subtitle="Escolha uma chave livre e fácil de ditar"
				icon={IconKey}
				onClose={closeRegister}
				feedback={feedback}
				footer={
					<>
						<Button size="lg" className="flex-1" onClick={closeRegister}>
							Cancelar
						</Button>
						<Button
							size="lg"
							variant="accent"
							className="flex-1"
							disabled={busy || key.trim().length < 3}
							onClick={() => submit("post:pixKey", { key: key.trim() })}
						>
							Cadastrar
						</Button>
					</>
				}
			>
				<Field
					label="Sua chave"
					icon={IconKey}
					placeholder="Ex: rogerio.canogrosso"
					maxLength={32}
					value={key}
					onChange={(event) => setKey(event.target.value)}
					hint="Letras, números, ponto e traço. Precisa não existir no banco."
				/>
			</Modal>
		</div>
	);
}
