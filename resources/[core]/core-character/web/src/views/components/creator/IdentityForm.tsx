import { ACTIONS } from "@app/constants/callbacks";
import type { Gender } from "@app/constants/options";
import { useCharacterStore } from "@app/stores/Character";
import { nuiAction } from "@app/utils/fetchNui";
import { flushPreview } from "@app/utils/updateClient";
import { validateName } from "@app/utils/validation";
import { IconGenderFemale, IconGenderMale } from "@tabler/icons-react";
import { Input } from "@views/components/ui/Input";
import { SectionTitle } from "@views/components/ui/SectionTitle";
import { Tag } from "@views/components/ui/Tag";
import { Toggle } from "@views/components/ui/Toggle";
import { useState } from "react";

interface IdentityFormProps {
	/** Forcado pelo botao de criar, para revelar os erros de uma vez. */
	showErrors?: boolean;
	onImport?: () => void;
}

export function IdentityForm({ showErrors, onImport }: IdentityFormProps) {
	const [touched, setTouched] = useState<Record<string, boolean>>({});
	const infos = useCharacterStore((state) => state.options.FACESETTINGS.infos);
	const setValue = useCharacterStore((state) => state.setValue);
	const setGender = useCharacterStore((state) => state.setGender);

	const fields = [
		{ key: "name", option: infos.name },
		{ key: "name2", option: infos.name2 },
	] as const;

	const changeGender = async (gender: Gender) => {
		setGender(gender);

		await nuiAction(ACTIONS.setGender, { gender }, true);

		// Trocar o modelo reseta o ped no client; reenvia o visual atual.
		flushPreview();
	};

	return (
		<div className="flex flex-col gap-1">
			<div className="flex w-full flex-col gap-3">
				{fields.map(({ key, option }) => {
					const error = validateName(option.value);
					const visible = (showErrors || touched[key]) && error;

					return (
						<div key={key}>
							<Input
								data-tooltip={option.info}
								value={option.value}
								placeholder={option.placeholder}
								onChange={(event) => {
									setTouched((current) => ({ ...current, [key]: true }));
									setValue(["FACESETTINGS", "infos", key], event.target.value);
								}}
							/>

							{visible && (
								<div className="mt-1 w-full animate-fade px-2 text-red-500 text-sm [text-shadow:_0_1px_0_rgb(0_0_0_/_40%)]">
									{error}
								</div>
							)}
						</div>
					);
				})}
			</div>

			<div className="flex gap-2">
				<Toggle
					data-tooltip="Sexo do seu personagem"
					active={infos.gender.value === "mp_m_freemode_01"}
					onClick={() => changeGender("mp_m_freemode_01")}
					className="w-full p-3 px-5"
				>
					<IconGenderMale size={18} stroke={2} />
					<h1 className="text-sm">Masculino</h1>
				</Toggle>

				<Toggle
					data-tooltip="Sexo do seu personagem"
					active={infos.gender.value === "mp_f_freemode_01"}
					onClick={() => changeGender("mp_f_freemode_01")}
					className="w-full p-3 px-5"
				>
					<IconGenderFemale size={18} stroke={2} />
					<h1 className="text-sm">Feminino</h1>
				</Toggle>
			</div>

			<SectionTitle name="OPÇÕES" className="mt-3 h-full w-full" />

			<div className="mt-3 flex flex-col gap-6">
				<Toggle
					data-tooltip="Importe as configurações do seu personagem de um outro servidor utilizando um JSON"
					onClick={onImport}
					className="w-full"
				>
					<Tag
						severity="info"
						value="Novidade"
						className="absolute top-[-.8rem] right-2 z-10"
					/>
					<h1 className="px-5 py-3 text-sm">Importar configurações</h1>
				</Toggle>

				<Toggle
					interactive={false}
					data-tooltip="Utilize alguma predefinição previamente salva ou aquela que você já utilizou em servidores parceiros anteriormente."
					className="w-full cursor-default opacity-50"
				>
					<Tag
						severity="warning"
						value="Em Breve"
						className="absolute top-[-.8rem] right-2 z-10"
					/>
					<h1 className="px-5 py-3 text-sm">Minhas configurações salvas</h1>
				</Toggle>
			</div>
		</div>
	);
}
