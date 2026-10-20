import { useDoorFormStore } from "@app/stores/DoorStore";

export function GroupsTab() {
	const groups    = useDoorFormStore((s) => s.groups);
	const setGroups = useDoorFormStore((s) => s.setGroups);

	const handleChange = (value: string | number, index: number, property: "name" | "grade") => {
		setGroups((prev) =>
			prev.map((item, i) => (i === index ? { ...item, [property]: value } : item)),
		);
	};

	const handleDelete = (index: number) => {
		setGroups((prev) => prev.filter((_, i) => i !== index));
	};

	const handleAdd = () => {
		setGroups((prev) => [...prev, { name: "", grade: null }]);
	};

	return (
		<div className="flex flex-col gap-2">
			{groups.map((field, index) => (
				<div key={`group-${index}`} className="flex items-center gap-2">
					<input
						type="text"
						placeholder="Nome do Grupo"
						value={(field.name as string) || ""}
						onChange={(e) => handleChange(e.target.value, index, "name")}
						className="dl-input"
					/>
					<input
						type="number"
						placeholder="Nível"
						value={field.grade ?? ""}
						onChange={(e) => handleChange(Number(e.target.value), index, "grade")}
						className="dl-input"
						style={{ width: 80, flexShrink: 0 }}
					/>
					<button
						type="button"
						onClick={() => handleDelete(index)}
						className="dl-btn-icon danger flex-shrink-0"
						style={{ width: 36, height: 36 }}
					>
						<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
							<polyline points="3 6 5 6 21 6" />
							<path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
						</svg>
					</button>
				</div>
			))}

			<button type="button" onClick={handleAdd} className="dl-add-btn" style={{ marginTop: groups.length > 0 ? 6 : 0 }}>
				<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
					<line x1="12" y1="5" x2="12" y2="19" />
					<line x1="5" y1="12" x2="19" y2="12" />
				</svg>
				Adicionar Grupo
			</button>
		</div>
	);
}
