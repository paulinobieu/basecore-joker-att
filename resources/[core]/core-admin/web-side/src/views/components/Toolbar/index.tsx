import { cn } from "@app/utils";
import type { ReactNode } from "react";

/**
 * Barra de comando das paginas: busca, filtros, contador e acao primaria
 * ficam sempre na mesma linha, no topo do conteudo. Componente apenas de
 * layout -- os controles internos mantem os estilos do design existente.
 */
export function Toolbar({
  className,
  children,
}: {
  className?: string;
  children: ReactNode;
}) {
  return (
    <div
      className={cn(
        "flex h-[2.25rem] w-full flex-shrink-0 items-center gap-[.625rem]",
        className
      )}
    >
      {children}
    </div>
  );
}

/** Divisor vertical entre grupos da toolbar. */
export function ToolbarDivider() {
  return <span className="h-[1.25rem] w-px flex-shrink-0 bg-white/[.08]" />;
}

/** Contador/resumo alinhado a direita da toolbar. */
export function ToolbarCount({
  value,
  label,
}: {
  value: ReactNode;
  label: string;
}) {
  return (
    <div className="flex flex-shrink-0 items-baseline gap-1.5">
      <span className="font-black text-[.9375rem] text-white leading-none">
        {value}
      </span>
      <span className="font-black text-[.625rem] text-white/30 uppercase">
        {label}
      </span>
    </div>
  );
}
