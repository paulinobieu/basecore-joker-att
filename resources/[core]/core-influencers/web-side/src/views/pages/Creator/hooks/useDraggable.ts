import { type RefObject, useEffect } from "react";

const STORE_KEY = "core_influencers_panel_pos";

function clamp(v: number, min: number, max: number) {
	return Math.max(min, Math.min(max, v));
}

export const useDraggable = (
	panelRef: RefObject<HTMLDivElement>,
	handleRef: RefObject<HTMLElement>,
) => {
	useEffect(() => {
		const panel = panelRef.current;
		const handle = handleRef.current;
		if (!panel || !handle) return;

		let dragging = false;
		let startMouseX = 0;
		let startMouseY = 0;
		let startLeft = 0;
		let startTop = 0;

		function applyPos(left: number, top: number) {
			if (!panel) return;
			panel.style.position = "absolute";
			panel.style.transform = "none";
			panel.style.left = `${left}px`;
			panel.style.top = `${top}px`;
		}

		function loadPos() {
			try {
				const raw = localStorage.getItem(STORE_KEY);
				if (!raw) return;
				const pos = JSON.parse(raw);
				if (typeof pos.left !== "number" || typeof pos.top !== "number") return;
				applyPos(pos.left, pos.top);
			} catch {}
		}

		function savePos() {
			if (!panel) return;
			try {
				const left = Number.parseFloat(panel.style.left) || 0;
				const top = Number.parseFloat(panel.style.top) || 0;
				localStorage.setItem(STORE_KEY, JSON.stringify({ left, top }));
			} catch {}
		}

		function onMouseMove(e: MouseEvent) {
			if (!dragging || !panel) return;

			const dx = e.clientX - startMouseX;
			const dy = e.clientY - startMouseY;

			const rect = panel.getBoundingClientRect();
			const maxLeft = window.innerWidth - rect.width;
			const maxTop = window.innerHeight - rect.height;

			const newLeft = clamp(startLeft + dx, 0, Math.max(0, maxLeft));
			const newTop = clamp(startTop + dy, 0, Math.max(0, maxTop));

			applyPos(newLeft, newTop);
		}

		function onMouseUp() {
			if (!dragging) return;
			dragging = false;

			document.removeEventListener("mousemove", onMouseMove);
			document.removeEventListener("mouseup", onMouseUp);

			savePos();
		}

		function onMouseDown(e: MouseEvent) {
			if (e.button !== 0 || !panel) return;

			dragging = true;
			startMouseX = e.clientX;
			startMouseY = e.clientY;

			const rect = panel.getBoundingClientRect();
			applyPos(rect.left, rect.top);

			startLeft = rect.left;
			startTop = rect.top;

			document.addEventListener("mousemove", onMouseMove);
			document.addEventListener("mouseup", onMouseUp);
		}

		handle.addEventListener("mousedown", onMouseDown);
		loadPos();

		return () => {
			handle.removeEventListener("mousedown", onMouseDown);
			document.removeEventListener("mousemove", onMouseMove);
			document.removeEventListener("mouseup", onMouseUp);
		};
	}, [panelRef, handleRef]);
};
