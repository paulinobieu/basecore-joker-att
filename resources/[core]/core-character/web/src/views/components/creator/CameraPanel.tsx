import { ACTIONS } from "@app/constants/callbacks";
import { isTyping } from "@app/hooks/useKeyPress";
import { cn } from "@app/utils";
import { nuiAction } from "@app/utils/fetchNui";
import {
	IconBodyScan,
	IconFaceId,
	IconMan,
	IconRotate360,
	IconShirt,
	IconYoga,
	IconZoomScan,
} from "@tabler/icons-react";
import { IconPants } from "@views/components/icons";
import { Panel } from "@views/components/ui/Panel";
import { Slider } from "@views/components/ui/Slider";
import {
	type ComponentType,
	useCallback,
	useEffect,
	useRef,
	useState,
} from "react";

interface CameraPanelProps {
	fov: number;
	onFovChange: (fov: number) => void;
	className?: string;
}

type CameraKey = "rotation" | "fov" | "cam" | "pose";

/** Cobre os icones do Tabler e os desenhados aqui. */
type IconComponent = ComponentType<{
	size?: number | string;
	stroke?: number | string;
	className?: string;
}>;

interface CameraItem {
	key: CameraKey;
	title: string;
	min: number;
	max: number;
	step: number;
	/** Abre um trilho; os demais so avancam entre predefinicoes. */
	slider: boolean;
	icons: IconComponent[];
}

const ITEMS: CameraItem[] = [
	{
		key: "rotation",
		title: "Altera a rotação do personagem",
		min: 0,
		max: 360,
		step: 1,
		slider: true,
		icons: [IconRotate360],
	},
	{
		key: "fov",
		title: "Aumenta e diminui o FOV da câmera.",
		min: 0,
		max: 90,
		step: 0.01,
		slider: true,
		icons: [IconZoomScan],
	},
	{
		key: "cam",
		title: "Posição predefinida da câmera.",
		min: 0,
		max: 3,
		step: 1,
		slider: false,
		icons: [IconBodyScan, IconFaceId, IconShirt, IconPants],
	},
	{
		key: "pose",
		title: "Altera a animação do personagem.",
		min: 0,
		max: 1,
		step: 1,
		slider: false,
		icons: [IconMan, IconYoga],
	},
];

export function CameraPanel({ fov, onFovChange, className }: CameraPanelProps) {
	const [values, setValues] = useState({ rotation: 180, cam: 1, pose: 0 });
	const [expanded, setExpanded] = useState<Record<string, boolean>>({});

	// A troca de camera no client leva quase um segundo; sem a trava,
	// clicar rapido enfileira transicoes e a camera fica pulando.
	const changing = useRef(false);
	const state = useRef({ ...values, fov });

	useEffect(() => {
		state.current = { ...values, fov };
	}, [values, fov]);

	const push = useCallback(
		async (index: CameraKey) => {
			const response = await nuiAction<{ fov?: number } | "ok">(
				ACTIONS.updateCamera,
				{ index, ...state.current },
				"ok",
			);

			// Algumas predefinicoes forcam o proprio FOV; o client devolve o
			// valor final para o trilho nao ficar dessincronizado.
			if (response && response !== "ok" && typeof response.fov === "number") {
				onFovChange(response.fov);
			}
		},
		[onFovChange],
	);

	const changeCamera = useCallback(
		(index: CameraKey) => {
			changing.current = true;
			push(index);

			setTimeout(() => {
				changing.current = false;
			}, 1000);
		},
		[push],
	);

	const cycle = useCallback(
		(item: CameraItem) => {
			if (item.slider) {
				return setExpanded((current) => ({
					...current,
					[item.key]: !current[item.key],
				}));
			}

			if (changing.current) return;

			setValues((current) => {
				const value = current[item.key as "cam" | "pose"];
				const next = value === item.max ? item.min : value + item.step;

				state.current = { ...state.current, [item.key]: next };

				return { ...current, [item.key]: next };
			});

			changeCamera(item.key);
		},
		[changeCamera],
	);

	// Teclas 1-4 pulam direto para a predefinicao de camera.
	useEffect(() => {
		const listener = (event: KeyboardEvent) => {
			if (isTyping()) return;

			const index = ["Digit1", "Digit2", "Digit3", "Digit4"].indexOf(
				event.code,
			);

			if (index < 0 || changing.current) return;
			if (state.current.cam === index) return;

			state.current = { ...state.current, cam: index };
			setValues((current) => ({ ...current, cam: index }));
			changeCamera("cam");
		};

		window.addEventListener("keyup", listener);

		return () => window.removeEventListener("keyup", listener);
	}, [changeCamera]);

	return (
		<div
			className={cn("flex flex-col items-end gap-2 transition-all", className)}
		>
			{ITEMS.map((item) => {
				const value =
					item.key === "fov" ? fov : values[item.key as keyof typeof values];
				const Icon = item.slider
					? item.icons[0]
					: (item.icons[Math.round(value)] ?? item.icons[0]);
				const open = !!expanded[item.key];

				return (
					<Panel
						key={item.key}
						interactive
						data-tooltip={item.title}
						data-tooltip-position="left"
						className="group flex animate-fade items-center justify-center gap-5 px-[.8rem] py-3 transition-all"
					>
						<button
							type="button"
							onClick={() => cycle(item)}
							className={cn(
								"flex h-8 w-8 items-center justify-center text-[#EDEAE599] transition-all duration-500 hover:text-primaryColor",
								open && "!text-primaryColor",
							)}
						>
							<Icon size={26} stroke={2} />
						</button>

						{item.slider && open && (
							<Slider
								value={value}
								min={item.min}
								max={item.max}
								step={item.step}
								onChange={(event) => {
									const next = Number(event.target.value);

									if (item.key === "fov") {
										onFovChange(next);
									} else {
										setValues((current) => ({ ...current, rotation: next }));
									}

									state.current = { ...state.current, [item.key]: next };
									push(item.key);
								}}
								className="w-44 animate-fade"
							/>
						)}
					</Panel>
				);
			})}
		</div>
	);
}
