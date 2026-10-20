import { useClickSound } from "@app/hooks/useClickSound";
import { useKeyPress } from "@app/hooks/useKeyPress";
import { useNuiMessage } from "@app/hooks/useNuiMessage";
import {
	type OpenPayload,
	type Row,
	type RowButton,
	type RowOptions,
	type RowSlider,
	useKeyboardStore,
} from "@app/stores/Keyboard";
import { cn } from "@app/utils";
import { isEnvBrowser } from "@app/utils/misc";
import { SelectField } from "@views/components/SelectField";
import { SliderField } from "@views/components/SliderField";
import { useCallback, useEffect, useRef } from "react";

function stripNonDigits(v: unknown): string {
	return v?.toString().replace(/\D/g, "") ?? "";
}

function applyTheme(hex?: string) {
	if (!hex || typeof hex !== "string") return;
	const match = hex.replace("#", "").match(/^[0-9a-fA-F]{6}$/);
	if (!match) return;
	const int = parseInt(match[0], 16);
	const r = (int >> 16) & 255;
	const g = (int >> 8) & 255;
	const b = int & 255;
	const root = document.documentElement;
	root.style.setProperty("--theme-color", hex);
	root.style.setProperty("--theme-rgb", `${r}, ${g}, ${b}`);
}

export function Keyboard() {
	const store = useKeyboardStore();
	const inputsRef = useRef<HTMLDivElement>(null);

	useClickSound();

	/* ── NUI events ── */
	useNuiMessage<OpenPayload>("Open", (data) => {
		applyTheme(data.Theme);
		store.open(data);
		setTimeout(() => {
			if (!inputsRef.current) return;
			const input = inputsRef.current.querySelector("input:not(.save)") as HTMLInputElement;
			const textarea = inputsRef.current.querySelector("textarea:not(.save)") as HTMLTextAreaElement;
			if (input) input.focus();
			else if (textarea) textarea.focus();
		}, 50);
	});

	const handleClose = useCallback(() => store.close(), [store]);
	useKeyPress("Escape", handleClose);

	/* ── debug open in browser ── */
	useEffect(() => {
		if (!isEnvBrowser()) return;
		store.open({
			Title: "Formulário",
			Subtitle: "Preencha os campos abaixo",
			Rows: [
				{ Mode: "text", Placeholder: "Nome completo", Value: "" },
				{ Mode: "number", Placeholder: "Quantidade", Value: "" },
				{ Mode: "area", Placeholder: "Descrição", Value: "" },
				{
					Mode: "slider",
					Placeholder: "Volume",
					Value: 50,
					Min: 0,
					Max: 100,
				},
				{
					Mode: "options",
					Placeholder: "Selecione uma opção",
					Options: [
						{ Label: "Opção 1", Value: "opt1" },
						{ Label: "Opção 2", Value: "opt2" },
						{ Label: "Opção 3", Value: "opt3" },
					],
					Value: "",
				},
			],
		} as OpenPayload);
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, []);

	/* ── helpers ── */
	const allSaveOnly = store.rows.every((r) => r.Save);

	const fieldHasError = (row: Row): boolean => {
		if (!store.showErrors) return false;
		if (row.Mode === "button") return false;
		if (row.Required && !row.Value) return true;
		if (row.Mode === "number") {
			const n = parseInt(stripNonDigits(row.Value));
			if (isNaN(n) || n <= 0) return true;
		}
		return false;
	};

	const getErrorMessage = (row: Row): string | null => {
		if (!fieldHasError(row)) return null;
		if (row.Mode === "number") {
			const n = parseInt(stripNonDigits(row.Value));
			if (isNaN(n) || n <= 0) return "Valor deve ser maior que 0";
		}
		return "Campo obrigatório";
	};

	const handleCopy = (index: number, text: string) => {
		if (store.copiedIdx[index]) return;
		try {
			const textarea = document.createElement("textarea");
			textarea.value = text;
			textarea.style.position = "fixed";
			textarea.style.left = "-999999px";
			textarea.style.top = "-999999px";
			textarea.style.opacity = "0";
			document.body.appendChild(textarea);
			textarea.select();
			textarea.setSelectionRange(0, 99999);
			document.execCommand("copy");
			document.body.removeChild(textarea);
			store.setCopied(index);
		} catch (_) {
			/* noop */
		}
	};

	const onInputKeyDown = (e: React.KeyboardEvent) => {
		if (e.key === "Enter") {
			e.preventDefault();
			store.submit();
		}
	};

	if (!store.visible && !store.closing) return null;

	return (
		<div className={cn("flex min-h-screen items-center justify-center", isEnvBrowser() && "bg-[#1a1a2e]")}>
			<div className={cn("pointer-events-auto", store.closing ? "kb-closing" : "kb-opening")}>
				{/* Glass Frame */}
				<div className="kb-frame">
					{/* Inner Panel */}
					<div className="kb-inner">
						{/* Title */}
						<div className="mb-4 flex items-start gap-3">
							<svg
								className="mt-0.5 shrink-0"
								width="22"
								height="22"
								viewBox="0 0 24 24"
								fill="none"
								stroke="var(--theme-color)"
								strokeWidth="2"
								strokeLinecap="round"
								strokeLinejoin="round"
							>
								<path d="M4 6h16M4 10h16M4 14h10M4 18h6" />
							</svg>
							<div>
								<h1 className="mb-1 text-base font-bold">{store.title}</h1>
								<p className="max-w-[16.25rem] text-[0.625rem] text-white/40">{store.subtitle}</p>
							</div>
						</div>

						{/* Fields */}
						<div className="flex w-full flex-col gap-2" ref={inputsRef}>
							{store.rows.map((row, idx) => {
								const shouldRender =
									row.Mode === "text" ||
									row.Mode === "number" ||
									(!row.Save && row.Mode === "password") ||
									row.Mode === "area" ||
									row.Mode === "slider" ||
									(!row.Save && row.Mode === "options" && (row as RowOptions).Options?.length > 0) ||
									row.Mode === "button";

								if (row.Save && !row.Value?.toString()) return null;
								if (!shouldRender) return null;

								const error = fieldHasError(row);
								const errorMsg = getErrorMessage(row);

								return (
									<div key={idx} className="relative w-full">
										{/* Copy button */}
										{row.Save &&
											(row.Mode === "text" || row.Mode === "number" || row.Mode === "area") &&
											row.Value?.toString() && (
												<button
													type="button"
													className={cn(
														"absolute right-2.5 z-10 text-white/40 transition-opacity hover:text-white/80",
														row.Mode === "area" ? "top-3" : "top-1/2 -translate-y-1/2",
													)}
													onClick={() => handleCopy(idx, row.Value?.toString() || "")}
												>
													{store.copiedIdx[idx] ? (
														<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#22c55e" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
															<polyline points="20 6 9 17 4 12" />
														</svg>
													) : (
														<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
															<rect x="9" y="9" width="13" height="13" rx="2" />
															<path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1" />
														</svg>
													)}
												</button>
											)}

										{/* Error icon */}
										{error && row.Mode !== "options" && row.Mode !== "slider" && row.Mode !== "button" && (
											<div
												className={cn(
													"pointer-events-none absolute right-2.5 z-10 text-red-500",
													row.Mode === "area" ? "top-3" : "top-1/2 -translate-y-1/2",
												)}
											>
												<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
													<circle cx="12" cy="12" r="10" />
													<line x1="12" y1="8" x2="12" y2="12" />
													<line x1="12" y1="16" x2="12.01" y2="16" />
												</svg>
											</div>
										)}

										{/* Text / Number / Password */}
										{(row.Mode === "text" || row.Mode === "number" || row.Mode === "password") && (
											<input
												type={row.Mode === "password" ? "password" : "text"}
												className={cn(
													"h-[2.625rem] w-full rounded-lg border bg-white/[.04] px-3.5 text-xs font-medium text-white placeholder:text-white/35 transition-colors focus:border-[rgba(var(--theme-rgb),0.4)] focus:bg-white/[.07]",
													error ? "border-red-500" : "border-white/10",
													row.Save && "pr-9 opacity-50",
												)}
												placeholder={row.Placeholder}
												value={row.Value?.toString() ?? ""}
												disabled={!!row.Save}
												onChange={(e) => {
													if (row.Mode === "number") {
														store.updateRow(idx, e.target.value.replace(/\D/g, ""));
													} else {
														store.updateRow(idx, e.target.value);
													}
												}}
												onKeyDown={onInputKeyDown}
											/>
										)}

										{/* Textarea */}
										{row.Mode === "area" && (
											<textarea
												className={cn(
													"block w-full resize-none rounded-lg border bg-white/[.04] px-3.5 py-2.5 text-xs font-medium text-white placeholder:text-white/35 transition-colors focus:border-[rgba(var(--theme-rgb),0.4)] focus:bg-white/[.07]",
													error ? "border-red-500" : "border-white/10",
													row.Save && "pr-9 opacity-50",
												)}
												placeholder={row.Placeholder}
												rows={5}
												value={row.Value?.toString() ?? ""}
												disabled={!!row.Save}
												onChange={(e) => store.updateRow(idx, e.target.value)}
											/>
										)}

										{/* Slider */}
										{row.Mode === "slider" && (
											<SliderField
												value={typeof row.Value === "number" ? row.Value : 0}
												min={(row as RowSlider).Min}
												max={(row as RowSlider).Max}
												placeholder={row.Placeholder}
												onChange={(v) => store.updateRow(idx, v)}
											/>
										)}

										{/* Options */}
										{row.Mode === "options" && (row as RowOptions).Options && (
											<SelectField
												options={(row as RowOptions).Options}
												value={row.Value?.toString() ?? ""}
												placeholder={row.Placeholder}
												hasError={error}
												onChange={(v) => store.updateRow(idx, v)}
											/>
										)}

										{/* Button */}
										{row.Mode === "button" && (
											<button
												type="button"
												className="kb-btn kb-btn--action"
												onClick={() => store.handleButton(row as RowButton)}
											>
												{row.Placeholder}
											</button>
										)}

										{/* Error message */}
										{errorMsg && row.Mode !== "options" && (
											<p className="mt-0.5 text-[0.625rem] text-red-500">{errorMsg}</p>
										)}
									</div>
								);
							})}
						</div>

						{/* Footer */}
						<div className="mt-4 flex w-full gap-2.5">
							{allSaveOnly ? (
								<button type="button" className="kb-btn kb-btn--confirm" onClick={store.close}>
									Fechar
								</button>
							) : (
								<>
									{!store.hideCancel && (
										<button type="button" className="kb-btn kb-btn--cancel" onClick={store.close}>
											Cancelar
										</button>
									)}
									<button type="button" className="kb-btn kb-btn--confirm" onClick={store.submit}>
										Enviar
									</button>
								</>
							)}
						</div>
					</div>
				</div>
			</div>
		</div>
	);
}
