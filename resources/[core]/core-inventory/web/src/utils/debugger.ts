import type {
  NuiCallbackName,
  NuiCallbackPayloadMap,
  NuiDebugEventFrame,
} from "@/types";
import { isEnvBrowser } from "./misc";

export const NUI_DEBUG_CALLBACK_EVENT = "nui:debug-callback";

export type NuiDebugCallbackFrame = {
  [K in NuiCallbackName]: {
    eventName: K;
    data: NuiCallbackPayloadMap[K];
  };
}[NuiCallbackName];

export function dispatchNuiDebugEvent(event: NuiDebugEventFrame): void {
  window.dispatchEvent(
    new MessageEvent("message", {
      data: event,
    }),
  );
}

export function dispatchNuiDebugCallback<K extends NuiCallbackName>(
  eventName: K,
  data: NuiCallbackPayloadMap[K],
): void {
  const detail = { eventName, data } as NuiDebugCallbackFrame;

  window.dispatchEvent(
    new CustomEvent<NuiDebugCallbackFrame>(NUI_DEBUG_CALLBACK_EVENT, {
      detail,
    }),
  );
}

export class Debugger {
  private readonly events: NuiDebugEventFrame[];
  private readonly timer: number;

  constructor(events: NuiDebugEventFrame[], timer = 1000) {
    this.events = events;
    this.timer = timer;
    if (isEnvBrowser()) {
      this.startProcessing();
    }
  }

  private startProcessing(): void {
    this.events.forEach((event) => {
      setTimeout(() => {
        this.handleEvent(event);
      }, this.timer);
    });
  }

  private handleEvent(event: NuiDebugEventFrame): void {
    dispatchNuiDebugEvent(event);
  }
}
