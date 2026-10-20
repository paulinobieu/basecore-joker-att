import { useEscStore } from "@app/stores/Esc";

const StatusIcon = ({ color }: { color?: string }) => (
	<svg
		width="1.1875rem"
		height="1.1875rem"
		viewBox="0 0 19 19"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
	>
		<path
			d="M4.4619 14.5382C3.80027 13.8766 3.27544 13.0911 2.91737 12.2267C2.5593 11.3622 2.375 10.4357 2.375 9.50002C2.375 8.56434 2.5593 7.63783 2.91737 6.77338C3.27544 5.90893 3.80027 5.12347 4.4619 4.46185M14.5382 4.46185C15.1999 5.12347 15.7247 5.90893 16.0828 6.77338C16.4408 7.63783 16.6251 8.56434 16.6251 9.50002C16.6251 10.4357 16.4408 11.3622 16.0828 12.2267C15.7247 13.0911 15.1999 13.8766 14.5382 14.5382M6.70073 12.2994C6.33305 11.9318 6.04139 11.4954 5.8424 11.015C5.64341 10.5347 5.54099 10.0199 5.54099 9.50002C5.54099 8.98012 5.64341 8.4653 5.8424 7.98499C6.04139 7.50467 6.33305 7.06826 6.70073 6.70069M12.2994 6.70069C12.6671 7.06826 12.9587 7.50467 13.1577 7.98499C13.3567 8.4653 13.4591 8.98012 13.4591 9.50002C13.4591 10.0199 13.3567 10.5347 13.1577 11.015C12.9587 11.4954 12.6671 11.9318 12.2994 12.2994M10.2917 9.50002C10.2917 9.70998 10.2083 9.91135 10.0599 10.0598C9.91139 10.2083 9.71003 10.2917 9.50006 10.2917C9.2901 10.2917 9.08874 10.2083 8.94027 10.0598C8.7918 9.91135 8.7084 9.70998 8.7084 9.50002C8.7084 9.29006 8.7918 9.08869 8.94027 8.94023C9.08874 8.79176 9.2901 8.70835 9.50006 8.70835C9.71003 8.70835 9.91139 8.79176 10.0599 8.94023C10.2083 9.08869 10.2917 9.29006 10.2917 9.50002Z"
			stroke={color || "#C8FF49"}
			strokeWidth="1.2"
			strokeLinecap="round"
			strokeLinejoin="round"
		/>
	</svg>
);

function StatusItem({
	color,
	title,
	value,
}: {
	color: string;
	title: string;
	value: number;
}) {
	return (
		<div className="flex items-start gap-3">
			<StatusIcon color={color} />
			<div className="flex flex-col items-start justify-center">
				<span className="text-white/70 text-xs">{title}</span>
				<h1 className="font-semibold text-base">{value}</h1>
			</div>
		</div>
	);
}

export function PlayersStatus() {
	const players = useEscStore((state) => state.players);

	return (
		<div className="ml-[1.625rem] flex items-center gap-[2.5rem]">
			<StatusItem color="#C8FF49" title="Online" value={players.online} />
			<StatusItem color="#35D9F2" title="Policiais" value={players.cops} />
			<StatusItem color="#F2B13F" title="Mecânico" value={players.mechanics} />
			<StatusItem color="#D2334E" title="Médicos" value={players.medics} />
		</div>
	);
}
