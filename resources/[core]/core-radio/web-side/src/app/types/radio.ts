export type RadioType = "public" | "private";

export interface RadioChannel {
	id: string;
	label: string;
	frequency: number;
	type: RadioType;
	connected?: boolean;
}

export interface FactionFrequency {
	id: string;
	label: string;
	frequency: number;
	connected: boolean;
}

export interface AnimationOption {
	id: string;
	label: string;
	thumbnail: string;
}
