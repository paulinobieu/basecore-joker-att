import { useCreatorStore } from "@app/stores/CreatorStore";
import { useVisibilityStore } from "@app/stores/Visibility";
import { BrandLogo, SearchIcon } from "@views/components/icons";
import { useEffect, useRef, useState } from "react";
import { EmoteList } from "./components/EmoteList";
import { GroupModal } from "./components/GroupModal";
import { Sidebar } from "./components/Sidebar";
import { TopBar } from "./components/TopBar";
import { useCreatorView } from "./hooks/useCreatorView";
import { useDraggable } from "./hooks/useDraggable";

export function Creator() {
	const visible = useVisibilityStore((state) => state.visible);
	const close = useVisibilityStore((state) => state.close);

	const search = useCreatorStore((state) => state.search);
	const setSearch = useCreatorStore((state) => state.setSearch);

	const { categories, activeCat, items, setActiveCat } = useCreatorView();

	const [groupOpen, setGroupOpen] = useState(false);

	const frameRef = useRef<HTMLDivElement>(null);
	const handleRef = useRef<HTMLDivElement>(null);
	const searchRef = useRef<HTMLInputElement>(null);

	useDraggable(frameRef, handleRef);

	useEffect(() => {
		if (!visible) return;
		const id = setTimeout(() => searchRef.current?.focus(), 50);
		return () => clearTimeout(id);
	}, [visible]);

	useEffect(() => {
		const listener = (e: KeyboardEvent) => {
			if (e.key !== "Escape") return;
			if (groupOpen) {
				setGroupOpen(false);
				return;
			}
			close();
		};

		window.addEventListener("keydown", listener);
		return () => window.removeEventListener("keydown", listener);
	}, [groupOpen, close]);

	if (!visible) return null;

	return (
		<div className="wrap">
			<div className="influencer-frame" ref={frameRef}>
				<div className="effect-circle effect-circle--a" />
				<div className="effect-circle effect-circle--b" />

				<div className="influencer-panel">
					<aside className="sidebar">
						<div className="sidebar-brand" ref={handleRef}>
							<BrandLogo />
							<div className="brand-text">
								<span className="brand-line1">Painel</span>
								<span className="brand-line2">Influencers</span>
							</div>
						</div>

						<div className="sidebar-label">Categorias</div>

						<Sidebar
							categories={categories}
							activeCat={activeCat}
							onSelect={setActiveCat}
						/>
					</aside>

					<main className="main">
						<div className="main-head">
							<div className="main-title">
								<span className="main-title-text">
									{activeCat ?? "Emotes"}
								</span>
								<span className="main-title-count">
									{items.length} {items.length === 1 ? "item" : "itens"}
								</span>
							</div>

							<TopBar onOpenGroup={() => setGroupOpen(true)} />
						</div>

						<div className="searchRow">
							<SearchIcon className="search-icon" />
							<input
								ref={searchRef}
								type="text"
								placeholder="Pesquisar emote..."
								autoComplete="off"
								value={search}
								onChange={(e) => setSearch(e.target.value)}
							/>
							<span className="search-hint">
								<b>F6</b> cancelar
							</span>
						</div>

						<EmoteList items={items} />
					</main>

					<GroupModal open={groupOpen} onClose={() => setGroupOpen(false)} />
				</div>
			</div>
		</div>
	);
}
