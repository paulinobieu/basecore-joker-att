import { IconDeviceFloppy, IconLogout } from "@tabler/icons-react";
import { Button } from "@views/components/ui/Button";

interface StoreActionsProps {
	/** Aparece no texto do tooltip: "sair da loja de ...". */
	subject: string;
	onSave: () => void;
	onLeave: () => void;
}

export function StoreActions({ subject, onSave, onLeave }: StoreActionsProps) {
	return (
		<div className="absolute right-0 bottom-0 z-40 m-5 flex flex-col gap-5">
			<Button
				data-tooltip={`Confirmar a troca de ${subject} com as predefinições atuais.`}
				onClick={onSave}
				className="h-[3.5rem] text-sm"
			>
				<IconDeviceFloppy size={18} stroke={2} />
				Salvar alterações
			</Button>

			<Button
				variant="ghost"
				data-tooltip={`Sair da loja de ${subject} sem salvar alterações.`}
				onClick={onLeave}
				className="h-[3.5rem] text-sm"
			>
				<IconLogout size={18} stroke={2} />
				Sair sem alterações
			</Button>
		</div>
	);
}
