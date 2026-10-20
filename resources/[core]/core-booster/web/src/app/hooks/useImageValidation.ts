import { useEffect, useState } from "react";

const FALLBACK_IMAGE =
	"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+Cjx0ZXh0IHg9IjUwIiB5PSI2MCIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjQwIiBmaWxsPSIjZmZmZmZmNTAiIHRleHQtYW5jaG9yPSJtaWRkbGUiPj88L3RleHQ+Cjwvc3ZnPgo=";

/**
 * Mantem a grade estavel quando a recompensa nao tem imagem no CDN e quando o
 * avatar do Discord expira.
 */
export const useImageValidation = (image?: string) => {
	const [imageUrl, setImageUrl] = useState(image || FALLBACK_IMAGE);

	useEffect(() => {
		setImageUrl(image || FALLBACK_IMAGE);
	}, [image]);

	const onImageError = () => setImageUrl(FALLBACK_IMAGE);

	return { imageUrl, onImageError };
};
