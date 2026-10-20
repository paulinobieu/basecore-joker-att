import path from "node:path";
import react from "@vitejs/plugin-react-swc";
import { defineConfig } from "vite";

export default defineConfig({
	base: "./",
	plugins: [react()],
	server: {
		host: "127.0.0.1",
		port: 1904,
	},
	resolve: {
		alias: {
			"@app": path.resolve(__dirname, "src", "app"),
			"@views": path.resolve(__dirname, "src", "views"),
		},
	},
	build: {
		outDir: "dist",
		sourcemap: false,
	},
});
