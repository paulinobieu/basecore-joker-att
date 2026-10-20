import { ACTIONS, MESSAGES, type Screen } from "@app/constants/callbacks";
import type { Gender } from "@app/constants/options";
import { mockEvents } from "@app/mocks";
import { type HairModels, useCharacterStore } from "@app/stores/Character";
import { type SetupPayload, useConfigStore } from "@app/stores/Config";
import {
	type CharacterSlot,
	type SpawnLocation,
	useScreenStore,
} from "@app/stores/Screen";
import { type ToastSeverity, useToastStore } from "@app/stores/Toast";
import { useVisibilityStore } from "@app/stores/Visibility";
import { debugData } from "@app/utils/debugData";
import { nuiAction } from "@app/utils/fetchNui";
import { flushPreview } from "@app/utils/updateClient";
import { useCallback, useEffect } from "react";
import { useNuiMessage } from "./useNuiMessage";

export interface OpenPayload {
	screen: Screen;
	hairs?: HairModels;
	gender?: Gender;
	/** Personagem ja existente, no formato plano do client. */
	character?: Record<string, number>;
	/** Identidade ja gravada, para o criador nao abrir com os campos vazios. */
	name?: string;
	lastname?: string;
	slots?: CharacterSlot[];
	locations?: SpawnLocation[];
	admin?: boolean;
}

export interface NotifyPayload {
	severity: ToastSeverity;
	title: string;
	message?: string;
	duration?: number;
}

/**
 * Ponte entre as mensagens do client e as stores. Fica no Layout, que
 * e o unico ponto montado durante toda a vida da NUI.
 */
export const useLayout = () => {
	const onSetup = useCallback(async (payload: SetupPayload) => {
		useConfigStore.getState().applySetup(payload ?? {});
		useVisibilityStore.getState().setReady(true);

		await nuiAction(ACTIONS.unlock, undefined, true);
	}, []);

	const onOpen = useCallback((payload: OpenPayload) => {
		if (!payload?.screen) return;

		const character = useCharacterStore.getState();
		const screen = useScreenStore.getState();

		if (payload.hairs) character.setHairs(payload.hairs);
		if (payload.gender) character.setGender(payload.gender);

		if (payload.name || payload.lastname) {
			character.setIdentity(payload.name ?? "", payload.lastname ?? "");
		}
		if (payload.slots) screen.setSlots(payload.slots);
		if (payload.locations) screen.setLocations(payload.locations);

		if (typeof payload.admin === "boolean") {
			useConfigStore.getState().setAdmin(payload.admin);
		}

		if (payload.character) {
			character.applyCharacter(payload.character);

			// A barbearia precisa do estado original para restaurar quando o
			// jogador sair sem salvar.
			if (payload.screen === "barber") {
				screen.setBackupCharacter(payload.character);
			}

			// Sem isso o ped fica no visual anterior ate o primeiro ajuste.
			flushPreview();
		}

		screen.setScreen(payload.screen);
		useVisibilityStore.getState().setVisible(true);
	}, []);

	const onClose = useCallback(() => {
		useVisibilityStore.getState().hide();
	}, []);

	const onNotify = useCallback((payload: NotifyPayload) => {
		if (!payload) return;

		useToastStore.getState().add({
			severity: payload.severity ?? "info",
			summary: payload.title,
			detail: payload.message,
			life: payload.duration ?? 5000,
		});
	}, []);

	useNuiMessage<SetupPayload>(MESSAGES.setup, onSetup);
	useNuiMessage<OpenPayload>(MESSAGES.open, onOpen);
	useNuiMessage<void>(MESSAGES.close, onClose);
	useNuiMessage<NotifyPayload>(MESSAGES.notify, onNotify);

	// Avisa o client que a NUI subiu; ele responde com o setup.
	useEffect(() => {
		nuiAction(ACTIONS.ready, undefined, true);

		debugData(mockEvents, 300);
	}, []);
};
