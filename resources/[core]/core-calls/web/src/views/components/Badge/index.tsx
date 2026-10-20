type Props = {
	children: React.ReactNode;
	/** Versao enxuta sem stage/anel — usar em contextos pequenos (toast/hint). */
	compact?: boolean;
};

/**
 * Badge sobrio: diamante solido em `--primary` + glifo branco no centro.
 * currentColor controla o fill via .app-header-badge / .incoming-icon /
 * .active-hint-icon (todos com `color: rgb(var(--primary-rgb))`).
 *
 * `compact` remove os detalhes internos (stage escura + anel branco) — eles
 * viram so ruido visual em tamanhos pequenos.
 */
export function Badge({ children, compact }: Props) {
	return (
		<svg
			viewBox="0 0 50 50"
			fill="none"
			xmlns="http://www.w3.org/2000/svg"
			aria-hidden
		>
			{/* Diamante solido em primary */}
			<path
				d="M20.7574 4.24264C23.1005 1.8995 26.8995 1.89949 29.2426 4.24264L45.7574 20.7574C48.1005 23.1005 48.1005 26.8995 45.7574 29.2426L29.2426 45.7574C26.8995 48.1005 23.1005 48.1005 20.7574 45.7574L4.24264 29.2426C1.8995 26.8995 1.89949 23.1005 4.24264 20.7574L20.7574 4.24264Z"
				fill="currentColor"
			/>
			{!compact && (
				<>
					{/* Stage interna sutilmente mais escura */}
					<path
						d="M23.7275 10.5557C24.4304 9.85292 25.5696 9.85292 26.2725 10.5557L39.4443 23.7275C40.1471 24.4304 40.1471 25.5696 39.4443 26.2725L26.2725 39.4443C25.5696 40.1471 24.4304 40.1471 23.7275 39.4443L10.5557 26.2725C9.85292 25.5696 9.85292 24.4304 10.5557 23.7275L23.7275 10.5557Z"
						fill="rgba(0, 0, 0, 0.18)"
					/>
					{/* Anel branco fino entre a stage e a borda */}
					<path
						d="M22.5254 6.93164C23.8921 5.56521 26.1079 5.56521 27.4746 6.93164L43.0684 22.5254C44.4348 23.8921 44.4348 26.1079 43.0684 27.4746L27.4746 43.0684C26.1079 44.4348 23.8921 44.4348 22.5254 43.0684L6.93164 27.4746C5.56521 26.1079 5.56521 23.8921 6.93164 22.5254L22.5254 6.93164Z"
						fill="none"
						stroke="rgba(255, 255, 255, 0.28)"
						strokeWidth="0.4"
					/>
				</>
			)}
			{/* Glifo branco no centro */}
			<g color="#ffffff">{children}</g>
		</svg>
	);
}

/* ── Glifos centrais (use dentro de <Badge>) ───────────────── */

/** Balao de fala — usado no prompt do jogador */
export function GlyphChat() {
	return (
		<g
			transform="translate(15.5 16) scale(0.79)"
			stroke="currentColor"
			strokeWidth="1.8"
			strokeLinecap="round"
			strokeLinejoin="round"
			fill="none"
		>
			<path d="M2 4a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H8l-5 4v-4H4a2 2 0 0 1-2-2V4z" />
			<circle cx="8" cy="9" r="1" fill="currentColor" stroke="none" />
			<circle cx="12" cy="9" r="1" fill="currentColor" stroke="none" />
			<circle cx="16" cy="9" r="1" fill="currentColor" stroke="none" />
		</g>
	);
}

/** Headset — Central de Chamados (staff atendendo) */
export function GlyphHeadset() {
	return (
		<g
			transform="translate(15.5 15.5) scale(0.79)"
			stroke="currentColor"
			strokeWidth="1.8"
			strokeLinecap="round"
			strokeLinejoin="round"
			fill="none"
		>
			<path d="M4 13v-1a8 8 0 0 1 16 0v1" />
			<path d="M3 13h3v6H4a1 1 0 0 1-1-1v-5z" fill="currentColor" />
			<path d="M21 13h-3v6h2a1 1 0 0 0 1-1v-5z" fill="currentColor" />
			<path d="M18 19v1a2 2 0 0 1-2 2h-3" />
		</g>
	);
}

/** Estrela — feedback de avaliacao */
export function GlyphStar() {
	return (
		<g transform="translate(14.5 15) scale(0.87)">
			<path
				d="M11 1.5l2.7 5.7 6.3.9-4.6 4.3 1.1 6.2L11 15.7l-5.6 2.9 1.1-6.2L2 8.1l6.3-.9L11 1.5z"
				fill="currentColor"
				stroke="currentColor"
				strokeWidth="0.6"
				strokeLinejoin="round"
			/>
		</g>
	);
}

/** Escudo com chave — menu de acoes da staff */
export function GlyphShieldTool() {
	return (
		<g
			transform="translate(15.5 14.5) scale(0.83)"
			stroke="currentColor"
			strokeWidth="1.7"
			strokeLinecap="round"
			strokeLinejoin="round"
			fill="none"
		>
			<path
				d="M12 1.5L4 4.4v6.1c0 5 3.4 9.6 8 10.9 4.6-1.3 8-5.9 8-10.9V4.4l-8-2.9z"
				fill="currentColor"
				fillOpacity="0.15"
			/>
			<path d="M9 12l-1.4 1.4a2 2 0 1 0 2.8 2.8L15 11.6" />
			<path d="M13.5 7.5l3 3 1.5-1.5-3-3-1.5 1.5z" fill="currentColor" />
		</g>
	);
}

/** Sino — toast de chamado recebido (usado dentro do toast, fora do diamante) */
export function GlyphBell() {
	return (
		<g
			transform="translate(14.5 14) scale(0.86)"
			stroke="currentColor"
			strokeWidth="1.8"
			strokeLinecap="round"
			strokeLinejoin="round"
			fill="none"
		>
			<path d="M6 8a6 6 0 1 1 12 0c0 4 1.5 6 2 7H4c.5-1 2-3 2-7z" fill="currentColor" fillOpacity="0.15" />
			<path d="M10.5 19a1.5 1.5 0 0 0 3 0" />
		</g>
	);
}
