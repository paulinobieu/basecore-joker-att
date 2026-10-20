import { useCrafting } from "@app/stores/Crafting";
import { useNotify } from "@app/stores/Notify";
import { IconHourglassEmpty } from "@tabler/icons-react";
import { Empty } from "@views/components/Empty";
import { Panel } from "@views/components/Panel";
import { useEffect, useState } from "react";
import { useShallow } from "zustand/shallow";
import { QueueLine } from "./components/QueueLine";

export function Queue() {
	const { queue, collectCraft, cancelCraft } = useCrafting(
		useShallow((state) => ({
			queue: state.queue,
			collectCraft: state.collectCraft,
			cancelCraft: state.cancelCraft,
		})),
	);

	const pushNotify = useNotify((state) => state.pushNotify);

	const [now, setNow] = useState(() => Date.now());

	useEffect(() => {
		if (queue.length === 0) return;

		const intervalId = setInterval(() => setNow(Date.now()), 250);

		return () => clearInterval(intervalId);
	}, [queue.length]);

	const onCollect = async (id: number) => {
		const result = await collectCraft(id);

		pushNotify(result.success ? "success" : "error", result.message);
	};

	const onCancel = async (id: number) => {
		const result = await cancelCraft(id);

		pushNotify(result.success ? "success" : "error", result.message);
	};

	return (
		<Panel
			title="Fila de fabricação"
			subtitle="Retire os itens quando ficarem prontos"
			className="min-h-0 flex-1"
		>
			<div className="customScrollbar flex min-h-0 flex-1 flex-col gap-[.5rem] overflow-y-auto p-[.75rem]">
				{queue.length === 0 ? (
					<Empty
						icon={IconHourglassEmpty}
						label="Nada em produção"
						hint="O que você fabricar aparece aqui"
					/>
				) : (
					queue.map((entry) => (
						<QueueLine
							key={entry.id}
							entry={entry}
							now={now}
							onCollect={() => onCollect(entry.id)}
							onCancel={() => onCancel(entry.id)}
						/>
					))
				)}
			</div>
		</Panel>
	);
}
