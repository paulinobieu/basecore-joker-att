import path from "node:path";
import react from "@vitejs/plugin-react-swc";
import { defineConfig } from "vite";
import viteBundleObfuscator from "vite-plugin-bundle-obfuscator";

// https://vitejs.dev/config/
export default defineConfig({
	plugins: [
		react(),
		viteBundleObfuscator({
			// O bundle sai inteiro num arquivo só (inlineDynamicImports abaixo),
			// então não há chunk de node_modules para separar. Deixar o auto
			// exclude ligado criaria um segundo arquivo — e ele sairia limpo.
			autoExcludeNodeModules: false,
			threadPool: true,
			log: true,
			options: {
				compact: true,
				// As duas opções mais caras do obfuscator ficam desligadas: elas
				// custam runtime e a interface aqui redesenha a cada clique no
				// preview do personagem.
				controlFlowFlattening: false,
				deadCodeInjection: false,
				debugProtection: false,
				disableConsoleOutput: true,
				identifierNamesGenerator: "hexadecimal",
				numbersToExpressions: false,
				renameGlobals: false,
				selfDefending: true,
				simplify: true,
				splitStrings: false,
				stringArray: true,
				stringArrayCallsTransform: false,
				stringArrayEncoding: [],
				stringArrayIndexShift: true,
				stringArrayRotate: true,
				stringArrayShuffle: true,
				// Abaixo de 1 sobra ~1 em cada 4 strings em texto plano no bundle —
				// inclusive nome de callback NUI. 1 manda todas para o array.
				stringArrayThreshold: 1,
				stringArrayWrappersChainedCalls: true,
				stringArrayWrappersCount: 1,
				stringArrayWrappersParametersMaxCount: 2,
				stringArrayWrappersType: "variable",
				unicodeEscapeSequence: false,
			},
		}),
	],
	base: "./",
	server: {
		open: true,
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
		// O resource serve a NUI de web/, entao o bundle sai com nomes
		// estaveis: o fxmanifest lista os arquivos sem hash.
		outDir: "dist",
		emptyOutDir: true,
		// Um bundle só e ofuscado passa de 500kB por construção; o aviso padrão
		// só pediria para dividir em chunks, que é justamente o que não queremos.
		chunkSizeWarningLimit: 2000,
		rollupOptions: {
			output: {
				// Junta tudo num bundle só. Vale por dois motivos: o fxmanifest
				// não precisa acompanhar nome de chunk novo a cada release, e a
				// ofuscação pega o código inteiro em vez de um pedaço.
				inlineDynamicImports: true,
				entryFileNames: "assets/index.js",
				assetFileNames: "assets/[name][extname]",
			},
		},
	},
});
