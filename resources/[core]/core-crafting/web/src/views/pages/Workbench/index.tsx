import { useCrafting } from "@app/stores/Crafting";
import { Loading } from "@views/components/SpinLoader";
import { Queue } from "./components/Queue";
import { RecipeDetails } from "./components/RecipeDetails";
import { RecipeList } from "./components/RecipeList";
import { Requirements } from "./components/Requirements";

export function Workbench() {
	const status = useCrafting((state) => state.status);

	if (status !== "ready") {
		return <Loading label="Carregando bancada" />;
	}

	return (
		<div className="flex h-full w-full">
			<RecipeList />

			<RecipeDetails />

			<aside className="flex h-full w-[23rem] flex-shrink-0 flex-col border-[#D9D9D91A] border-l border-solid">
				<Requirements />
				<Queue />
			</aside>
		</div>
	);
}
