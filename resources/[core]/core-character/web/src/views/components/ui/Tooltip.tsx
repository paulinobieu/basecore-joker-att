import { cn } from "@app/utils";
import { useEffect, useLayoutEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";

export type TooltipPosition = "top" | "bottom" | "left" | "right";

interface TooltipState {
	text: string;
	position: TooltipPosition;
	rect: DOMRect;
}

const GAP = 8;

function place(
	state: TooltipState,
	width: number,
	height: number,
): { left: number; top: number } {
	const { rect, position } = state;

	switch (position) {
		case "bottom":
			return {
				left: rect.left + rect.width / 2 - width / 2,
				top: rect.bottom + GAP,
			};
		case "left":
			return {
				left: rect.left - width - GAP,
				top: rect.top + rect.height / 2 - height / 2,
			};
		case "right":
			return {
				left: rect.right + GAP,
				top: rect.top + rect.height / 2 - height / 2,
			};
		default:
			return {
				left: rect.left + rect.width / 2 - width / 2,
				top: rect.top - height - GAP,
			};
	}
}

/**
 * Tooltip global dirigido por atributo, no lugar de um wrapper por
 * elemento: `data-tooltip` (texto) e `data-tooltip-position`.
 *
 * Ler do DOM evita envolver botoes que sao filhos diretos de grids —
 * um wrapper ali quebraria o posicionamento das celulas.
 */
export function Tooltip() {
	const [state, setState] = useState<TooltipState | null>(null);
	const [coords, setCoords] = useState({ left: 0, top: 0 });
	const tipRef = useRef<HTMLDivElement>(null);

	useEffect(() => {
		const show = (event: MouseEvent) => {
			const target = (event.target as HTMLElement | null)?.closest?.(
				"[data-tooltip]",
			) as HTMLElement | null;

			if (!target) return setState(null);

			const text = target.dataset.tooltip;

			if (!text) return setState(null);

			setState({
				text,
				position: (target.dataset.tooltipPosition ?? "top") as TooltipPosition,
				rect: target.getBoundingClientRect(),
			});
		};

		const hide = () => setState(null);

		window.addEventListener("mouseover", show);
		window.addEventListener("mousedown", hide);
		window.addEventListener("wheel", hide);

		return () => {
			window.removeEventListener("mouseover", show);
			window.removeEventListener("mousedown", hide);
			window.removeEventListener("wheel", hide);
		};
	}, []);

	// Precisa do tamanho ja renderizado para centralizar, entao mede
	// antes do paint e so depois posiciona.
	useLayoutEffect(() => {
		if (!state || !tipRef.current) return;

		const { offsetWidth, offsetHeight } = tipRef.current;

		setCoords(place(state, offsetWidth, offsetHeight));
	}, [state]);

	if (!state) return null;

	return createPortal(
		<div
			ref={tipRef}
			style={{ left: coords.left, top: coords.top }}
			className={cn(
				"pointer-events-none fixed z-[2000] max-w-[15rem] animate-fade-fast",
				"rounded-field border border-white/[.07] bg-[#26262a] px-[.5625rem] py-1.5 shadow-tooltip",
				"font-semibold text-[.6875rem] text-ink-muted leading-[1.4]",
			)}
		>
			{state.text}

			<span
				className={cn(
					"absolute h-0 w-0 border-solid",
					state.position === "top" &&
						"-bottom-[.3125rem] -ml-[.3125rem] left-1/2 border-[.3125rem_.3125rem_0_.3125rem] border-transparent border-t-[#26262a]",
					state.position === "bottom" &&
						"-top-[.3125rem] -ml-[.3125rem] left-1/2 border-[0_.3125rem_.3125rem_.3125rem] border-transparent border-b-[#26262a]",
					state.position === "left" &&
						"-right-[.3125rem] -mt-[.3125rem] top-1/2 border-[.3125rem_0_.3125rem_.3125rem] border-transparent border-l-[#26262a]",
					state.position === "right" &&
						"-left-[.3125rem] -mt-[.3125rem] top-1/2 border-[.3125rem_.3125rem_.3125rem_0] border-transparent border-r-[#26262a]",
				)}
			/>
		</div>,
		document.body,
	);
}
