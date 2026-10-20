import type {
	AppConfig,
	FeedbackPayload,
	IncomingPayload,
	KeyBindings,
	PanelInitial,
	StaffMenuContext,
	Surface,
	ThemeConfig,
	Ticket,
	TicketActive,
} from "@app/types";
import { create } from "zustand";

interface CallsStore {
	theme: ThemeConfig;
	keys: KeyBindings;

	surface: Surface;
	initial: PanelInitial | null;
	tickets: Ticket[];
	feedback: FeedbackPayload | null;
	staffMenu: StaffMenuContext | null;

	incoming: IncomingPayload | null;
	ticketActive: TicketActive | null;
}

interface CallsActions {
	setConfig: (cfg: AppConfig) => void;
	applyTheme: (theme: ThemeConfig) => void;

	openPrompt: () => void;
	openPanel: (initial: PanelInitial) => void;
	openFeedback: (info: FeedbackPayload) => void;
	openStaffMenu: (ctx: StaffMenuContext) => void;
	closeSurface: () => void;

	setIncoming: (incoming: IncomingPayload | null) => void;
	setTickets: (tickets: Ticket[]) => void;
	setTicketActive: (info: TicketActive | null) => void;
}

const DEFAULT_KEYS: KeyBindings = {
	accept: "Y",
	decline: "U",
	staff: "F2",
	finish: "F7",
};

const hexToRgb = (hex: string): string => {
	const cleaned = hex.replace("#", "");
	if (cleaned.length !== 6) return "1, 67, 187";
	const r = Number.parseInt(cleaned.slice(0, 2), 16);
	const g = Number.parseInt(cleaned.slice(2, 4), 16);
	const b = Number.parseInt(cleaned.slice(4, 6), 16);
	return `${r}, ${g}, ${b}`;
};

export const useCallsStore = create<CallsStore & CallsActions>()((set) => ({
	theme: { hex: "#0143bb", rgb: "1, 67, 187" },
	keys: DEFAULT_KEYS,

	surface: "none",
	initial: null,
	tickets: [],
	feedback: null,
	staffMenu: null,

	incoming: null,
	ticketActive: null,

	setConfig: (cfg) =>
		set((state) => ({
			theme: cfg.theme ?? state.theme,
			keys: cfg.keys ?? state.keys,
		})),

	applyTheme: (theme) => {
		const root = document.documentElement;
		const rgb = theme.rgb || hexToRgb(theme.hex);
		root.style.setProperty("--primaryColor", rgb);
		root.style.setProperty("--primary", theme.hex);
		root.style.setProperty("--primary-rgb", rgb);
	},

	openPrompt: () => set({ surface: "prompt" }),
	openPanel: (initial) =>
		set({ surface: "panel", initial, tickets: initial.tickets }),
	openFeedback: (feedback) => set({ surface: "feedback", feedback }),
	openStaffMenu: (staffMenu) => set({ surface: "staff", staffMenu }),
	closeSurface: () =>
		set({
			surface: "none",
			initial: null,
			feedback: null,
			staffMenu: null,
		}),

	setIncoming: (incoming) => set({ incoming }),
	setTickets: (tickets) => set({ tickets }),
	setTicketActive: (ticketActive) => set({ ticketActive }),
}));
