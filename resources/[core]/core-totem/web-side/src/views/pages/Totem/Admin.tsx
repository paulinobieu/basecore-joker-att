import type { OpenPayload, TotemItem } from "@app/types/totem";
import { fetchNui } from "@app/utils/fetchNui";
import { formatCurrency } from "@app/utils/format";
import { IconCash, IconPackage } from "@tabler/icons-react";
import { ActionModal } from "@views/components/ActionModal";
import { AdminProductCard } from "@views/components/AdminProductCard";
import { Banner } from "@views/components/Banner";
import { Detail } from "@views/components/Detail";
import { useEffect, useState } from "react";

type ModalMode = "price" | "stock" | null;

export function Admin({ config }: { config: OpenPayload }) {
	const [modalMode, setModalMode] = useState<ModalMode>(null);
	const [selectedItem, setSelectedItem] = useState<TotemItem | null>(null);
	const [inputValue, setInputValue] = useState("");

	useEffect(() => {
		if (!selectedItem || !modalMode) return;
		setInputValue(modalMode === "price" ? selectedItem.price.toString() : "");
	}, [modalMode, selectedItem]);

	const openModal = (mode: Exclude<ModalMode, null>, item: TotemItem) => {
		setSelectedItem(item);
		setModalMode(mode);
	};

	const closeModal = () => {
		setModalMode(null);
		setSelectedItem(null);
		setInputValue("");
	};

	const confirmModal = async () => {
		if (!selectedItem || !modalMode) return;
		const value = Number.parseInt(inputValue, 10);
		if (!Number.isFinite(value)) return;

		if (modalMode === "price") {
			const price = Math.min(config.priceMax, Math.max(config.priceMin, value));
			await fetchNui({
				path: "setPrice",
				payload: { itemId: selectedItem.id, price },
				mockData: { ok: true },
			});
		} else {
			const availableSpace = Math.max(0, config.maxStock - selectedItem.stock);
			const amount = Math.min(availableSpace, Math.max(0, value));
			if (amount === 0) return;
			await fetchNui({
				path: "restock",
				payload: { itemId: selectedItem.id, amount },
				mockData: { ok: true },
			});
		}
		closeModal();
	};

	const withdraw = async () => {
		if (config.revenue <= 0) return;
		await fetchNui({ path: "withdraw", payload: {}, mockData: { ok: true } });
	};

	const isPriceModal = modalMode === "price";
	const stockSpace = selectedItem
		? Math.max(0, config.maxStock - selectedItem.stock)
		: 0;

	return (
		<div className="flex h-full min-h-0 flex-col">
			<Banner image={config.banner} />
			<div className="admin-content">
				<section>
					<h2 className="section-heading">Visão geral</h2>
					<div className="admin-overview">
						<div className="admin-stat group">
							<Detail />
							<IconPackage className="size-4" stroke={2} />
							<span>
								Vendas<strong>{config.totalSales}</strong>
							</span>
						</div>
						<div className="admin-stat group">
							<Detail />
							<IconCash className="size-4" stroke={2} />
							<span>
								Receita
								<strong>
									{formatCurrency(
										config.revenue,
										config.currencyPrefix,
										config.currencySuffix,
										config.currencySeparator,
									)}
								</strong>
							</span>
						</div>
					</div>
				</section>
				<section className="admin-products">
					<h2 className="section-heading">Produtos do totem</h2>
					<div className="admin-list customScrollbar">
						{config.items.map((item) => (
							<AdminProductCard
								key={item.id}
								item={item}
								maxStock={config.maxStock}
								currencyPrefix={config.currencyPrefix}
								currencySuffix={config.currencySuffix}
								currencySeparator={config.currencySeparator}
								onEditPrice={(entry) => openModal("price", entry)}
								onRestock={(entry) => openModal("stock", entry)}
							/>
						))}
					</div>
				</section>
			</div>
			{!config.useCoreGroups ? (
				<footer className="admin-footer">
					<div>
						<span>Saldo disponível</span>
						<strong>
							{formatCurrency(
								config.revenue,
								config.currencyPrefix,
								config.currencySuffix,
								config.currencySeparator,
							)}
						</strong>
					</div>
					<button
						type="button"
						className="confirm-button"
						disabled={config.revenue <= 0}
						onClick={withdraw}
					>
						Retirar dinheiro
					</button>
				</footer>
			) : null}

			<ActionModal
				open={modalMode !== null && selectedItem !== null}
				title={isPriceModal ? "Alterar preço" : "Reabastecer estoque"}
				onClose={closeModal}
				description={
					selectedItem ? (
						<>
							{isPriceModal
								? "Defina o novo valor de "
								: "Informe quantas unidades deseja adicionar de "}
							<strong className="font-black text-primaryColor">
								{selectedItem.name}
							</strong>
							.
						</>
					) : null
				}
			>
				<div className="modal-metric">
					<span>{isPriceModal ? "Faixa permitida" : "Espaço disponível"}</span>
					<strong>
						{isPriceModal
							? `${formatCurrency(config.priceMin, config.currencyPrefix, config.currencySuffix, config.currencySeparator)} — ${formatCurrency(config.priceMax, config.currencyPrefix, config.currencySuffix, config.currencySeparator)}`
							: `${stockSpace} unidades`}
					</strong>
				</div>
				<label className="mt-4 block">
					<span className="mb-2 block text-[.55rem] font-black uppercase text-white/30">
						{isPriceModal ? "Novo preço" : "Quantidade"}
					</span>
					<input
						className="modal-input"
						type="number"
						min={isPriceModal ? config.priceMin : 1}
						max={isPriceModal ? config.priceMax : stockSpace}
						value={inputValue}
						placeholder={
							isPriceModal ? "Digite o valor" : `Máximo: ${stockSpace}`
						}
						onChange={(event) => setInputValue(event.target.value)}
						onKeyDown={(event) => {
							if (event.key === "Enter") void confirmModal();
						}}
					/>
				</label>
				<div className="mt-4 flex w-full items-center gap-2.5">
					<button type="button" className="modal-cancel" onClick={closeModal}>
						Cancelar
					</button>
					<button
						type="button"
						className="confirm-button"
						onClick={confirmModal}
					>
						Confirmar
					</button>
				</div>
			</ActionModal>
		</div>
	);
}
