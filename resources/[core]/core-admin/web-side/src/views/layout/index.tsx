import { useClickSound } from "@app/hooks/useClickSound";
import { useVisibility } from "@app/providers/VisibilityProvider";
import { cn } from "@app/utils";
import { Header } from "@views/components/Header";
import { Sidebar } from "@views/components/Sidebar";
import { Outlet } from "react-router-dom";

export function Layout() {
  const { visible } = useVisibility();

  useClickSound();

  return (
    <div
      className={cn(
        "-translate-x-1/2 absolute top-1/2 left-1/2 z-[2] flex h-[50rem] w-[90rem] rounded-[.625rem] bg-[#111114F5] outline outline-[.5625rem] outline-[#14141769] transition-all duration-500",
        visible
          ? "-translate-y-1/2 opacity-100"
          : "-translate-y-[200%] pointer-events-none opacity-0"
      )}
    >
      <Sidebar />
      <div className="flex h-full w-[calc(100%-6.1875rem-.9375rem)] flex-col">
        <Header />
        <main className="flex h-[calc(100%-4.1875rem)] w-full">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
