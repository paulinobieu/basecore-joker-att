import { ACTIONS } from "@app/constants/callbacks";
import { barberMenus } from "@app/constants/menus";
import {
	CAMERA_SURFACE_ID,
	useCharacterCamera,
} from "@app/hooks/useCharacterCamera";
import { useCreatorMenus } from "@app/hooks/useCreatorMenus";
import { useKeyPress } from "@app/hooks/useKeyPress";
import { useConfigStore } from "@app/stores/Config";
import { confirm } from "@app/stores/Confirm";
import { useVisibilityStore } from "@app/stores/Visibility";
import { nuiAction } from "@app/utils/fetchNui";
import { IconDeviceFloppy, IconLogout } from "@tabler/icons-react";
import { CameraPanel } from "@views/components/creator/CameraPanel";
import { CreatorPanel } from "@views/components/creator/CreatorPanel";
import { Button } from "@views/components/ui/Button";
import { useCallback, useMemo, useState } from "react";

export function BarberShop() {
	const eyesBarber = useConfigStore((state) => state.eyesBarber);
	const admin = useConfigStore((state) => state.admin);
	const hide = useVisibilityStore((state) => state.hide);

	const menus = useMemo(() => barberMenus(eyesBarber), [eyesBarber]);
	const creator = useCreatorMenus(menus);

	const [fov, setFov] = useState(45);

	useCharacterCamera({ fov, onFovChange: setFov });

	// O visual a restaurar é o que o client guardou ao abrir a barbearia;
	// mandar o backup daqui seria confiar na NUI para reescrever o ped.
	const discard = useCallback(async () => {
		hide();

		await nuiAction(ACTIONS.cancelBarber, undefined, true);
	}, [hide]);

	const confirmDiscard = useCallback(() => {
		confirm.require({
			header: "Confirmação",
			message: "Você tem certeza que deseja sair sem salvar as alterações?",
			accept: discard,
		});
	}, [discard]);

	const confirmSave = () => {
		confirm.require({
			header: "Confirmação",
			message: "Você tem certeza que deseja salvar as alterações?",
			accept: async () => {
				hide();

				await nuiAction(ACTIONS.saveBarber, undefined, true);
			},
		});
	};

	// Admin sai direto: quem esta testando visual nao quer confirmar a
	// cada saida.
	useKeyPress("Escape", admin ? discard : confirmDiscard);

	return (
		<div id="BarberShop" className="relative flex h-full w-full gap-2 p-5">
			<CreatorPanel
				centered
				menus={menus}
				section={creator.section}
				sectionData={creator.sectionData}
				activeMenu={creator.activeMenu}
				activeItem={creator.activeItem}
				onSelectSection={creator.setSection}
				onSelectMenu={creator.selectMenu}
			/>

			<div id={CAMERA_SURFACE_ID} className="z-30 h-full w-full opacity-40" />

			<CameraPanel
				fov={fov}
				onFovChange={setFov}
				className="absolute top-0 right-0 z-40 p-5"
			/>

			<div className="absolute right-0 bottom-0 z-40 m-5 flex flex-col gap-2.5">
				<Button
					data-tooltip="Confirmar a edição do seu personagem com as predefinições atuais."
					onClick={confirmSave}
					className="h-[3.5rem] text-sm"
				>
					<IconDeviceFloppy size={18} stroke={2} />
					Salvar alterações
				</Button>

				<Button
					variant="ghost"
					data-tooltip="Sair da barbearia sem salvar alterações."
					onClick={confirmDiscard}
					className="h-[3.5rem] text-sm"
				>
					<IconLogout size={18} stroke={2} />
					Sair sem alterações
				</Button>
			</div>
		</div>
	);
}
