import type { MenuSection, SubMenuItem } from "@app/constants/menus";
import type {
	CharacterOption,
	OptionGroupName,
	OptionPath,
} from "@app/constants/options";
import { useCharacterStore } from "@app/stores/Character";
import { SectionTitle } from "@views/components/ui/SectionTitle";
import { ColorsCard } from "./ColorsCard";
import { HairCard } from "./HairCard";
import { IdentityForm } from "./IdentityForm";
import { LineageCard } from "./LineageCard";
import { SliderCard } from "./SliderCard";
import { SubMenu } from "./SubMenu";

interface OptionsListProps {
	section: MenuSection;
	activeMenu: string;
	onChangeMenu: (item: SubMenuItem) => void;
	/** Barbearia: algumas secoes so expoem as cores. */
	colorsOnly?: boolean;
	showErrors?: boolean;
	onImport?: () => void;
}

function OptionCard({
	path,
	option,
}: {
	path: OptionPath;
	option: CharacterOption;
}) {
	switch (option.kind) {
		case "lineage":
			return (
				<div className="animate-rise-far">
					<LineageCard path={path} option={option} />
				</div>
			);
		case "hair":
			return (
				<div className="animate-rise">
					<HairCard path={path} option={option} />
				</div>
			);
		case "color":
			return (
				<div className="animate-rise-far">
					<ColorsCard path={path} option={option} />
				</div>
			);
		case "slider":
			return (
				<div className="animate-rise-far">
					<SliderCard path={path} option={option} />
				</div>
			);
		// Nome, sobrenome e sexo aparecem no IdentityForm, nao como card.
		default:
			return null;
	}
}

export function OptionsList({
	section,
	activeMenu,
	onChangeMenu,
	colorsOnly,
	showErrors,
	onImport,
}: OptionsListProps) {
	const options = useCharacterStore((state) => state.options);

	const group = section.group as OptionGroupName;
	const entries = Object.entries(
		((options as any)[group][activeMenu] ?? {}) as Record<
			string,
			CharacterOption
		>,
	);

	const visible = colorsOnly
		? entries.filter(([, option]) => option.kind === "color")
		: entries;

	const activeName =
		section.menus.find((item) => item.index === activeMenu)?.name ?? "";

	const isIdentity = group === "FACESETTINGS" && activeMenu === "infos";

	return (
		<div className="flex w-[29rem] flex-col gap-5">
			{section.menus.length > 0 && (
				<SubMenu
					items={section.menus}
					grid={section.grid}
					active={activeMenu}
					onChange={onChangeMenu}
				/>
			)}

			<SectionTitle name={activeName} />

			{isIdentity && (
				<IdentityForm showErrors={showErrors} onImport={onImport} />
			)}

			{/* A chave troca junto com a secao para a animacao de entrada
			    tocar de novo a cada aba. */}
			{visible.map(([key, option]) => (
				<OptionCard
					key={`${group}:${activeMenu}:${key}`}
					path={[group, activeMenu, key]}
					option={option}
				/>
			))}
		</div>
	);
}
