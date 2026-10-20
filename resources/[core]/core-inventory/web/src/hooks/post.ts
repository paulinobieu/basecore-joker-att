import { isEnvBrowser } from "@/utils/misc";
import { dispatchNuiDebugCallback } from "@/utils/debugger";
import type { NuiCallbackName, NuiCallbackPayloadMap } from "@/types";

const REQUEST_TIMEOUT = 8000;

async function parseResponse<T>(response: Response): Promise<T> {
  if (!response.ok) {
    throw new Error(`NUI callback returned HTTP ${response.status}`);
  }

  const body = await response.text();
  if (!body) return undefined as T;

  try {
    return JSON.parse(body) as T;
  } catch {
    return body as T;
  }
}

export class Post {
  public static async create<K extends NuiCallbackName, T = unknown>(
    eventName: K,
    data: NuiCallbackPayloadMap[K],
    mockData?: T,
  ): Promise<T> {
    if (isEnvBrowser()) {
      dispatchNuiDebugCallback(eventName, data);
      return mockData as T;
    }

    const controller = new AbortController();
    const timeout = window.setTimeout(
      () => controller.abort(),
      REQUEST_TIMEOUT,
    );
    const options: RequestInit = {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: JSON.stringify(data),
      signal: controller.signal,
    };

    const resourceName = window.GetParentResourceName?.() ?? "nui-frame-app";

    try {
      const response = await fetch(
        `https://${resourceName}/${eventName}`,
        options,
      );
      return await parseResponse<T>(response);
    } catch (error) {
      console.error(`NUI request failed: ${eventName}`, error);
      throw error;
    } finally {
      window.clearTimeout(timeout);
    }
  }

  public static send<K extends NuiCallbackName>(
    eventName: K,
    data: NuiCallbackPayloadMap[K],
  ): void {
    void Post.create(eventName, data).catch(() => undefined);
  }
}
