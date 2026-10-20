interface SearchBarProps {
    value: string
    onChange: (val: string) => void
}

export function SearchBar({ value, onChange }: SearchBarProps) {
    return (
        <div className="search-bar">
            <span className="search-icon">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                    <circle cx="11" cy="11" r="7" stroke="currentColor" strokeWidth="2" />
                    <path d="M16 16l4.5 4.5" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
                </svg>
            </span>
            <input
                type="text"
                className="search-input"
                placeholder="Buscar roupas"
                value={value}
                onChange={(e) => onChange(e.target.value)}
            />
            {value && (
                <button className="search-clear" onClick={() => onChange('')}>
                    <svg width="10" height="10" viewBox="0 0 14 14" fill="none">
                        <path d="M1 1l12 12M13 1L1 13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
                    </svg>
                </button>
            )}
        </div>
    )
}
