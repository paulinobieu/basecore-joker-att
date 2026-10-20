export async function fetchNui<T = unknown>(
    eventName: string,
    data?: Record<string, unknown>
): Promise<T> {
    const resourceName = (window as any).GetParentResourceName
        ? (window as any).GetParentResourceName()
        : 'core-elevator'

    const resp = await fetch(`https://${resourceName}/${eventName}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data ?? {}),
    })

    return resp.json() as Promise<T>
}
