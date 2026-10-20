import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import * as path from "node:path";

export default defineConfig({
  plugins: [react()],
  base: "./",
  server: {
    host: "127.0.0.1",
    port: 1904,
  },
  build: {
    outDir: "dist",
  },
  resolve: {
    alias: {
      "@views": path.resolve(__dirname, "src", "views"),
      "@app": path.resolve(__dirname, "src", "app"),
    },
  },
});
