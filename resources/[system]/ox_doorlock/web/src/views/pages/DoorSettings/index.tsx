import {
	useDoorFormStore,
	useClipboardStore,
	type DoorFormState,
} from "@app/stores/DoorStore";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { fetchNuiSimple } from "@app/utils/fetchNui";
import { useState } from "react";
import { useNavigate, Route, Routes } from "react-router-dom";
import { GeneralTab } from "./tabs/GeneralTab";
import { CharactersTab } from "./tabs/CharactersTab";
import { GroupsTab } from "./tabs/GroupsTab";
import { ItemsTab } from "./tabs/ItemsTab";
import { LockpickTab } from "./tabs/LockpickTab";
import { SoundTab } from "./tabs/SoundTab";

const tabs = [
	{ id: "general",    label: "Geral",       icon: "settings"  },
	{ id: "characters", label: "Personagens",  icon: "user"      },
	{ id: "groups",     label: "Grupos",       icon: "briefcase" },
	{ id: "items",      label: "Itens",        icon: "package"   },
	{ id: "lockpick",   label: "Lockpick",     icon: "lock"      },
	{ id: "sound",      label: "Som",          icon: "volume"    },
] as const;

const TabIcon = ({ icon }: { icon: string }) => {
	const cls = "flex-shrink-0";
	switch (icon) {
		case "settings":
			return <svg className={cls} width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z" /><circle cx="12" cy="12" r="3" /></svg>;
		case "user":
			return <svg className={cls} width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" /><circle cx="12" cy="7" r="4" /></svg>;
		case "briefcase":
			return <svg className={cls} width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="2" y="7" width="20" height="14" rx="2" ry="2" /><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16" /></svg>;
		case "package":
			return <svg className={cls} width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M16.5 9.4l-9-5.19M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" /><polyline points="3.27 6.96 12 12.01 20.73 6.96" /><line x1="12" y1="22.08" x2="12" y2="12" /></svg>;
		case "lock":
			return <svg className={cls} width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2" /><path d="M7 11V7a5 5 0 0 1 10 0v4" /></svg>;
		case "volume":
			return <svg className={cls} width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" /><path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07" /></svg>;
		default: return null;
	}
};

export function DoorSettings() {
	const navigate = useNavigate();
	const setVisible = useVisibilityStore((s) => s.setVisible);
	const clipboard = useClipboardStore((s) => s.clipboard);
	const setClipboard = useClipboardStore((s) => s.setClipboard);
	const lockpick = useDoorFormStore((s) => s.lockpick);
	const doorId = useDoorFormStore((s) => s.id);
	const loadDoor = useDoorFormStore((s) => s.loadDoor);
	const [activeTab, setActiveTab] = useState("general");
	const [confirmDelete, setConfirmDelete] = useState(false);

	const handleTabClick = (tabId: string) => {
		if (tabId === "lockpick" && !lockpick) return;
		setActiveTab(tabId);
		navigate(`/settings/${tabId}`);
	};

	const handleSubmit = () => {
		const data = { ...useDoorFormStore.getState() };

		if (data.name === "") data.name = null;
		if (data.passcode === "") data.passcode = null;
		if (data.lockSound === "") data.lockSound = null;
		if (data.unlockSound === "") data.unlockSound = null;

		data.autolock = data.autolock || null;
		data.maxDistance = data.maxDistance || 2;
		data.doorRate = data.doorRate ? data.doorRate + 0.0 : null;
		data.auto = data.auto || null;
		data.lockpick = data.lockpick || null;
		data.hideUi = data.hideUi || null;
		data.holdOpen = data.holdOpen || null;

		if (data.items && data.items.length > 0) {
			const items = [];
			for (const itemField of data.items) {
				if (itemField.name && itemField.name !== "") {
					if (itemField.metadata === "") itemField.metadata = null;
					if (!itemField.remove) itemField.remove = null;
					items.push(itemField);
				}
			}
			data.items = items;
		}

		if (data.characters && data.characters.length > 0) {
			const arr: Array<string | number> = [];
			for (const c of data.characters) {
				if (c && c !== "") arr.push(Number.isNaN(+c) ? c : +c);
			}
			// @ts-ignore
			data.characters = arr;
		}

		if (data.groups && data.groups.length > 0) {
			const obj: { [key: string]: number } = {};
			for (const g of data.groups) {
				if (g.name && g.name !== "") obj[g.name] = g.grade || 0;
			}
			// @ts-ignore
			data.groups = obj;
		} else {
			// @ts-ignore
			data.groups = null;
		}

		if (data.lockpickDifficulty && data.lockpickDifficulty.length > 0) {
			const arr = [];
			for (const f of data.lockpickDifficulty) {
				if (f !== "") arr.push(f);
			}
			data.lockpickDifficulty = arr;
		}

		setVisible(false);
		fetchNuiSimple("createDoor", data);
	};

	const handleDelete = () => {
		if (!doorId) return;
		fetchNuiSimple("deleteDoor", doorId);
		navigate("/home");
	};

	const handlePasteClipboard = () => {
		if (!clipboard) return;
		loadDoor({
			...clipboard,
			name: "",
			id: useDoorFormStore.getState().id,
		});
		fetchNuiSimple("notify", "Configurações aplicadas");
	};

	return (
		<div className="flex flex-col gap-0 animate-in">
			{/* Tab bar */}
			<div className="dl-tab-bar">
				<button type="button" onClick={() => navigate("/home")} className="dl-tab-back">
					<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
						<line x1="19" y1="12" x2="5" y2="12" />
						<polyline points="12 19 5 12 12 5" />
					</svg>
					Voltar
				</button>

				{tabs.map((tab) => (
					<button
						key={tab.id}
						type="button"
						onClick={() => handleTabClick(tab.id)}
						disabled={tab.id === "lockpick" && !lockpick}
						className={cn("dl-tab", activeTab === tab.id && "active")}
					>
						<TabIcon icon={tab.icon} />
						{tab.label}
					</button>
				))}
			</div>

			{/* Fixed-height tab content */}
			<div className="dl-tab-content">
				<Routes>
					<Route path="/general"    element={<GeneralTab />} />
					<Route path="/characters" element={<CharactersTab />} />
					<Route path="/groups"     element={<GroupsTab />} />
					<Route path="/items"      element={<ItemsTab />} />
					<Route path="/lockpick"   element={<LockpickTab />} />
					<Route path="/sound"      element={<SoundTab />} />
				</Routes>
			</div>

			{/* Action bar */}
			<div className="dl-action-bar">
				<button type="button" onClick={handleSubmit} className="dl-btn-confirm">
					<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
						<polyline points="20 6 9 17 4 12" />
					</svg>
					Confirmar Porta
				</button>

				{/* Paste clipboard */}
				<button
					type="button"
					onClick={handlePasteClipboard}
					disabled={!clipboard}
					className={cn("dl-btn-icon", clipboard ? "accent" : "")}
					title={clipboard ? "Aplicar configurações copiadas" : "Sem configurações copiadas"}
				>
					<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
						<path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2" />
						<rect x="8" y="2" width="8" height="4" rx="1" ry="1" />
						<path d="M9 14l2 2 4-4" />
					</svg>
				</button>

				{/* Delete */}
				{confirmDelete ? (
					<>
						<button type="button" onClick={handleDelete} className="dl-btn-danger-confirm">
							<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><polyline points="20 6 9 17 4 12" /></svg>
							Confirmar
						</button>
						<button type="button" onClick={() => setConfirmDelete(false)} className="dl-btn-cancel">
							Cancelar
						</button>
					</>
				) : (
					<button
						type="button"
						onClick={() => doorId && setConfirmDelete(true)}
						disabled={!doorId}
						className={cn("dl-btn-icon", doorId ? "danger" : "")}
						title="Excluir porta"
					>
						<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
							<polyline points="3 6 5 6 21 6" />
							<path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
						</svg>
					</button>
				)}
			</div>
		</div>
	);
}
