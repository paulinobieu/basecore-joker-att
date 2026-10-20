import { useConfigStore } from "@app/stores/Config";

/**
 * Logo no centro superior, nas mesmas medidas do HUD. Imagem e
 * dimensoes vem do setup, que o client pode sobrescrever.
 */
export function Logo() {
	const logo = useConfigStore((state) => state.logo);

	if (!logo.image) return null;

	return (
		<div
			style={{ top: logo.top }}
			className="-translate-x-1/2 pointer-events-none absolute left-1/2 z-50 flex flex-col items-center"
		>
			<img
				src={logo.image}
				alt=""
				className="object-contain"
				style={{ width: logo.width, height: logo.height }}
			/>
		</div>
	);
}
