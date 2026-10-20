import { useImageValidation } from "@app/hooks/useImageValidation";
import { useIsRendered } from "@app/hooks/useIsRendered";
import { AnimationProvider } from "@app/providers/Animation";
import { useBooster } from "@app/stores/Booster";
import { IconGift } from "@tabler/icons-react";
import { Hexagon } from "@views/components/Hexagon";
import { useState } from "react";

export function Topbar() {
	const { isRendered } = useIsRendered();
	const data = useBooster((state) => state.data);
	const { imageUrl, onImageError } = useImageValidation(data?.player.avatar);
	// O emblema some em vez de virar placeholder: nem toda tag tem badge.
	const [badgeFailed, setBadgeFailed] = useState(false);

	return (
		<header className="flex h-[5rem] w-full flex-shrink-0 items-center gap-[1rem] border-[#D9D9D91A] border-b border-solid px-[1.5rem]">
			<AnimationProvider
				show={isRendered}
				className="flex min-w-0 flex-1 items-center gap-[1rem]"
			>
				<Hexagon size={3.25}>
					<IconGift stroke={2} className="size-[1.25rem] text-white" />
				</Hexagon>

				<div className="flex min-w-0 flex-col gap-[.1875rem]">
					<h1 className="truncate font-black text-[1.125rem] text-white uppercase leading-none">
						{data?.language.title}
					</h1>
					<span className="truncate font-semibold text-[.75rem] text-white/30">
						{data?.language.subtitle}
					</span>
				</div>
			</AnimationProvider>

			{/* Perfil na ordem do Discord: foto, nome e a tag do servidor. */}
			<AnimationProvider show={isRendered} className="flex-shrink-0">
				<div className="player-card flex h-[3rem] items-center gap-[.625rem] rounded-[.375rem] border border-white/[.06] border-solid pr-[.5rem] pl-[.4375rem]">
					<img
						src={imageUrl}
						alt={data?.player.name}
						onError={onImageError}
						className="relative z-10 size-[2.125rem] flex-shrink-0 rounded-full border border-white/10 border-solid object-cover"
					/>

					<span className="relative z-10 max-w-[10rem] truncate font-black text-[.875rem] text-white">
						{data?.player.name}
					</span>

					{data?.player.tag ? (
						<span className="tag-chip relative z-10 flex min-w-0 flex-shrink-0 items-center gap-[.25rem] rounded-[.25rem] px-[.375rem] py-[.25rem]">
							{data.player.badge && !badgeFailed ? (
								<img
									src={data.player.badge}
									alt={data.player.tag}
									onError={() => setBadgeFailed(true)}
									className="relative z-10 size-[.8125rem] flex-shrink-0 object-contain"
								/>
							) : null}
							<span className="relative z-10 max-w-[6rem] truncate font-black text-[.6875rem] text-white/75 uppercase leading-none">
								{data.player.tag}
							</span>
						</span>
					) : null}
				</div>
			</AnimationProvider>
		</header>
	);
}
