import { ACTIONS } from "@app/constants/callbacks";
import { useConfigStore } from "@app/stores/Config";
import { confirm } from "@app/stores/Confirm";
import { type CharacterSlot, useScreenStore } from "@app/stores/Screen";
import { useVisibilityStore } from "@app/stores/Visibility";
import { nuiAction } from "@app/utils/fetchNui";
import { IconCheck } from "@tabler/icons-react";
import { Button } from "@views/components/ui/Button";
import { Panel } from "@views/components/ui/Panel";
import { Toggle } from "@views/components/ui/Toggle";
import { useState } from "react";
import { useShallow } from "zustand/shallow";

/** Slot sem `createPerson` e um personagem existente. */
const isCharacter = (slot: CharacterSlot) => slot.createPerson == null;

function tooltipFor(slot: CharacterSlot, buyPerson: boolean) {
	if (slot.name) return `Selecione o personagem ${slot.name}`;
	if (slot.createPerson) return "Criar um novo personagem em seu slot liberado";
	if (buyPerson) return "Comprar um novo slot de personagem utilizando coins";

	return undefined;
}

export function Select() {
	const slots = useScreenStore((state) => state.slots);
	const hide = useVisibilityStore((state) => state.hide);
	const { buyPerson, buyPersonPrice } = useConfigStore(
		useShallow((state) => ({
			buyPerson: state.buyPerson,
			buyPersonPrice: state.buyPersonPrice,
		})),
	);

	const [selected, setSelected] = useState(0);

	const enterCharacter = async () => {
		hide();

		await nuiAction(
			ACTIONS.selectCharacter,
			{ characterId: slots[selected]?.id },
			true,
		);
	};

	const changeSelected = (index: number, slot: CharacterSlot) => {
		if (slot.createPerson) {
			return confirm.require({
				header: "Confirmação",
				message: "Você tem certeza que deseja criar um novo personagem?",
				accept: async () => {
					hide();

					await nuiAction(ACTIONS.createCharacter, undefined, true);
				},
			});
		}

		if (isCharacter(slot)) {
			setSelected(index);

			return nuiAction(
				ACTIONS.previewCharacter,
				{ characterId: slot.id },
				true,
			);
		}

		if (buyPerson) {
			confirm.require({
				header: "Confirmação",
				message: `Você tem certeza que deseja comprar este slot por ${buyPersonPrice} coins`,
				accept: async () => {
					await nuiAction(ACTIONS.buySlot, undefined, true);
				},
			});
		}
	};

	return (
		<div
			id="Select"
			className="relative flex h-full w-full gap-2 bg-[linear-gradient(270deg,rgba(10,10,10,.79)_0%,rgba(4,4,4,.25)_50%,rgba(0,0,0,1)_100%)] p-5"
		>
			<Panel className="flex h-fit w-[29rem] flex-col items-center gap-5 p-6">
				{slots.map((slot, index) => (
					<Toggle
						key={slot.id ?? `slot-${index}`}
						active={selected === index && isCharacter(slot)}
						data-tooltip={tooltipFor(slot, buyPerson)}
						onClick={() => changeSelected(index, slot)}
						className="w-full cursor-pointer p-4"
					>
						{slot.name ? (
							<div className="flex h-full flex-col items-center justify-center gap-1">
								<h1 className="font-extrabold text-xl uppercase tracking-wider">
									{slot.name}
								</h1>
								<p className="font-semibold text-sm">#{slot.id}</p>
							</div>
						) : (
							<div className="flex h-full w-full flex-col items-center justify-center">
								<h1 className="font-extrabold text-xl tracking-wide">
									{slot.createPerson
										? "SLOT LIBERADO"
										: buyPerson
											? "DESBLOQUEIE ESTE SLOT"
											: "SLOT BLOQUEADO"}
								</h1>

								<p className="font-semibold text-sm">
									{slot.createPerson
										? "CRIAR UM PERSONAGEM"
										: buyPerson
											? "ADQUIRIR SLOT"
											: "BLOQUEADO"}
								</p>
							</div>
						)}
					</Toggle>
				))}
			</Panel>

			<Button
				data-tooltip="Confirma a seleção do personagem selecionado"
				onClick={enterCharacter}
				className="absolute right-0 bottom-0 z-40 m-5 h-[3.5rem] px-6 text-sm"
			>
				<IconCheck size={18} stroke={2} />
				Selecionar Personagem
			</Button>
		</div>
	);
}
