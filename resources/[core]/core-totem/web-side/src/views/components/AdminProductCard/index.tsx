import type { TotemItem } from "@app/types/totem";
import { FALLBACK_IMAGE } from "@app/utils/fallbackImage";
import { formatCurrency } from "@app/utils/format";
import { IconPencil, IconPlus } from "@tabler/icons-react";
import { Detail } from "@views/components/Detail";

interface AdminProductCardProps {
	item: TotemItem;
	maxStock: number;
	currencyPrefix: string;
	currencySuffix: string;
	currencySeparator: string;
	onEditPrice: (item: TotemItem) => void;
	onRestock: (item: TotemItem) => void;
}

export function AdminProductCard({
	item,
	maxStock,
	currencyPrefix,
	currencySuffix,
	currencySeparator,
	onEditPrice,
	onRestock,
}: AdminProductCardProps) {
	return (
		<article className="menu-item admin-menu-item group">
			<Detail />
			<div className="menu-item-image">
				<img
					src={item.image}
					alt={item.name}
					onError={(event) => {
						event.currentTarget.src = FALLBACK_IMAGE;
					}}
				/>
			</div>
			<div className="menu-item-info">
				<h2>{item.name}</h2>
				<p>
					{formatCurrency(
						item.price,
						currencyPrefix,
						currencySuffix,
						currencySeparator,
					)}{" "}
					· {item.stock}/{maxStock} em estoque
				</p>
			</div>
			<div className="admin-item-actions">
				<button
					type="button"
					aria-label={`Editar preço de ${item.name}`}
					onClick={() => onEditPrice(item)}
				>
					<IconPencil className="size-3.5" stroke={2} />
				</button>
				<button
					type="button"
					aria-label={`Reabastecer ${item.name}`}
					disabled={item.stock >= maxStock}
					onClick={() => onRestock(item)}
				>
					<IconPlus className="size-3.5" stroke={2} />
				</button>
			</div>
		</article>
	);
}
