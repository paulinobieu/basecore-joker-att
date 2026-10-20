import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { create } from "zustand";

interface OptionItem {
	Label: string;
	Value: string;
}

interface RowBase {
	Mode: string;
	Placeholder: string;
	Value?: string | number;
	Required?: boolean;
	Save?: boolean;
}

export interface RowText extends RowBase {
	Mode: "text" | "number" | "password";
}
export interface RowArea extends RowBase {
	Mode: "area";
}
export interface RowSlider extends RowBase {
	Mode: "slider";
	Min: number;
	Max: number;
	Value: number;
}
export interface RowOptions extends RowBase {
	Mode: "options";
	Options: OptionItem[];
}
export interface RowButton extends RowBase {
	Mode: "button";
	Event?: string;
	Params?: unknown;
}

export type Row = RowText | RowArea | RowSlider | RowOptions | RowButton;

export interface OpenPayload {
	Rows: Row[];
	Title?: string;
	Subtitle?: string;
	HideCancel?: boolean;
	Theme?: string;
}

function stripNonDigits(v: unknown): string {
	return v?.toString().replace(/\D/g, "") ?? "";
}

function normalizeOptions(raw: unknown[]): OptionItem[] {
	return raw.map((o) => {
		if (typeof o === "string") return { Label: o, Value: o };
		if (o && typeof o === "object" && "Label" in o && "Value" in o)
			return { Label: (o as OptionItem).Label, Value: (o as OptionItem).Value };
		return { Label: "", Value: "" };
	});
}

function parseRows(rows: Row[]): Row[] {
	return rows.map((r) => {
		let value = r.Value ?? "";

		if (r.Mode === "number" && typeof value === "string") {
			const n = parseInt(stripNonDigits(value));
			value = isNaN(n) ? "" : n;
		}

		if (r.Mode === "slider") {
			const s = r as RowSlider;
			const min = typeof s.Min === "number" ? s.Min : 0;
			const max = typeof s.Max === "number" ? s.Max : 100;
			let v = typeof value === "string" ? parseFloat(value) : typeof value === "number" ? value : 0;
			if (isNaN(v)) v = 0;
			v = Math.max(min, Math.min(max, v));
			return { ...r, Min: min, Max: max, Value: v };
		}

		if (r.Mode === "options" && r.Options) {
			return { ...r, Options: normalizeOptions(r.Options as unknown[]), Value: value };
		}

		if (r.Mode === "button") return { ...r };

		return { ...r, Value: value };
	}) as Row[];
}

interface KeyboardState {
	visible: boolean;
	closing: boolean;
	rows: Row[];
	title: string;
	subtitle: string;
	hideCancel: boolean;
	showErrors: boolean;
	copiedIdx: Record<number, boolean>;
}

interface KeyboardActions {
	open: (data: OpenPayload) => void;
	close: () => void;
	setClosing: (v: boolean) => void;
	setVisible: (v: boolean) => void;
	updateRow: (index: number, value: string | number) => void;
	setShowErrors: (v: boolean) => void;
	setCopied: (index: number) => void;
	submit: () => void;
	handleButton: (row: RowButton) => void;
	reset: () => void;
}

export const useKeyboardStore = create<KeyboardState & KeyboardActions>()(
	(set, get) => ({
		visible: isEnvBrowser(),
		closing: false,
		rows: [],
		title: "",
		subtitle: "",
		hideCancel: false,
		showErrors: false,
		copiedIdx: {},

		open: (data) => {
			set({
				showErrors: false,
				title: data.Title || "Formulário",
				subtitle: data.Subtitle || "Preencha os campos abaixo",
				hideCancel: data.HideCancel || false,
				rows: data.Rows ? parseRows(data.Rows) : [],
				closing: false,
				visible: true,
				copiedIdx: {},
			});
		},

		close: () => {
			const { closing } = get();
			if (closing) return;
			set({ closing: true });
			fetchNui({ path: "Close" });
			setTimeout(() => {
				set({ closing: false, visible: false, rows: [] });
			}, 300);
		},

		setClosing: (v) => set({ closing: v }),
		setVisible: (v) => set({ visible: v }),

		updateRow: (index, value) => {
			const { rows } = get();
			set({ rows: rows.map((r, i) => (i === index ? { ...r, Value: value } : r)) });
		},

		setShowErrors: (v) => set({ showErrors: v }),

		setCopied: (index) => {
			set((state) => ({ copiedIdx: { ...state.copiedIdx, [index]: true } }));
			setTimeout(() => {
				set((state) => {
					const next = { ...state.copiedIdx };
					delete next[index];
					return { copiedIdx: next };
				});
			}, 1500);
		},

		submit: () => {
			const { rows } = get();

			const hasError = rows.some((r) => {
				if (r.Mode === "button") return false;
				if (r.Required && !r.Value) return true;
				if (r.Mode === "number") {
					const n = parseInt(stripNonDigits(r.Value));
					if (isNaN(n) || n <= 0) return true;
				}
				return false;
			});

			if (hasError) {
				set({ showErrors: true });
				return;
			}

			const inputs = rows
				.map((r) => {
					if (r.Mode === "button") return null;
					if ((r.Mode === "number" || r.Mode === "slider") && typeof r.Value !== "number") {
						const n = parseInt(stripNonDigits(r.Value));
						return isNaN(n) ? "" : n;
					}
					return r.Value ?? "";
				})
				.filter((v) => v !== null);

			fetchNui({ path: "Success", payload: { Inputs: inputs } });
			set({ closing: true });
			setTimeout(() => {
				set({ closing: false, visible: false, rows: [] });
			}, 300);
		},

		handleButton: (row) => {
			if (row.Event) {
				fetchNui({ path: "Button", payload: { Event: row.Event, Params: row.Params } });
			}
			set({ closing: true });
			setTimeout(() => {
				set({ closing: false, visible: false, rows: [] });
			}, 300);
		},

		reset: () => set({ visible: false, closing: false, rows: [], showErrors: false, copiedIdx: {} }),
	}),
);
