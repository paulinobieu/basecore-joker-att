import type { TotemItem } from "@app/types/totem";
import { FALLBACK_IMAGE } from "@app/utils/fallbackImage";
import { formatCurrency } from "@app/utils/format";
import { IconMinus, IconPlus } from "@tabler/icons-react";
import { Detail } from "@views/components/Detail";
import { memo } from "react";

interface ProductCardProps {
	item: TotemItem;
	quantity: number;
	maxQuantity: number;
	currencyPrefix: string;
	currencySuffix: string;
	currencySeparator: string;
	onUpdate: (id: string, delta: number) => void;
}

function ProductCardComponent({
	item,
	quantity,
	maxQuantity,
	currencyPrefix,
	currencySuffix,
	currencySeparator,
	onUpdate,
}: ProductCardProps) {
	return (
		<article className="menu-item group">
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
					)}
				</p>
			</div>
			<div className="quantity-selector">
				<button
					type="button"
					aria-label={`Remover ${item.name}`}
					disabled={quantity === 0}
					onClick={() => onUpdate(item.id, -1)}
				>
					<IconMinus className="size-3" stroke={2} />
				</button>
				<strong>{quantity}</strong>
				<button
					type="button"
					aria-label={`Adicionar ${item.name}`}
					disabled={quantity >= maxQuantity}
					onClick={() => onUpdate(item.id, 1)}
				>
					<IconPlus className="size-3" stroke={2} />
				</button>
			</div>
		</article>
	);
}

export const ProductCard = memo(ProductCardComponent);
