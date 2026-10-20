import { fetchNui } from "@app/utils/fetchNui";
import {
	IconChristmasTree,
	IconCloud,
	IconCloudFog,
	IconCloudOff,
	IconCloudRain,
	IconCloudSnow,
	IconCloudStorm,
	IconHaze,
	IconPumpkinScary,
	IconRainbow,
	IconSnowflake,
	IconSun,
	IconSunHigh,
	IconSunOff,
	IconWind,
} from "@tabler/icons-react";
import { create } from "zustand";

export interface IWeatherType {
	id: string;
	name: string;
	Icon: typeof IconSun;
}

export const weatherTypes: IWeatherType[] = [
	{ id: "EXTRASUNNY", name: "Sol Forte", Icon: IconSunHigh },
	{ id: "CLEAR", name: "Limpo", Icon: IconSun },
	{ id: "CLOUDS", name: "Nublado", Icon: IconCloud },
	{ id: "OVERCAST", name: "Encoberto", Icon: IconSunOff },
	{ id: "SMOG", name: "Poluição", Icon: IconHaze },
	{ id: "FOGGY", name: "Neblina", Icon: IconCloudFog },
	{ id: "RAIN", name: "Chuva", Icon: IconCloudRain },
	{ id: "THUNDER", name: "Tempestade", Icon: IconCloudStorm },
	{ id: "CLEARING", name: "Abrindo", Icon: IconRainbow },
	{ id: "NEUTRAL", name: "Neutro", Icon: IconCloudOff },
	{ id: "SNOWLIGHT", name: "Neve Leve", Icon: IconSnowflake },
	{ id: "SNOW", name: "Neve", Icon: IconCloudSnow },
	{ id: "BLIZZARD", name: "Nevasca", Icon: IconWind },
	{ id: "XMAS", name: "Natal", Icon: IconChristmasTree },
	{ id: "HALLOWEEN", name: "Halloween", Icon: IconPumpkinScary },
];

export const WEATHERS_PER_PAGE = 8;
export const pageCount = Math.ceil(weatherTypes.length / WEATHERS_PER_PAGE);

export function getPeriodName(hour: number) {
	if (hour >= 0 && hour < 6) return "Madrugada";
	if (hour >= 6 && hour < 12) return "Manhã";
	if (hour >= 12 && hour < 18) return "Tarde";
	return "Noite";
}

export interface IOpenWeatherData {
	weather?: string;
	hour?: number;
	minute?: number;
	themeColor?: string;
}

interface WeatherStore {
	currentWeather: string;
	currentHour: number;
	currentMinute: number;
	pendingHour: number;
	pendingMinute: number;
	selectedWeather: string | null;
	page: number;
}

interface WeatherActions {
	open: (data: IOpenWeatherData) => void;
	setPendingTime: (hour: number, minute: number) => void;
	setSelectedWeather: (weather: string) => void;
	setPage: (page: number) => void;

	fetchApplyTime: () => void;
	fetchApplyWeather: () => void;
	fetchResetSync: () => void;
}

export const useWeatherStore = create<WeatherStore & WeatherActions>()(
	(set, get) => ({
		currentWeather: "CLEAR",
		currentHour: 12,
		currentMinute: 0,
		pendingHour: 12,
		pendingMinute: 0,
		selectedWeather: null,
		page: 0,

		open: (data) =>
			set((state) => ({
				currentWeather: data.weather ?? state.currentWeather,
				currentHour: data.hour ?? state.currentHour,
				currentMinute: data.minute ?? state.currentMinute,
				pendingHour: data.hour ?? state.pendingHour,
				pendingMinute: data.minute ?? state.pendingMinute,
				selectedWeather: null,
				page: 0,
			})),

		setPendingTime: (hour, minute) =>
			set({ pendingHour: hour, pendingMinute: minute }),

		setSelectedWeather: (weather) => set({ selectedWeather: weather }),

		setPage: (page) => set({ page }),

		fetchApplyTime: () => {
			const { pendingHour, pendingMinute } = get();

			fetchNui({
				path: "core-weather",
				payload: {
					action: "setTime",
					hour: pendingHour,
					minute: pendingMinute,
				},
				mockData: "ok",
			});

			set({ currentHour: pendingHour, currentMinute: pendingMinute });
		},

		fetchApplyWeather: () => {
			const { selectedWeather } = get();

			if (!selectedWeather) return;

			fetchNui({
				path: "core-weather",
				payload: { action: "setWeather", weather: selectedWeather },
				mockData: "ok",
			});

			set({ currentWeather: selectedWeather, selectedWeather: null });
		},

		fetchResetSync: () => {
			fetchNui({
				path: "core-weather",
				payload: { action: "reset" },
				mockData: "ok",
			});
		},
	}),
);
