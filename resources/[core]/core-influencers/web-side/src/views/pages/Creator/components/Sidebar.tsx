import { cn } from "@app/utils";
import type { CategoryEntry } from "../hooks/useCreatorView";

interface SidebarProps {
	categories: CategoryEntry[];
	activeCat: string | null;
	onSelect: (cat: string) => void;
}

export function Sidebar({ categories, activeCat, onSelect }: SidebarProps) {
	return (
		<div className="tabs">
			{categories.map((cat) => (
				<button
					key={cat.name}
					type="button"
					className={cn("tab-btn", activeCat === cat.name && "active")}
					onClick={() => onSelect(cat.name)}
				>
					<span className="tab-title">{cat.name}</span>
					<span className="tab-count">{cat.count}</span>
				</button>
			))}
		</div>
	);
}
