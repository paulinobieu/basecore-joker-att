import { cn } from '@app/utils'

interface UpgradeBarsProps {
    level: number
    maxLevel: number
}

export function UpgradeBars({ level, maxLevel }: UpgradeBarsProps) {
    return (
        <div className="flex gap-[4px] mb-[10px]">
            {Array.from({ length: maxLevel }).map((_, i) => {
                const active = i < level
                return (
                    <div
                        key={i}
                        className={cn(
                            'flex-1 h-[8px] rounded-[2px] transition-[background] duration-300 ease-[ease]',
                            active ? 'bg-accent' : 'bg-white/[0.06]',
                        )}
                        style={
                            active
                                ? { boxShadow: '0 0 6px rgba(var(--accent-color-rgb), 0.3)' }
                                : undefined
                        }
                    />
                )
            })}
        </div>
    )
}
