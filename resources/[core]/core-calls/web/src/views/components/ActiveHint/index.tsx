import { useCallsStore } from "@app/stores/Calls";
import { Badge, GlyphHeadset } from "@views/components/Badge";
import { useShallow } from "zustand/shallow";

export function ActiveHint() {
	const { ticketActive, keys } = useCallsStore(
		useShallow((s) => ({
			ticketActive: s.ticketActive,
			keys: s.keys,
		})),
	);

	if (!ticketActive) return null;

	return (
		<div className="active-hint">
			<div className="active-hint-inner">
				<div className="active-hint-icon">
					<Badge compact>
						<GlyphHeadset />
					</Badge>
				</div>
				<div>
					<div className="active-hint-text">
						<kbd>{keys.staff}</kbd> acoes rapidas
					</div>
					<div className="active-hint-meta">
						#{ticketActive.id} • {ticketActive.name}
					</div>
				</div>
			</div>
		</div>
	);
}
