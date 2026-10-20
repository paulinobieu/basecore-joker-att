import { useClickSound } from "@app/hooks/useClickSound";
import { useLayout } from "@app/hooks/useLayout";
import { useNuiEvent } from "@app/hooks/useNuiEvent";
import {
	type DoorColumn,
	useDoorFormStore,
	useDoorsStore,
} from "@app/stores/DoorStore";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { convertData } from "@app/utils/convertData";
import { debugData } from "@app/utils/debugData";
import { ErrorBoundary } from "@views/components/ErrorBoundary";
import { useEffect } from "react";
import { Outlet, useNavigate } from "react-router-dom";

debugData<DoorColumn[]>(
	[
		{
			action: "updateDoorData",
			data: [
				{
					name: "Porta MRPD Principal",
					passcode: "policia123",
					autolock: 300,
					id: 0,
					zone: "Mission Row",
					characters: ["charid1", "charid2"],
					groups: { police: 0, ambulance: 1 },
					items: [
						{ name: "mrpd_key", metadata: "lspd_key", remove: true },
					],
					lockpickDifficulty: [],
					lockSound: null,
					unlockSound: null,
					maxDistance: 15.2,
					state: true,
					doors: true,
					auto: true,
					lockpick: true,
					hideUi: true,
					doorRate: null,
					holdOpen: true,
				},
				{
					name: "Porta Hospital",
					passcode: "",
					autolock: 0,
					id: 1,
					zone: "Pillbox Hill",
					characters: [],
					groups: { ambulance: 0 },
					items: [],
					lockpickDifficulty: [],
					lockSound: null,
					unlockSound: null,
					maxDistance: 5,
					state: false,
					doors: false,
					auto: false,
					lockpick: false,
					hideUi: false,
					doorRate: null,
					holdOpen: false,
				},
			] as any,
		},
	],
	500,
);

debugData<string[]>([
	{
		action: "setSoundFiles",
		data: ["button-remote", "door-bolt-4", "metal-locker", "metallic-creak"],
	},
]);

export function Layout() {
	const { visible, setVisible } = useVisibilityStore();
	const navigate = useNavigate();
	const doors = useDoorsStore((s) => s.doors);
	const setDoors = useDoorsStore((s) => s.setDoors);
	const loadDoor = useDoorFormStore((s) => s.loadDoor);
	const setSounds = useDoorFormStore((s) => s.setSounds);

	useLayout();
	useClickSound();

	useNuiEvent("playSound", async (data: { sound: string; volume: number }) => {
		const sound = new Audio(`./sounds/${data.sound}.ogg`);
		sound.volume = data.volume;
		await sound.play();
	});

	useNuiEvent("setSoundFiles", (data: string[]) => setSounds(data));

	useNuiEvent("setVisible", (data: number | undefined) => {
		setVisible(true);
		if (data === undefined) {
			navigate("home", { replace: true });
			return;
		}
		for (let i = 0; i < doors.length; i++) {
			if (doors[i].id === data) {
				loadDoor(convertData(doors[i]));
				navigate("settings/general", { replace: true });
				break;
			}
		}
	});

	useNuiEvent(
		"updateDoorData",
		(data: DoorColumn | DoorColumn[] | number) => {
			if (typeof data === "number") {
				setDoors(doors.filter((door) => door.id !== data));
				return;
			}

			if (Array.isArray(data)) {
				setDoors(data);
				return;
			}

			if (data.hasOwnProperty("id") && typeof (data as DoorColumn).id === "number") {
				const singleDoor = data as DoorColumn;
				let found = false;
				const updated = doors.map((d) => {
					if (d.id === singleDoor.id) {
						found = true;
						return singleDoor;
					}
					return d;
				});
				if (!found) updated.push(singleDoor);
				setDoors(updated);
				return;
			}

			setDoors(Object.values(data));
		},
	);

	return (
		<>
			<div
				className={cn(
					"absolute top-1/2 left-1/2 z-[2] transition-all duration-500",
					visible
						? "panel-animate-in"
						: "pointer-events-none -translate-x-1/2 -translate-y-1/2 opacity-0",
				)}
			>
				<div className="dl-frame">
					<div className="effect-circle effect-circle--a" />
					<div className="effect-circle effect-circle--b" />

					<div className="dl-panel">
						{/* Header */}
						<div className="dl-header">
							<div className="dl-header-icon">
								<svg
									xmlns="http://www.w3.org/2000/svg"
									width="20" height="20"
									viewBox="0 0 24 24"
									fill="none"
									stroke="currentColor"
									strokeWidth="2"
									strokeLinecap="round"
									strokeLinejoin="round"
								>
									<rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
									<path d="M7 11V7a5 5 0 0 1 10 0v4" />
								</svg>
							</div>
							<div className="dl-header-info">
								<span className="dl-header-title">DOORS</span>
								<span className="dl-header-subtitle">Gerencia e crie novas trancas</span>
							</div>
						</div>

						<div className="dl-divider" />

						{/* Page content */}
						<div className="dl-panel-content">
							<ErrorBoundary>
								<Outlet />
							</ErrorBoundary>
						</div>
					</div>
				</div>
			</div>
		</>
	);
}
