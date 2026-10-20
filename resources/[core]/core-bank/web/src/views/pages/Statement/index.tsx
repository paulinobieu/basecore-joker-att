import { useBankStore } from "@app/stores/Bank";
import {
	IconArrowDownLeft,
	IconArrowUpRight,
	IconReceipt,
} from "@tabler/icons-react";
import { Card } from "@views/components/Card";
import { Segmented } from "@views/components/Segmented";
import { StatementList } from "@views/components/StatementList";
import { Stat } from "@views/components/Stat";
import { useMemo, useState } from "react";
import { useShallow } from "zustand/shallow";

type Filter = "all" | "in" | "out";

const FILTERS = [
	{ value: "all" as const, label: "Tudo" },
	{ value: "in" as const, label: "Entradas" },
	{ value: "out" as const, label: "Saídas" },
];

export function Statement() {
	const { account, loading } = useBankStore(
		useShallow((state) => ({ account: state.account, loading: state.loading })),
	);

	const [filter, setFilter] = useState<Filter>("all");

	const movements = account?.statement ?? [];

	const totals = useMemo(
		() =>
			movements.reduce(
				(sum, movement) => {
					if (movement.outgoing) sum.out += movement.amount;
					else sum.income += movement.amount;

					return sum;
				},
				{ income: 0, out: 0 },
			),
		[movements],
	);

	const visible = useMemo(() => {
		if (filter === "in")
			return movements.filter((movement) => !movement.outgoing);
		if (filter === "out")
			return movements.filter((movement) => movement.outgoing);

		return movements;
	}, [movements, filter]);

	return (
		<div className="flex h-full w-full flex-col gap-[.875rem] p-[1.25rem]">
			<div className="flex h-[8.5rem] flex-shrink-0 gap-[.875rem]">
				<Stat
					className="flex-1"
					label="Entradas"
					value={totals.income}
					icon={IconArrowDownLeft}
					footnote="Somando o que aparece no extrato"
				/>

				<Stat
					className="flex-1"
					label="Saídas"
					value={totals.out}
					icon={IconArrowUpRight}
					footnote="Somando o que aparece no extrato"
				/>

				<Stat
					accent
					className="flex-1"
					label="Saldo atual"
					value={account?.balance ?? 0}
					icon={IconReceipt}
					footnote={`${movements.length} ${movements.length === 1 ? "movimento" : "movimentos"} no período`}
				/>
			</div>

			<Card
				title="Extrato"
				icon={IconReceipt}
				className="min-h-0 flex-1"
				action={
					<Segmented
						options={FILTERS}
						value={filter}
						onChange={setFilter}
						className="h-[1.875rem]"
					/>
				}
			>
				<StatementList
					movements={visible}
					loading={loading}
					emptyHint="Nada movimentado nesta conta ainda"
				/>
			</Card>
		</div>
	);
}
