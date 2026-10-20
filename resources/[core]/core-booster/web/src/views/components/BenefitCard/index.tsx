import { type IBenefit, useBooster } from "@app/stores/Booster";
import { cn } from "@app/utils";
import { accentVars } from "@app/utils/colors";
import { format, toArray } from "@app/utils/misc";
import { IconChevronRight, IconGift } from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Hexagon } from "@views/components/Hexagon";
import { Icon } from "@views/components/Icon";
import type { CSSProperties } from "react";
import { useShallow } from "zustand/shallow";
import { Rewards } from "./components/Rewards";
import { Status } from "./components/Status";

export function BenefitCard({ benefit }: { benefit: IBenefit }) {
	const { language, claiming, feedback, claimBenefit, openRewards } = useBooster(
		useShallow((state) => ({
			language: state.data?.language,
			claiming: state.claiming,
			feedback: state.feedback,
			claimBenefit: state.claimBenefit,
			openRewards: state.openRewards,
		})),
	);

	if (!language) return null;

	const canClaim = benefit.active && !benefit.claimed;

	const buttonLabel = benefit.claimed
		? language.claimed
		: benefit.active
			? language.claim
			: language.unavailable;

	// A linha acima do rodape conta o estado; o retorno da coleta toma o lugar
	// dela para o jogador ler a resposta sem tirar os olhos do botao.
	const message = !benefit.active
		? language.inactiveMessage
		: benefit.claimed
			? language.claimedMessage
			: language.availableMessage;

	const result = feedback?.id === benefit.id ? feedback : null;

	return (
		<div
			style={accentVars(benefit.accent) as CSSProperties}
			className="benefit-card flex h-full flex-col overflow-hidden rounded-[.5rem] border border-white/[.05] border-solid py-[1.5rem] pr-[1.5rem] pl-[1.75rem]"
		>
			<span className="benefit-rail" />

			<header className="flex items-center gap-[1.125rem]">
				<div className="relative flex flex-shrink-0 items-center justify-center">
					<span className="benefit-glow" />
					<Hexagon size={4.125} active={benefit.active}>
						<Icon
							icon={benefit.icon}
							className={cn(
								"size-[1.625rem]",
								benefit.active ? "text-white" : "text-white/35",
							)}
						/>
					</Hexagon>
				</div>

				<div className="flex min-w-0 flex-1 flex-col gap-[.5rem]">
					<h2 className="truncate font-black text-[1.25rem] text-white uppercase leading-none">
						{benefit.title}
					</h2>
					<Status benefit={benefit} />
				</div>
			</header>

			<p className="mt-[1.125rem] font-semibold text-[.8125rem] text-white/40 leading-[1.55]">
				{benefit.description}
			</p>

			<span className="mt-[1.25rem] h-[.0625rem] w-full flex-shrink-0 bg-white/[.06]" />

			<Rewards benefit={benefit} />

			<footer className="mt-auto flex w-full flex-col gap-[.75rem] pt-[1.25rem]">
				<span
					className={cn(
						"truncate font-semibold text-[.6875rem]",
						result
							? result.success
								? "text-[#52FF97]"
								: "text-[#E24040]"
							: "text-white/35",
					)}
				>
					{result?.message || message}
				</span>

				<div className="flex w-full items-stretch gap-[.625rem]">
					<Button
						size="xl"
						variant={canClaim ? "accent" : "ghost"}
						disabled={!canClaim || claiming === benefit.id}
						onClick={() => claimBenefit(benefit.id)}
						icon={<IconGift stroke={2} className="relative z-10 size-[1rem]" />}
						className="flex-1"
					>
						{buttonLabel}
					</Button>

					<Button
						size="xl"
						onClick={() => openRewards(benefit)}
						icon={
							<IconChevronRight
								stroke={2}
								className="relative z-10 size-[.9375rem]"
							/>
						}
						className="flex-row-reverse"
					>
						{format(language.viewAll, toArray(benefit.rewards).length)}
					</Button>
				</div>
			</footer>
		</div>
	);
}
