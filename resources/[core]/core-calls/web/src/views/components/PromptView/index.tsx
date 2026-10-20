import { useCallsStore } from "@app/stores/Calls";
import { useVisibilityStore } from "@app/stores/Visibility";
import { fetchNui } from "@app/utils/fetchNui";
import { Badge, GlyphChat } from "@views/components/Badge";
import { useState } from "react";

export function PromptView() {
	const closeSurface = useCallsStore((s) => s.closeSurface);
	const fetchHideFrame = useVisibilityStore((s) => s.fetchHideFrame);
	const [text, setText] = useState("");
	const [loading, setLoading] = useState(false);

	const submit = async () => {
		const trimmed = text.trim();
		if (!trimmed || loading) return;
		setLoading(true);
		closeSurface();
		await fetchNui({
			path: "submitTicket",
			payload: { text: trimmed },
			mockData: { ok: true },
		});
		setText("");
		setLoading(false);
		fetchHideFrame();
	};

	const handleClose = () => {
		closeSurface();
		fetchHideFrame();
	};

	return (
		<div className="app-container size-prompt">
			<header className="app-header">
				<div className="app-header-brand">
					<span className="app-header-badge">
						<Badge>
							<GlyphChat />
						</Badge>
					</span>
					<div className="app-header-info">
						<span className="app-header-title">Chamado</span>
						<span className="app-header-subtitle">Solicitar suporte</span>
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
				<label className="field-label" htmlFor="callsPromptText">
					Descreva o motivo
				</label>
				<textarea
					id="callsPromptText"
					className="field-textarea"
					value={text}
					onChange={(e) => setText(e.target.value)}
					onKeyDown={(e) => {
						if (e.key === "Enter" && (e.ctrlKey || e.metaKey)) submit();
					}}
					placeholder="Explique brevemente o motivo do chamado..."
					spellCheck={false}
					autoFocus
					rows={4}
				/>
				<span className="field-hint">Ctrl+Enter para enviar</span>

				<div style={{ marginTop: "0.75rem" }}>
					<button
						type="button"
						className="btn-primary"
						onClick={submit}
						disabled={loading || !text.trim()}
					>
						{loading ? "Enviando..." : "Enviar chamado"}
					</button>
				</div>
			</div>

			<footer className="app-footer">
				<span>Aguarde retorno de um membro da staff</span>
				<span>
					<kbd>ESC</kbd>fechar
				</span>
			</footer>
		</div>
	);
}
