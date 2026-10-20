import { useClothesItem } from "@app/hooks/useClothesItem";
import { isTyping } from "@app/hooks/useKeyPress";
import { IconChevronLeft, IconChevronRight } from "@tabler/icons-react";
import { Input } from "@views/components/ui/Input";
import { Toggle } from "@views/components/ui/Toggle";
import { useEffect, useState } from "react";

/** Teclas que andam pela grade de miniaturas — três colunas por linha. */
const ITEM_STEP: Record<string, number> = {
	ArrowRight: 1,
	ArrowLeft: -1,
	ArrowDown: 3,
	ArrowUp: -3,
};

/** Teclas que a loja consome: sem isso a grade rola junto. */
const HELD_KEYS = ["ArrowRight", "ArrowLeft", "ArrowDown", "ArrowUp", "Enter"];

// O incremento nativo do navegador não respeita os índices bloqueados
// pelo servidor, e as setas do teclado já cobrem o passo a passo.
const NUMBER_FIELD = [
	"py-2 text-base font-bold",
	"[-moz-appearance:textfield]",
	"[&::-webkit-inner-spin-button]:appearance-none",
	"[&::-webkit-outer-spin-button]:appearance-none",
].join(" ");

interface StepperProps {
	label: string;
	value: number;
	previousTooltip: string;
	nextTooltip: string;
	/** O índice existe e pode ser aplicado enquanto o jogador digita. */
	isValid: (value: number) => boolean;
	onStep: (delta: number) => void;
	onSelect: (value: number) => void;
}

function Stepper({
	label,
	value,
	previousTooltip,
	nextTooltip,
	isValid,
	onStep,
	onSelect,
}: StepperProps) {
	// Rascunho do campo: sem ele, apagar para digitar outro número seria
	// impossível — o valor da store voltaria a cada tecla.
	const [draft, setDraft] = useState(() => String(value));

	useEffect(() => {
		setDraft(String(value));
	}, [value]);

	return (
		<div className="flex w-full flex-col items-center">
			<h1 className="text-center text-sm text-white">{label}</h1>

			<div className="flex items-center gap-2">
				<Toggle
					data-tooltip={previousTooltip}
					onClick={() => onStep(-1)}
					className="h-[2.6rem] w-6"
				>
					<IconChevronLeft size={14} stroke={2.5} />
				</Toggle>

				<Input
					type="number"
					value={draft}
					onChange={(event) => {
						const raw = event.target.value;
						const next = Number(raw);

						setDraft(raw);

						// Um número fora da faixa fica só no rascunho; aplicar a
						// cada tecla trocaria a peça no meio da digitação.
						if (raw !== "" && !Number.isNaN(next) && isValid(next)) {
							onSelect(next);
						}
					}}
					onBlur={() => {
						const next = Number(draft);

						if (draft !== "" && !Number.isNaN(next)) onSelect(next);

						setDraft(String(value));
					}}
					containerClassName="w-[8rem]"
					className={NUMBER_FIELD}
				/>

				<Toggle
					data-tooltip={nextTooltip}
					onClick={() => onStep(1)}
					className="h-[2.6rem] w-6"
				>
					<IconChevronRight size={14} stroke={2.5} />
				</Toggle>
			</div>
		</div>
	);
}

/** Contadores de modelo e de textura da peça em edição. */
export function StepperMenu() {
	const {
		entry,
		variants,
		item,
		texture,
		maxTexture,
		stepItem,
		selectItem,
		stepTexture,
		selectTexture,
	} = useClothesItem();

	// Segurar a seta repetiria a troca dezenas de vezes por segundo, e
	// cada uma veste o ped: o passo acontece ao soltar. O keydown existe
	// só para o navegador não rolar a grade junto.
	useEffect(() => {
		const onKeyDown = (event: KeyboardEvent) => {
			if (isTyping()) return;

			if (HELD_KEYS.includes(event.key) || event.code === "Space") {
				event.preventDefault();
			}
		};

		const onKeyUp = (event: KeyboardEvent) => {
			if (isTyping()) return;

			if (event.key === "Enter") return stepTexture(1);

			const step = ITEM_STEP[event.key];

			if (step !== undefined) stepItem(step);
		};

		window.addEventListener("keydown", onKeyDown);
		window.addEventListener("keyup", onKeyUp);

		return () => {
			window.removeEventListener("keydown", onKeyDown);
			window.removeEventListener("keyup", onKeyUp);
		};
	}, [stepItem, stepTexture]);

	if (!entry) return null;

	return (
		<div className="flex h-24 w-full items-center justify-between gap-3">
			<Stepper
				label={`${entry.infos.maxItem} Modelos`}
				value={item}
				previousTooltip="Modelo anterior"
				nextTooltip="Próximo modelo"
				isValid={(value) => !!variants[String(value)]}
				onStep={stepItem}
				onSelect={selectItem}
			/>

			<Stepper
				label={`${maxTexture} Texturas`}
				value={texture}
				previousTooltip="Textura anterior"
				nextTooltip="Próxima textura"
				isValid={(value) => value >= 0 && value <= maxTexture}
				onStep={stepTexture}
				onSelect={selectTexture}
			/>
		</div>
	);
}
