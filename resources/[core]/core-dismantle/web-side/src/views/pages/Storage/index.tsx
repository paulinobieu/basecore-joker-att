import { useDismantleStore } from "@app/stores/Dismantle";
import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { useState } from "react";

type NuiResponse = { success: boolean };

const STORAGE_ITEMS = [
    { key: "money",     icon: "money.png",     label: "Dinheiro Sujo" },
    { key: "doors",     icon: "doors.png",     label: "Portas" },
    { key: "ehxausts",  icon: "ehxausts.png",  label: "Escapamentos" },
    { key: "wheels",    icon: "wheels.png",     label: "Rodas" },
    { key: "batteries", icon: "batteries.png",  label: "Baterias" },
] as const;

export function StoragePage() {
    const { data, updatePanelData } = useDismantleStore();
    const [loading, setLoading] = useState(false);
    const [withdrawTarget, setWithdrawTarget] = useState<{ item: string; label: string } | null>(null);
    const [withdrawAmount, setWithdrawAmount] = useState<number | string>("");

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
        const res = await fetchNui<NuiResponse>({ path: "withdraw", payload: { item, amount } });
        if (res.success) {
            updatePanelData({ [item]: (panelData[item as keyof typeof panelData] as number) - amount });
        }
        setLoading(false);
    };

    return (
        <div className="dm-page">
            <div className="dm-page__header">
                <h2 className="dm-page__title">Armazém</h2>
                <span className="dm-page__desc">Itens coletados dos veículos desmanchados.</span>
            </div>

            <div className="dm-storage-grid">
                {STORAGE_ITEMS.map(({ key, icon, label }) => {
                    const amount = panelData[key as keyof typeof panelData] as number;
                    return (
                        <div key={key} className="dm-storage-card">
                            <div className="dm-storage-card__visual">
                                <img src={`./assets/img/${icon}`} alt="" className="dm-storage-card__img" />
                            </div>
                            <div className="dm-storage-card__info">
                                <span className="dm-storage-card__label">{label}</span>
                                <span className="dm-storage-card__amount">{amount.toLocaleString("pt-BR")}x</span>
                            </div>
                            <button
                                className="dm-btn dm-btn--accent dm-storage-card__btn"
                                disabled={amount <= 0 || loading}
                                onClick={() => {
                                    setWithdrawTarget({ item: key, label });
                                    setWithdrawAmount("");
                                }}
                            >
                                Coletar
                            </button>
                        </div>
                    );
                })}
            </div>

            {/* Modal Retirada */}
            {withdrawTarget && (
                <div className="dm-overlay">
                    <div className="dm-modal">
                        <span className="dm-modal__title">Retirada</span>
                        <span className="dm-modal__desc">
                            Quantidade de <strong style={{ color: "white" }}>{withdrawTarget.label}</strong> a retirar:
                        </span>
                        <input
                            type="number"
                            min={1}
                            value={withdrawAmount}
                            onChange={(e) => setWithdrawAmount(Number(e.target.value))}
                            className="dm-modal__input"
                            placeholder="Ex: 10"
                            autoFocus
                        />
                        <div className="dm-modal__buttons">
                            <button className="dm-btn dm-btn--cancel" onClick={() => setWithdrawTarget(null)}>Cancelar</button>
                            <button
                                className="dm-btn dm-btn--accent"
                                disabled={!withdrawAmount || Number(withdrawAmount) <= 0}
                                onClick={() => {
                                    handleWithdraw(withdrawTarget.item, Number(withdrawAmount));
                                    setWithdrawTarget(null);
                                }}
                            >
                                Confirmar
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
