import { useCallsStore } from "@app/stores/Calls";
import { useVisibilityStore } from "@app/stores/Visibility";
import { fetchNui } from "@app/utils/fetchNui";
import { Badge, GlyphShieldTool } from "@views/components/Badge";
import { useState } from "react";
import { useShallow } from "zustand/shallow";

type ActionKey = "revive" | "tpTo" | "pull" | "garage";

interface ActionDef {
	key: ActionKey;
	label: string;
	path: string;
	icon: React.ReactNode;
}

const ACTIONS: ActionDef[] = [
	{
		key: "revive",
		label: "Reviver",
		path: "staffRevive",
		icon: (
			<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
				<path d="M12 2L4 6v6c0 5 3.5 9.5 8 10 4.5-.5 8-5 8-10V6l-8-4z" />
				<path d="M9 12h6M12 9v6" />
			</svg>
		),
	},
	{
		key: "tpTo",
		label: "Teleportar ate o jogador",
		path: "staffTpTo",
		icon: (
			<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
				<path d="M5 12h12M11 6l6 6-6 6" />
			</svg>
		),
	},
	{
		key: "pull",
		label: "Puxar jogador",
		path: "staffPullPlayer",
		icon: (
			<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
				<path d="M19 12H7M13 6l-6 6 6 6" />
			</svg>
		),
	},
	{
		key: "garage",
		label: "Enviar para garagem",
		path: "staffSendToGarage",
		icon: (
			<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
				<path d="M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-3v-7H7v7H4a1 1 0 0 1-1-1v-9z" />
				<path d="M7 14h10M7 17h10" />
			</svg>
		),
	},
];

export function StaffActionsView() {
	const { staffMenu, keys, closeSurface } = useCallsStore(
		useShallow((s) => ({
			staffMenu: s.staffMenu,
			keys: s.keys,
			closeSurface: s.closeSurface,
		})),
	);
	const fetchHideFrame = useVisibilityStore((s) => s.fetchHideFrame);
	const [busy, setBusy] = useState<ActionKey | null>(null);

	if (!staffMenu) return null;

	const run = async (action: ActionDef) => {
		if (busy) return;
		setBusy(action.key);
		await fetchNui({ path: action.path, mockData: { ok: true } });
		setBusy(null);
		if (action.key === "tpTo" || action.key === "pull") {
			closeSurface();
			fetchHideFrame();
		}
	};

	const handleClose = () => {
		closeSurface();
		fetchHideFrame();
	};

	return (
		<div className="app-container size-staff">
			<header className="app-header">
				<div className="app-header-brand">
					<span className="app-header-badge">
						<Badge>
							<GlyphShieldTool />
						</Badge>
					</span>
					<div className="app-header-info">
						<span className="app-header-title">Menu Staff</span>
						<span className="app-header-subtitle">Acoes rapidas</span>
					</div>
				</div>
				<button
					type="button"
					className="app-header-close"
					onClick={handleClose}
					aria-label="Fechar"
				>
					<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="14" height="14">
						<path d="M18 6L6 18M6 6L18 18" />
					</svg>
				</button>
			</header>

			<div className="app-main">
				<div className="staff-card">
					<span>
						Atendendo <b>#{staffMenu.id}</b>
					</span>
					<b>{staffMenu.name}</b>
				</div>

				<div className="staff-list">
					{ACTIONS.map((a) => (
						<button
							key={a.key}
							type="button"
							className="staff-action"
							disabled={busy !== null && busy !== a.key}
							onClick={() => run(a)}
						>
							<span className="staff-action-icon">{a.icon}</span>
							<span className="staff-action-label">{a.label}</span>
							{busy === a.key && <span className="staff-action-busy">...</span>}
						</button>
					))}
				</div>
			</div>

			<footer className="app-footer">
				<span>
					Finalize com <kbd>{keys.finish}</kbd>
				</span>
				<span>
					<kbd>ESC</kbd>fechar
				</span>
			</footer>
		</div>
	);
}

