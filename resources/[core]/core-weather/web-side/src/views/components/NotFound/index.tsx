import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

export function NotFound() {
	const [errorReaded, setErrorReaded] = useState(false);
	const navigate = useNavigate();

	useEffect(() => {
		const timeoutId = setTimeout(() => {
			setErrorReaded(true);
		}, 5000);

		return () => clearTimeout(timeoutId);
	}, []);

	// biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
	useEffect(() => {
		if (!errorReaded) return;

		navigate(-1);
	}, [errorReaded]);

	return <h1 className="not-found">Página não encontrada</h1>;
}
