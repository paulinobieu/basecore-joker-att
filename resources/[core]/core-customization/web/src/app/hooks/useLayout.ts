import { ACTIONS, MESSAGES, type Screen } from "@app/constants/callbacks";
import type { ClothesConfig } from "@app/constants/clothes";
import type { Tattoo, ZoneKey } from "@app/constants/tattoos";
import { mockEvents } from "@app/mocks";
import { useClothesStore } from "@app/stores/Clothes";
import { type SetupPayload, useConfigStore } from "@app/stores/Config";
import { useScreenStore } from "@app/stores/Screen";
import { useTattoosStore } from "@app/stores/Tattoos";
import {
	type PedType,
	type TextureCatalog,
	useTexturesStore,
} from "@app/stores/Textures";
import { type ToastSeverity, useToastStore } from "@app/stores/Toast";
import { useVisibilityStore } from "@app/stores/Visibility";
import { debugData } from "@app/utils/debugData";
import { nuiAction } from "@app/utils/fetchNui";
import { useCallback, useEffect } from "react";
import { useNuiMessage } from "./useNuiMessage";

export interface OpenPayload {
	screen: Screen;
	pedType?: PedType;
	admin?: boolean;
	/** Loja de roupas: o que o jogador veste e os limites do modelo. */
	clothes?: Partial<ClothesConfig>;
	/** Loja de tatuagens: catálogo do ponto e o que já está aplicado. */
	tattoos?: {
		available?: Partial<Record<ZoneKey, Tattoo[]>>;
		active?: string[];
	};
}

export interface NotifyPayload {
	severity: ToastSeverity;
	title: string;
	message?: string;
	duration?: number;
}

/**
 * Ponte entre as mensagens do client e as stores. Fica no Layout, que
 * é o único ponto montado durante toda a vida da NUI.
 */
export const useLayout = () => {
	const onSetup = useCallback((payload: SetupPayload) => {
		useConfigStore.getState().applySetup(payload ?? {});
	}, []);

	// O catálogo é medido no boot do client, vestindo os dois modelos.
	// Enquanto ele não chega a loja não pode abrir: a grade e o contador
	// de texturas leem daqui.
	const onTextures = useCallback(
		async (payload: Record<PedType, TextureCatalog>) => {
			if (!payload) return;

			useTexturesStore.getState().setCatalog(payload);
			useVisibilityStore.getState().setReady(true);

			await nuiAction(ACTIONS.unlock, undefined, true);
		},
		[],
	);

	const onOpen = useCallback((payload: OpenPayload) => {
		if (!payload?.screen) return;

		useConfigStore
			.getState()
			.setUser({ pedType: payload.pedType, admin: payload.admin });

		if (payload.clothes) {
			useClothesStore.getState().applyConfig(payload.clothes);
		}

		if (payload.tattoos) {
			useTattoosStore
				.getState()
				.applyCatalog(
					payload.tattoos.available ?? {},
					payload.tattoos.active ?? [],
				);
		}

		useScreenStore.getState().setScreen(payload.screen);
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
	useNuiMessage<Record<PedType, TextureCatalog>>(MESSAGES.textures, onTextures);
	useNuiMessage<OpenPayload>(MESSAGES.open, onOpen);
	useNuiMessage<void>(MESSAGES.close, onClose);
	useNuiMessage<NotifyPayload>(MESSAGES.notify, onNotify);

	// Avisa o client que a NUI subiu; ele responde com o setup.
	useEffect(() => {
		nuiAction(ACTIONS.ready, undefined, true);

		debugData(mockEvents, 300);
	}, []);
};
