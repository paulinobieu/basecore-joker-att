import { useNuiMessage } from "@app/hooks/useNuiMessage";
import {
	playSound3D,
	setAudioMuted,
	stopAllSounds,
	stopSound3D,
	updateAudio,
} from "@app/audio/spatialAudio";
import { MOCK_DATA } from "@app/data/mock";
import {
	type CameraState,
	type CreatorData,
	type GroupState,
	useCreatorStore,
} from "@app/stores/CreatorStore";
import { useVisibilityStore } from "@app/stores/Visibility";
import { attributeColorsToHTML } from "@app/utils/colors";
import { isEnvBrowser } from "@app/utils/misc";
import { useEffect, useRef } from "react";
import { useShallow } from "zustand/shallow";

interface SetDataPayload extends CreatorData {
	colors?: {
		primaryColor: string;
		secondaryColor: string;
		thirdyColor: string;
	};
}

export const useCreatorBridge = () => {
	const { setData, setGroup, setMuted, setCamera, loadFavorites } =
		useCreatorStore(
			useShallow((state) => ({
				setData: state.setData,
				setGroup: state.setGroup,
				setMuted: state.setMuted,
				setCamera: state.setCamera,
				loadFavorites: state.loadFavorites,
			})),
		);

	const setVisible = useVisibilityStore((state) => state.setVisible);

	const seeded = useRef(false);

	// biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
	useEffect(() => {
		if (!isEnvBrowser() || seeded.current) return;
		seeded.current = true;

		setData(MOCK_DATA);
		loadFavorites();
		setMuted(!!MOCK_DATA.muted);
		setAudioMuted(!!MOCK_DATA.muted);
		setVisible(true);
	}, []);

	useNuiMessage<SetDataPayload>("setData", (payload) => {
		if (!payload) return;
		if (payload.colors) attributeColorsToHTML(payload.colors);
		setData(payload);
		loadFavorites();
		setMuted(!!payload.muted);
		setAudioMuted(!!payload.muted);
		setVisible(true);
	});

	useNuiMessage<{ group: GroupState }>("groupState", (payload) => {
		setGroup(payload?.group);
	});

	useNuiMessage<{ muted: boolean }>("muteState", (payload) => {
		setMuted(!!payload?.muted);
		setAudioMuted(!!payload?.muted);
	});

	useNuiMessage<Partial<CameraState> & { open?: boolean }>(
		"camera",
		(payload) => {
			setCamera({ ...payload, open: payload?.open === true });
		},
	);

	useNuiMessage<Partial<CameraState>>("cameraUpdate", (payload) => {
		setCamera(payload || {});
	});

	useNuiMessage<{ id: string | number; file: string; volume?: number }>(
		"sound3dPlay",
		(payload) => {
			if (!payload) return;
			playSound3D(payload.id, payload.file, payload.volume);
		},
	);

	useNuiMessage<{ id: string | number }>("sound3dStop", (payload) => {
		if (!payload) return;
		stopSound3D(payload.id);
	});

	useNuiMessage("soundStopAll", () => {
		stopAllSounds();
	});

	useNuiMessage<{ listener: any; sources: any[] }>("audioUpdate", (payload) => {
		if (!payload) return;
		updateAudio(payload.listener, payload.sources);
	});
};
