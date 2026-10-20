import { useDoorFormStore } from "@app/stores/DoorStore";

export function SoundTab() {
	const lockSound   = useDoorFormStore((s) => s.lockSound);
	const unlockSound = useDoorFormStore((s) => s.unlockSound);
	const sounds      = useDoorFormStore((s) => s.sounds);
	const setField    = useDoorFormStore((s) => s.setField);

	return (
		<div className="flex flex-col gap-4">
			<div className="dl-field">
				<label className="dl-field-label">Som de Travar</label>
				<select
					value={lockSound || ""}
					onChange={(e) => setField("lockSound", e.target.value || null)}
					className="dl-input"
					style={{ appearance: 'none', cursor: 'pointer' }}
				>
					<option value="">Padrão</option>
					{sounds.map((s) => (
						<option key={`lock-${s}`} value={s}>{s}</option>
					))}
				</select>
			</div>

			<div className="dl-field">
				<label className="dl-field-label">Som de Destravar</label>
				<select
					value={unlockSound || ""}
					onChange={(e) => setField("unlockSound", e.target.value || null)}
					className="dl-input"
					style={{ appearance: 'none', cursor: 'pointer' }}
				>
					<option value="">Padrão</option>
					{sounds.map((s) => (
						<option key={`unlock-${s}`} value={s}>{s}</option>
					))}
				</select>
			</div>

			{sounds.length === 0 && (
				<p style={{ textAlign: 'center', color: 'var(--text-dimmed)', fontSize: 11, marginTop: 8 }}>
					Nenhum arquivo de som disponível
				</p>
			)}
		</div>
	);
}
