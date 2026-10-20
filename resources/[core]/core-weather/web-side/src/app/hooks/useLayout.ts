import { useVisibilityStore } from "@app/stores/Visibility";
import { type IOpenWeatherData, useWeatherStore } from "@app/stores/Weather";
import { attributeColorsToHTML } from "@app/utils/colors";
import { useShallow } from "zustand/shallow";
import { useKeyPress } from "./useKeyPress";
import { useNuiMessage } from "./useNuiMessage";

export const useLayout = () => {
	const { fetchHideFrame, setVisible } = useVisibilityStore(
		useShallow((state) => ({
			fetchHideFrame: state.fetchHideFrame,
			setVisible: state.setVisible,
		})),
	);
	const open = useWeatherStore((state) => state.open);

	useKeyPress("Escape", fetchHideFrame);

	useNuiMessage<IOpenWeatherData>("openWeather", (data) => {
		if (data.themeColor) attributeColorsToHTML(data.themeColor);

		open(data);
		setVisible(true);
	});
};
