import type { OptionPath, SliderOption } from "@app/constants/options";
import { useCharacterStore } from "@app/stores/Character";
import { clamp } from "@app/utils/misc";
import { previewOption } from "@app/utils/updateClient";
import { IconChevronLeft, IconChevronRight } from "@tabler/icons-react";
import { Chip } from "@views/components/ui/Chip";
import { Label } from "@views/components/ui/Label";
import { Panel } from "@views/components/ui/Panel";
import { Slider } from "@views/components/ui/Slider";

interface SliderCardProps {
	path: OptionPath;
	option: SliderOption;
}

/** Passos de 0.01 acumulam ruido de ponto flutuante ao somar. */
const round = (value: number) => Math.round(value * 100) / 100;

export function SliderCard({ path, option }: SliderCardProps) {
	const setValue = useCharacterStore((state) => state.setValue);

	const commit = (next: number) => {
		setValue(path, clamp(round(next), option.min, option.max));
		previewOption(path);
	};

	return (
		<Panel
			interactive
			className="group flex h-20 items-center justify-center overflow-hidden"
		>
			<div className="flex h-full w-[9.75rem] items-center justify-center border-white/[.06] border-r px-6">
				<Label className="w-[9.75rem] text-center text-xs">{option.name}</Label>
			</div>

			<div className="flex h-full w-full flex-col items-center gap-3 rounded-r-[.2775rem] bg-white/[.03] px-4 py-4">
				<div className="flex w-full items-center justify-center">
					{option.helper && (
						<span className="mr-auto font-black text-[.625rem] text-ink-muted uppercase tracking-[.08em]">
							{option.helper[0]}
						</span>
					)}

					<Chip className="mb-auto">
						{option.value.toFixed(2)}/{option.max.toFixed(2)}
					</Chip>

					{option.helper && (
						<span className="ml-auto font-black text-[.625rem] text-ink-muted uppercase tracking-[.08em]">
							{option.helper[1]}
						</span>
					)}
				</div>

				<div className="flex w-full items-center justify-center gap-2">
					<button
						type="button"
						data-tooltip="Diminuir valor"
						onClick={() => commit(option.value - option.step)}
						className="mr-[11.5rem] mb-[.4rem] text-[#EDEAE599] transition-all hover:text-primaryColor"
					>
						<IconChevronLeft size={16} stroke={2.5} />
					</button>

					<Slider
						value={option.value}
						min={option.min}
						max={option.max}
						step={option.step}
						onChange={(event) => commit(Number(event.target.value))}
						className="absolute z-[999] mb-[.4rem] w-44"
					/>

					<button
						type="button"
						data-tooltip="Aumentar valor"
						onClick={() => commit(option.value + option.step)}
						className="mb-[.4rem] text-[#EDEAE599] transition-all hover:text-primaryColor"
					>
						<IconChevronRight size={16} stroke={2.5} />
					</button>
				</div>
			</div>
		</Panel>
	);
}
