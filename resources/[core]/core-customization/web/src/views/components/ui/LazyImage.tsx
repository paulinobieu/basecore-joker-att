import { cn } from "@app/utils";
import LoadingImage from "@views/assets/images/loading.svg";
import NotFoundImage from "@views/assets/images/not_found.png";
import { useEffect, useRef, useState } from "react";

type LazyState = "loading" | "loaded" | "error";

interface LazyImageProps {
	src: string;
	className?: string;
	alt?: string;
}

/**
 * Miniatura carregada sob demanda, com placeholder e imagem de falha.
 *
 * Uma peça como a jaqueta passa de 700 modelos vindos de CDN; sem o
 * IntersectionObserver o CEF dispara todas as requisições de uma vez e
 * trava a primeira renderização da loja.
 *
 * A imagem real é baixada por um `Image()` à parte e só entra no DOM
 * quando termina — assim o placeholder nunca pisca meio carregado.
 */
export function LazyImage({ src, className, alt = "" }: LazyImageProps) {
	const [state, setState] = useState<LazyState>("loading");
	const [visible, setVisible] = useState(false);
	const ref = useRef<HTMLImageElement>(null);

	// Reaproveitar a mesma célula para outra imagem tem que voltar ao
	// placeholder: sem isso a miniatura anterior ficaria congelada nela.
	// Ajustar em render, e não num efeito, evita o quadro intermediário.
	const [previous, setPrevious] = useState(src);

	if (src !== previous) {
		setPrevious(src);
		setState("loading");
		setVisible(false);
	}

	useEffect(() => {
		const element = ref.current;

		if (!element || visible) return;

		const observer = new IntersectionObserver(
			(entries) => {
				for (const entry of entries) {
					if (!entry.isIntersecting) continue;

					setVisible(true);
					observer.disconnect();
				}
			},
			{ rootMargin: "120px", threshold: 0.1 },
		);

		observer.observe(element);

		return () => observer.disconnect();
	}, [visible]);

	useEffect(() => {
		if (!visible) return;

		const image = new Image();

		image.onload = () => setState("loaded");
		image.onerror = () => setState("error");
		image.src = src;

		return () => {
			image.onload = null;
			image.onerror = null;
		};
	}, [visible, src]);

	const source =
		state === "loaded" ? src : state === "error" ? NotFoundImage : LoadingImage;

	return (
		<img
			ref={ref}
			alt={alt}
			src={source}
			data-lazy={state}
			// O tamanho vem do consumidor: a célula da grade já reserva o
			// espaço, então o placeholder ocupa a mesma caixa da miniatura.
			className={cn(className, state === "loading" && "p-4 opacity-70")}
		/>
	);
}
