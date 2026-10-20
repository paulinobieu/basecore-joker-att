import { ACTIONS } from "@app/constants/callbacks";
import { CAMERA_SURFACE_ID, useSceneCamera } from "@app/hooks/useSceneCamera";
import { useStoreExit } from "@app/hooks/useStoreExit";
import { useTattoosStore } from "@app/stores/Tattoos";
import { CameraPanel } from "@views/components/customization/CameraPanel";
import { StoreActions } from "@views/components/customization/StoreActions";
import { TattooGrid } from "@views/components/customization/TattooGrid";
import { ZoneRail } from "@views/components/customization/ZoneRail";
import { Panel } from "@views/components/ui/Panel";
import { SectionTitle } from "@views/components/ui/SectionTitle";
import { useState } from "react";

export function Tattoos() {
	const [fov, setFov] = useState(45);

	const title = useTattoosStore((state) => state.zones[state.activeZone].title);

	useSceneCamera({ fov, onFovChange: setFov });

	const { requestSave, requestLeave } = useStoreExit({
		save: ACTIONS.applyTattoos,
		cancel: ACTIONS.cancelTattoos,
	});

	return (
		<div className="flex h-full w-full gap-2 p-5">
			<ZoneRail />

			<Panel className="flex h-full w-[32rem] animate-fade flex-col items-center gap-5 py-7 transition-all">
				<div className="flex h-full w-full flex-col gap-5 px-7">
					<SectionTitle name={title} />

					<div className="h-full overflow-y-scroll pr-4">
						<TattooGrid className="pr-3" />
					</div>
				</div>
			</Panel>

			{/* Superfície que captura arrasto e roda do mouse sobre a cena. */}
			<div id={CAMERA_SURFACE_ID} className="z-30 h-full w-[84.7rem]" />

			<CameraPanel
				fov={fov}
				onFovChange={setFov}
				className="absolute top-0 right-0 z-40 p-5"
			/>

			<StoreActions
				subject="tatuagens"
				onSave={requestSave}
				onLeave={requestLeave}
			/>
		</div>
	);
}
