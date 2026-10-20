import { useDoorFormStore, useDoorsStore, useSearchStore, useClipboardStore, type DoorColumn, getDefaultFormState } from "@app/stores/DoorStore";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { convertData } from "@app/utils/convertData";
import { fetchNuiSimple } from "@app/utils/fetchNui";
import useDebounce from "@app/hooks/useDebounce";
import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";

export function DoorsList() {
	const doors = useDoorsStore((s) => s.doors);
	const navigate = useNavigate();
	const loadDoor = useDoorFormStore((s) => s.loadDoor);
	const resetForm = useDoorFormStore((s) => s.resetForm);
	const setVisible = useVisibilityStore((s) => s.setVisible);
	const setClipboard = useClipboardStore((s) => s.setClipboard);

	const [search, setSearch] = useState("");
	const debouncedSearch = useDebounce(search, 300);
	const [currentPage, setCurrentPage] = useState(1);
	const [sortKey, setSortKey] = useState<"id" | "name" | "zone">("id");
	const [sortDir, setSortDir] = useState<"asc" | "desc">("asc");

	const pageSize = 6;

	const filteredDoors = useMemo(() => {
		let result = [...doors];

		if (debouncedSearch) {
			const lower = debouncedSearch.toLowerCase();
			result = result.filter(
				(d) =>
					d.name?.toLowerCase().includes(lower) ||
					d.zone?.toLowerCase().includes(lower),
			);
		}

		result.sort((a, b) => {
			const aVal = a[sortKey];
			const bVal = b[sortKey];
			if (typeof aVal === "number" && typeof bVal === "number") {
				return sortDir === "asc" ? aVal - bVal : bVal - aVal;
			}
			const aStr = String(aVal || "").toLowerCase();
			const bStr = String(bVal || "").toLowerCase();
			return sortDir === "asc"
				? aStr.localeCompare(bStr)
				: bStr.localeCompare(aStr);
		});

		return result;
	}, [doors, debouncedSearch, sortKey, sortDir]);

	const totalPages = Math.max(1, Math.ceil(filteredDoors.length / pageSize));
	const pagedDoors = filteredDoors.slice(
		(currentPage - 1) * pageSize,
		currentPage * pageSize,
	);

	useEffect(() => {
		setCurrentPage(1);
	}, [debouncedSearch]);

	const handleSort = (key: "id" | "name" | "zone") => {
		if (sortKey === key) {
			setSortDir((d) => (d === "asc" ? "desc" : "asc"));
		} else {
			setSortKey(key);
			setSortDir("asc");
		}
	};

	const SortIcon = ({ column }: { column: string }) => {
		if (sortKey !== column)
			return (
				<svg className="ml-1 inline h-3 w-3 opacity-20" viewBox="0 0 24 24" fill="currentColor">
					<path d="M7 10l5-5 5 5H7zm0 4l5 5 5-5H7z" />
				</svg>
			);
		return sortDir === "asc" ? (
			<svg className="ml-1 inline h-3 w-3 text-primaryColor" viewBox="0 0 24 24" fill="currentColor">
				<path d="M7 14l5-5 5 5H7z" />
			</svg>
		) : (
			<svg className="ml-1 inline h-3 w-3 text-primaryColor" viewBox="0 0 24 24" fill="currentColor">
				<path d="M7 10l5 5 5-5H7z" />
			</svg>
		);
	};

	const handleEdit = (door: DoorColumn) => {
		loadDoor(convertData(door));
		navigate("/settings/general");
	};

	const handleCreate = () => {
		resetForm();
		navigate("/settings/general");
	};

	const handleDelete = (door: DoorColumn) => {
		fetchNuiSimple("deleteDoor", door.id);
	};

	const handleCopy = (door: DoorColumn) => {
		setClipboard(convertData(door));
		fetchNuiSimple("notify", "Configurações copiadas");
	};

	const handleTeleport = (door: DoorColumn) => {
		setVisible(false);
		fetchNuiSimple("teleportToDoor", door.id);
	};

	return (
		<div className="flex flex-col gap-0 animate-in">
			{/* Toolbar */}
			<div className="dl-toolbar">
				<button type="button" onClick={handleCreate} className="dl-btn-new">
					<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
						<line x1="12" y1="5" x2="12" y2="19" />
						<line x1="5" y1="12" x2="19" y2="12" />
					</svg>
					Nova Porta
				</button>

				<div className="relative flex-1">
					<svg
						className="absolute top-1/2 left-3 h-3.5 w-3.5 -translate-y-1/2 pointer-events-none"
						style={{ color: 'var(--text-dimmed)' }}
						viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"
					>
						<circle cx="11" cy="11" r="8" />
						<line x1="21" y1="21" x2="16.65" y2="16.65" />
					</svg>
					<input
						type="text"
						placeholder="Buscar portas..."
						value={search}
						onChange={(e) => setSearch(e.target.value)}
						className="dl-search"
					/>
				</div>

				<button
					type="button"
					onClick={() => { setVisible(false); fetchNuiSimple("exit"); }}
					className="dl-btn-icon"
					style={{ width: 36, height: 36 }}
				>
					<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
						<line x1="18" y1="6" x2="6" y2="18" />
						<line x1="6" y1="6" x2="18" y2="18" />
					</svg>
				</button>
			</div>

			{/* Table — fixed height matching tab content */}
			<div className="dl-tab-content" style={{ display: 'flex', flexDirection: 'column' }}>
			{filteredDoors.length > 0 ? (
				<div className="flex flex-col" style={{ flex: 1 }}>
					<div className="dl-table-wrap">
						<table className="dl-table">
							<thead>
								<tr>
									<th onClick={() => handleSort("id")}>
										ID <SortIcon column="id" />
									</th>
									<th onClick={() => handleSort("name")}>
										Nome <SortIcon column="name" />
									</th>
									<th onClick={() => handleSort("zone")}>
										Zona <SortIcon column="zone" />
									</th>
									<th>Ações</th>
								</tr>
							</thead>
							<tbody>
								{pagedDoors.map((door) => (
									<tr key={door.id}>
										<td>
											<span className="dl-id-badge">#{door.id}</span>
										</td>
										<td style={{ color: 'var(--text-secondary)', fontWeight: 600 }}>
											{door.name || "Sem nome"}
										</td>
										<td style={{ color: 'var(--text-muted)', fontSize: 11 }}>
											{door.zone || "—"}
										</td>
										<td>
											<div className="dl-row-actions">
												<button
													type="button"
													onClick={() => handleEdit(door)}
													className="dl-row-btn blue"
													title="Configurações"
												>
													<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
														<path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z" />
														<circle cx="12" cy="12" r="3" />
													</svg>
												</button>
												<button
													type="button"
													onClick={() => handleCopy(door)}
													className="dl-row-btn green"
													title="Copiar configurações"
												>
													<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
														<rect x="9" y="9" width="13" height="13" rx="2" ry="2" />
														<path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
													</svg>
												</button>
												<button
													type="button"
													onClick={() => handleTeleport(door)}
													className="dl-row-btn cyan"
													title="Teleportar"
												>
													<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
														<path d="M3 3l7.07 16.97 2.51-7.39 7.39-2.51L3 3z" />
														<path d="M13 13l6 6" />
													</svg>
												</button>
												<button
													type="button"
													onClick={() => handleDelete(door)}
													className="dl-row-btn red"
													title="Excluir"
												>
													<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
														<polyline points="3 6 5 6 21 6" />
														<path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
													</svg>
												</button>
											</div>
										</td>
									</tr>
								))}
							</tbody>
						</table>
					</div>

					<div className="flex-1" />

					{/* Pagination */}
					<div className={cn("dl-pagination", totalPages <= 1 && "invisible")}>
						{Array.from({ length: totalPages }, (_, i) => i + 1).map((page) => (
							<button
								key={page}
								type="button"
								onClick={() => setCurrentPage(page)}
								className={cn("dl-page-btn", page === currentPage && "active")}
							>
								{page}
							</button>
						))}
					</div>
				</div>
			) : (
				<div className="dl-empty" style={{ flex: 1 }}>
					<svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
						<circle cx="11" cy="11" r="8" />
						<line x1="21" y1="21" x2="16.65" y2="16.65" />
					</svg>
					<span style={{ fontSize: 13, fontWeight: 500 }}>Nenhuma porta encontrada</span>
				</div>
			)}
			</div>

			{/* Invisible spacer — same height as DoorSettings action bar so panel doesn't resize on nav */}
			<div style={{ height: 40, marginTop: 10, flexShrink: 0 }} aria-hidden="true" />
		</div>
	);
}
