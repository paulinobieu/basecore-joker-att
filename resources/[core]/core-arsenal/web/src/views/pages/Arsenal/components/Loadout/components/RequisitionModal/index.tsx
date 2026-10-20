import type { ILoadoutItem } from "@app/hooks/useLoadoutItems";
import { useLoadout } from "@app/stores/Loadout";
import { formatMoney } from "@app/utils/misc";
import { IconAlertTriangle, IconClipboardCheck } from "@tabler/icons-react";
import { Modal } from "@views/components/Modal";
import { useShallow } from "zustand/shallow";

interface RequisitionModalProps {
	visible: boolean;
	list: ILoadoutItem[];
	total: number;
	onClose(): void;
}

/**
 * Confirmacao da retirada. A mensagem de resultado nao aparece aqui: quem
 * avisa e o Notify do jogo, disparado pelo proprio client no `buyProducts`.
 * O modal so mostra que a retirada foi recusada, para o operador nao ficar
 * olhando para uma requisicao intacta sem entender o motivo.
 */
export function RequisitionModal({
	visible,
	list,
	total,
	onClose,
}: RequisitionModalProps) {
	const { status, denied, requisition } = useLoadout(
		useShallow((state) => ({
			status: state.status,
			denied: state.denied,
			requisition: state.requisition,
		})),
	);

	return (
		<Modal
			visible={visible}
			icon={IconClipboardCheck}
			title="Autorizar retirada"
			width="28rem"
			loading={status === "sending"}
			description="Confira o manifesto antes de liberar o armamento."
			footerLabels={{ cancel: "Voltar", confirm: "Autorizar" }}
			onClose={onClose}
			onConfirm={async () => {
				const approved = await requisition();

				if (approved) onClose();
			}}
		>
			<div className="customScrollbar flex max-h-[16rem] flex-col overflow-y-auto pr-1">
				{list.map((entry) => (
					<div
						key={entry.item.id}
						className="flex items-center justify-between gap-2 border-white/[.04] border-b border-solid py-[.4375rem] last:border-0"
					>
						<span className="truncate font-bold text-[.75rem] text-white/80">
							<span className="text-primaryColor tabular-nums">
								{entry.amount}x
							</span>{" "}
							{entry.item.name}
						</span>
						<span className="flex-shrink-0 font-black text-[.75rem] text-white tabular-nums">
							{formatMoney(entry.total)}
						</span>
					</div>
				))}
			</div>

			<div className="flex items-center justify-between border-white/[.06] border-t border-solid pt-[.625rem]">
				<span className="stencil text-[.6875rem] text-white/45">
					Custo total
				</span>
				<span className="font-black text-[1rem] text-primaryColor tabular-nums">
					{formatMoney(total)}
				</span>
			</div>

			{denied && (
				<div className="flex items-center gap-2 rounded-[.1875rem] border border-[#e24040]/30 border-solid bg-[#e24040]/10 px-[.625rem] py-[.5rem]">
					<IconAlertTriangle
						stroke={2.5}
						className="size-[.875rem] flex-shrink-0 text-[#e24040]"
					/>
					<span className="font-bold text-[#e24040] text-[.6875rem]">
						Retirada negada — a requisição continua montada.
					</span>
				</div>
			)}
		</Modal>
	);
}
