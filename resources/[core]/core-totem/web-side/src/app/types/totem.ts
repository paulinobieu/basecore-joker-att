export interface TotemItem {
	id: string;
	name: string;
	price: number;
	stock: number;
	image: string;
	defaultPrice: number;
}

export interface OpenPayload {
	totemId: string;
	banner: string;
	themeColor: string;
	isAdmin: boolean;
	useCoreGroups: boolean;
	items: TotemItem[];
	revenue: number;
	totalSales: number;
	currencyPrefix: string;
	currencySuffix: string;
	currencySeparator: string;
	priceMin: number;
	priceMax: number;
	maxStock: number;
	maxPurchasePerItem: number;
}

export interface UpdatePayload {
	items: TotemItem[];
	revenue: number;
	totalSales: number;
}

export interface OrderEntry {
	id: string;
	quantity: number;
}
