/**
 * Contrato NUI do core-customization.
 *
 * ACTIONS  — NUI -> client. Vão todas pelo callback `core-customization`, na
 *            chave `action`, via nuiAction()/postNui().
 *
 *            Os valores sao propositalmente opacos: quem abrir o bundle nao
 *            descobre o contrato so de ler as strings. O nome real de cada um
 *            esta no comentario ao lado da entrada correspondente em
 *            client/modules/nui.lua — os dois lados mudam juntos.
 * MESSAGES — client -> NUI (SendNUIMessage), no formato `{ action, payload }`,
 *            consumidas por useNuiMessage().
 */

export const ACTIONS = {
	// ---------- ciclo de vida ----------
	/** NUI montada: o client responde com a mensagem de setup. */
	ready: "CORENETWORKQAsInReVJgrcfqqm",
	/** Catálogo de peças recebido: libera a abertura das lojas. */
	unlock: "CORENETWORKIpoxZMPKdqLpgvJZ",

	// ---------- loja de roupas ----------
	/** Veste o preview no ped a cada ajuste. */
	updatePreview: "CORENETWORKbJKoyxfjmygbKpuw",
	applyClothes: "CORENETWORKpaAIAGxmQkoZvVuD",
	cancelClothes: "CORENETWORKuEMmKdMthLiOEgvi",

	// ---------- loja de tatuagens ----------
	toggleTattoo: "CORENETWORKxGXyQSzXBPLnJvAM",
	applyTattoos: "CORENETWORKbdoiQcyiYQaewpTj",
	cancelTattoos: "CORENETWORKSKKRsLrJcTiRrtvR",

	// ---------- câmera ----------
	rotateCharacter: "CORENETWORKiKxRiHVfrCnDTCwg",
	setFov: "CORENETWORKsJFVUKimuLTPEihU",
	setHeading: "CORENETWORKLoaBbVbAweKeQqsL",
	updateCamera: "CORENETWORKouvpiZYSNKqWOyLM",
} as const;

export const MESSAGES = {
	/** Cores e logo. */
	setup: "setup",
	/** Catálogo de peças por sexo: imagens e nº de texturas. */
	textures: "textures",
	/** Abre uma loja: `{ screen, ...dados }`. */
	open: "open",
	/** Fecha tudo. */
	close: "close",
	/** Notificação em toast. */
	notify: "notify",
} as const;

export type Screen = "clothes" | "tattoos";
