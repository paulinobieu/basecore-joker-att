import { useIsRendered } from "@app/hooks/useIsRendered";
import { AnimationProvider } from "@app/providers/Animation";
import { useBooster } from "@app/stores/Booster";
import { toArray } from "@app/utils/misc";
import { BenefitCard } from "@views/components/BenefitCard";

export function Rewards() {
	const { isRendered } = useIsRendered();
	const data = useBooster((state) => state.data);

	if (!data) return null;

	return (
		<main className="flex h-[calc(100%-5rem)] w-full gap-[1.25rem] p-[1.5rem]">
			{toArray(data.benefits).map((benefit, index) => (
				<AnimationProvider
					key={benefit.id}
					show={isRendered}
					style={{ transitionDelay: `${index * 80}ms` }}
					className="h-full min-w-0 flex-1"
				>
					<BenefitCard benefit={benefit} />
				</AnimationProvider>
			))}
		</main>
	);
}
