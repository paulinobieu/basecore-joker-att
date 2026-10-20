import { fetchNui } from "@app/utils/fetchNui";
import { create } from "zustand";

interface Category {
	id: string;
	name: string;
}

interface Price {
	diamonds: number;
	cash: number;
}

interface Product {
	id: string;
	name: string;
	image: string;
	price: Price;
	category: Category;
}

interface ShopData {
	products: Product[];
	categories: Category[];
}

interface ShopStore {
	categories: Category[];
	products: Product[];
	selectedCategory: Category | null;
	selectedProduct: Product | null;
	getShopData: () => Promise<void>;
	buy: (product?: Product, paymentMethod?: string) => Promise<void>;
	setSelectedCategory: (category: Category) => void;
	setSelectedProduct: (product: Product | null) => void;
}

export const useShopStore = create<ShopStore>()((set, get) => ({
	categories: [],
	products: [],
	selectedCategory: null,
	selectedProduct: null,
	async getShopData() {
		const categories = [
				{ id: "todas", name: "Todas" },
				{ id: "aeronaves", name: "Aeronaves" },
				{ id: "barcos", name: "Barcos" },
				{ id: "caminhoes", name: "Caminhões" },
				{ id: "itens", name: "Itens" },
				{ id: "consumiveis", name: "Consumíveis" },
				{ id: "motos", name: "Motos" },
			],
			mockData: ShopData = {
				products: [
					{
						id: "heli_maverick",
						name: "Helicóptero Maverick",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 500, cash: 55250 },
						category: categories[1],
					},
					{
						id: "plane_luxor",
						name: "Jato Luxor Deluxe",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 5e3, cash: 0 },
						category: categories[1],
					},
					{
						id: "heli_buzzard",
						name: "Helicóptero Buzzard Attack",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 3500, cash: 0 },
						category: categories[1],
					},
					{
						id: "plane_dodo",
						name: "Hidroavião Dodo",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 1800, cash: 0 },
						category: categories[1],
					},
					{
						id: "heli_annihilator",
						name: "Helicóptero Annihilator Stealth",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 4200, cash: 0 },
						category: categories[1],
					},
					{
						id: "plane_titan",
						name: "Avião de Carga Titan",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 3e3, cash: 0 },
						category: categories[1],
					},
					{
						id: "yacht_adder",
						name: "Iate Adder Luxury",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 8e3, cash: 0 },
						category: categories[2],
					},
					{
						id: "speedboat_jetmax",
						name: "Lancha Jetmax Racing",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 1200, cash: 0 },
						category: categories[2],
					},
					{
						id: "submarine_kraken",
						name: "Submarino Kraken",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 2800, cash: 0 },
						category: categories[2],
					},
					{
						id: "boat_dinghy",
						name: "Bote Inflável Dinghy",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 450, cash: 0 },
						category: categories[2],
					},
					{
						id: "yacht_marquis",
						name: "Iate Marquis Executive",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 6500, cash: 0 },
						category: categories[2],
					},
					{
						id: "speedboat_seashark",
						name: "Jet Ski Seashark",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 800, cash: 0 },
						category: categories[2],
					},
					{
						id: "boat_toro",
						name: "Barco Pescador Toro",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 950, cash: 0 },
						category: categories[2],
					},
					{
						id: "truck_hauler",
						name: "Caminhão Hauler Custom",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 285e3 },
						category: categories[3],
					},
					{
						id: "truck_phantom",
						name: "Caminhão Phantom Wedge",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 1800, cash: 0 },
						category: categories[3],
					},
					{
						id: "truck_pounder",
						name: "Caminhão Pounder Custom",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 32e4 },
						category: categories[3],
					},
					{
						id: "truck_mule",
						name: "Caminhão Mule",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 95e3 },
						category: categories[3],
					},
					{
						id: "truck_terrorbyte",
						name: "Terrorbyte Command Center",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 3200, cash: 0 },
						category: categories[3],
					},
					{
						id: "truck_guardian",
						name: "Caminhão Guardian 6x6",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 45e4 },
						category: categories[3],
					},
					{
						id: "item_lockpick",
						name: "Kit de Gazuas Profissional",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 2500 },
						category: categories[4],
					},
					{
						id: "item_drill",
						name: "Furadeira Industrial",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 15e3 },
						category: categories[4],
					},
					{
						id: "item_hacking_device",
						name: "Dispositivo de Hacking",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 150, cash: 0 },
						category: categories[4],
					},
					{
						id: "item_armor_vest",
						name: "Colete à Prova de Balas",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 5e3 },
						category: categories[4],
					},
					{
						id: "item_binoculars",
						name: "Binóculos Táticos",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 3500 },
						category: categories[4],
					},
					{
						id: "item_radio",
						name: "Rádio Comunicador",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 1800 },
						category: categories[4],
					},
					{
						id: "item_gps",
						name: "GPS Avançado",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 4200 },
						category: categories[4],
					},
					{
						id: "item_flashlight",
						name: "Lanterna Tática LED",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 850 },
						category: categories[4],
					},
					{
						id: "item_parachute",
						name: "Paraquedas Esportivo",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 7500 },
						category: categories[4],
					},
					{
						id: "consumable_energy_drink",
						name: "Energético RedWood",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 25 },
						category: categories[5],
					},
					{
						id: "consumable_sandwich",
						name: "Sanduíche Gourmet",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 45 },
						category: categories[5],
					},
					{
						id: "consumable_coffee",
						name: "Café Premium",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 15 },
						category: categories[5],
					},
					{
						id: "consumable_protein_bar",
						name: "Barra de Proteína",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 35 },
						category: categories[5],
					},
					{
						id: "consumable_water_bottle",
						name: "Garrafa de Água",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 12 },
						category: categories[5],
					},
					{
						id: "consumable_pizza_slice",
						name: "Fatia de Pizza",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 28 },
						category: categories[5],
					},
					{
						id: "consumable_smoothie",
						name: "Smoothie Tropical",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 38 },
						category: categories[5],
					},
					{
						id: "bike_bati801",
						name: "Bati 801 Racing",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 15e4 },
						category: categories[6],
					},
					{
						id: "bike_akuma",
						name: "Akuma Street",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 95e3 },
						category: categories[6],
					},
					{
						id: "bike_hakuchou",
						name: "Hakuchou Drag",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 28e4 },
						category: categories[6],
					},
					{
						id: "bike_shotaro",
						name: "Shotaro Futuristic",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 2200, cash: 0 },
						category: categories[6],
					},
					{
						id: "bike_sanchez",
						name: "Sanchez Cross",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 45e3 },
						category: categories[6],
					},
					{
						id: "bike_fcr1000",
						name: "FCR 1000 Custom",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 18e4 },
						category: categories[6],
					},
					{
						id: "bike_daemon",
						name: "Daemon Chopper",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 0, cash: 78e3 },
						category: categories[6],
					},
					{
						id: "bike_oppressor",
						name: "Oppressor MK II",
						image: "https://via.placeholder.com/300x200",
						price: { diamonds: 3800, cash: 0 },
						category: categories[6],
					},
				],
				categories: categories,
			},
			result = await fetchNui<ShopData>({
				path: "get:shop:data",
				mockData: mockData,
			});
		result &&
			set({
				products: result.products,
				categories: result.categories,
				selectedCategory: result.categories[0],
			});
	},
	async buy(product, paymentMethod) {
		const { selectedProduct } = get();
		(!product && !selectedProduct) ||
			(console.log({
				product: product || selectedProduct,
				paymentMethod: paymentMethod,
			}),
			!(await fetchNui({
				path: "post:shop:buy",
				payload: { product: product || selectedProduct, paymentMethod },
				mockData: !0,
			}))) ||
			set({ selectedProduct: null });
	},
	setSelectedCategory(category) {
		set({ selectedCategory: category });
	},
	setSelectedProduct(product) {
		set({ selectedProduct: product });
	},
}));
