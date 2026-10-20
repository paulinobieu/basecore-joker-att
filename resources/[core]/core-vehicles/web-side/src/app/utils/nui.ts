export const isEnvBrowser = (): boolean =>
  typeof (window as any).GetParentResourceName !== "function";

const resourceName = (window as any).GetParentResourceName
  ? (window as any).GetParentResourceName()
  : "core-vehicles";

export async function fetchNui<T = any>(payload: any): Promise<T> {
  if (isEnvBrowser()) {
    const devHandler = (window as any).__devNui;
    if (typeof devHandler === "function") {
      return devHandler(payload) as T;
    }
    console.debug("[DEBUG] fetchNui:", payload);
    return null as T;
  }
  try {
    const resp = await fetch(`https://${resourceName}/_GET`, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=UTF-8" },
      body: JSON.stringify(payload),
    });
    return await resp.json();
  } catch (error) {
    console.error("[ERROR] fetchNui:", error);
    return null as T;
  }
}

export function sendNui(payload: any): void {
  if (isEnvBrowser()) {
    console.debug("[DEBUG] sendNui:", payload);
    return;
  }
  fetch(`https://${resourceName}/_GET`, {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify(payload),
  }).catch(() => {});
}
