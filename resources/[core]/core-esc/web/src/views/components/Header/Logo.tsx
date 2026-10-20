import { useImageValidation } from "@app/hooks/useImageValidation";
import { useEscStore } from "@app/stores/Esc";
import LogoFallback from "@views/assets/images/logo-fallback.png";

export function Logo() {
	const logo = useEscStore((state) => state.logo);
	const { imageUrl, isImageValid } = useImageValidation(logo);

	return (
		<img
			src={isImageValid ? imageUrl : LogoFallback}
			alt="logo"
			className="mr-[1.625rem] h-full w-[6.375rem] object-contain"
		/>
	);
}
