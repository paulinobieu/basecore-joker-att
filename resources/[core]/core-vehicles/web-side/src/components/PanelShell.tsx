import { ReactNode } from "react";

interface PanelShellProps {
  id?: string;
  title: string;
  search?: { value: string; onChange: (v: string) => void; placeholder?: string };
  showHomeIcon?: boolean;
  homeIcon?: string;
  className?: string;
  children: ReactNode;
  withGradient?: boolean;
  gradientClass?: string;
}

export function PanelShell({
  id,
  title,
  search,
  showHomeIcon = true,
  homeIcon = "fa-solid fa-house",
  className = "",
  children,
  withGradient = true,
  gradientClass = "gp-gradient",
}: PanelShellProps) {
  return (
    <>
      {withGradient && <div className={gradientClass} />}
      <div id={id} className={`cv-panel ${className}`.trim()}>
        <div className="gv-title">
          <span>{title}</span>
        </div>
        {(search || showHomeIcon) && (
          <div className="gv-toolbar">
            {showHomeIcon && (
              <div className="gv-icon-btn" title="Início">
                <i className={homeIcon} />
              </div>
            )}
            {search && (
              <div className="gv-search">
                <input
                  placeholder={search.placeholder ?? "Pesquisar"}
                  value={search.value}
                  onChange={(e) => search.onChange(e.target.value)}
                />
                <i className="fa-solid fa-magnifying-glass" />
              </div>
            )}
          </div>
        )}
        {children}
      </div>
    </>
  );
}
