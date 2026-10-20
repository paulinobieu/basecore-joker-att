interface BannerProps {
	image: string;
}

export function Banner({ image }: BannerProps) {
	return (
		<div className="totem-banner">
			{image ? (
				<img src={image} alt="Identidade visual do restaurante" />
			) : (
				<span>Banner do restaurante</span>
			)}
		</div>
	);
}
