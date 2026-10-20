import { formatCurrency } from "@app/utils/format";
import { useModalAction } from "@app/hooks/useModalAction";
import { routes } from "@app/router/routes";
import { useBankStore } from "@app/stores/Bank";
import { useVisibilityStore } from "@app/stores/Visibility";
import {
	IconBriefcase,
	IconBuildingBank,
	IconChevronRight,
	IconPlus,
	IconUser,
	IconX,
} from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Field } from "@views/components/Field";
import { Hexagon } from "@views/components/Hexagon";
import { Modal } from "@views/components/Modal";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useShallow } from "zustand/shallow";

export function Accounts() {
	const navigate = useNavigate();
	const fetchHideFrame = useVisibilityStore((state) => state.fetchHideFrame);

	const { accounts, busy, select } = useBankStore(
		useShallow((state) => ({
			accounts: state.accounts,
			busy: state.busy,
			select: state.select,
		})),
	);

	const { feedback, submit, clear } = useModalAction();

	const [creating, setCreating] = useState(false);
	const [name, setName] = useState("");

	async function open(accountId: number) {
		await select(accountId);
		navigate(`/${routes.dashboard}`);
	}

	function closeBusiness() {
		setCreating(false);
		clear();

		if (feedback?.kind === "success") setName("");
	}

	return (
		<div className="flex h-full w-full flex-col p-[1.5rem]">
			<button
				type="button"
				title="Fechar"
				onClick={fetchHideFrame}
				className="absolute top-[1rem] right-[1rem] flex size-[2rem] items-center justify-center rounded-[.25rem] text-white/25 transition-all duration-300 hover:bg-white/[.05] hover:text-white"
			>
				<IconX stroke={2.5} className="size-[1rem]" />
			</button>

			<div className="flex flex-col items-center">
				<div className="relative flex size-[4.125rem] items-center justify-center">
					<IconBuildingBank
						stroke={2}
						className="relative z-10 size-[1.5rem] text-white"
					/>
					<Hexagon active />
				</div>

				<h1 className="mt-[.75rem] font-black text-[1.125rem] text-ink uppercase tracking-wide">
					Core Bank
				</h1>
				<p className="mt-[.125rem] font-semibold text-[.75rem] text-ink-ghost">
					Escolha a conta que vai movimentar
				</p>
			</div>

			<div className="customScrollbar mt-[1.5rem] flex min-h-0 flex-1 flex-col gap-[.5rem] overflow-y-auto pr-[.25rem]">
				{accounts.map((account) => (
					<button
						key={account.id}
						type="button"
						onClick={() => open(account.id)}
						className="group row-surface flex flex-shrink-0 items-center gap-[.75rem] p-[.75rem] text-left"
					>
						<span className="flex size-[2.5rem] flex-shrink-0 items-center justify-center rounded-[.25rem] bg-white/[.04]">
							{account.business ? (
								<IconBriefcase
									stroke={2.5}
									className="size-[1.125rem] text-primaryColor"
								/>
							) : (
								<IconUser
									stroke={2.5}
									className="size-[1.125rem] text-primaryColor"
								/>
							)}
						</span>

						<div className="flex min-w-0 flex-1 flex-col">
							<span className="truncate font-black text-[.8125rem] text-ink leading-tight">
								{account.name}
							</span>
							<span className="font-semibold text-[.6875rem] text-ink-ghost leading-tight">
								{account.business
									? `Empresa · ${account.members} ${account.members === 1 ? "sócio" : "sócios"}`
									: "Conta pessoal"}
							</span>
						</div>

						<div className="flex flex-shrink-0 items-center gap-[.5rem]">
							<span className="font-black text-[.8125rem] text-ink-faint">
								{formatCurrency(account.balance)}
							</span>
							<IconChevronRight
								stroke={2.5}
								className="size-[.875rem] text-white/20 transition-all duration-300 group-hover:translate-x-[.125rem] group-hover:text-primaryColor"
							/>
						</div>
					</button>
				))}
			</div>

			<Button
				size="lg"
				variant="accent"
				className="mt-[1rem] w-full flex-shrink-0"
				icon={<IconPlus stroke={3} className="size-[.875rem]" />}
				onClick={() => setCreating(true)}
			>
				Abrir empresa
			</Button>

			<Modal
				open={creating}
				title="Abrir empresa"
				subtitle="Uma conta separada, com sócios e saldo próprio"
				icon={IconBriefcase}
				onClose={closeBusiness}
				feedback={feedback}
				footer={
					<>
						<Button size="lg" className="flex-1" onClick={closeBusiness}>
							Cancelar
						</Button>
						<Button
							size="lg"
							variant="accent"
							className="flex-1"
							disabled={busy || name.trim().length < 3}
							onClick={() => submit("post:business", { name: name.trim() })}
						>
							Abrir
						</Button>
					</>
				}
			>
				<Field
					label="Nome da empresa"
					placeholder="Ex: Canogrosso Transportes"
					maxLength={32}
					value={name}
					onChange={(event) => setName(event.target.value)}
					hint="O nome aparece para quem receber suas cobranças"
				/>
			</Modal>
		</div>
	);
}
