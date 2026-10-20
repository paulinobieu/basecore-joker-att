import { useIsRendered } from "@app/hooks/useIsRendered";
import { AnimationProvider } from "@app/providers/Animation";
import { useVisibility } from "@app/providers/VisibilityProvider";
import { cn } from "@app/utils";
import { IconX } from "@tabler/icons-react";
import { Hexagon } from "@views/components/Sidebar/components/Hexagon";
import { useState } from "react";

export function CloseUI() {
  const { isRendered } = useIsRendered();
  const { hideFrame } = useVisibility();
  const [isHovered, setIsHovered] = useState(false);

  return (
    <AnimationProvider show={isRendered}>
      <button
        type="button"
        className="relative flex size-[4.125rem] items-center justify-center"
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
        onClick={hideFrame}
      >
        <IconX
          stroke={2}
          className={cn(
            "pointer-events-none relative z-10 size-[1.625rem] transition-all duration-500",
            isHovered ? "text-white" : "text-white/45"
          )}
        />
        <Hexagon active={isHovered} />
      </button>
    </AnimationProvider>
  );
}
