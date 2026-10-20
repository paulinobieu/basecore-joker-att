/**
 * Returns true when running in a normal browser (dev mode),
 * false when running inside FiveM NUI.
 */
export function isEnvBrowser(): boolean {
    return !(window as any).invokeNative
}
