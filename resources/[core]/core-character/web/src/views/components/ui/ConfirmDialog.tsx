import { useConfirmStore } from "@app/stores/Confirm";
import { IconAlertTriangle } from "@tabler/icons-react";
import { useShallow } from "zustand/shallow";
import { Dialog } from "./Dialog";

export function ConfirmDialog() {
	const { request, accept, reject } = useConfirmStore(
		useShallow((state) => ({
			request: state.request,
			accept: state.accept,
			reject: state.reject,
		})),
	);

	return (
		<Dialog
			open={!!request}
			header={request?.header ?? "Confirmação"}
			className="w-[27rem]"
			footer={
				<>
					<button
						type="button"
						onClick={reject}
						className="h-7 min-w-[7rem] rounded-surface border border-white/[.03] bg-[rgba(221,221,221,.17)] font-black text-ink-muted text-xs uppercase transition-all duration-500 hover:bg-[rgba(221,221,221,.25)] hover:text-white"
					>
						{request?.rejectLabel ?? "Não"}
					</button>

					<button
						type="button"
						onClick={accept}
						className="h-7 min-w-[7rem] rounded-surface border border-white/[.15] bg-accent font-black text-white text-xs uppercase bg-blend-multiply transition-all duration-500 hover:brightness-75"
					>
						{request?.acceptLabel ?? "Sim"}
					</button>
				</>
			}
		>
			<div className="flex items-center">
				<IconAlertTriangle size={24} stroke={2} className="text-primaryColor" />
				<p className="ml-4 font-medium text-[#adadad] text-[.8125rem]">
					{request?.message}
				</p>
			</div>
		</Dialog>
	);
}
