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
		port: 1907,
	},
	build: {
		outDir: "dist",
		// O pacote fechado ofusca cada .js de web/ separadamente. Com o bundle
		// quebrado em chunks, as rotas lazy viram import() de arquivo hasheado e
		// o CEF não resolve depois da ofuscação — então tudo sai num arquivo só.
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
