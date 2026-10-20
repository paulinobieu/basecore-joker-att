import { formatDateTime } from "@app/utils/format";
import { useModalAction } from "@app/hooks/useModalAction";
import { useBankStore } from "@app/stores/Bank";
import {
	IconBriefcase,
	IconMail,
	IconUserPlus,
	IconUsers,
	IconX,
} from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Card } from "@views/components/Card";
import { Empty } from "@views/components/Empty";
import { Field } from "@views/components/Field";
import { Modal } from "@views/components/Modal";
import { useState } from "react";
import { useShallow } from "zustand/shallow";

export function Invites() {
	const { account, invites, busy, run } = useBankStore(
		useShallow((state) => ({
			account: state.account,
			invites: state.invites,
			busy: state.busy,
			run: state.run,
		})),
	);

	const { feedback, submit, clear } = useModalAction();

	const [inviting, setInviting] = useState(false);
	const [target, setTarget] = useState("");

	const members = account?.members ?? [];
	const isBusiness = account?.business ?? false;
	const isOwner = account?.owner ?? false;

	function closeInvite() {
		setInviting(false);
		clear();

		if (feedback?.kind === "success") setTarget("");
	}

	return (
		<div className="flex h-full w-full gap-[.875rem] p-[1.25rem]">
			<Card
				title="Convites recebidos"
				icon={IconMail}
				className="min-w-0 flex-1"
			>
				{invites.length === 0 ? (
					<Empty
						icon={IconMail}
						label="Nenhum convite"
						hint="Sociedades que te chamarem aparecem aqui"
					/>
				) : (
					<div className="customScrollbar flex min-h-0 flex-1 flex-col gap-[.375rem] overflow-y-auto pr-[.25rem]">
						{invites.map((invite) => (
							<div
								key={invite.account}
								className="row-surface flex flex-shrink-0 items-center gap-[.75rem] px-[.75rem] py-[.625rem]"
							>
								<span className="flex size-[2rem] flex-shrink-0 items-center justify-center rounded-[.25rem] bg-primaryColor/10">
									<IconBriefcase
										stroke={2.5}
										className="size-[.9375rem] text-primaryColor"
									/>
								</span>

								<div className="flex min-w-0 flex-1 flex-col">
									<span className="truncate font-black text-[.8125rem] text-ink leading-tight">
										{invite.name}
									</span>
									<span className="truncate font-semibold text-[.6875rem] text-ink-ghost leading-tight">
										{invite.owner} · {formatDateTime(invite.date).date}
									</span>
								</div>

								<div className="flex flex-shrink-0 gap-[.375rem]">
									<Button
										disabled={busy}
										onClick={() =>
											run("post:inviteAnswer", {
												account: invite.account,
												accept: false,
											})
										}
									>
										Recusar
									</Button>
									<Button
										variant="accent"
										disabled={busy}
										onClick={() =>
											run("post:inviteAnswer", {
												account: invite.account,
												accept: true,
											})
										}
									>
										Aceitar
									</Button>
								</div>
							</div>
						))}
					</div>
				)}
			</Card>

			<Card
				title="Sócios da conta"
				icon={IconUsers}
				className="w-[30rem] flex-shrink-0"
				action={
					isBusiness &&
					isOwner && (
						<Button
							size="sm"
							variant="accent"
							icon={<IconUserPlus stroke={2.5} className="size-[.75rem]" />}
							onClick={() => setInviting(true)}
						>
							Convidar
						</Button>
					)
				}
			>
				{!isBusiness ? (
					<Empty
						icon={IconUsers}
						label="Conta pessoal"
						hint="Só empresas têm sócios. Abra uma na tela de contas."
					/>
				) : (
					<div className="customScrollbar flex min-h-0 flex-1 flex-col gap-[.375rem] overflow-y-auto pr-[.25rem]">
						{members.map((member) => (
							<div
								key={member.passport}
								className="row-surface flex flex-shrink-0 items-center gap-[.75rem] px-[.75rem] py-[.625rem]"
							>
								<div className="flex min-w-0 flex-1 flex-col">
									<span className="truncate font-black text-[.8125rem] text-ink leading-tight">
										{member.name}
									</span>
									<span className="font-semibold text-[.6875rem] text-ink-ghost leading-tight">
										#{member.passport} · {member.owner ? "Dono" : "Sócio"}
									</span>
								</div>

								{isOwner && !member.owner && (
									<button
										type="button"
										title="Remover"
										disabled={busy}
										onClick={() =>
											run("post:memberRemove", { target: member.passport })
										}
										className="flex size-[1.75rem] flex-shrink-0 items-center justify-center rounded-[.25rem] text-white/25 transition-all duration-300 hover:bg-negative/10 hover:text-negative"
									>
										<IconX stroke={2.5} className="size-[.875rem]" />
									</button>
								)}
							</div>
						))}
					</div>
				)}
			</Card>

			<Modal
				open={inviting}
				title="Convidar sócio"
				subtitle="O convidado precisa aceitar para entrar na empresa"
				icon={IconUserPlus}
				onClose={closeInvite}
				feedback={feedback}
				footer={
					<>
						<Button size="lg" className="flex-1" onClick={closeInvite}>
							Cancelar
						</Button>
						<Button
							size="lg"
							variant="accent"
							className="flex-1"
							disabled={busy || target.length === 0}
							onClick={() => submit("post:invite", { target })}
						>
							Convidar
						</Button>
					</>
				}
			>
				<Field
					label="Passaporte do convidado"
					placeholder="Ex: 123"
					inputMode="numeric"
					value={target}
					onChange={(event) => setTarget(event.target.value.replace(/\D/g, ""))}
				/>
			</Modal>
		</div>
	);
}
