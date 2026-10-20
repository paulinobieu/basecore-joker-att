import { getPeriodName, useWeatherStore, weatherTypes } from "@app/stores/Weather";
import { IconSun } from "@tabler/icons-react";
import { useShallow } from "zustand/shallow";

function pad(n: number) {
	return n.toString().padStart(2, "0");
}

export function CurrentWeather() {
	const { currentWeather, currentHour, currentMinute } = useWeatherStore(
		useShallow((state) => ({
			currentWeather: state.currentWeather,
			currentHour: state.currentHour,
			currentMinute: state.currentMinute,
		})),
	);

	const activeWeather = weatherTypes.find((w) => w.id === currentWeather);
	const ActiveIcon = activeWeather?.Icon ?? IconSun;

	return (
		<div className="current-weather-row">
			<div className="current-weather-icon">
				<ActiveIcon size={34} stroke={2} />
			</div>
			<div className="current-weather-info">
				<span className="current-time">
					{pad(currentHour)}:{pad(currentMinute)}
				</span>
				<span className="current-period">{getPeriodName(currentHour)}</span>
			</div>
			<div className="current-weather-badge">
				<span>{activeWeather?.name ?? "Limpo"}</span>
			</div>
		</div>
	);
}
