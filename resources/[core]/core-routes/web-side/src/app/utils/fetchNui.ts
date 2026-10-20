import { isEnvBrowser, sleep } from './misc'

const resourceName = (window as any).GetParentResourceName
  ? (window as any).GetParentResourceName()
  : 'core-routes'

export async function fetchNui<T = unknown>({
  path,
  payload,
  delay,
  mockData,
}: {
  path: string
  payload?: any
  delay?: number
  mockData?: T
}): Promise<T> {
  const isBrowser = isEnvBrowser()

  if (isBrowser && mockData) {
    if (delay) await sleep(delay)
    return mockData
  }

  if (isBrowser) return null as T

  try {
    const resp = await fetch(`https://${resourceName}/${path}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(payload ?? {}),
    })

    return (await resp.json()) as T
  } catch (error) {
    console.error(`[ERROR] fetchNui ${path} ->`, error)
    return null as T
  }
}
