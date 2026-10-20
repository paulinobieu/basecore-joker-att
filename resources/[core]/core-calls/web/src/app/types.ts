export interface ThemeConfig {
	hex: string;
	rgb: string;
}

export interface KeyBindings {
	accept: string;
	decline: string;
	staff: string;
	finish: string;
}

export interface AppConfig {
	theme?: ThemeConfig;
	keys?: KeyBindings;
}

export interface Ticket {
	id: number;
	name: string;
	text: string;
	hour: string;
	createdAt: number;
}

export interface StaffProfile {
	id: number;
	name: string;
	role: string;
	total: number;
	positives: number;
	negatives: number;
	fast: number;
}

export interface StaffRanking {
	staff: number;
	name: string;
	role: string;
	total: number;
	positives: number;
	negatives: number;
	fast: number;
}

export interface PanelInitial {
	tickets: Ticket[];
	profile: StaffProfile;
	ranking: { allTime: StaffRanking[]; monthly: StaffRanking[] };
}

export interface IncomingPayload {
	id: number;
	name: string;
	text: string;
	time: number;
}

export interface FeedbackPayload {
	name: string;
	role: string;
}

export interface TicketActive {
	id: number;
	name: string;
}

export interface StaffMenuContext {
	id: number;
	name: string;
	text?: string;
}

export type Surface = "none" | "prompt" | "panel" | "feedback" | "staff";
