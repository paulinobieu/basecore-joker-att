export interface MenuItem {
	id: string;
	title?: string;
	icon?: string;
	image?: string;
	items?: MenuItem[];
	triggerArgs?: string[];
	trigger?: string;
	server?: boolean;
}

export interface RadialMenuProps {
	menuItems: MenuItem[];
	isNight?: boolean;
	size?: number | string;
	onAction: (item: MenuItem) => void;
	onClose: () => void;
}

export interface NuiMessage {
	state: "show" | "destroy";
	data?: MenuItem[];
	isNight?: boolean;
}
