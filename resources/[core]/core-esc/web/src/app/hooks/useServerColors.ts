import { useVisibilityStore } from "@app/stores/Visibility";
import { attributeColorsToHTML } from "@app/utils/colors";
import { fetchNui } from "@app/utils/fetchNui";
import { useEffect } from "react";

export const useServerColors = () => {
	const visible = useVisibilityStore((state) => state.visible);

	useEffect(() => {
		if (!visible) return;

		(async () => {
			const data = await fetchNui<{
				primaryColor: string;
				secondaryColor: string;
				thirdyColor: string;
			}>({
				path: "getColors",
				mockData: {
					primaryColor: "#0143bb",
					secondaryColor: "#01205c",
					thirdyColor: "#2563eb",
				},
			});

			if (!data) return;

			attributeColorsToHTML(data);
		})();
	}, [visible]);
};
