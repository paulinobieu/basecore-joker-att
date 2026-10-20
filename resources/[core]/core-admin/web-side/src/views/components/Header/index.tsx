import { useIsRendered } from "@app/hooks/useIsRendered";
import { AnimationProvider } from "@app/providers/Animation";
import { navigation } from "@app/router/routes";
import { useMemo } from "react";
import { useLocation } from "react-router-dom";

export function Header() {
  const { isRendered } = useIsRendered();
  const { pathname } = useLocation();

  const entry = useMemo(
    () => navigation.find((item) => `/${item.route}` === pathname),
    [pathname]
  );

  return (
    <header className="flex h-[4.125rem] w-full items-center border-[#D9D9D91A] border-b border-solid pr-[1.5625rem] pl-[1.25rem]">
      <AnimationProvider
        show={isRendered}
        className="w-[15rem] font-black text-[1.0625rem] text-white uppercase"
      >
        {entry?.label || "Painel"}
      </AnimationProvider>

      <AnimationProvider
        show={isRendered}
        className="flex h-full items-center border-[#D9D9D91A] border-l border-solid pl-5 font-black text-[1.0625rem] text-white/45 uppercase"
      >
        {entry?.subtitle || "Administração"}
      </AnimationProvider>
    </header>
  );
}
