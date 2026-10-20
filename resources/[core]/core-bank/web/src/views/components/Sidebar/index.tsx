import { navigation } from "@app/router/routes";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { IconX } from "@tabler/icons-react";
import { Hexagon } from "@views/components/Hexagon";
import { Logo } from "@views/components/Logo";
import type { ReactNode } from "react";
import { useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";

interface NavButtonProps {
	label: string;
	active?: boolean;
	onClick: () => void;
	children: ReactNode;
}

function NavButton({ active, label, onClick, children }: NavButtonProps) {
	const [hovered, setHovered] = useState(false);
	const lit = active || hovered;

	return (
		<button
			type="button"
			title={label}
			onClick={onClick}
			onMouseEnter={() => setHovered(true)}
			onMouseLeave={() => setHovered(false)}
			className="relative flex size-[4.125rem] items-center justify-center"
		>
			<span
				className={cn(
					"pointer-events-none relative z-10 transition-all duration-500",
					lit ? "text-white" : "text-white/45",
				)}
			>
				{children}
			</span>

			<Hexagon active={!!lit} />

			<span
				className={cn(
					"pointer-events-none absolute left-[4.375rem] z-30 whitespace-nowrap rounded-[.25rem] border border-white/[.06] border-solid bg-[#151519] px-2 py-1 font-extrabold text-[.6875rem] text-white uppercase transition-all duration-300",
					hovered ? "opacity-100" : "opacity-0",
				)}
			>
				{label}
			</span>
		</button>
	);
}

export function Sidebar() {
	const { pathname } = useLocation();
	const navigate = useNavigate();
	const fetchHideFrame = useVisibilityStore((state) => state.fetchHideFrame);

	return (
		<aside className="flex w-[6.125rem] flex-shrink-0 flex-col items-center justify-between border-[#D9D9D91A] border-r border-solid pt-5 pb-4">
			<Logo className="size-[2.25rem] text-white" />

			<nav className="flex flex-col items-center">
				{navigation.map((entry) => {
					const Icon = entry.icon;

					return (
						<NavButton
							key={entry.route}
							label={entry.label}
							active={pathname.endsWith(entry.route)}
							onClick={() => navigate(`/${entry.route}`)}
						>
							<Icon stroke={2} className="size-[1.5rem]" />
						</NavButton>
					);
				})}
			</nav>

			<NavButton label="Fechar" onClick={fetchHideFrame}>
				<IconX stroke={2.5} className="size-[1.625rem]" />
			</NavButton>
		</aside>
	);
}
