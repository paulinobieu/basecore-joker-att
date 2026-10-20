import type { MenuIcon, MenuSection, SubMenuItem } from "@app/constants/menus";
import { cn } from "@app/utils";
import {
	IconFingerprint,
	IconMan,
	IconMoodHappy,
	IconScissors,
} from "@tabler/icons-react";
import { HexButton } from "@views/components/ui/HexButton";
import { Panel } from "@views/components/ui/Panel";
import { OptionsList } from "./OptionsList";

const MENU_ICONS: Record<MenuIcon, typeof IconMan> = {
	dna: IconFingerprint,
	face: IconMoodHappy,
	barber: IconScissors,
	body: IconMan,
};

interface CreatorPanelProps {
	menus: Record<string, MenuSection>;
	section: string;
	sectionData: MenuSection;
	activeMenu: string;
	activeItem?: SubMenuItem;
	onSelectSection: (key: string) => void;
	onSelectMenu: (item: SubMenuItem) => void;
	/** A barbearia tem menos secoes, entao os hexagonos ficam centrados. */
	centered?: boolean;
	showErrors?: boolean;
	onImport?: () => void;
}

export function CreatorPanel({
	menus,
	section,
	sectionData,
	activeMenu,
	activeItem,
	onSelectSection,
	onSelectMenu,
	centered,
	showErrors,
	onImport,
}: CreatorPanelProps) {
	return (
		<Panel className="flex h-full w-[31rem] flex-col items-center gap-5 py-10">
			<div
				className={cn(
					"flex w-full items-center px-7",
					centered ? "justify-center gap-16" : "justify-between",
				)}
			>
				{Object.entries(menus).map(([key, item]) => {
					const Icon = MENU_ICONS[item.icon];

					return (
						<button
							key={key}
							type="button"
							onClick={() => onSelectSection(key)}
							className={cn(
								"flex h-fit cursor-pointer flex-col items-center gap-1 text-[#adadad] transition-all duration-500 hover:text-primaryColor",
								section === key && "!text-primaryColor",
							)}
						>
							<HexButton active={section === key}>
								<Icon size={26} stroke={2} />
							</HexButton>

							<p className="font-black text-sm uppercase">{item.name}</p>
						</button>
					);
				})}
			</div>

			<div className="mr-[.575rem] h-full overflow-y-scroll">
				<div className="px-[.875rem] pl-7">
					<OptionsList
						section={sectionData}
						activeMenu={activeMenu}
						colorsOnly={activeItem?.colorsOnly}
						onChangeMenu={onSelectMenu}
						showErrors={showErrors}
						onImport={onImport}
					/>
				</div>
			</div>
		</Panel>
	);
}
