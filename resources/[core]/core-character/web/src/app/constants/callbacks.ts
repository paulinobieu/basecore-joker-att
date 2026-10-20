/**
 * Contrato NUI do core-character.
 *
 * ACTIONS  — NUI -> client. Vão todas pelo callback `core-character`, na
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
	ready: "CORENETWORKoRLfyvCbHLqbjbFy",
	/** Setup aplicado: libera a interface para receber telas. */
	unlock: "CORENETWORKWArMSkgykbQJsvUB",
	/** Jogador pediu para fechar (Escape). */
	close: "CORENETWORKLhTUvuyoojxOfJBz",

	// ---------- criação / edição ----------
	setGender: "CORENETWORKgEygdlsCPPKJRPyy",
	updateFace: "CORENETWORKTwvzLlMMvibTqLod",
	updateSkin: "CORENETWORKPFsWRjyAweDMshLi",
	updateHead: "CORENETWORKYSkahMLbVuFLuSGD",
	finishCharacter: "CORENETWORKtxxuzWaulrMckKrs",

	// ---------- câmera ----------
	rotateCharacter: "CORENETWORKNdTjvxtYZMgmquRC",
	setFov: "CORENETWORKjIZQuHgSRBaWjpuA",
	setHeading: "CORENETWORKYkPJVZTywmIswyHT",
	updateCamera: "CORENETWORKzZOhbRXmWximUPPA",

	// ---------- seleção de personagem ----------
	selectCharacter: "CORENETWORKUGibAGndpnbbQWZm",
	previewCharacter: "CORENETWORKMlwAtFhQFCynFWKt",
	createCharacter: "CORENETWORKwfbrDykAMwfkGzMv",
	buySlot: "CORENETWORKuDutwNkMpVgQSPGm",

	// ---------- seleção de spawn ----------
	previewLocation: "CORENETWORKlKycstGNoeuARLJU",
	confirmSpawn: "CORENETWORKMxBnUvRHLnxIHpUE",

	// ---------- barbearia ----------
	saveBarber: "CORENETWORKzMxkJtvBcjVFboJR",
	cancelBarber: "CORENETWORKYJHXyabWWBJmjgJo",
} as const;

export const MESSAGES = {
	/** Cores, logo, caminhos de imagem e flags de configuração. */
	setup: "setup",
	/** Abre uma tela: `{ screen, ...dados }`. */
	open: "open",
	/** Fecha tudo. */
	close: "close",
	/** Notificação em toast. */
	notify: "notify",
	/** Resultado de uma ação que foi ao servidor. */
	actionResult: "actionResult",
} as const;

export type Screen = "character" | "select" | "spawn" | "barber";
