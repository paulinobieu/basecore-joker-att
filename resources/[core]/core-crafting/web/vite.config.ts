import path from "node:path";
import react from "@vitejs/plugin-react-swc";

import { defineConfig } from "vite";

export default defineConfig({
	plugins: [react()],
	base: "./",
	server: {
		host: "127.0.0.1",
		port: 1906,
	},
	build: {
		outDir: "dist",
	},
	resolve: {
		alias: {
			"@app": path.resolve(__dirname, "src", "app"),
			"@views": path.resolve(__dirname, "src", "views"),
		},
	},
});
