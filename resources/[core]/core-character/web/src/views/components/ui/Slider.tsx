import { cn } from "@app/utils";
import type { InputHTMLAttributes } from "react";

/**
 * Preenchimento do trilho ate a posicao atual.
 *
 * Faixas que so andam para o negativo (min -1 / max 0.99) ficam sem
 * preenchimento: o gradiente partindo da esquerda leria como "cheio"
 * num valor que na verdade e o minimo.
 */
export function trackBackground(value: number, min: number, max: number) {
	const percent = ((value - min) * 100) / (max - min);

	if (min === -1 && max === 0.99) {
		return "rgba(255, 255, 255, 0.08)";
	}

	return `linear-gradient(90deg, rgba(var(--secondaryColor), 0.9) 0%, rgba(var(--primaryColor), 0.9) ${percent}%, rgba(255, 255, 255, 0.08) ${percent}%)`;
}

export interface SliderProps
	extends Omit<InputHTMLAttributes<HTMLInputElement>, "type" | "value"> {
	value: number;
	min: number;
	max: number;
	step: number;
}

export function Slider({
	className,
	value,
	min,
	max,
	step,
	...props
}: SliderProps) {
	return (
		<input
			type="range"
			value={value}
			min={min}
			max={max}
			step={step}
			style={{ background: trackBackground(value, min, max) }}
			className={cn(
				"h-[.375rem] appearance-none rounded-[.625rem] outline-none transition-[filter] duration-300",
				"[&::-webkit-slider-thumb]:h-[.9375rem] [&::-webkit-slider-thumb]:w-[.9375rem] [&::-webkit-slider-thumb]:appearance-none",
				"[&::-webkit-slider-thumb]:cursor-grab [&::-webkit-slider-thumb]:rounded-full",
				"[&::-webkit-slider-thumb]:border [&::-webkit-slider-thumb]:border-white/[.35]",
				"[&::-webkit-slider-thumb]:bg-accent-solid [&::-webkit-slider-thumb]:shadow-glow-sm",
				"[&::-webkit-slider-thumb]:transition-all [&::-webkit-slider-thumb]:duration-300",
				"[&::-webkit-slider-thumb:hover]:border-white/60 [&::-webkit-slider-thumb:hover]:shadow-glow-lg",
				"[&::-webkit-slider-thumb:active]:cursor-grabbing [&::-webkit-slider-thumb:active]:brightness-[1.15]",
				className,
			)}
			{...props}
		/>
	);
}
