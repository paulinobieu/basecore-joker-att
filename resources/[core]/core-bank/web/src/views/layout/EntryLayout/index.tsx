import { Outlet } from "react-router-dom";

/** Painel compacto da escolha de conta e do cadastro de sociedade. */
export function EntryLayout() {
	return (
		<div className="entry-shell relative flex h-[38rem] w-[28rem] flex-col rounded-[.625rem] bg-[#111114F5] outline outline-[#14141769] outline-[.5625rem]">
			<Outlet />
		</div>
	);
}
