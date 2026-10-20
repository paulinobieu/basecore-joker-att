import { useLoadoutItems } from "@app/hooks/useLoadoutItems";
import { useLoadout } from "@app/stores/Loadout";
import { formatMoney, pad } from "@app/utils/misc";
import {
	IconClipboardCheck,
	IconClipboardList,
	IconClipboardOff,
} from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Empty } from "@views/components/Empty";
import { SpinLoader } from "@views/components/SpinLoader";
import { useState } from "react";
import { useShallow } from "zustand/shallow";
import { LoadoutLine } from "./components/LoadoutLine";
import { RequisitionModal } from "./components/RequisitionModal";

export function Loadout() {
	const { list, amount, total } = useLoadoutItems();

	const { status, clearLoadout } = useLoadout(
		useShallow((state) => ({
			status: state.status,
			clearLoadout: state.clearLoadout,
		})),
	);

	const [confirmOpen, setConfirmOpen] = useState(false);

	return (
		<>
			<aside className="surface-panel flex h-full w-[24rem] flex-shrink-0 flex-col border-[#D9D9D91A] border-l border-solid">
				<header className="flex h-[3.25rem] flex-shrink-0 items-center gap-2 border-white/[.05] border-b border-solid px-[1rem]">
					<IconClipboardList
						stroke={2}
						className="size-[1rem] text-primaryColor"
					/>
					<h2 className="stencil text-[#EDEAE5] text-[.8125rem]">Requisição</h2>

					{list.length > 0 && (
						<>
							<span className="font-black text-[.6875rem] text-white/30 tabular-nums">
								{pad(amount)}
							</span>
							<Button
								size="sm"
								variant="ghost"
								className="ml-auto"
								onClick={clearLoadout}
							>
								Limpar
							</Button>
						</>
					)}
				</header>

				<div className="customScrollbar flex flex-1 flex-col gap-[.5rem] overflow-y-auto p-[.75rem]">
					{list.length === 0 ? (
						<Empty
							icon={IconClipboardOff}
							label="Requisição vazia"
							hint="Selecione o armamento para montar a retirada"
						/>
					) : (
						list.map((entry) => <LoadoutLine key={entry.item.id} {...entry} />)
					)}
				</div>

				<footer className="flex flex-shrink-0 flex-col gap-[.75rem] border-white/[.05] border-t border-solid p-[1rem]">
					<div className="flex flex-col">
						<span className="stencil text-[.625rem] text-white/35">
							Custo total
						</span>
						<span className="font-black text-[1.375rem] text-white tabular-nums leading-none">
							{formatMoney(total)}
						</span>
					</div>

					<Button
						size="lg"
						variant="accent"
						className="w-full"
						disabled={list.length === 0 || status === "sending"}
						icon={
							status === "sending" ? (
								<SpinLoader className="size-[.875rem]" />
							) : (
								<IconClipboardCheck
									stroke={2}
									className="relative z-10 size-[.9375rem] text-white"
								/>
							)
						}
						onClick={() => setConfirmOpen(true)}
					>
						{status === "sending" ? "Processando" : "Autorizar retirada"}
					</Button>
				</footer>
			</aside>

			<RequisitionModal
				visible={confirmOpen}
				list={list}
				total={total}
				onClose={() => setConfirmOpen(false)}
			/>
		</>
	);
}
