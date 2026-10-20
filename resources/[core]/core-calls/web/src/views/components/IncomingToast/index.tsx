import { useCallsStore } from "@app/stores/Calls";
import { fetchNui } from "@app/utils/fetchNui";
import { Badge, GlyphBell } from "@views/components/Badge";
import { useEffect } from "react";
import { useShallow } from "zustand/shallow";

export function IncomingToast() {
	const { incoming, keys, setIncoming } = useCallsStore(
		useShallow((s) => ({
			incoming: s.incoming,
			keys: s.keys,
			setIncoming: s.setIncoming,
		})),
	);

	useEffect(() => {
		if (!incoming) return;
		const id = setTimeout(() => setIncoming(null), incoming.time * 1000);
		return () => clearTimeout(id);
	}, [incoming, setIncoming]);

	if (!incoming) return null;

	const onAccept = async () => {
		setIncoming(null);
		await fetchNui({
			path: "acceptTicket",
			payload: { id: incoming.id },
			mockData: { ok: true },
		});
	};

	const onDecline = async () => {
		setIncoming(null);
		await fetchNui({ path: "dismissIncoming", mockData: { ok: true } });
	};

	return (
		<div className="incoming-toast">
			<div className="incoming-bar">
				<span style={{ animationDuration: `${incoming.time}s` }} />
			</div>

			<div className="incoming-body">
				<div className="incoming-icon">
					<Badge compact>
						<GlyphBell />
					</Badge>
				</div>
				<div className="incoming-info">
					<div className="incoming-label">Chamado recebido</div>
					<div className="incoming-name">
						{incoming.name}
						<small>#{incoming.id}</small>
					</div>
					<p className="incoming-text">{incoming.text}</p>
				</div>
			</div>

			<div className="incoming-actions">
				<button type="button" className="accept" onClick={onAccept}>
					ACEITAR
					<kbd>{keys.accept}</kbd>
				</button>
				<button type="button" className="decline" onClick={onDecline}>
					IGNORAR
					<kbd>{keys.decline}</kbd>
				</button>
			</div>
		</div>
	);
}
