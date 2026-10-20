import { useCallsStore } from "@app/stores/Calls";
import { debugData } from "@app/utils/debugData";
import { ActiveHint } from "@views/components/ActiveHint";
import { DevSwitcher } from "@views/components/DevSwitcher";
import { FeedbackView } from "@views/components/FeedbackView";
import { IncomingToast } from "@views/components/IncomingToast";
import { PromptView } from "@views/components/PromptView";
import { StaffActionsView } from "@views/components/StaffActionsView";
import { StaffPanelView } from "@views/components/StaffPanelView";

// Bootstrap so o overlay aparece visivel em dev. Os botoes do DevSwitcher
// disparam as outras visoes.
debugData(
	[
		{
			action: "setConfig",
			payload: {
				theme: { hex: "#0143bb", rgb: "1, 67, 187" },
				keys: { accept: "Y", decline: "U", staff: "F2", finish: "F7" },
			},
		},
		{
			action: "openPanel",
			payload: {
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
			},
		},
	],
	0,
);

export function Home() {
	const surface = useCallsStore((s) => s.surface);

	return (
		<>
			{surface === "prompt" && <PromptView />}
			{surface === "panel" && <StaffPanelView />}
			{surface === "feedback" && <FeedbackView />}
			{surface === "staff" && <StaffActionsView />}

			<IncomingToast />
			<ActiveHint />

			<DevSwitcher />
		</>
	);
}
