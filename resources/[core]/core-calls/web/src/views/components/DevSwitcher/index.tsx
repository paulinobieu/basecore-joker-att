import type { PanelInitial } from "@app/types";
import { debugData } from "@app/utils/debugData";
import { isEnvBrowser } from "@app/utils/misc";

const MOCK_PANEL: PanelInitial = {
	tickets: [
		{
			id: 741,
			name: "Joao Gomes",
			text: "Fui morto sem motivo na zona sul.",
			hour: "14:32",
			createdAt: Date.now(),
		},
		{
			id: 822,
			name: "Maria Souza",
			text: "Bug ao entrar no veiculo.",
			hour: "14:35",
			createdAt: Date.now() + 1,
		},
	],
	profile: {
		id: 22,
		name: "Carlos Andrade",
		role: "Coordenador",
		total: 184,
		positives: 142,
		negatives: 7,
		fast: 96,
	},
	ranking: {
		allTime: [
			{ staff: 22, name: "Carlos Andrade", role: "Coordenador", total: 184, positives: 142, negatives: 7, fast: 96 },
			{ staff: 31, name: "Bruno Lima",     role: "Moderador",   total: 152, positives: 110, negatives: 4, fast: 60 },
			{ staff: 44, name: "Ana Pereira",    role: "Suporte",     total:  88, positives:  70, negatives: 2, fast: 38 },
		],
		monthly: [
			{ staff: 22, name: "Carlos Andrade", role: "Coordenador", total: 42, positives: 38, negatives: 1, fast: 22 },
			{ staff: 31, name: "Bruno Lima",     role: "Moderador",   total: 31, positives: 24, negatives: 1, fast: 16 },
		],
	},
};

type Btn = { label: string; fire: () => void };

const BUTTONS: Btn[] = [
	{
		label: "Prompt jogador",
		fire: () => debugData([{ action: "openPrompt" }], 0),
	},
	{
		label: "Painel staff",
		fire: () => debugData([{ action: "openPanel", payload: MOCK_PANEL }], 0),
	},
	{
		label: "Feedback (estrelas)",
		fire: () =>
			debugData(
				[{ action: "openFeedback", payload: { name: "Carlos Andrade", role: "Coordenador" } }],
				0,
			),
	},
	{
		label: "Menu staff",
		fire: () =>
			debugData(
				[{ action: "openStaffMenu", payload: { id: 741, name: "Joao Gomes", text: "RDM" } }],
				0,
			),
	},
	{
		label: "Toast incoming",
		fire: () =>
			debugData(
				[
					{
						action: "incoming",
						payload: {
							id: 741,
							name: "Joao Gomes",
							text: "Fui morto sem motivo na zona sul.",
							time: 15,
						},
					},
				],
				0,
			),
	},
	{
		label: "Hint chamado ativo",
		fire: () =>
			debugData([{ action: "ticketActive", payload: { id: 741, name: "Joao Gomes" } }], 0),
	},
	{
		label: "Fechar overlay (closeSurface + ticketEnded)",
		fire: () =>
			debugData(
				[{ action: "closeSurface" }, { action: "ticketEnded" }, { action: "hideIncoming" }],
				0,
			),
	},
];

export function DevSwitcher() {
	if (import.meta.env.MODE !== "development" || !isEnvBrowser()) return null;

	return (
		<div
			style={{
				position: "fixed",
				top: "0.5rem",
				left: "0.5rem",
				zIndex: 9999,
				display: "flex",
				flexDirection: "column",
				gap: "0.25rem",
				padding: "0.5rem",
				background: "rgba(0, 0, 0, 0.65)",
				border: "1px solid rgba(255, 255, 255, 0.15)",
				borderRadius: "0.4rem",
				backdropFilter: "blur(6px)",
				fontFamily: "Outfit, sans-serif",
				fontSize: "0.7rem",
				color: "#fff",
				maxWidth: "13rem",
			}}
		>
			<span
				style={{
					fontSize: "0.55rem",
					letterSpacing: "0.08em",
					textTransform: "uppercase",
					color: "rgba(255, 255, 255, 0.5)",
				}}
			>
				Dev · trocar visao
			</span>
			{BUTTONS.map((b) => (
				<button
					key={b.label}
					type="button"
					onClick={b.fire}
					style={{
						appearance: "none",
						textAlign: "left",
						padding: "0.3rem 0.5rem",
						background: "rgba(255, 255, 255, 0.05)",
						border: "1px solid rgba(255, 255, 255, 0.1)",
						borderRadius: "0.3rem",
						color: "#fff",
						cursor: "pointer",
						fontSize: "0.7rem",
						fontFamily: "inherit",
					}}
				>
					{b.label}
				</button>
			))}
		</div>
	);
}
