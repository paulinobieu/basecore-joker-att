import type { ColorOption, OptionPath } from "@app/constants/options";
import { useCharacterStore } from "@app/stores/Character";
import { useConfigStore } from "@app/stores/Config";
import { cn } from "@app/utils";
import { previewOption } from "@app/utils/updateClient";
import { IconCheck } from "@tabler/icons-react";
import { Label } from "@views/components/ui/Label";
import { Panel } from "@views/components/ui/Panel";

interface ColorsCardProps {
	path: OptionPath;
	option: ColorOption;
}

export function ColorsCard({ path, option }: ColorsCardProps) {
	const setValue = useCharacterStore((state) => state.setValue);
	const palette = useConfigStore((state) => state.palettes[option.palette]);

	// Um personagem importado pode trazer indice fora da paleta (-1
	// significa "sem maquiagem", por exemplo).
	const current = palette[String(option.value)];

	const select = (index: string) => {
		setValue(path, Number(index));
		previewOption(path);
	};

	return (
		<div className="flex flex-col gap-3">
			<Panel
				interactive
				className="group flex h-[3.5rem] items-center gap-3 overflow-hidden"
			>
				<div className="flex h-full w-[9.75rem] items-center justify-center border-white/[.06] border-r px-6">
					<Label className="w-[9.75rem] text-center text-xs">
						{option.name}
					</Label>
				</div>

				<div className="flex w-full items-center justify-center gap-2">
					<div
						style={{ background: current?.hexColor }}
						className="flex h-[1.025rem] w-[1.025rem] items-center justify-center rounded-field outline outline-2 outline-white/60 transition-all"
					/>
					<h1 className="font-black text-ink text-xs uppercase transition-all">
						{current?.name ?? "Nenhuma"} - {option.value}
					</h1>
				</div>
			</Panel>

			<Panel className="flex h-fit items-center justify-center p-3">
				{/* 15 colunas: a paleta ocupa a largura do painel em vez de
				    ficar espremida no meio. */}
				<div className="grid grid-cols-[repeat(15,5fr)] gap-[.4775rem]">
					{Object.entries(palette).map(([index, color]) => (
						<button
							key={index}
							type="button"
							style={{ background: color.hexColor }}
							data-tooltip={`${color.name} - ${index}`}
							onClick={() => select(index)}
							className={cn(
								"flex h-[1.225rem] w-[1.225rem] items-center justify-center rounded-field transition-all",
								"hover:outline hover:outline-2 hover:outline-white/40",
								String(option.value) === index &&
									"outline outline-2 outline-white",
							)}
						>
							{String(option.value) === index && (
								<IconCheck
									size={14}
									stroke={3}
									className="text-white transition-all"
								/>
							)}
						</button>
					))}
				</div>
			</Panel>
		</div>
	);
}
