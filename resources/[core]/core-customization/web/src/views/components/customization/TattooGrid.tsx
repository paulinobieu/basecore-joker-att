import { ACTIONS } from "@app/constants/callbacks";
import { useTattoosStore } from "@app/stores/Tattoos";
import { cn } from "@app/utils";
import { postNui } from "@app/utils/fetchNui";
import { LazyImage } from "@views/components/ui/LazyImage";

interface TattooGridProps {
	className?: string;
}

/** Tatuagens da zona selecionada. Clicar aplica ou remove. */
export function TattooGrid({ className }: TattooGridProps) {
	const activeZone = useTattoosStore((state) => state.activeZone);
	const zone = useTattoosStore((state) => state.zones[state.activeZone]);
	const active = useTattoosStore((state) => state.active);
	const toggle = useTattoosStore((state) => state.toggle);

	return (
		<div className={cn("grid grid-cols-3 gap-4", className)}>
			{zone.available.map((tattoo, index) => (
				<button
					key={tattoo.name}
					type="button"
					data-tooltip="Selecionar esse modelo"
					onClick={() => {
						toggle(tattoo.name);
						postNui(ACTIONS.toggleTattoo, { zone: activeZone, index });
					}}
					className="relative flex h-32 w-32"
				>
					<div className="absolute right-0 bottom-0 z-10 mr-4 mb-2 font-bold text-primaryColor">
						{index}
					</div>

					<LazyImage
						src={tattoo.link}
						className={cn(
							"z-0 h-full w-full rounded-[.25rem] border-2 border-transparent object-contain",
							"hover:border-primaryColor",
							active.includes(tattoo.name) && "!border-primaryColor",
						)}
					/>
				</button>
			))}
		</div>
	);
}
