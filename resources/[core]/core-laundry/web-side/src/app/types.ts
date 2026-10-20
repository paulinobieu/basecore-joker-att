export interface WashStatus {
    isWashing: boolean
    isDone: boolean
    amount: number
    result: number
    time: number
    cleaners: number
    progress: number
}

export interface WashConfig {
    machineId: string
    machineName: string
    taxRate: number
    cleanersOwned: number
    efficiencyLevel: number
    efficiencyMax: number
    efficiencyLimit: string
    efficiencyCost: number
    powerLevel: number
    powerMax: number
    powerLimit: string
    powerCost: number
    themeColor?: string
    logoUrl?: string
    currencyPrefix: string
    currencySuffix: string
    currencySeparator: string
}

export type TabKey = 'quantidade' | 'status' | 'armazem' | 'melhorias'

export const defaultStatus: WashStatus = {
    isWashing: false,
    isDone: false,
    amount: 0,
    result: 0,
    time: 0,
    cleaners: 0,
    progress: 0,
}

export const defaultConfig: WashConfig = {
    machineId: 'LAVAGEM1',
    machineName: 'Lavagem 1',
    taxRate: 5,
    cleanersOwned: 68,
    efficiencyLevel: 5,
    efficiencyMax: 8,
    efficiencyLimit: 'R$ 1.000.000',
    efficiencyCost: 100000,
    powerLevel: 4,
    powerMax: 8,
    powerLimit: 'R$ 2.000.000',
    powerCost: 150000,
    themeColor: undefined,
    logoUrl: 'https://cdn.corenetwork.dev/IDCore/LOGO%20-%20BRANCO.png',
    currencyPrefix: 'R$ ',
    currencySuffix: '',
    currencySeparator: '.',
}

export interface MachinePoint {
    id: string
    name: string
    permission: string
    spawnObject?: boolean
    x: number
    y: number
    z: number
    h: number
}

export interface AdminSettings {
    items: { dirty: string; clean: string; cleaner: string }
    mathematics: { baseValue: number; washTime: number; cleanerCost: number; taxPercent: number; minimumWashTime: number }
    cancel: { refundPercent: number; refundCleaners: boolean }
    upgrades: {
        efficiency: { enabled: boolean; defaultLimit: number; levels: { limit: number; price: number }[] }
        potency: { enabled: boolean; levels: { percent: number; price: number }[] }
    }
}

export const defaultAdminSettings: AdminSettings = {
    items: { dirty: 'dirtydollar', clean: 'dollar', cleaner: 'water' },
    mathematics: { baseValue: 10000, washTime: 5, cleanerCost: 1, taxPercent: 10, minimumWashTime: 5 },
    cancel: { refundPercent: 100, refundCleaners: false },
    upgrades: {
        efficiency: {
            enabled: true,
            defaultLimit: 1000000,
            levels: [
                { limit: 2000000, price: 100000 },
                { limit: 3000000, price: 100000 },
            ],
        },
        potency: {
            enabled: true,
            levels: [
                { percent: 10, price: 100000 },
                { percent: 15, price: 100000 },
            ],
        },
    },
}

export type NotifyType = 'warn' | 'success' | 'error' | 'info'

export interface NotifyData {
    type: NotifyType
    desc: string
    time?: number
}

export interface NotifyItem {
    id: string
    type: NotifyType
    desc: string
    time: number
}
