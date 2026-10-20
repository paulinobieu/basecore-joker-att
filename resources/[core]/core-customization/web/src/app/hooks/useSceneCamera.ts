import { ACTIONS } from "@app/constants/callbacks";
import { nuiAction } from "@app/utils/fetchNui";
import { clamp } from "@app/utils/misc";
import { useEffect, useRef } from "react";
import { isTyping } from "./useKeyPress";

/** Elemento que captura arrasto e roda do mouse sobre a cena. */
export const CAMERA_SURFACE_ID = "cameraSurface";

const ROTATE_KEYS: Record<string, "left" | "right"> = {
	KeyD: "left",
	KeyA: "right",
};

interface UseSceneCameraOptions {
	fov: number;
	onFovChange: (fov: number) => void;
}

/**
 * Controles de câmera compartilhados pelas duas lojas: A/D giram o
 * personagem, a roda ajusta o FOV e arrastar sobre a cena muda o
 * ângulo.
 */
export function useSceneCamera({ fov, onFovChange }: UseSceneCameraOptions) {
	const drag = useRef<{ x: number; active: boolean }>({ x: 0, active: false });
	// A roda dispara várias vezes por segundo; o ref evita recriar os
	// listeners a cada frame só porque o FOV mudou.
	const fovRef = useRef(fov);

	useEffect(() => {
		fovRef.current = fov;
	}, [fov]);

	useEffect(() => {
		const surface = () => document.getElementById(CAMERA_SURFACE_ID);

		const onKeyDown = (event: KeyboardEvent) => {
			if (isTyping()) return;

			const side = ROTATE_KEYS[event.code];

			if (!side) return;

			nuiAction(ACTIONS.rotateCharacter, { side }, true);
		};

		const onWheel = (event: WheelEvent) => {
			if (event.target !== surface()) return;

			const delta = clamp(event.deltaY, -1, 1);
			const next = clamp(fovRef.current + delta, 0, 130);

			fovRef.current = next;
			onFovChange(next);

			nuiAction(ACTIONS.setFov, { fov: next }, true);
		};

		const onMouseDown = (event: MouseEvent) => {
			if (event.target !== surface()) return;

			drag.current = { x: event.pageX, active: true };
		};

		const onMouseUp = () => {
			drag.current.active = false;
		};

		const onMouseMove = (event: MouseEvent) => {
			if (!drag.current.active) return;

			const difference = (event.pageX - drag.current.x) * 0.4;
			const angle = 180 + clamp(difference, -180, 180);

			nuiAction(ACTIONS.setHeading, { angle }, true);
		};

		window.addEventListener("keydown", onKeyDown);
		window.addEventListener("wheel", onWheel);
		window.addEventListener("mousedown", onMouseDown);
		window.addEventListener("mouseup", onMouseUp);
		window.addEventListener("mousemove", onMouseMove);

		return () => {
			window.removeEventListener("keydown", onKeyDown);
			window.removeEventListener("wheel", onWheel);
			window.removeEventListener("mousedown", onMouseDown);
			window.removeEventListener("mouseup", onMouseUp);
			window.removeEventListener("mousemove", onMouseMove);
		};
	}, [onFovChange]);
}
