import { useBankStore } from "@app/stores/Bank";
import type { ModalFeedback } from "@views/components/Modal";
import { useCallback, useState } from "react";

/**
 * Operação disparada de dentro de um modal. O resultado não vira toast: ele
 * fica no próprio modal, que se transforma na tela de resposta.
 */
export function useModalAction() {
	const run = useBankStore((state) => state.run);
	const [feedback, setFeedback] = useState<ModalFeedback | null>(null);

	const submit = useCallback(
		async (path: string, payload?: Record<string, unknown>) => {
			const result = await run(path, payload, { silent: true });

			setFeedback({
				kind: result.success ? "success" : "error",
				message: result.message,
			});

			return result.success;
		},
		[run],
	);

	const clear = useCallback(() => setFeedback(null), []);

	return { feedback, submit, clear };
}
