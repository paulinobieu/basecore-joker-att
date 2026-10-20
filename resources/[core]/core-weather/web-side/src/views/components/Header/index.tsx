import { useVisibilityStore } from "@app/stores/Visibility";
import { IconTemperatureSun, IconX } from "@tabler/icons-react";

export function Header() {
	const fetchHideFrame = useVisibilityStore((state) => state.fetchHideFrame);

	return (
		<header className="panel-header">
			<span className="panel-header-icon">
				<IconTemperatureSun size={19} stroke={2} />
			</span>
			<span className="panel-header-title">Clima & Horário</span>
			<button type="button" className="panel-close" onClick={fetchHideFrame}>
				<IconX size={14} stroke={2.5} />
			</button>
		</header>
	);
}
