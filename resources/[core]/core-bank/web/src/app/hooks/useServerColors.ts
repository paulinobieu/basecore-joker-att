import { useVisibilityStore } from "@app/stores/Visibility";
import { attributeColorsToHTML } from "@app/utils/colors";
import { fetchNui } from "@app/utils/fetchNui";
import { useEffect } from "react";

export const useServerColors = () => {
	const visible = useVisibilityStore((state) => state.visible);

	useEffect(() => {
		if (!visible) return;

		(async () => {
			const color = await fetchNui<string>({
				path: "get:colors",
				mockData: "#dc1553",
			});

			if (!color) return;

			attributeColorsToHTML(color);
		})();
	}, [visible]);
};
