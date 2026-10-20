import { fallbackZoneIcon, tattooZoneIcons } from "@app/constants/icons";
import type { ZoneKey } from "@app/constants/tattoos";
import { useTattoosStore } from "@app/stores/Tattoos";
import { cn } from "@app/utils";
import { HexButton } from "@views/components/ui/HexButton";
import { Rail } from "@views/components/ui/Rail";
import { useMemo } from "react";

/** Trilha das zonas do corpo, em ordem alfabética pelo título. */
export function ZoneRail() {
	const zones = useTattoosStore((state) => state.zones);
	const activeZone = useTattoosStore((state) => state.activeZone);
	const setActiveZone = useTattoosStore((state) => state.setActiveZone);

	const keys = useMemo(
		() =>
			(Object.keys(zones) as ZoneKey[]).sort((a, b) =>
				zones[a].title.localeCompare(zones[b].title),
			),
		[zones],
	);

	return (
		<Rail className="gap-1">
			{keys.map((key) => {
				const zone = zones[key];
				const { icon: Icon, flip } =
					tattooZoneIcons[zone.icon] ?? fallbackZoneIcon;

				return (
					<button
						key={key}
						type="button"
						data-tooltip={zone.title}
						data-tooltip-position="right"
						onClick={() => setActiveZone(key)}
					>
						<HexButton size={3.25} active={key === activeZone}>
							<Icon
								size={20}
								stroke={2}
								className={cn(flip && "scale-x-[-1]")}
							/>
						</HexButton>
					</button>
				);
			})}
		</Rail>
	);
}
