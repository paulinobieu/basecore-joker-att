import { useCreatorStore } from "@app/stores/CreatorStore";
import { cn } from "@app/utils";
import { CloseIcon, GroupIcon } from "@views/components/icons";
import { useState } from "react";
import { creatorActions } from "../actions";

interface GroupModalProps {
	open: boolean;
	onClose: () => void;
}

export function GroupModal({ open, onClose }: GroupModalProps) {
	const group = useCreatorStore((state) => state.group);
	const [invite, setInvite] = useState("");

	const isOwner = group.isOwner === true;
	const hasGroup = typeof group.owner === "number";
	const members = group.members || [];

	function sendInvite() {
		const sid = Number(invite || 0);
		if (sid > 0) {
			creatorActions.groupInvite(sid);
			setInvite("");
		}
	}

	return (
		<div className={cn("groupModal", !open && "hidden")}>
			<div className="group-frame">
				<div className="effect-circle effect-circle--a" />
				<div className="effect-circle effect-circle--b" />

				<div className="groupCard">
					<div className="groupHead">
						<div className="groupHead-left">
							<span className="groupIcon">
								<GroupIcon />
							</span>
							<div className="groupTitle">Grupo</div>
						</div>
						<button
							className="actionBtn sq danger"
							type="button"
							onClick={onClose}
						>
							<span className="icon">
								<CloseIcon />
							</span>
						</button>
					</div>

				{(isOwner || !hasGroup) && (
					<div className="groupInviteRow">
						<input
							type="number"
							placeholder="ID do player"
							value={invite}
							onChange={(e) => setInvite(e.target.value)}
							onKeyDown={(e) => e.key === "Enter" && sendInvite()}
						/>
						<button className="btn accent" type="button" onClick={sendInvite}>
							Convidar
						</button>
					</div>
				)}

				<div className="groupList">
					{!hasGroup && (
						<div className="groupEmpty">
							<span className="groupEmpty-icon">
								<GroupIcon />
							</span>
							<span className="groupEmpty-text">
								Você ainda não tem um grupo. Convide alguém pelo ID para
								começar.
							</span>
						</div>
					)}

					{hasGroup && members.length === 0 && (
						<div className="groupEmpty">
							<span className="groupEmpty-icon">
								<GroupIcon />
							</span>
							<span className="groupEmpty-text">
								Nenhum membro no grupo ainda.
							</span>
						</div>
					)}

					{hasGroup &&
						members.map((m) => (
							<div className="groupMember" key={m.sid}>
								<div className="groupMemberName">
									{m.name} <span>{m.isOwner ? "(Líder)" : ""}</span>
								</div>

								{isOwner && !m.isOwner && (
									<button
										className="btn"
										type="button"
										onClick={() => creatorActions.groupRemove(m.sid)}
									>
										Remover
									</button>
								)}

								{!isOwner && !m.isOwner && (
									<button
										className="btn"
										type="button"
										onClick={() => creatorActions.groupLeave()}
									>
										Sair
									</button>
								)}
							</div>
						))}
				</div>
			</div>
		</div>
		</div>
	);
}
