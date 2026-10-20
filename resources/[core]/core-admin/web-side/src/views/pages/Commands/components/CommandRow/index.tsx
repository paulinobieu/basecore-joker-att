import type { Icon } from "@tabler/icons-react";
import type { ReactNode } from "react";

interface CommandRowProps {
  title: string;
  description: string;
  icon: Icon;
  children: ReactNode;
}

/**
 * Linha de comando: identificacao a esquerda, controle sempre na mesma
 * coluna a direita -- o olho corre uma coluna so para executar qualquer acao.
 */
export function CommandRow({
  title,
  description,
  icon: RowIcon,
  children,
}: CommandRowProps) {
  return (
    <div className="table-row-bar flex min-h-[3.75rem] flex-1 items-center gap-[.75rem] border-white/[.03] border-b border-solid px-[.875rem] py-[.5rem]">
      <div className="surface-card flex size-[2.5rem] flex-shrink-0 items-center justify-center rounded-[.3125rem] border border-white/[.05] border-solid">
        <RowIcon stroke={2} className="size-[1.125rem] text-primaryColor" />
      </div>

      <div className="flex min-w-0 flex-1 flex-col">
        <span className="truncate font-black text-[.8125rem] text-[#EDEAE5] uppercase">
          {title}
        </span>
        <span className="font-semibold text-[.6875rem] text-white/35 leading-snug">
          {description}
        </span>
      </div>

      <div className="flex w-[15rem] flex-shrink-0 items-center gap-1.5">
        {children}
      </div>
    </div>
  );
}
