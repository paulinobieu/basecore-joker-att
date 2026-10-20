import { ACTIONS } from "@app/constants/callbacks";
import { CREATOR_MENUS } from "@app/constants/menus";
import {
	CAMERA_SURFACE_ID,
	useCharacterCamera,
} from "@app/hooks/useCharacterCamera";
import { useCreatorMenus } from "@app/hooks/useCreatorMenus";
import { useCharacterStore } from "@app/stores/Character";
import { confirm } from "@app/stores/Confirm";
import { nuiAction } from "@app/utils/fetchNui";
import { validateName } from "@app/utils/validation";
import { IconCheck } from "@tabler/icons-react";
import { CameraPanel } from "@views/components/creator/CameraPanel";
import { CreatorPanel } from "@views/components/creator/CreatorPanel";
import { ImportDialog } from "@views/components/creator/ImportDialog";
import { Button } from "@views/components/ui/Button";
import { useState } from "react";

export function Character() {
	const creator = useCreatorMenus(CREATOR_MENUS);

	const [fov, setFov] = useState(45);
	const [showErrors, setShowErrors] = useState(false);
	const [importOpen, setImportOpen] = useState(false);

	useCharacterCamera({ fov, onFovChange: setFov });

	const confirmCreate = () => {
		// Os campos de identidade ficam na primeira aba; sem voltar para
		// ela o jogador nao veria por que a criacao foi barrada.
		creator.reset();
		setShowErrors(true);

		const { infos } = useCharacterStore.getState().options.FACESETTINGS;

		if (validateName(infos.name.value) || validateName(infos.name2.value)) {
			return;
		}

		confirm.require({
			header: "Confirmação",
			message: "Você tem certeza que deseja criar seu personagem?",
			accept: async () => {
				await nuiAction(
					ACTIONS.finishCharacter,
					{
						name: infos.name.value,
						lastname: infos.name2.value,
						gender: infos.gender.value,
					},
					true,
				);
			},
		});
	};

	return (
		<div id="Character" className="relative flex h-full w-full gap-2 p-5">
			<CreatorPanel
				menus={CREATOR_MENUS}
				section={creator.section}
				sectionData={creator.sectionData}
				activeMenu={creator.activeMenu}
				activeItem={creator.activeItem}
				onSelectSection={creator.setSection}
				onSelectMenu={creator.selectMenu}
				showErrors={showErrors}
				onImport={() => setImportOpen(true)}
			/>

			{/* Superficie que recebe arrasto e roda do mouse sobre a cena. */}
			<div id={CAMERA_SURFACE_ID} className="z-30 h-full w-full opacity-40" />

			<CameraPanel
				fov={fov}
				onFovChange={setFov}
				className="absolute top-0 right-0 z-40 p-5"
			/>

			<Button
				data-tooltip="Confirmar a criação do seu personagem com as predefinições atuais."
				onClick={confirmCreate}
				className="absolute right-0 bottom-0 z-40 m-5 h-[3.5rem] w-[13rem] text-sm"
			>
				<IconCheck size={18} stroke={2} />
				Criar Personagem
			</Button>

			<ImportDialog open={importOpen} onClose={() => setImportOpen(false)} />
		</div>
	);
}
