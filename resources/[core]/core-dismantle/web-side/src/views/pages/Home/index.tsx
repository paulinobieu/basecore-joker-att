import { useDismantleStore } from "@app/stores/Dismantle";
import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { cn } from "@app/utils";
import { useState } from "react";

type NuiResponse = {
    success: boolean;
};

const STORAGE_ITEMS = [
    { key: "money",     icon: "money.png",     label: "Dinheiro Sujo" },
    { key: "doors",     icon: "doors.png",     label: "Portas" },
    { key: "ehxausts",  icon: "ehxausts.png",  label: "Escapamentos" },
    { key: "wheels",    icon: "wheels.png",     label: "Rodas" },
    { key: "batteries", icon: "batteries.png",  label: "Baterias" },
] as const;

export function Home() {
    const { data, updatePanelData } = useDismantleStore();
    const [loading, setLoading] = useState(false);
    const [editingPercent, setEditingPercent] = useState(false);
    const [percentValue, setPercentValue] = useState(0);
    const [withdrawTarget, setWithdrawTarget] = useState<{ item: string; label: string } | null>(null);

    if (!data) return null;

    const { panelData } = data;

    const handleWithdraw = async (item: string, amount: number) => {
        if (loading || amount <= 0) return;

        setLoading(true);
        if (isEnvBrowser()) {
            updatePanelData({ [item]: (panelData[item as keyof typeof panelData] as number) - amount });
            setLoading(false);
            return;
        }

        const res = await fetchNui<NuiResponse>({
            path: "withdraw",
            payload: { item, amount },
        });
        if (res.success) {
            updatePanelData({ [item]: (panelData[item as keyof typeof panelData] as number) - amount });
        }
        setLoading(false);
    };

    const handleTogglePublic = async () => {
        if (loading) return;
        setLoading(true);
        const newState = panelData.public === 1 ? 0 : 1;
        if (isEnvBrowser()) {
            updatePanelData({ public: newState });
            setLoading(false);
            return;
        }
        const res = await fetchNui<NuiResponse>({
            path: "updateStatus",
            payload: { isPublic: newState === 1 },
        });
        if (res.success) {
            updatePanelData({ public: newState });
        }
        setLoading(false);
    };

    const handleSavePercent = async () => {
        if (loading) return;
        setLoading(true);
        if (isEnvBrowser()) {
            updatePanelData({ percent: percentValue });
            setEditingPercent(false);
            setLoading(false);
            return;
        }
        const res = await fetchNui<NuiResponse>({
            path: "updatePercent",
            payload: { percent: percentValue },
        });
        if (res.success) {
            updatePanelData({ percent: percentValue });
            setEditingPercent(false);
        }
        setLoading(false);
    };

    return (
        <div className="relative z-[2]">
            {/* ── HEADER ── */}
            <header className="dm-header">
                <div className="dm-header__icon">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M14 16H9m10.7-6.7L16 6l-2.3-2.3a1 1 0 0 0-1.4 0l-9 9a1 1 0 0 0 0 1.4L6 16.8" />
                        <circle cx="17" cy="17" r="3" />
                        <path d="m6 6 4 4" />
                    </svg>
                </div>
                <div className="flex flex-col min-w-0">
                    <span className="text-[0.8125rem] font-black text-white uppercase tracking-wider leading-tight">Desmanche</span>
                    <span className="text-[0.625rem] font-semibold text-white/[.3] uppercase tracking-wide truncate">{data.name}</span>
                </div>
                <div className="dm-header__actions">
                    <button className="dm-btn dm-btn--ghost" onClick={() => fetchNui({ path: "tryMarkDismantleLocation" })}>
                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" /><circle cx="12" cy="10" r="3" /></svg>
                        <span className="ml-1.5">GPS</span>
                    </button>
                    <button className="dm-btn dm-btn--ghost" onClick={() => fetchNui({ path: "tryChangeDismantleLocation" })}>
                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" /><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" /></svg>
                        <span className="ml-1.5">Alterar</span>
                    </button>
                </div>
            </header>

            <div className="dm-divider" />

            {/* ── ARMAZÉM ── */}
            <div className="dm-label">
                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" /><polyline points="3.27 6.96 12 12.01 20.73 6.96" /><line x1="12" y1="22.08" x2="12" y2="12" /></svg>
                Armazém
            </div>

            <div>
                {STORAGE_ITEMS.map(({ key, icon, label }) => {
                    const amount = panelData[key as keyof typeof panelData] as number;
                    return (
                        <div key={key} className="dm-row">
                            <img src={`./assets/img/${icon}`} alt="" className="dm-row__icon" />
                            <span className="dm-row__label">{label}</span>
                            <span className="dm-row__amount">{amount.toLocaleString("pt-BR")}x</span>
                            <button
                                className="dm-btn dm-btn--accent"
                                disabled={amount <= 0 || loading}
                                onClick={() => setWithdrawTarget({ item: key, label })}
                            >
                                Coletar
                            </button>
                        </div>
                    );
                })}
            </div>

            <div className="dm-divider" />

            {/* ── CONFIGURAÇÕES ── */}
            <div className="dm-label">
                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3" /><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" /></svg>
                Configurações
            </div>

            <div className="dm-settings">
                <div className="dm-settings__group">
                    <span className="dm-settings__label">Público</span>
                    <button
                        className={cn("dm-toggle", panelData.public === 1 && "dm-toggle--on")}
                        onClick={handleTogglePublic}
                    >
                        <div className="dm-toggle__dot" />
                    </button>
                </div>

                <div className="dm-settings__sep" />

                <div className="dm-settings__group" style={{ marginLeft: "auto" }}>
                    <span className="dm-settings__label">Pagamento</span>
                    <div className="dm-badge">{panelData.percent}%</div>
                    <button
                        className="dm-icon-btn"
                        onClick={() => {
                            setPercentValue(panelData.percent);
                            setEditingPercent(true);
                        }}
                    >
                        <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" /><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" /></svg>
                    </button>
                </div>
            </div>

            <p className="dm-hint">
                Com o modo público habilitado, qualquer pessoa poderá desmanchar veículos, recebendo a porcentagem definida do dinheiro sujo.
            </p>

            {/* ── MODALS ── */}
            {editingPercent && (
                <ModalPercent
                    value={percentValue}
                    setValue={setPercentValue}
                    onCancel={() => setEditingPercent(false)}
                    onConfirm={handleSavePercent}
                />
            )}

            {withdrawTarget && (
                <ModalWithdraw
                    label={withdrawTarget.label}
                    onCancel={() => setWithdrawTarget(null)}
                    onConfirm={(amt) => {
                        handleWithdraw(withdrawTarget.item, amt);
                        setWithdrawTarget(null);
                    }}
                />
            )}
        </div>
    );
}

/* ── MODAL: Porcentagem ── */
function ModalPercent({ value, setValue, onCancel, onConfirm }: { value: number; setValue: (v: number) => void; onCancel: () => void; onConfirm: () => void }) {
    return (
        <div className="dm-overlay">
            <div className="dm-modal">
                <span className="dm-modal__title">Porcentagem</span>
                <span className="dm-modal__desc">
                    Insira a porcentagem do lucro paga ao público:
                </span>
                <input
                    type="number"
                    min={0}
                    max={100}
                    value={value}
                    onChange={(e) => setValue(Number(e.target.value))}
                    className="dm-modal__input"
                    autoFocus
                />
                <div className="dm-modal__buttons">
                    <button className="dm-btn dm-btn--cancel flex-1 py-2" onClick={onCancel}>
                        Cancelar
                    </button>
                    <button className="dm-btn dm-btn--accent flex-1 py-2" onClick={onConfirm}>
                        Confirmar
                    </button>
                </div>
            </div>
        </div>
    );
}

/* ── MODAL: Retirada ── */
function ModalWithdraw({ label, onCancel, onConfirm }: { label: string; onCancel: () => void; onConfirm: (amt: number) => void }) {
    const [amount, setAmount] = useState<number | string>("");

    return (
        <div className="dm-overlay">
            <div className="dm-modal">
                <span className="dm-modal__title">Retirada</span>
                <span className="dm-modal__desc">
                    Quantidade de <strong className="text-white font-semibold">{label}</strong> a retirar:
                </span>
                <input
                    type="number"
                    min={1}
                    value={amount}
                    onChange={(e) => setAmount(Number(e.target.value))}
                    className="dm-modal__input"
                    placeholder="Ex: 10"
                    autoFocus
                />
                <div className="dm-modal__buttons">
                    <button className="dm-btn dm-btn--cancel flex-1 py-2" onClick={onCancel}>
                        Cancelar
                    </button>
                    <button
                        className="dm-btn dm-btn--accent flex-1 py-2"
                        disabled={!amount || Number(amount) <= 0}
                        onClick={() => onConfirm(Number(amount))}
                    >
                        Confirmar
                    </button>
                </div>
            </div>
        </div>
    );
}
