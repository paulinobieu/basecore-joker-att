export const isEnvBrowser = (): boolean =>
  typeof window.invokeNative !== "function";
