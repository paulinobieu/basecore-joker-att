import { useDoorFormStore } from "@app/stores/DoorStore";

export function CharactersTab() {
	const characters  = useDoorFormStore((s) => s.characters);
	const setCharacters = useDoorFormStore((s) => s.setCharacters);

	const handleChange = (value: string, index: number) => {
		setCharacters((prev) => prev.map((item, i) => (i === index ? value : item)));
	};

	const handleDelete = (index: number) => {
		setCharacters((prev) => prev.filter((_, i) => i !== index));
	};

	const handleAdd = () => {
		setCharacters((prev) => [...prev, ""]);
	};

	return (
		<div className="flex flex-col gap-2">
			{characters.map((field, index) => (
				<div key={`char-${index}`} className="flex items-center gap-2">
					<input
						type="text"
						placeholder="ID do Personagem"
						value={(field as string) || ""}
						onChange={(e) => handleChange(e.target.value, index)}
						className="dl-input"
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

			<button type="button" onClick={handleAdd} className="dl-add-btn" style={{ marginTop: characters.length > 0 ? 6 : 0 }}>
				<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
					<line x1="12" y1="5" x2="12" y2="19" />
					<line x1="5" y1="12" x2="19" y2="12" />
				</svg>
				Adicionar Personagem
			</button>
		</div>
	);
}
