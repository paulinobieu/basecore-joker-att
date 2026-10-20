import { useNotify } from "@app/stores/Notify";
import { useEffect } from "react";
import { useShallow } from "zustand/shallow";
import { Notify } from "./components/Notify";

/**
 * Fila de notificações, renderizada fora do painel.
 */
export function Notifys() {
	const { notifys, removeNotify } = useNotify(
		useShallow((state) => ({
			notifys: state.notifys,
			removeNotify: state.removeNotify,
		})),
	);

	useEffect(() => {
		if (notifys.length === 0) return;

		const timers = notifys.map((notify) =>
			setTimeout(() => removeNotify(notify.id), notify.time),
		);

		return () => {
			for (const timer of timers) clearTimeout(timer);
		};
	}, [notifys, removeNotify]);

	return (
		<div className="-translate-x-1/2 pointer-events-none fixed bottom-10 left-1/2 z-[999] flex flex-col items-center gap-4">
			{notifys.map((notify) => (
				<Notify key={notify.id} {...notify} />
			))}
		</div>
	);
}
