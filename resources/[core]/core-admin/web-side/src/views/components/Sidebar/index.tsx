import { CloseUI } from "./components/CloseUI";
import { Logo } from "./components/Logo";
import { Navbar } from "./components/Navbar";

export function Sidebar() {
  return (
    <aside className="flex w-[6.125rem] flex-col items-center justify-between border-[#D9D9D91A] border-r border-solid pt-5 pb-4">
      <Logo />
      <Navbar />
      <CloseUI />
    </aside>
  );
}
