import { useEffect, useState } from "react";

export const useIsRendered = () => {
	const [isRendered, setIsRendered] = useState(false);

	useEffect(() => {
		const timeoutId = setTimeout(() => setIsRendered(true), 50);

		return () => clearTimeout(timeoutId);
	}, []);

	return { isRendered };
};
