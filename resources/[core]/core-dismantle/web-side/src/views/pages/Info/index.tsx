import { useDismantleStore } from "@app/stores/Dismantle";
import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { useState } from "react";

type NuiResponse = { success: boolean };

export function InfoPage() {
    const { data, updatePanelData } = useDismantleStore();
    const [loading, setLoading] = useState(false);
    const [editingPercent, setEditingPercent] = useState(false);
    const [percentValue, setPercentValue] = useState(0);

    if (!data) return null;
    const { panelData } = data;

    const handleTogglePublic = async () => {
        if (loading) return;
        setLoading(true);
        const newState = panelData.public === 1 ? 0 : 1;
        if (isEnvBrowser()) {
            updatePanelData({ public: newState });
            setLoading(false);
            return;
        }
        const res = await fetchNui<NuiResponse>({ path: "updateStatus", payload: { isPublic: newState === 1 } });
        if (res.success) updatePanelData({ public: newState });
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
        const res = await fetchNui<NuiResponse>({ path: "updatePercent", payload: { percent: percentValue } });
        if (res.success) {
            updatePanelData({ percent: percentValue });
            setEditingPercent(false);
        }
        setLoading(false);
    };

    return (
        <div className="dm-page">
            <div className="dm-page__header">
                <h2 className="dm-page__title">Informações</h2>
                <span className="dm-page__desc">Gerencie seu desmanche, localização e configurações de acesso.</span>
            </div>

            {/* Localização */}
            <div className="dm-section">
                <div className="dm-section__label">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" /><circle cx="12" cy="10" r="3" /></svg>
                    Localização
                </div>
                <div className="dm-location">
                    <span className="dm-location__name">{data.name}</span>
                    <div className="dm-location__actions">
                        <button className="dm-chip" onClick={() => fetchNui({ path: "tryMarkDismantleLocation" })}>
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" /><circle cx="12" cy="10" r="3" /></svg>
                            GPS
                        </button>
                        <button className="dm-chip" onClick={() => fetchNui({ path: "tryChangeDismantleLocation" })}>
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" /><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" /></svg>
                            Alterar Local
                        </button>
                    </div>
                </div>
            </div>

            {/* Modo Público */}
            <div className="dm-section">
                <div className="dm-section__label">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" /><circle cx="9" cy="7" r="4" /><path d="M23 21v-2a4 4 0 0 0-3-3.87" /><path d="M16 3.13a4 4 0 0 1 0 7.75" /></svg>
                    Modo Público
                </div>
                <div className="dm-public-row">
                    <button
                        className={`dm-toggle ${panelData.public === 1 ? "dm-toggle--on" : ""}`}
                        onClick={handleTogglePublic}
                    >
                        <div className="dm-toggle__track">
                            <div className="dm-toggle__dot" />
                        </div>
                    </button>
                    <span className="dm-public-row__status">
                        {panelData.public === 1 ? "Ativado" : "Desativado"}
                    </span>
                </div>
                <p className="dm-hint">
                    Com o modo público habilitado, qualquer pessoa poderá desmanchar veículos, recebendo a porcentagem definida do dinheiro sujo.
                </p>
            </div>

            {/* Porcentagem */}
            <div className="dm-section">
                <div className="dm-section__label">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><line x1="19" y1="5" x2="5" y2="19" /><circle cx="6.5" cy="6.5" r="2.5" /><circle cx="17.5" cy="17.5" r="2.5" /></svg>
                    Pagamento ao Público
                </div>
                <div className="dm-percent-row">
                    <div className="dm-badge">{panelData.percent}%</div>
                    <button
                        className="dm-chip"
                        onClick={() => { setPercentValue(panelData.percent); setEditingPercent(true); }}
                    >
                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" /><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" /></svg>
                        Editar
                    </button>
                </div>
            </div>

            {/* Modal Porcentagem */}
            {editingPercent && (
                <div className="dm-overlay">
                    <div className="dm-modal">
                        <span className="dm-modal__title">Porcentagem</span>
                        <span className="dm-modal__desc">Insira a porcentagem do lucro paga ao público:</span>
                        <input
                            type="number"
                            min={0}
                            max={100}
                            value={percentValue}
                            onChange={(e) => setPercentValue(Number(e.target.value))}
                            className="dm-modal__input"
                            autoFocus
                        />
                        <div className="dm-modal__buttons">
                            <button className="dm-btn dm-btn--cancel" onClick={() => setEditingPercent(false)}>Cancelar</button>
                            <button className="dm-btn dm-btn--accent" onClick={handleSavePercent}>Confirmar</button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
