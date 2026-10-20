import { type ReactNode, useRef, useState } from "react";
import { createPortal } from "react-dom";

interface TooltipProps {
	label: string;
	place?: "top" | "bottom";
	children: ReactNode;
}

interface Coords {
	x: number;
	y: number;
}

export function Tooltip({ label, place = "top", children }: TooltipProps) {
	const ref = useRef<HTMLSpanElement>(null);
	const [coords, setCoords] = useState<Coords | null>(null);

	function show() {
		const el = ref.current;
		if (!el) return;
		const r = el.getBoundingClientRect();
		setCoords({
			x: r.left + r.width / 2,
			y: place === "top" ? r.top : r.bottom,
		});
	}

	function hide() {
		setCoords(null);
	}

	return (
		<span
			ref={ref}
			className="tooltip-trigger"
			onMouseEnter={show}
			onMouseLeave={hide}
		>
			{children}

			{coords &&
				createPortal(
					<div
						className="tip"
						data-place={place}
						style={{ left: coords.x, top: coords.y }}
					>
						{label}
					</div>,
					document.body,
				)}
		</span>
	);
}
