export interface Preset {
    id: string
    label: string
    value: number
}

export interface RangeConfig {
    Min: number
    Max: number
    Step: number
}

export interface OpenPayload {
    themeColor: string
    currentScale: number
    presets: Preset[]
    range: RangeConfig
}
