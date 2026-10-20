import { useVisibilityStore } from "@app/stores/Visibility";
import { formatTotemName } from "@app/utils/format";
import { IconToolsKitchen2, IconX } from "@tabler/icons-react";

interface HeaderProps {
	totemId: string;
}

export function Header({ totemId }: HeaderProps) {
	const close = useVisibilityStore((state) => state.fetchHideFrame);

	return (
		<header className="totem-header">
			<span className="restaurant-icon">
				<IconToolsKitchen2 className="size-[1.1rem]" stroke={2} />
			</span>
			<h1>{formatTotemName(totemId)}</h1>
			<button
				type="button"
				className="close-button"
				onClick={close}
				aria-label="Fechar totem"
			>
				<IconX className="size-4" stroke={2} />
			</button>
		</header>
	);
}
