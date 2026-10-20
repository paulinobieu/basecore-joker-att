import { ACTIONS } from "@app/constants/callbacks";
import { type SpawnLocation, useScreenStore } from "@app/stores/Screen";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { nuiAction } from "@app/utils/fetchNui";
import { IconMapPin } from "@tabler/icons-react";
import { Button } from "@views/components/ui/Button";
import { Card } from "@views/components/ui/Card";
import { useState } from "react";

export function SelectSpawn() {
	const locations = useScreenStore((state) => state.locations);
	const hide = useVisibilityStore((state) => state.hide);

	const [selected, setSelected] = useState<number | null>(null);

	const previewLocation = async (location: SpawnLocation, index: number) => {
		setSelected(index);

		await nuiAction(ACTIONS.previewLocation, { hash: location.hash }, true);
	};

	const spawn = async () => {
		if (selected === null) return;

		hide();

		await nuiAction(ACTIONS.confirmSpawn, { index: selected }, true);
	};

	return (
		<div
			id="SelectSpawn"
			className="flex h-full w-full items-center justify-center bg-[#1b1b1bf0] p-6"
		>
			<div className="flex flex-col items-center justify-center gap-8 rounded-md p-8">
				<h1 className="font-black text-2xl text-white uppercase">
					SELECIONE UMA LOCALIZAÇÃO PARA SPAWNAR
				</h1>

				<div className="h-[42rem] overflow-y-auto pr-5">
					<div className="grid grid-cols-3 grid-rows-3 gap-6">
						{locations.map((location, index) => (
							<button
								key={`${location.name}-${index}`}
								type="button"
								onClick={() => previewLocation(location, index)}
							>
								<Card
									active={selected === index}
									className={cn(
										"h-52 w-96 overflow-hidden grayscale transition-all delay-0 duration-500 hover:grayscale-0",
										selected === index && "grayscale-0",
									)}
								>
									<div
										style={{ backgroundImage: `url('${location.image}')` }}
										className="h-full w-full bg-center bg-cover"
									>
										<div className="flex h-full w-full flex-col items-start justify-end p-5">
											<h1 className="font-black text-lg text-white uppercase">
												{location.name}
											</h1>
											<p className="font-semibold text-[#adadad] text-sm">
												{location.text}
											</p>
										</div>
									</div>
								</Card>
							</button>
						))}
					</div>
				</div>

				<Button
					disabled={selected === null}
					data-tooltip={
						selected === null
							? "Selecione uma localização primeiro"
							: "Confirma a seleção da localização selecionada"
					}
					onClick={spawn}
					className="z-40 m-5 h-[3.5rem] px-6 text-sm"
				>
					<IconMapPin size={18} stroke={2} />
					Spawnar nessa localização
				</Button>
			</div>
		</div>
	);
}
