import {
	IconArrowsLeftRight,
	IconCoinBitcoin,
	IconFileInvoice,
	IconLayoutDashboard,
	IconMail,
	IconPigMoney,
	IconReceipt,
	IconScale,
} from "@tabler/icons-react";
import type { Icon } from "@tabler/icons-react";
import { IconPix } from "@views/assets/icons/Pix";

export const routes = {
	accounts: "accounts",
	dashboard: "dashboard",
	pix: "pix",
	transfer: "transfer",
	statement: "statement",
	cryptos: "cryptos",
	investments: "investments",
	invoices: "invoices",
	fines: "fines",
	invites: "invites",
};

export interface NavigationEntry {
	route: string;
	label: string;
	subtitle: string;
	icon: Icon;
}

export const navigation: NavigationEntry[] = [
	{
		route: routes.dashboard,
		label: "Dashboard",
		subtitle: "Saldo, carteira e movimentações",
		icon: IconLayoutDashboard,
	},
	{
		route: routes.pix,
		label: "PIX",
		subtitle: "Chaves e transferências instantâneas",
		icon: IconPix,
	},
	{
		route: routes.transfer,
		label: "Transferir",
		subtitle: "Envio de valores por passaporte",
		icon: IconArrowsLeftRight,
	},
	{
		route: routes.statement,
		label: "Extrato",
		subtitle: "Tudo que entrou e saiu desta conta",
		icon: IconReceipt,
	},
	{
		route: routes.cryptos,
		label: "Criptomoedas",
		subtitle: "Mercado em tempo real e negociação",
		icon: IconCoinBitcoin,
	},
	{
		route: routes.investments,
		label: "Investimentos",
		subtitle: "Aplicações disponíveis e rendimento",
		icon: IconPigMoney,
	},
	{
		route: routes.invoices,
		label: "Faturas",
		subtitle: "Cobranças recebidas e enviadas",
		icon: IconFileInvoice,
	},
	{
		route: routes.fines,
		label: "Multas",
		subtitle: "Infrações aplicadas a você",
		icon: IconScale,
	},
	{
		route: routes.invites,
		label: "Convites",
		subtitle: "Sociedades que te chamaram",
		icon: IconMail,
	},
];
