import { formatCurrency } from "@app/utils/format";
import { Detail } from "@views/components/Detail";

interface OrderSummaryProps {
	count: number;
	total: number;
	currencyPrefix: string;
	currencySuffix: string;
	currencySeparator: string;
	onClear: () => void;
	onConfirm: () => void;
}

export function OrderSummary({
	count,
	total,
	currencyPrefix,
	currencySuffix,
	currencySeparator,
	onClear,
	onConfirm,
}: OrderSummaryProps) {
	const empty = count === 0;

	return (
		<section className="order-summary">
			<h2>Seu pedido</h2>
			<div className="order-metrics">
				<div className="group">
					<Detail />
					<span>Itens</span>
					<strong>{count}</strong>
				</div>
				<div className="group">
					<Detail />
					<span>Total</span>
					<strong className="order-total">
						{formatCurrency(
							total,
							currencyPrefix,
							currencySuffix,
							currencySeparator,
						)}
					</strong>
				</div>
			</div>
			<div className="order-actions">
				<button
					type="button"
					className="clear-button"
					disabled={empty}
					onClick={onClear}
				>
					Limpar
				</button>
				<button
					type="button"
					className="confirm-button"
					disabled={empty}
					onClick={onConfirm}
				>
					Confirmar pedido
				</button>
			</div>
		</section>
	);
}
