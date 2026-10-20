/**
 * Nome e sobrenome sao gravados separados e usados como identidade do
 * personagem, entao cada campo aceita uma palavra so, sem numeros nem
 * simbolos.
 */
export function validateName(value: string): string | null {
	if (!value.trim()) return "Este campo é obrigatório";

	if (!/^[\p{L}\s]+$/u.test(value)) {
		return "Apenas letras e espaços são permitidos";
	}

	if (value.trim().split(/\s+/).length !== 1) {
		return "Apenas um nome é permitido";
	}

	return null;
}
