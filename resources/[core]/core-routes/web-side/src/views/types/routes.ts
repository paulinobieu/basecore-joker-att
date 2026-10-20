export interface RouteItem {
    id: string
    name: string
    image: string
    quantity?: number
    price?: number
}

export interface RouteConfig {
    title: string
    description: string
    items: RouteItem[]
    routeCost: number
    routeStyles: string[]
}
