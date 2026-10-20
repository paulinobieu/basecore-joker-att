import { useCartItems } from "@app/hooks/useCartItems";
import { useCart } from "@app/stores/Cart";
import { formatMoney } from "@app/utils/misc";
import { IconShoppingCart, IconShoppingCartOff } from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Empty } from "@views/components/Empty";
import { SpinLoader } from "@views/components/SpinLoader";
import { useState } from "react";
import { useShallow } from "zustand/shallow";
import { CartLine } from "./components/CartLine";
import { CheckoutModal } from "./components/CheckoutModal";

export function Cart() {
	const { items, total } = useCartItems();

	const { status, clearCart } = useCart(
		useShallow((state) => ({
			status: state.status,
			clearCart: state.clearCart,
		})),
	);

	const [confirmOpen, setConfirmOpen] = useState(false);

	return (
		<>
			<aside className="flex h-full w-[24rem] flex-shrink-0 flex-col border-[#D9D9D91A] border-l border-solid">
				<header className="flex h-[3.25rem] flex-shrink-0 items-center gap-2 border-white/[.05] border-b border-solid px-[1rem]">
					<IconShoppingCart
						stroke={2}
						className="size-[1rem] text-primaryColor"
					/>
					<h2 className="font-black text-[#EDEAE5] text-[.8125rem] uppercase">
						Seu carrinho
					</h2>
					{items.length > 0 && (
						<Button
							size="sm"
							variant="ghost"
							className="ml-auto"
							onClick={clearCart}
						>
							Limpar carrinho
						</Button>
					)}
				</header>

				<div className="customScrollbar flex flex-1 flex-col gap-[.5rem] overflow-y-auto p-[.75rem]">
					{items.length === 0 ? (
						<Empty
							icon={IconShoppingCartOff}
							label="Carrinho vazio"
							hint="Adicione produtos para finalizar a compra"
						/>
					) : (
						items.map((item) => <CartLine key={item.product.id} {...item} />)
					)}
				</div>

				<footer className="flex flex-shrink-0 flex-col gap-[.75rem] border-white/[.05] border-t border-solid p-[1rem]">
					<div className="flex flex-col">
						<span className="font-black text-[.625rem] text-white/35 uppercase">
							Valor total
						</span>
						<span className="font-black text-[1.375rem] text-white leading-none">
							{formatMoney(total)}
						</span>
					</div>

					<Button
						size="lg"
						variant="accent"
						className="w-full"
						disabled={items.length === 0 || status === "sending"}
						icon={
							status === "sending" ? (
								<SpinLoader className="size-[.875rem]" />
							) : (
								<IconShoppingCart
									stroke={2}
									className="relative z-10 size-[.9375rem] text-white"
								/>
							)
						}
						onClick={() => setConfirmOpen(true)}
					>
						{status === "sending" ? "Processando" : "Finalizar compra"}
					</Button>
				</footer>
			</aside>

			<CheckoutModal
				visible={confirmOpen}
				items={items}
				total={total}
				onClose={() => setConfirmOpen(false)}
			/>
		</>
	);
}
