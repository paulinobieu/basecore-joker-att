import path from "node:path";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  base: "./",
  resolve: {
    alias: {
      "@app": path.resolve(__dirname, "src", "app"),
      "@views": path.resolve(__dirname, "src", "views"),
    },
  },
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    copyPublicDir: false,
    rollupOptions: {
      output: {
        assetFileNames: (assetInfo) => {
          const assetName = assetInfo.name ?? ''
          if (assetName.endsWith('.png')) {
            return 'assets/animations/[name]-[hash][extname]'
          }
          return 'assets/[name]-[hash][extname]'
        },
      },
    },
  },
})
