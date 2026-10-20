interface ProgressBarProps {
    progress: number
}

export function ProgressBar({ progress }: ProgressBarProps) {
    return (
        <div
            className="w-full h-[4px] rounded-[2px] mt-[8px] overflow-hidden"
            style={{ background: 'var(--border-subtle)' }}
        >
            <div
                className="h-full rounded-[2px] bg-accent transition-[width] duration-[400ms] ease-[ease]"
                style={{ width: `${Math.min(100, Math.max(0, progress))}%` }}
            />
        </div>
    )
}
