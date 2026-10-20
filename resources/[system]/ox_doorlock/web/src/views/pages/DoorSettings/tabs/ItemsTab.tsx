import { useDoorFormStore } from "@app/stores/DoorStore";
import { cn } from "@app/utils";
import { useState } from "react";

interface ItemModalProps {
	onSave: (item: { name: string; metadata?: string; remove?: boolean }) => void;
	onClose: () => void;
	initial?: { name: string; metadata?: string; remove?: boolean };
}

function ItemModal({ onSave, onClose, initial }: ItemModalProps) {
	const [name, setName]       = useState(initial?.name || "");
	const [metadata, setMetadata] = useState(initial?.metadata || "");
	const [remove, setRemove]   = useState(initial?.remove || false);

	return (
		<div className="dl-modal-overlay">
			<div className="dl-modal-frame">
				<div className="dl-modal-content">
					<p className="dl-modal-title">{initial ? "Editar Item" : "Adicionar Item"}</p>

					<div className="flex flex-col gap-2">
						<input
							type="text"
							placeholder="Nome do Item"
							value={name}
							onChange={(e) => setName(e.target.value)}
							className="dl-input"
						/>
						<input
							type="text"
							placeholder="Metadado (opcional)"
							value={metadata}
							onChange={(e) => setMetadata(e.target.value)}
							className="dl-input"
						/>

						<div className="dl-switch-card" style={{ cursor: 'pointer' }} onClick={() => setRemove(!remove)}>
							<span style={{ fontSize: 12, fontWeight: 600, color: 'var(--text-secondary)' }}>Remover ao usar</span>
							<button type="button" className={cn("dl-switch", remove && "active")}>
								<span className="dl-switch-thumb" />
							</button>
						</div>
					</div>

					<div className="flex gap-2" style={{ marginTop: 4 }}>
						<button type="button" onClick={onClose} className="dl-btn-cancel" style={{ flex: 1, justifyContent: 'center' }}>
							Cancelar
						</button>
						<button
							type="button"
							onClick={() => {
								if (!name.trim()) return;
								onSave({
									name: name.trim(),
									metadata: metadata.trim() || undefined,
									remove: remove || undefined,
								});
							}}
							className="dl-btn-confirm"
							style={{ flex: 1 }}
						>
							Salvar
						</button>
					</div>
				</div>
			</div>
		</div>
	);
}

export function ItemsTab() {
	const items    = useDoorFormStore((s) => s.items);
	const setItems = useDoorFormStore((s) => s.setItems);
	const [modal, setModal] = useState<{ open: boolean; index?: number }>({ open: false });

	const handleDelete = (index: number) => {
		setItems((prev) => prev.filter((_, i) => i !== index));
	};

	const handleSave = (item: { name: string; metadata?: string; remove?: boolean }) => {
		if (modal.index !== undefined) {
			setItems((prev) => prev.map((it, i) => (i === modal.index ? item : it)));
		} else {
			setItems((prev) => [...prev, item]);
		}
		setModal({ open: false });
	};

	return (
		<div className="flex flex-col gap-2">
			{items.map((item, index) => (
				<div key={`item-${index}`} className="dl-item-row">
					<div className="flex flex-1 flex-col gap-0.5 min-w-0">
						<span style={{ fontSize: 13, fontWeight: 600, color: 'var(--text-secondary)' }}>{item.name}</span>
						{item.metadata && (
							<span style={{ fontSize: 10, color: 'var(--text-muted)' }}>Meta: {item.metadata}</span>
						)}
						{item.remove && (
							<span style={{ fontSize: 10, color: 'rgba(239,68,68,0.6)' }}>Remover ao usar</span>
						)}
					</div>

					<button
						type="button"
						onClick={() => setModal({ open: true, index })}
						className="dl-btn-icon flex-shrink-0"
						style={{ width: 28, height: 28 }}
					>
						<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
							<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
							<path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
						</svg>
					</button>
					<button
						type="button"
						onClick={() => handleDelete(index)}
						className="dl-btn-icon danger flex-shrink-0"
						style={{ width: 28, height: 28 }}
					>
						<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
							<polyline points="3 6 5 6 21 6" />
							<path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
						</svg>
					</button>
				</div>
			))}

			<button type="button" onClick={() => setModal({ open: true })} className="dl-add-btn" style={{ marginTop: items.length > 0 ? 6 : 0 }}>
				<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
					<line x1="12" y1="5" x2="12" y2="19" />
					<line x1="5" y1="12" x2="19" y2="12" />
				</svg>
				Adicionar Item
			</button>

			{modal.open && (
				<ItemModal
					onSave={handleSave}
					onClose={() => setModal({ open: false })}
					initial={modal.index !== undefined ? items[modal.index] : undefined}
				/>
			)}
		</div>
	);
}
