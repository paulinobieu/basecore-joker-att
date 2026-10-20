import { setAudioMuted } from "@app/audio/spatialAudio";
import { useCreatorStore } from "@app/stores/CreatorStore";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { isEnvBrowser } from "@app/utils/misc";
import { Tooltip } from "@views/components/Tooltip";
import {
	CameraIcon,
	CloseIcon,
	GroupIcon,
	PauseIcon,
	PlayIcon,
	SoundOffIcon,
	SoundOnIcon,
} from "@views/components/icons";
import { creatorActions } from "../actions";

interface TopBarProps {
	onOpenGroup: () => void;
}

export function TopBar({ onOpenGroup }: TopBarProps) {
	const group = useCreatorStore((state) => state.group);
	const muted = useCreatorStore((state) => state.muted);
	const setMuted = useCreatorStore((state) => state.setMuted);
	const setGroupEnabled = useCreatorStore((state) => state.setGroupEnabled);
	const camera = useCreatorStore((state) => state.camera);
	const setCamera = useCreatorStore((state) => state.setCamera);
	const close = useVisibilityStore((state) => state.close);

	const showGroupPlay = group.isOwner && group.members.length > 1;

	function openCamera() {
		creatorActions.openCamera();
		if (isEnvBrowser()) {
			setCamera({ open: !camera.open });
		}
	}

	function toggleMute() {
		const next = !muted;
		setMuted(next);
		setAudioMuted(next);
		creatorActions.toggleMute();
	}

	function toggleGroupPlay() {
		const next = !group.enabled;
		setGroupEnabled(next);
		creatorActions.groupToggle(next);
	}

	return (
		<div className="topActions">
			<Tooltip label="Abrir grupo">
				<button className="actionBtn" type="button" onClick={onOpenGroup}>
					<span className="icon">
						<GroupIcon />
					</span>
					<span className="btnLabel">Grupo</span>
				</button>
			</Tooltip>

			{showGroupPlay && (
				<Tooltip
					label={
						group.enabled
							? "Desativar animação em grupo"
							: "Ativar animação em grupo"
					}
				>
					<button
						className={cn("actionBtn sq", group.enabled && "accent")}
						type="button"
						onClick={toggleGroupPlay}
					>
						<span className="icon">
							{group.enabled ? <PlayIcon /> : <PauseIcon />}
						</span>
					</button>
				</Tooltip>
			)}

			<Tooltip label="Abrir câmera creator">
				<button
					className="actionBtn accent"
					type="button"
					onClick={openCamera}
				>
					<span className="icon">
						<CameraIcon />
					</span>
					<span className="btnLabel">Câmera</span>
				</button>
			</Tooltip>

			<Tooltip label={muted ? "Desmutar músicas" : "Mutar músicas"}>
				<button
					className={cn("actionBtn soundBtn", !muted && "accent")}
					type="button"
					onClick={toggleMute}
				>
					<span className="icon">
						{muted ? <SoundOffIcon /> : <SoundOnIcon />}
					</span>
					<span className="btnLabel">{muted ? "Som OFF" : "Som ON"}</span>
				</button>
			</Tooltip>

			<Tooltip label="Fechar painel">
				<button
					className="actionBtn sq danger"
					type="button"
					onClick={() => close()}
				>
					<span className="icon">
						<CloseIcon />
					</span>
				</button>
			</Tooltip>
		</div>
	);
}
