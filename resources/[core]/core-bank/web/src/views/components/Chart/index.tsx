import { formatCompact, formatCurrency } from "@app/utils/format";
import { cn } from "@app/utils";
import { useId, useMemo, useState } from "react";

export interface ChartPoint {
	label: string;
	value: number;
}

interface ChartProps {
	data: ChartPoint[];
	className?: string;
}

/** Margem vertical para a linha não encostar na borda do quadro. */
const TOP = 10;
const BOTTOM = 88;

/**
 * Área desenhada à mão em SVG: o `preserveAspectRatio="none"` estica o traçado
 * na horizontal e o `vector-effect` segura a espessura da linha.
 */
export function Chart({ data, className }: ChartProps) {
	const gradientId = useId().replace(/:/g, "");
	const [hovered, setHovered] = useState<number | null>(null);

	const { points, area, line, floor, ceiling } = useMemo(() => {
		const values = data.map((point) => point.value);
		const highest = Math.max(...values, 0);
		const lowest = Math.min(...values, 0);
		const range = highest - lowest || 1;

		const mapped = data.map((point, index) => ({
			...point,
			x: data.length === 1 ? 50 : (index / (data.length - 1)) * 100,
			y: BOTTOM - ((point.value - lowest) / range) * (BOTTOM - TOP),
		}));

		const path = mapped.map((point) => `${point.x},${point.y}`).join(" L ");

		return {
			points: mapped,
			line: mapped.length ? `M ${path}` : "",
			area: mapped.length
				? `M ${mapped[0].x},100 L ${path} L ${mapped[mapped.length - 1].x},100 Z`
				: "",
			floor: lowest,
			ceiling: highest,
		};
	}, [data]);

	return (
		<div className={cn("relative flex h-full w-full", className)}>
			<div className="flex h-full w-[3.5rem] flex-shrink-0 flex-col justify-between py-[.25rem] pr-[.5rem] text-right font-bold text-[.625rem] text-white/20">
				<span>{formatCompact(ceiling)}</span>
				<span>{formatCompact((ceiling + floor) / 2)}</span>
				<span>{formatCompact(floor)}</span>
			</div>

			<div className="relative h-full flex-1">
				{[0, 50, 100].map((offset) => (
					<span
						key={offset}
						style={{ top: `${offset}%` }}
						className="absolute left-0 h-[.0625rem] w-full bg-white/[.04]"
					/>
				))}

				<svg
					viewBox="0 0 100 100"
					preserveAspectRatio="none"
					className="absolute inset-0 h-full w-full"
				>
					<title>Evolução do saldo</title>

					<defs>
						<linearGradient
							id={`chartFill-${gradientId}`}
							x1="0"
							y1="0"
							x2="0"
							y2="1"
						>
							<stop
								offset="0%"
								stopColor="rgb(var(--primaryColor))"
								stopOpacity="0.35"
							/>
							<stop
								offset="100%"
								stopColor="rgb(var(--primaryColor))"
								stopOpacity="0"
							/>
						</linearGradient>
					</defs>

					<path d={area} fill={`url(#chartFill-${gradientId})`} />
					<path
						d={line}
						fill="none"
						stroke="rgb(var(--primaryColor))"
						strokeWidth="2"
						strokeLinejoin="round"
						strokeLinecap="round"
						vectorEffect="non-scaling-stroke"
					/>
				</svg>

				{points.map((point, index) => (
					<span
						key={point.label + String(index)}
						style={{ left: `${point.x}%`, top: `${point.y}%` }}
						className={cn(
							"-translate-x-1/2 -translate-y-1/2 pointer-events-none absolute size-[.5rem] rounded-full bg-primaryColor transition-all duration-200",
							hovered === index ? "scale-150 opacity-100" : "opacity-0",
						)}
					/>
				))}

				{hovered !== null && points[hovered] && (
					<div
						style={{
							left: `${points[hovered].x}%`,
							top: `${points[hovered].y}%`,
						}}
						className="-translate-x-1/2 pointer-events-none absolute z-10 mt-[-3.25rem] flex flex-col items-center rounded-[.25rem] border border-white/[.08] border-solid bg-[#151519] px-[.625rem] py-[.375rem]"
					>
						<span className="whitespace-nowrap font-black text-[.75rem] text-white">
							{formatCurrency(points[hovered].value)}
						</span>
						<span className="font-semibold text-[.625rem] text-white/35">
							{points[hovered].label}
						</span>
					</div>
				)}

				<div className="absolute inset-0 flex">
					{points.map((point, index) => (
						<button
							key={`hit-${point.label}-${String(index)}`}
							type="button"
							tabIndex={-1}
							onMouseEnter={() => setHovered(index)}
							onMouseLeave={() => setHovered(null)}
							className="h-full flex-1"
						/>
					))}
				</div>
			</div>

			<div className="pointer-events-none absolute right-0 bottom-[-1.125rem] left-[3.5rem] flex justify-between font-bold text-[.625rem] text-white/20">
				{points.length > 0 && <span>{points[0].label}</span>}
				{points.length > 1 && <span>{points[points.length - 1].label}</span>}
			</div>
		</div>
	);
}
