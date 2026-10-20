import type { ICartItem } from "@app/hooks/useCartItems";
import { useCart } from "@app/stores/Cart";
import { useNotify } from "@app/stores/Notify";
import { formatMoney } from "@app/utils/misc";
import { IconShoppingCart } from "@tabler/icons-react";
import { Modal } from "@views/components/Modal";
import { useShallow } from "zustand/shallow";

interface CheckoutModalProps {
	visible: boolean;
	items: ICartItem[];
	total: number;
	onClose(): void;
}

export function CheckoutModal({
	visible,
	items,
	total,
	onClose,
}: CheckoutModalProps) {
	const { status, checkout } = useCart(
		useShallow((state) => ({ status: state.status, checkout: state.checkout })),
	);

	const pushNotify = useNotify((state) => state.pushNotify);

	return (
		<Modal
			visible={visible}
			icon={IconShoppingCart}
			title="Finalizar compra"
			width="28rem"
			loading={status === "sending"}
			description="Confira os itens antes de confirmar."
			footerLabels={{ cancel: "Voltar", confirm: "Comprar" }}
			onClose={onClose}
			onConfirm={async () => {
				const result = await checkout();

				pushNotify(result.success ? "success" : "error", result.message);

				if (result.success) onClose();
			}}
		>
			<div className="customScrollbar flex max-h-[16rem] flex-col overflow-y-auto pr-1">
				{items.map((item) => (
					<div
						key={item.product.id}
						className="flex items-center justify-between gap-2 border-white/[.04] border-b border-solid py-[.4375rem] last:border-0"
					>
						<span className="truncate font-bold text-[.75rem] text-white/80">
							<span className="text-primaryColor">{item.amount}x</span>{" "}
							{item.product.name}
						</span>
						<span className="flex-shrink-0 font-black text-[.75rem] text-white">
							{formatMoney(item.total)}
						</span>
					</div>
				))}
			</div>

			<div className="flex items-center justify-between border-white/[.06] border-t border-solid pt-[.625rem]">
				<span className="font-black text-[.6875rem] text-white/45 uppercase">
					Total
				</span>
				<span className="font-black text-[1rem] text-primaryColor">
					{formatMoney(total)}
				</span>
			</div>
		</Modal>
	);
}
