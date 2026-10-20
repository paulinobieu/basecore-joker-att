interface IconProps {
    size?: number
}

export function ElevatorIcon({ size = 24 }: IconProps) {
    return (
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M7 18H10V14H11V11.5C11 10.95 10.8043 10.4793 10.413 10.088C10.0217 9.69667 9.55067 9.50067 9 9.5H8C7.45 9.5 6.97933 9.696 6.588 10.088C6.19667 10.48 6.00067 10.9507 6 11.5V14H7V18ZM9.388 8.138C9.62933 7.896 9.75 7.6 9.75 7.25C9.75 6.9 9.629 6.604 9.387 6.362C9.145 6.12 8.84933 5.99933 8.5 6C8.15067 6.00067 7.85467 6.12167 7.612 6.363C7.36933 6.60433 7.24867 6.9 7.25 7.25C7.25133 7.6 7.37233 7.896 7.613 8.138C7.85367 8.38 8.14933 8.50067 8.5 8.5C8.85067 8.49933 9.14667 8.37933 9.388 8.138ZM13 11H18L15.5 7L13 11ZM15.5 17L18 13H13L15.5 17ZM5 21C4.45 21 3.97933 20.8043 3.588 20.413C3.19667 20.0217 3.00067 19.5507 3 19V5C3 4.45 3.196 3.97933 3.588 3.588C3.98 3.19667 4.45067 3.00067 5 3H19C19.55 3 20.021 3.196 20.413 3.588C20.805 3.98 21.0007 4.45067 21 5V19C21 19.55 20.8043 20.021 20.413 20.413C20.0217 20.805 19.5507 21.0007 19 21H5Z" fill="currentColor"/>
        </svg>
    )
}

export function FloorIcon({ size = 24 }: IconProps) {
    return (
        <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <rect x="3" y="3" width="18" height="18" rx="2" />
            <path d="M9 3v18" />
            <path d="M3 9h18" />
        </svg>
    )
}

export function PersonIcon({ size = 24 }: IconProps) {
    return (
        <svg width={size} height={size} viewBox="0 0 16 19" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M14.75 17.75C14.75 14.4401 11.0598 11.7495 7.75 11.7495C4.44021 11.7495 0.75 14.4401 0.75 17.75M7.75 8.75011C8.81083 8.75011 9.82821 8.32868 10.5783 7.57852C11.3285 6.82836 11.7499 5.81093 11.7499 4.75005C11.7499 3.68917 11.3285 2.67174 10.5783 1.92159C9.82821 1.17143 8.81083 0.75 7.75 0.75C6.68917 0.75 5.67179 1.17143 4.92167 1.92159C4.17155 2.67174 3.75013 3.68917 3.75013 4.75005C3.75013 5.81093 4.17155 6.82836 4.92167 7.57852C5.67179 8.32868 6.68917 8.75011 7.75 8.75011Z" stroke="var(--theme-color)" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
    )
}

export function LockIcon({ size = 24 }: IconProps) {
    return (
        <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <circle cx="12" cy="12" r="10" />
            <path d="M12 8v4" />
            <path d="M12 16h.01" />
        </svg>
    )
}
