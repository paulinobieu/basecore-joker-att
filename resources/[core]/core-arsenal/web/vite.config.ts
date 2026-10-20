import path from "node:path";
import react from "@vitejs/plugin-react-swc";

import { defineConfig } from "vite";

export default defineConfig({
	plugins: [react()],
	base: "./",
	server: {
		host: "127.0.0.1",
		port: 1904,
	},
	build: {
		outDir: "dist",
		// O pacote fechado ofusca cada .js de web/ separadamente, entao o bundle
		// precisa sair em arquivo unico.
		rollupOptions: {
			output: {
				inlineDynamicImports: true,
				entryFileNames: "assets/index.js",
				assetFileNames: "assets/[name][extname]",
			},
		},
	},
	resolve: {
		alias: {
			"@app": path.resolve(__dirname, "src", "app"),
			"@views": path.resolve(__dirname, "src", "views"),
		},
	},
});
