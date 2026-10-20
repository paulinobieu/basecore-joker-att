import { useIsRendered } from "@app/hooks/useIsRendered";
import { AnimationProvider } from "@app/providers/Animation";
import type { NavigationEntry } from "@app/router/routes";
import { cn } from "@app/utils";
import { Hexagon } from "@views/components/Sidebar/components/Hexagon";
import { useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";

export function Link({ entry }: { entry: NavigationEntry }) {
  const { isRendered } = useIsRendered();
  const { pathname } = useLocation();
  const [isHovered, setIsHovered] = useState(false);
  const navigate = useNavigate();

  const isOnPage = pathname === `/${entry.route}`;
  const active = isOnPage || isHovered;
  const Icon = entry.icon;

  return (
    <AnimationProvider show={isRendered}>
      <button
        type="button"
        className="relative flex size-[4.125rem] items-center justify-center"
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
        onClick={() => navigate(`/${entry.route}`)}
      >
        <Icon
          stroke={2}
          className={cn(
            "pointer-events-none relative z-10 size-[1.5rem] transition-all duration-500",
            active ? "text-white" : "text-white/45"
          )}
        />
        <Hexagon active={active} />

        <span
          className={cn(
            "pointer-events-none absolute left-[4.375rem] z-[30] whitespace-nowrap rounded-[.25rem] border border-white/[.06] border-solid bg-[#151519] px-2 py-1 font-extrabold text-[.6875rem] text-white uppercase transition-all duration-300",
            isHovered ? "opacity-100" : "opacity-0"
          )}
        >
          {entry.label}
        </span>
      </button>
    </AnimationProvider>
  );
}
