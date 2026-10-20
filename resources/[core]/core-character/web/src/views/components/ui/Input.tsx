import { cn } from "@app/utils";
import type { InputHTMLAttributes, TextareaHTMLAttributes } from "react";

/**
 * Superficie dos campos.
 *
 * Usa o atalho `background` em vez de `bg-*`: o utilitario do Tailwind
 * so escreve `background-image`, e o `background-color` branco que o
 * navegador aplica a input/textarea continuaria por baixo.
 */
const FIELD = [
	"rounded-field border border-white/[.08] [background:var(--surface-field)] bg-blend-screen",
	"transition-all duration-500",
	"hover:border-primaryColor/40 focus-within:border-primaryColor/40",
].join(" ");

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
	/** Classes do invólucro, que e quem desenha a superficie. */
	containerClassName?: string;
}

export function Input({ className, containerClassName, ...props }: InputProps) {
	return (
		<div className={cn(FIELD, "flex w-full items-center", containerClassName)}>
			<input
				type="text"
				className={cn(
					"w-full bg-transparent px-5 py-4 font-extrabold text-sm text-white outline-none",
					"placeholder:font-extrabold placeholder:text-ink-ghost",
					className,
				)}
				{...props}
			/>
		</div>
	);
}

export function Textarea({
	className,
	...props
}: TextareaHTMLAttributes<HTMLTextAreaElement>) {
	return (
		<textarea
			className={cn(
				FIELD,
				"w-full resize-none px-3 py-2.5 font-bold text-white text-xs outline-none",
				"placeholder:text-ink-ghost",
				className,
			)}
			{...props}
		/>
	);
}
