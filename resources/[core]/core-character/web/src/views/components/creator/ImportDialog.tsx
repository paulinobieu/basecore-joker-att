import { ACTIONS } from "@app/constants/callbacks";
import type { Gender } from "@app/constants/options";
import { useCharacterStore } from "@app/stores/Character";
import { toast } from "@app/stores/Toast";
import {
	IMPORT_OPTIONS,
	type ImportSource,
	convertCharacter,
} from "@app/utils/converterCharacter";
import { nuiAction } from "@app/utils/fetchNui";
import { flushPreview } from "@app/utils/updateClient";
import {
	IconCheck,
	IconGenderFemale,
	IconGenderMale,
} from "@tabler/icons-react";
import { Button } from "@views/components/ui/Button";
import { Dialog } from "@views/components/ui/Dialog";
import { Dropdown, type DropdownOption } from "@views/components/ui/Dropdown";
import { Textarea } from "@views/components/ui/Input";
import { useState } from "react";

interface ImportDialogProps {
	open: boolean;
	onClose: () => void;
}

export function ImportDialog({ open, onClose }: ImportDialogProps) {
	const [source, setSource] = useState<DropdownOption | null>(null);
	const [gender, setGender] = useState<Gender>("mp_m_freemode_01");
	const [json, setJson] = useState("");

	const reset = () => {
		setSource(null);
		setGender("mp_m_freemode_01");
		setJson("");
	};

	const close = () => {
		reset();
		onClose();
	};

	const importCharacter = async () => {
		if (!json || !source) return;

		try {
			const parsed = JSON.parse(json);
			const converted = convertCharacter(parsed, source.index as ImportSource);

			const character = useCharacterStore.getState();

			character.applyCharacter(converted);
			character.setGender(gender);

			await nuiAction(ACTIONS.setGender, { gender }, true);

			flushPreview();
			close();
		} catch (error) {
			toast.add({
				severity: "error",
				summary: "Rejeitado",
				detail: String(error).replace(/^Error: /, ""),
				life: 5000,
			});
		}
	};

	return (
		<Dialog
			open={open}
			header="Importe seu personagem"
			onClose={close}
			style={{ width: "27vw" }}
		>
			<div className="flex flex-col gap-5">
				<p className="font-medium text-[#adadad] text-xs">
					Por favor, selecione entre os sistemas de criação de personagens
					utilizados em outros servidores para importar o seu personagem para o
					nosso servidor.
				</p>

				<p className="font-medium text-[#adadad] text-xs">
					Atenção: Gostaríamos de informar que ao importar um personagem, é
					possível que haja variações nas texturas de pele devido às diferenças
					entre os servidores disponíveis. Isso significa que o personagem
					importado pode não ficar 100% idêntico ao original.
				</p>

				<Dropdown
					options={IMPORT_OPTIONS}
					value={source}
					placeholder="Selecione a criação"
					onChange={setSource}
				/>

				{source && (
					<>
						<div className="flex gap-2">
							<Button
								variant={gender === "mp_m_freemode_01" ? "primary" : "ghost"}
								data-tooltip="Sexo do personagem a ser importado"
								onClick={() => setGender("mp_m_freemode_01")}
								className="w-full px-5 py-3 text-xs"
							>
								<IconGenderMale size={18} stroke={2} />
								Masculino
							</Button>

							<Button
								variant={gender === "mp_f_freemode_01" ? "primary" : "ghost"}
								data-tooltip="Sexo do personagem a ser importado"
								onClick={() => setGender("mp_f_freemode_01")}
								className="w-full px-5 py-3 text-xs"
							>
								<IconGenderFemale size={18} stroke={2} />
								Feminino
							</Button>
						</div>

						<Textarea
							rows={5}
							value={json}
							onChange={(event) => setJson(event.target.value)}
						/>

						<Button
							data-tooltip="Confirmar e importar seu personagem"
							onClick={importCharacter}
							className="w-full px-5 py-3 text-xs"
						>
							<IconCheck size={18} stroke={2} />
							Importar personagem
						</Button>
					</>
				)}
			</div>
		</Dialog>
	);
}
