import { applyColors } from "@app/utils/colors";
import { fetchNui } from "@app/utils/fetchNui";
import { useEffect } from "react";
import { useVisibility } from "@app/stores/Visibility";

export const useServerColors = () => {
	const visible = useVisibility((state) => state.visible);

	useEffect(() => {
		if (!visible) return;

		fetchNui<string | { primaryColor: string; secondaryColor: string; thirdColor: string }>({
			path: "get:colors",
			mockData: {
				primaryColor: "0, 149, 243",
				secondaryColor: "229, 16, 127",
				thirdColor: "126, 54, 214",
			},
		}).then((color) => {
			if (color) applyColors(color);
		});
	}, [visible]);
};
