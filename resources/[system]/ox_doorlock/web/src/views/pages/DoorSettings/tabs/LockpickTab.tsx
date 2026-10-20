import { useDoorFormStore } from "@app/stores/DoorStore";
import { cn } from "@app/utils";
import { useState } from "react";

const PRESETS: Record<string, { areaSize: number; speedMultiplier: number }> = {
	easy:   { areaSize: 50, speedMultiplier: 12 },
	medium: { areaSize: 40, speedMultiplier: 15 },
	hard:   { areaSize: 25, speedMultiplier: 20 },
};

const DIFFICULTY_LABELS: Record<string, string> = {
	easy:   "Fácil",
	medium: "Médio",
	hard:   "Difícil",
	custom: "Personalizado",
};

export function LockpickTab() {
	const lockpickDifficulty    = useDoorFormStore((s) => s.lockpickDifficulty);
	const setLockpickDifficulty = useDoorFormStore((s) => s.setLockpickDifficulty);

	const [showCustom, setShowCustom] = useState(
		lockpickDifficulty !== null && typeof lockpickDifficulty !== "string",
	);
	const [customArea, setCustomArea]   = useState(
		typeof lockpickDifficulty === "object" ? lockpickDifficulty?.areaSize ?? 40 : 40,
	);
	const [customSpeed, setCustomSpeed] = useState(
		typeof lockpickDifficulty === "object" ? lockpickDifficulty?.speedMultiplier ?? 15 : 15,
	);

	const currentSelection =
		lockpickDifficulty === null
			? null
			: typeof lockpickDifficulty === "string"
				? lockpickDifficulty
				: "custom";

	const handleSelect = (key: string) => {
		if (key === "custom") {
			setShowCustom(true);
			setLockpickDifficulty({ areaSize: customArea, speedMultiplier: customSpeed });
		} else {
			setShowCustom(false);
			setLockpickDifficulty(key);
		}
	};

	const handleClear = () => {
		setShowCustom(false);
		setLockpickDifficulty(null);
	};

	return (
		<div className="flex flex-col gap-3">
			<div className="flex items-center justify-between">
				<span style={{ fontSize: 10, fontWeight: 700, color: 'var(--text-muted)', letterSpacing: '0.6px', textTransform: 'uppercase' }}>
					Dificuldade
				</span>
				{currentSelection && (
					<button
						type="button"
						onClick={handleClear}
						style={{ fontSize: 10, fontWeight: 600, color: 'rgba(239,68,68,0.6)', cursor: 'pointer', background: 'none', border: 'none', transition: 'color 0.2s' }}
						onMouseEnter={(e) => (e.currentTarget.style.color = 'rgb(239,68,68)')}
						onMouseLeave={(e) => (e.currentTarget.style.color = 'rgba(239,68,68,0.6)')}
					>
						Limpar
					</button>
				)}
			</div>

			<div className="grid grid-cols-2 gap-2">
				{Object.keys(DIFFICULTY_LABELS).map((key) => (
					<button
						key={key}
						type="button"
						onClick={() => handleSelect(key)}
						className={cn("dl-diff-btn", currentSelection === key && "active")}
					>
						{DIFFICULTY_LABELS[key]}
					</button>
				))}
			</div>

			{showCustom && (
				<div className="flex flex-col gap-2" style={{ background: 'var(--bg-card)', border: '1px solid var(--border-subtle)', borderRadius: 'var(--radius-sm)', padding: '12px 14px' }}>
					<span style={{ fontSize: 10, fontWeight: 700, color: 'var(--text-muted)', letterSpacing: '0.5px', textTransform: 'uppercase', marginBottom: 2 }}>
						Configuração Personalizada
					</span>

					<div className="flex items-center gap-2">
						<label style={{ width: 140, flexShrink: 0, fontSize: 11, fontWeight: 600, color: 'var(--text-muted)' }}>
							Tamanho da Área
						</label>
						<input
							type="number"
							value={customArea}
							onChange={(e) => {
								const val = Number(e.target.value);
								setCustomArea(val);
								setLockpickDifficulty({ areaSize: val, speedMultiplier: customSpeed });
							}}
							className="dl-input"
						/>
					</div>
					<div className="flex items-center gap-2">
						<label style={{ width: 140, flexShrink: 0, fontSize: 11, fontWeight: 600, color: 'var(--text-muted)' }}>
							Multiplicador de Velocidade
						</label>
						<input
							type="number"
							value={customSpeed}
							onChange={(e) => {
								const val = Number(e.target.value);
								setCustomSpeed(val);
								setLockpickDifficulty({ areaSize: customArea, speedMultiplier: val });
							}}
							className="dl-input"
						/>
					</div>
				</div>
			)}

			{!currentSelection && (
				<p style={{ textAlign: 'center', color: 'var(--text-dimmed)', fontSize: 11, marginTop: 4 }}>
					Nenhuma dificuldade — lockpick desativado
				</p>
			)}

			{currentSelection && currentSelection !== "custom" && (
				<div className="flex items-center gap-3" style={{ background: 'var(--bg-card)', border: '1px solid var(--border-subtle)', borderRadius: 'var(--radius-sm)', padding: '10px 14px' }}>
					<div className="flex flex-1 flex-col gap-1">
						<span style={{ fontSize: 10, fontWeight: 600, color: 'var(--text-muted)' }}>Tamanho da Área</span>
						<span style={{ fontSize: 13, fontWeight: 700, color: 'var(--accent-color)' }}>{PRESETS[currentSelection]?.areaSize}</span>
					</div>
					<div className="flex flex-1 flex-col gap-1">
						<span style={{ fontSize: 10, fontWeight: 600, color: 'var(--text-muted)' }}>Multiplicador</span>
						<span style={{ fontSize: 13, fontWeight: 700, color: 'var(--accent-color)' }}>{PRESETS[currentSelection]?.speedMultiplier}</span>
					</div>
				</div>
			)}
		</div>
	);
}
