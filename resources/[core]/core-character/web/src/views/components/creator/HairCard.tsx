import type { HairOption, OptionPath } from "@app/constants/options";
import { isTyping } from "@app/hooks/useKeyPress";
import { type HairModel, useCharacterStore } from "@app/stores/Character";
import { cn } from "@app/utils";
import { clamp } from "@app/utils/misc";
import { previewOption } from "@app/utils/updateClient";
import { IconChevronLeft, IconChevronRight } from "@tabler/icons-react";
import { IconHair } from "@views/components/icons";
import { Badge } from "@views/components/ui/Badge";
import { LazyImage } from "@views/components/ui/LazyImage";
import { Panel } from "@views/components/ui/Panel";
import { Toggle } from "@views/components/ui/Toggle";
import { useCallback, useEffect, useMemo, useState } from "react";

interface HairCardProps {
	path: OptionPath;
	option: HairOption;
}

const PER_PAGE = 30;
const COLUMNS = 6;

/** Referencia estavel: um `[]` novo por render faria o zustand
    considerar o seletor sempre alterado. */
const EMPTY: HairModel[] = [];

/** Setas do teclado andam pela grade: laterais em 1, verticais em uma linha. */
const KEY_STEP: Record<string, number> = {
	ArrowRight: 1,
	ArrowLeft: -1,
	ArrowDown: COLUMNS,
	ArrowUp: -COLUMNS,
};

export function HairCard({ path, option }: HairCardProps) {
	const setValue = useCharacterStore((state) => state.setValue);
	const gender = useCharacterStore(
		(state) => state.options.FACESETTINGS.infos.gender.value,
	);
	const hairs = useCharacterStore(
		(state) =>
			state.hairs[gender === "mp_m_freemode_01" ? "Male" : "Female"] ?? EMPTY,
	);

	const maxPages = Math.max(1, Math.ceil(hairs.length / PER_PAGE));

	// A lista tem buracos: o servidor pode esconder estilos, então o índice do
	// cabelo não é a posição dele na grade.
	const positionOf = useCallback(
		(value: number) => hairs.findIndex((hair) => hair.index === value),
		[hairs],
	);

	const pageOf = useCallback(
		(position: number) =>
			clamp(Math.floor(Math.max(0, position) / PER_PAGE) + 1, 1, maxPages),
		[maxPages],
	);

	const [page, setPage] = useState(() => pageOf(positionOf(option.value)));

	// Trocar de sexo troca a lista inteira: a pagina anterior pode nem
	// existir na nova.
	// biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
	useEffect(() => {
		setPage(pageOf(positionOf(option.value)));
	}, [gender, hairs.length]);

	const visible = useMemo(
		() => hairs.slice((page - 1) * PER_PAGE, page * PER_PAGE),
		[hairs, page],
	);

	const select = useCallback(
		(index: number) => {
			setValue(path, index);
			previewOption(path);
		},
		[path, setValue],
	);

	useEffect(() => {
		const listener = (event: KeyboardEvent) => {
			if (isTyping()) return;

			const step = KEY_STEP[event.key];

			if (step === undefined) return;

			event.preventDefault();

			// Anda pela posição na grade, não pelo índice: com estilos
			// escondidos os dois deixam de coincidir.
			const next = clamp(
				positionOf(option.value) + step,
				0,
				Math.max(0, hairs.length - 1),
			);

			const hair = hairs[next];

			if (!hair) return;

			select(hair.index);
			setPage(pageOf(next));
		};

		window.addEventListener("keydown", listener);

		return () => window.removeEventListener("keydown", listener);
	}, [option.value, hairs, positionOf, pageOf, select]);

	return (
		<div className="flex items-center justify-center bg-transparent">
			<Panel className="mt-2 flex h-[25rem] w-full flex-col items-center px-3 pt-11">
				<Badge className="absolute top-[-1rem] left-2 px-5 py-2">
					<IconHair size={18} stroke={2} />
					<span className="text-base">ESTILOS</span>
				</Badge>

				<div className="absolute top-0 right-0 mt-[.6rem] mr-3 flex items-center justify-center gap-1">
					<Toggle
						data-tooltip="Página anterior"
						onClick={() => setPage((current) => Math.max(1, current - 1))}
						className="h-6 w-6"
					>
						<IconChevronLeft size={14} stroke={2.5} />
					</Toggle>

					<Toggle
						data-tooltip="Ir ao seu estilo de cabelo atual"
						onClick={() => setPage(pageOf(positionOf(option.value)))}
						className="h-6 w-[8rem] px-2"
					>
						<p className="text-xs transition-all">Posição atual</p>
					</Toggle>

					<Toggle
						data-tooltip="Próxima página"
						onClick={() =>
							setPage((current) => Math.min(maxPages, current + 1))
						}
						className="h-6 w-6"
					>
						<IconChevronRight size={14} stroke={2.5} />
					</Toggle>
				</div>

				<div className="grid grid-cols-6 grid-rows-5 gap-2">
					{visible.map((hair) => (
						<button
							key={hair.index}
							type="button"
							data-tooltip={String(hair.index)}
							onClick={() => select(hair.index)}
						>
							<LazyImage
								src={hair.image}
								className={cn(
									"z-0 rounded-[.25rem] border border-white/[.08] object-contain",
									"hover:border-primaryColor",
									option.value === hair.index &&
										"outline outline-2 outline-primaryColor",
								)}
							/>
						</button>
					))}
				</div>

				<p className="mt-auto mb-1 text-white text-xs">
					{page}/{maxPages}
				</p>
			</Panel>
		</div>
	);
}
