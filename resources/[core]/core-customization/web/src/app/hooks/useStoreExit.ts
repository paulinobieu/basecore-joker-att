import { useConfigStore } from "@app/stores/Config";
import { confirm } from "@app/stores/Confirm";
import { useVisibilityStore } from "@app/stores/Visibility";
import { postNui } from "@app/utils/fetchNui";
import { useCallback } from "react";
import { useKeyPress } from "./useKeyPress";

interface UseStoreExitOptions {
	/** Ação que persiste o que o jogador montou. */
	save: string;
	/** Ação que devolve o visual anterior. */
	cancel: string;
}

/**
 * Saída das lojas. As duas confirmam antes de fechar; administrador
 * sai direto no Escape, porque quem está testando não quer o diálogo a
 * cada abertura.
 *
 * Fechar é sempre local: o client tira o foco e roda o fade quando
 * recebe a ação.
 */
export function useStoreExit({ save, cancel }: UseStoreExitOptions) {
	const admin = useConfigStore((state) => state.admin);
	const hide = useVisibilityStore((state) => state.hide);

	const close = useCallback(
		(action: string) => {
			hide();
			postNui(action);
		},
		[hide],
	);

	const requestSave = useCallback(
		() =>
			confirm.require({
				header: "Confirmação",
				message: "Você tem certeza que deseja salvar as alterações?",
				accept: () => close(save),
			}),
		[close, save],
	);

	const requestLeave = useCallback(
		() =>
			confirm.require({
				header: "Confirmação",
				message: "Você tem certeza que deseja sair sem salvar as alterações?",
				accept: () => close(cancel),
			}),
		[close, cancel],
	);

	useKeyPress("Escape", () => {
		if (admin) return close(cancel);

		requestLeave();
	});

	return { requestSave, requestLeave };
}
