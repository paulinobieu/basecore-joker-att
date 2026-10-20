export function formatMoney(value: number, separator = '.'): string {
    return Math.floor(value).toString().replace(/\B(?=(\d{3})+(?!\d))/g, separator)
}

export function formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
}
