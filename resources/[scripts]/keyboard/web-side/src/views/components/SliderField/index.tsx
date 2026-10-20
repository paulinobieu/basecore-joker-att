import { useCallback, useEffect, useRef, useState } from "react";

interface SliderFieldProps {
	value: number;
	min: number;
	max: number;
	placeholder: string;
	onChange: (value: number) => void;
}

export function SliderField({ value, min, max, placeholder, onChange }: SliderFieldProps) {
	const trackRef = useRef<HTMLDivElement>(null);
	const [dragging, setDragging] = useState(false);

	const pct = max > min ? ((value - min) / (max - min)) * 100 : 0;

	const updateValue = useCallback(
		(clientX: number) => {
			if (!trackRef.current) return;
			const rect = trackRef.current.getBoundingClientRect();
			const ratio = Math.max(0, Math.min(1, (clientX - rect.left) / rect.width));
			onChange(Math.round(min + ratio * (max - min)));
		},
		[min, max, onChange],
	);

	useEffect(() => {
		if (!dragging) return;
		const onMove = (e: MouseEvent) => updateValue(e.clientX);
		const onUp = () => setDragging(false);
		window.addEventListener("mousemove", onMove);
		window.addEventListener("mouseup", onUp);
		return () => {
			window.removeEventListener("mousemove", onMove);
			window.removeEventListener("mouseup", onUp);
		};
	}, [dragging, updateValue]);

	return (
		<div className="w-full">
			<div className="mb-2 flex items-center justify-between">
				<span className="text-[0.6875rem] font-medium text-white/50">{placeholder}</span>
				<span className="text-xs font-bold" style={{ color: "var(--theme-color)" }}>
					{value}
				</span>
			</div>
			<div
				className="kb-slider-track"
				ref={trackRef}
				onMouseDown={(e) => {
					setDragging(true);
					updateValue(e.clientX);
				}}
			>
				<div className="kb-slider-fill" style={{ width: `${pct}%` }} />
				<div className="kb-slider-thumb" style={{ left: `${pct}%` }} />
			</div>
		</div>
	);
}
