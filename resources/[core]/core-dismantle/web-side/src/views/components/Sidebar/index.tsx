import { useDismantleStore, type DismantleTab } from "@app/stores/Dismantle";

const TABS: { id: DismantleTab; label: string; icon: JSX.Element }[] = [
    {
        id: "info",
        label: "Informações",
        icon: (
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="12" cy="12" r="10" />
                <line x1="12" y1="16" x2="12" y2="12" />
                <line x1="12" y1="8" x2="12.01" y2="8" />
            </svg>
        ),
    },
    {
        id: "storage",
        label: "Armazém",
        icon: (
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
                <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
                <line x1="12" y1="22.08" x2="12" y2="12" />
            </svg>
        ),
    },
];

export function Sidebar() {
    const tab = useDismantleStore((s) => s.tab);
    const setTab = useDismantleStore((s) => s.setTab);
    return (
        <aside className="dm-sidebar">
            <div className="dm-sidebar__header">
                <div className="dm-sidebar__logo">
                    <svg className="dm-sidebar__logo-bg" viewBox="0 0 36 36" fill="none">
                        <rect x="18" y="2" width="22.63" height="22.63" rx="4" transform="rotate(45 18 2)" fill={`rgb(var(--primaryColor))`} fillOpacity="0.2" stroke={`rgb(var(--primaryColor))`} strokeWidth="1.2" />
                        <rect x="18" y="6" width="16.97" height="16.97" rx="3" transform="rotate(45 18 6)" fill={`rgb(var(--primaryColor))`} fillOpacity="0.5" />
                    </svg>
                    <svg width="17" height="17" viewBox="0 0 128 128" fill="none">
                        <path d="M68.125 58.875C69.3516 58.875 70.528 59.3623 71.3954 60.2296C72.2627 61.097 72.75 62.2734 72.75 63.5C72.75 64.7266 72.2627 65.903 71.3954 66.7704C70.528 67.6377 69.3516 68.125 68.125 68.125C66.8984 68.125 65.722 67.6377 64.8546 66.7704C63.9873 65.903 63.5 64.7266 63.5 63.5C63.5 62.2734 63.9873 61.097 64.8546 60.2296C65.722 59.3623 66.8984 58.875 68.125 58.875ZM44.3525 36.9062C47.383 33.6259 51.0593 31.0079 55.1505 29.2171C59.2416 27.4262 63.6591 26.5011 68.125 26.5C84.3125 26.5 97.91 38.5712 100.176 54.25H109.75V63.5H82C82 59.8201 80.5382 56.291 77.9361 53.6889C75.334 51.0868 71.8049 49.625 68.125 49.625C64.4451 49.625 60.916 51.0868 58.3139 53.6889C55.7118 56.291 54.25 59.8201 54.25 63.5H17.25V54.25H17.4812C18.4062 43.7513 22.5225 34.1775 28.8125 26.5L44.3525 36.9062ZM39.1263 44.4912L31.4025 39.3112C28.9512 43.8438 27.3325 48.885 26.7775 54.25H36.0738C36.5825 50.7812 37.6 47.4975 39.1263 44.4912ZM42.225 79.225L35.75 72.75H62.5287C63.6387 74.6925 65.8125 75.9875 68.125 75.9875C70.4375 75.9875 72.6113 74.6925 73.7213 72.75H100.5V79.225C93.0537 74.6925 93.3775 80.8438 93.3775 80.8438V89.9087L84.3125 98.9738C82 90.88 77.8375 95.4125 77.8375 95.4125L71.3625 101.887H58.4125C62.945 94.4412 56.7938 94.765 56.7938 94.765H47.7288L38.6638 85.7C46.7575 83.4337 42.225 79.225 42.225 79.225Z" fill="white"/>
                    </svg>
                </div>
                <span className="dm-sidebar__title">DESMANCHE</span>
            </div>

            <nav className="dm-tabs">
                {TABS.map((t) => (
                    <button
                        key={t.id}
                        type="button"
                        className={`dm-tab ${tab === t.id ? "active" : ""}`}
                        onClick={() => setTab(t.id)}
                    >
                        <span className="dm-tab__icon">{t.icon}</span>
                        <span className="dm-tab__label">{t.label}</span>
                    </button>
                ))}
            </nav>
        </aside>
    );
}
