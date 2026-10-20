import { ButtonHTMLAttributes, ReactNode } from "react";

type Variant = "default" | "themed" | "danger" | "success";

interface CoreButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  icon?: string;
  children?: ReactNode;
  block?: boolean;
}

export function CoreButton({
  variant = "default",
  icon,
  children,
  block,
  className = "",
  ...rest
}: CoreButtonProps) {
  const cls = `cv-btn cv-btn-${variant} ${block ? "cv-btn-block" : ""} ${className}`.trim();
  return (
    <button type="button" className={cls} {...rest}>
      {icon && <i className={icon} />}
      {children && <span>{children}</span>}
    </button>
  );
}
