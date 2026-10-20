/// <reference types="vite/client" />

interface Window {
  GetParentResourceName?: () => string;
  invokeNative?: (native: string, ...args: unknown[]) => unknown;
}
