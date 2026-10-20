import type { SubMenuItem } from "@app/constants/menus";
import { cn } from "@app/utils";
import { Toggle } from "@views/components/ui/Toggle";

interface SubMenuProps {
	items: SubMenuItem[];
	grid: string;
	active: string;
	onChange: (item: SubMenuItem) => void;
}

export function SubMenu({ items, grid, active, onChange }: SubMenuProps) {
	return (
		<div className={cn("w-full gap-2", grid)}>
			{items.map((item) => (
				<Toggle
					key={item.index}
					active={item.index === active}
					onClick={() => onChange(item)}
					className={cn("px-4 py-[.65rem]", item.span)}
				>
					<p className="truncate text-sm tracking-widest">{item.name}</p>
				</Toggle>
			))}
		</div>
	);
}
