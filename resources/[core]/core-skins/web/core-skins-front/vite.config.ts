import path from "node:path";
import react from "@vitejs/plugin-react-swc";

import { defineConfig } from "vite";

// https://vitejs.dev/config/
export default defineConfig({
	plugins: [react()],
	base: "./",
	server: {
		open: true,
		host: "127.0.0.1",
		port: 1905,
	},
	build: {
		outDir: "web",
		emptyOutDir: true,
		chunkSizeWarningLimit: 1500,
	},
	resolve: {
		alias: {
			"@app": path.resolve(__dirname, "src", "app"),
			"@views": path.resolve(__dirname, "src", "views"),
		},
	},
});
