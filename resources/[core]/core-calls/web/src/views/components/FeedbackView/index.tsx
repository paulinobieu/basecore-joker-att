import { useCallsStore } from "@app/stores/Calls";
import { useVisibilityStore } from "@app/stores/Visibility";
import { fetchNui } from "@app/utils/fetchNui";
import { Badge, GlyphStar } from "@views/components/Badge";
import { useState } from "react";
import { useShallow } from "zustand/shallow";

const LABELS = ["Pessimo", "Ruim", "Razoavel", "Bom", "Otimo"];

export function FeedbackView() {
	const { feedback, closeSurface } = useCallsStore(
		useShallow((s) => ({
			feedback: s.feedback,
			closeSurface: s.closeSurface,
		})),
	);
	const fetchHideFrame = useVisibilityStore((s) => s.fetchHideFrame);
	const [stars, setStars] = useState(5);
	const [sending, setSending] = useState(false);

	if (!feedback) return null;

	const submit = async () => {
		if (sending) return;
		setSending(true);
		closeSurface();
		await fetchNui({
			path: "submitFeedback",
			payload: { stars },
			mockData: { ok: true },
		});
		fetchHideFrame();
	};

	return (
		<div className="app-container size-feedback">
			<header className="app-header">
				<div className="app-header-brand">
					<span className="app-header-badge">
						<Badge>
							<GlyphStar />
						</Badge>
					</span>
					<div className="app-header-info">
						<span className="app-header-title">Chamado finalizado</span>
						<span className="app-header-subtitle">Avalie o atendimento</span>
					</div>
				</div>
			</header>

			<div className="app-main">
				<div className="feedback-info">
					<span>
						Atendido por <b>{feedback.name}</b>
					</span>
					<span>
						Cargo <b>{feedback.role}</b>
					</span>
				</div>

				<label className="field-label">Como foi o atendimento?</label>
				<div className="stars-row">
					{[1, 2, 3, 4, 5].map((n) => (
						<button
							key={n}
							type="button"
							className={`star-btn ${stars >= n ? "active" : ""}`}
							onClick={() => setStars(n)}
						>
							★ {n}
						</button>
					))}
				</div>
				<div className="stars-label">{LABELS[stars - 1]}</div>

				<div style={{ marginTop: "0.85rem" }}>
					<button
						type="button"
						className="btn-primary"
						onClick={submit}
						disabled={sending}
					>
						{sending ? "Enviando..." : "Confirmar feedback"}
					</button>
				</div>
			</div>

			<footer className="app-footer">
				<span>Sua avaliacao ajuda a melhorar o atendimento</span>
			</footer>
		</div>
	);
}
