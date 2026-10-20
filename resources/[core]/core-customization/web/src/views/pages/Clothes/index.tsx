import { ACTIONS } from "@app/constants/callbacks";
import { CAMERA_SURFACE_ID, useSceneCamera } from "@app/hooks/useSceneCamera";
import { useStoreExit } from "@app/hooks/useStoreExit";
import { activeClothesItem, useClothesStore } from "@app/stores/Clothes";
import { CameraPanel } from "@views/components/customization/CameraPanel";
import { ItemGrid } from "@views/components/customization/ItemGrid";
import { ItemRail } from "@views/components/customization/ItemRail";
import { StepperMenu } from "@views/components/customization/StepperMenu";
import { StoreActions } from "@views/components/customization/StoreActions";
import { Panel } from "@views/components/ui/Panel";
import { SectionTitle } from "@views/components/ui/SectionTitle";
import { useState } from "react";

export function Clothes() {
	const [fov, setFov] = useState(45);

	const activeName = useClothesStore(
		(state) => activeClothesItem(state)?.infos.name ?? "",
	);

	useSceneCamera({ fov, onFovChange: setFov });

	const { requestSave, requestLeave } = useStoreExit({
		save: ACTIONS.applyClothes,
		cancel: ACTIONS.cancelClothes,
	});

	return (
		<div className="flex h-full w-full gap-2 p-5">
			<ItemRail />

			<Panel className="flex h-full w-[32rem] animate-fade flex-col items-center gap-5 py-7 transition-all">
				<div className="flex h-full w-full flex-col gap-5 px-7">
					<StepperMenu />
					<SectionTitle name={activeName} />

					<div className="h-full overflow-y-scroll pr-4">
						<ItemGrid className="pr-3" />
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
				subject="roupas"
				onSave={requestSave}
				onLeave={requestLeave}
			/>
		</div>
	);
}
