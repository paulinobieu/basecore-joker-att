import { useDoorFormStore } from "@app/stores/DoorStore";
import { cn } from "@app/utils";

export function GeneralTab() {
	const name        = useDoorFormStore((s) => s.name);
	const passcode    = useDoorFormStore((s) => s.passcode);
	const autolock    = useDoorFormStore((s) => s.autolock);
	const maxDistance = useDoorFormStore((s) => s.maxDistance);
	const doorRate    = useDoorFormStore((s) => s.doorRate);
	const state       = useDoorFormStore((s) => s.state);
	const doors       = useDoorFormStore((s) => s.doors);
	const auto        = useDoorFormStore((s) => s.auto);
	const lockpick    = useDoorFormStore((s) => s.lockpick);
	const hideUi      = useDoorFormStore((s) => s.hideUi);
	const holdOpen    = useDoorFormStore((s) => s.holdOpen);
	const setField    = useDoorFormStore((s) => s.setField);
	const toggleCheckbox = useDoorFormStore((s) => s.toggleCheckbox);

	return (
		<div className="flex flex-col gap-4">
			{/* Inputs grid */}
			<div className="grid grid-cols-2 gap-3">
				<InputField label="Nome da Porta" type="text" value={name || ""} onChange={(v) => setField("name", v)} />
				<InputField label="Senha" type="text" value={passcode || ""} onChange={(v) => setField("passcode", v)} />
				<InputField
					label="Auto-travar (s)"
					type="number"
					value={autolock || 0}
					onChange={(v) => setField("autolock", Number(v))}
					tooltip="Tempo em segundos para travar automaticamente"
				/>
				<InputField
					label="Distância (m)"
					type="number"
					value={maxDistance || 0}
					onChange={(v) => setField("maxDistance", Number(v))}
					tooltip="Distância máxima para interagir"
				/>
				<div className="col-span-2">
					<InputField
						label="Velocidade da Porta"
						type="number"
						value={doorRate || 0}
						onChange={(v) => setField("doorRate", Number(v))}
						tooltip="Velocidade de abertura/fechamento"
					/>
				</div>
			</div>

			{/* Switches grid */}
			<div className="grid grid-cols-2 gap-2">
				<SwitchField label="Trancada"    tooltip="Porta trancada por padrão"        value={state    || false} onToggle={() => toggleCheckbox("state")} />
				<SwitchField label="Dupla"       tooltip="Porta dupla"                       value={doors    || false} onToggle={() => toggleCheckbox("doors")} />
				<SwitchField label="Automática"  tooltip="Porta se move automaticamente"     value={auto     || false} onToggle={() => toggleCheckbox("auto")} />
				<SwitchField label="Lockpick"    tooltip="Permite arrombamento"               value={lockpick || false} onToggle={() => toggleCheckbox("lockpick")} />
				<SwitchField label="Esconder UI" tooltip="Esconde indicadores visuais"        value={hideUi   || false} onToggle={() => toggleCheckbox("hideUi")} />
				<SwitchField label="Manter Aberta" tooltip="Permanece aberta enquanto destrancada" value={holdOpen || false} onToggle={() => toggleCheckbox("holdOpen")} />
			</div>
		</div>
	);
}

function InputField({
	label,
	type,
	value,
	onChange,
	tooltip,
}: {
	label: string;
	type: "text" | "number";
	value: string | number;
	onChange: (value: string) => void;
	tooltip?: string;
}) {
	return (
		<div className="dl-field">
			<label className="dl-field-label">
				{label}
				{tooltip && (
					<span className="group relative inline-flex">
						<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" style={{ opacity: 0.3 }}>
							<circle cx="12" cy="12" r="10" />
							<path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
							<line x1="12" y1="17" x2="12.01" y2="17" />
						</svg>
						<span className="pointer-events-none absolute bottom-full left-1/2 z-50 mb-2 w-40 -translate-x-1/2 rounded bg-black/90 px-2.5 py-1.5 text-center text-[10px] font-medium text-white/70 opacity-0 transition-opacity group-hover:opacity-100">
							{tooltip}
						</span>
					</span>
				)}
			</label>
			<input
				type={type}
				value={value}
				onChange={(e) => onChange(e.target.value)}
				step={type === "number" ? "0.1" : undefined}
				className="dl-input"
			/>
		</div>
	);
}

function SwitchField({
	label,
	tooltip,
	value,
	onToggle,
}: {
	label: string;
	tooltip: string;
	value: boolean;
	onToggle: () => void;
}) {
	return (
		<div className="dl-switch-card">
			<div className="flex items-center gap-1.5">
				<span style={{ fontSize: 12, fontWeight: 600, color: 'var(--text-secondary)' }}>{label}</span>
				<span className="group relative inline-flex">
					<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" style={{ opacity: 0.25 }}>
						<circle cx="12" cy="12" r="10" />
						<path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
						<line x1="12" y1="17" x2="12.01" y2="17" />
					</svg>
					<span className="pointer-events-none absolute bottom-full left-1/2 z-50 mb-2 w-40 -translate-x-1/2 rounded bg-black/90 px-2.5 py-1.5 text-center text-[10px] font-medium text-white/70 opacity-0 transition-opacity group-hover:opacity-100">
						{tooltip}
					</span>
				</span>
			</div>
			<button
				type="button"
				onClick={onToggle}
				className={cn("dl-switch", value && "active")}
			>
				<span className="dl-switch-thumb" />
			</button>
		</div>
	);
}
