import { isEnvBrowser } from "./misc";

export async function fetchNui<T = any>(
  eventName: string,
  data?: any,
  mockData?: T
): Promise<T> {
  if (isEnvBrowser()) {
    if (typeof mockData !== "undefined") {
      return mockData;
    }
    return null as T;
  }

  const options = {
    method: "post",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify(data),
  };

  const resourceName = (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : "nui-frame-app";

  const resp = await fetch(`https://${resourceName}/${eventName}`, options);
  try {
    const respFormatted = await resp.json();
    return respFormatted;
  } catch (e) {
    return null as T;
  }
}
