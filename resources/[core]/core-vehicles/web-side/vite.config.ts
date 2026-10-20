import path from "node:path";
import react from "@vitejs/plugin-react-swc";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [react()],
  base: "./",
  server: {
    open: true,
    host: "127.0.0.1",
    port: 1904,
  },
  resolve: {
    alias: {
      "@app": path.resolve(__dirname, "src", "app"),
    },
  },
  build: {
    outDir: "dist",
    emptyOutDir: true,
  },
});
