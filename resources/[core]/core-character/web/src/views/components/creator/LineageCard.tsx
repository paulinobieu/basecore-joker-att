import {
	ALL_LINEAGE_MODELS,
	type LineageOption,
	type OptionPath,
} from "@app/constants/options";
import { useCharacterStore } from "@app/stores/Character";
import { useConfigStore } from "@app/stores/Config";
import { cn } from "@app/utils";
import { previewOption } from "@app/utils/updateClient";
import { IconGenderFemale, IconGenderMale } from "@tabler/icons-react";
import { Badge } from "@views/components/ui/Badge";
import { LazyImage } from "@views/components/ui/LazyImage";
import { Panel } from "@views/components/ui/Panel";
import { Toggle } from "@views/components/ui/Toggle";
import { useState } from "react";

interface LineageCardProps {
	path: OptionPath;
	option: LineageOption;
}

export function LineageCard({ path, option }: LineageCardProps) {
	const [showAll, setShowAll] = useState(false);
	const setValue = useCharacterStore((state) => state.setValue);
	const pathFace = useConfigStore((state) => state.pathFace);

	// O painel e o mesmo para os dois lados da heranca; o icone
	// diferencia paterno de materno sem repetir o texto do badge.
	const LineageIcon =
		option.side === "maternal" ? IconGenderFemale : IconGenderMale;

	const models = showAll ? ALL_LINEAGE_MODELS : option.list;

	const select = (index: string) => {
		setValue(path, Number(index));
		previewOption(path);
	};

	return (
		<div className="flex flex-col gap-5">
			<Panel className="mt-2 flex min-h-[19.8rem] w-full flex-col px-3 pt-11 pb-5">
				<Badge className="absolute top-[-1rem] left-2 px-5 py-2">
					<LineageIcon size={18} stroke={2} />
					<span className="text-base">{option.name}</span>
				</Badge>

				<div className="absolute top-0 right-0 mt-[.6rem] mr-3">
					<Toggle
						onClick={() => setShowAll((current) => !current)}
						className="px-2 py-[2px]"
					>
						<p className="text-xs">
							{showAll ? "Mostrar menos" : "Mostrar todos"}
						</p>
					</Toggle>
				</div>

				<div className="grid grid-cols-6 gap-2">
					{models.map((model) => (
						<button
							key={model.index}
							type="button"
							data-tooltip={`${model.name} - ${model.index}`}
							onClick={() => select(model.index)}
						>
							<LazyImage
								src={pathFace + model.image}
								className={cn(
									"z-0 animate-rise rounded-[.25rem] border border-white/[.08] object-contain",
									"hover:border-primaryColor",
									String(option.value) === model.index &&
										"outline outline-2 outline-primaryColor",
								)}
							/>
						</button>
					))}
				</div>
			</Panel>
		</div>
	);
}
