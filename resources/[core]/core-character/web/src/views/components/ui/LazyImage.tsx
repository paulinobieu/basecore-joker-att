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
 * As grades de rosto e cabelo passam de 400 itens vindos de CDN; sem o
 * IntersectionObserver o CEF dispara todas as requisicoes de uma vez e
 * trava a primeira renderizacao da tela.
 *
 * A imagem real e baixada por um `Image()` a parte e so entra no DOM
 * quando termina — assim o placeholder nunca pisca meio carregado.
 */
export function LazyImage({ src, className, alt = "" }: LazyImageProps) {
	const [state, setState] = useState<LazyState>("loading");
	const [visible, setVisible] = useState(false);
	const ref = useRef<HTMLImageElement>(null);

	// Reaproveitar a mesma celula para outra imagem tem que voltar ao
	// placeholder: sem isso a miniatura anterior ficaria congelada nela.
	// Ajustar em render, e nao num efeito, evita o quadro intermediario.
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
			className={cn(
				className,
				// Reserva o espaco da miniatura para a grade nao pular
				// enquanto carrega — ou de vez, se a imagem nao existir.
				state !== "loaded" && "h-[3.625rem] w-[3.625rem] object-contain",
				state === "loading" && "p-2",
			)}
		/>
	);
}
