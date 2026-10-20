import { cn } from "@app/utils";

interface DetailProps {
	active?: boolean;
	full?: boolean;
}

/**
 * Marcacao de canto da base, reescrita em colchete militar: em vez da linha
 * atravessando a peca inteira com um ponto na ponta, sao quatro cantoneiras
 * curtas -- a mira de um visor tatico.
 */
export function Detail({ active = false, full = false }: DetailProps) {
	const bracket = cn(
		"absolute size-[.625rem] border-[#D9D9D9]/[.09] transition-all duration-500",
		active && "border-primaryColor",
	);

	return (
		<div className="pointer-events-none absolute inset-0 z-[20] overflow-hidden rounded-[.1875rem]">
			<div className="relative h-full w-full">
				<div
					className={cn(
						bracket,
						"top-[.375rem] left-[.375rem] border-t border-l",
					)}
				/>
				<div
					className={cn(
						bracket,
						"top-[.375rem] right-[.375rem] border-t border-r",
					)}
				/>

				{full && (
					<>
						<div
							className={cn(
								bracket,
								"bottom-[.375rem] left-[.375rem] border-b border-l",
							)}
						/>
						<div
							className={cn(
								bracket,
								"right-[.375rem] bottom-[.375rem] border-r border-b",
							)}
						/>
					</>
				)}
			</div>
		</div>
	);
}
