import { CurrentWeather } from "@views/components/CurrentWeather";
import { TimeControls } from "@views/components/TimeControls";
import { WeatherSelector } from "@views/components/WeatherSelector";

export function Home() {
	return (
		<>
			<TimeControls />
			<CurrentWeather />
			<WeatherSelector />
		</>
	);
}
