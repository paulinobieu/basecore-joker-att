import { RARITY_MAP } from "@app/stores/constants";
import { useImageValidation } from "@app/hooks/useImageValidation";
import { DiamondIcon } from "@views/components/DiamondIcon";
import { SkinFallbackSVG } from "@views/components/SkinFallbackSVG";

interface SkinCardProps {
	image: string;
	model_name?: string;
	name: string;
	rarity: string;
}

export function SkinCard({ image, model_name, name, rarity }: SkinCardProps) {
	const rarityData = RARITY_MAP[rarity] || RARITY_MAP.comum;
	const color = `rgb(${rarityData.rgb})`;
	const { isImageValid } = useImageValidation(image);

	return (
		<div
			className="group relative flex h-[13.75rem] w-[11.875rem] cursor-pointer flex-col items-center overflow-hidden rounded-[.375rem] transition-all duration-300"
			style={{
				background: `linear-gradient(180deg, rgba(${rarityData.rgb}, 0.24) -17.86%, rgba(${rarityData.rgb}, 0) 53.57%), rgba(12, 12, 12, 0.24)`,
				border: `.125rem solid ${color}`,
			}}
		>
			<div className="relative flex h-[7.5rem] w-full items-center justify-center py-[.5rem]">
				<div className="scale-[1.3]">
					<DiamondIcon color={color} />
				</div>
				{!isImageValid && <SkinFallbackSVG fill={color} />}
				{isImageValid && (
					<img
						src={image}
						alt={name}
						className="absolute max-h-[6.25rem] w-[85%] object-contain transition-transform group-hover:scale-105"
						onError={(e) => {
							(e.target as HTMLImageElement).src = image;
						}}
					/>
				)}
			</div>
			<div className="flex flex-col items-center gap-[.125rem] pb-[.625rem]">
				<span
					className="w-full px-[.25rem] text-center font-semibold text-[#F2F2F2] text-[1rem] tracking-[-0.04rem]"
					style={{ fontFamily: "Montserrat, sans-serif" }}
				>
					{name}
				</span>
			</div>
		</div>
	);
}
