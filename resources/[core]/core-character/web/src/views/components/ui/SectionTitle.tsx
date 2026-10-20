import { cn } from "@app/utils";

interface SectionTitleProps {
	name: string;
	className?: string;
}

/** Titulo de secao com a linha que preenche o resto da largura. */
export function SectionTitle({ name, className }: SectionTitleProps) {
	return (
		<div className={cn("flex w-full items-center gap-3", className)}>
			<h1 className="w-fit font-black text-[1.0625rem] text-white uppercase">
				{name}
			</h1>
			<div className="h-[.0625rem] flex-1 bg-[#D9D9D91A]" />
		</div>
	);
}
