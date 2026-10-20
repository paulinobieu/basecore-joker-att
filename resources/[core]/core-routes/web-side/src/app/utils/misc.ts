export const isEnvBrowser = (): boolean => !(window as any).invokeNative

export const sleep = (ms: number) =>
  new Promise((resolve) => {
    setTimeout(resolve, ms)
  })
