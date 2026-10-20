import { type EmoteItem, useCreatorStore } from "@app/stores/CreatorStore";
import { cn } from "@app/utils";
import {
	GroupIcon,
	MusicIcon,
	PlayIcon,
	StarIcon,
} from "@views/components/icons";
import {
	memo,
	useEffect,
	useLayoutEffect,
	useMemo,
	useRef,
	useState,
} from "react";
import { creatorActions } from "../actions";

const COLS = 2;
const GAP_REM = 0.625;
const BUFFER_ROWS = 3;

interface EmoteRowProps {
	item: EmoteItem;
	isFavorite: boolean;
	onToggle: (command: string) => void;
}

const EmoteRow = memo(function EmoteRow({
	item,
	isFavorite,
	onToggle,
}: EmoteRowProps) {
	const command = String(item.command || "");

	return (
		<div
			className={cn("item", isFavorite && "isFavorite")}
			onClick={() => creatorActions.play(command)}
		>
			<div className="left">
				<div className="name">{item.label}</div>
				<div className="cmd">/{command}</div>
			</div>

			<div className="right">
				<button
					className={cn("favBtn", isFavorite && "active")}
					type="button"
					title="Favoritar dança"
					onClick={(ev) => {
						ev.preventDefault();
						ev.stopPropagation();
						onToggle(command);
					}}
				>
					<StarIcon width={18} height={18} />
				</button>

				{item.sync && (
					<span className="ico shared" title="Animação compartilhada">
						<GroupIcon width={18} height={18} />
					</span>
				)}

				{item.music && (
					<span className="ico music" title="Possui música">
						<MusicIcon width={18} height={18} />
					</span>
				)}

				<span className="ico play" aria-hidden="true">
					<PlayIcon width={20} height={20} />
				</span>
			</div>
		</div>
	);
});

interface EmoteListProps {
	items: EmoteItem[];
}

export function EmoteList({ items }: EmoteListProps) {
	const favorites = useCreatorStore((state) => state.favorites);
	const toggleFavorite = useCreatorStore((state) => state.toggleFavorite);

	const favoriteSet = useMemo(() => new Set(favorites), [favorites]);

	const scrollRef = useRef<HTMLDivElement>(null);
	const windowRef = useRef<HTMLDivElement>(null);
	const [scrollTop, setScrollTop] = useState(0);
	const [viewportH, setViewportH] = useState(0);
	const [rowH, setRowH] = useState(70);

	useEffect(() => {
		const el = scrollRef.current;
		if (!el) return;

		const update = () => setViewportH(el.clientHeight);
		update();

		const observer = new ResizeObserver(update);
		observer.observe(el);
		return () => observer.disconnect();
	}, []);

	// biome-ignore lint/correctness/useExhaustiveDependencies: reset on list change
	useEffect(() => {
		if (scrollRef.current) scrollRef.current.scrollTop = 0;
		setScrollTop(0);
	}, [items]);

	const rowCount = Math.ceil(items.length / COLS);
	const totalH = rowCount * rowH;

	const startRow = Math.max(0, Math.floor(scrollTop / rowH) - BUFFER_ROWS);
	const endRow = Math.min(
		rowCount,
		Math.ceil((scrollTop + viewportH) / rowH) + BUFFER_ROWS,
	);
	const startIdx = startRow * COLS;
	const endIdx = Math.min(items.length, endRow * COLS);
	const visible = items.slice(startIdx, endIdx);
	const offsetY = startRow * rowH;

	// biome-ignore lint/correctness/useExhaustiveDependencies: measure after layout
	useLayoutEffect(() => {
		const first = windowRef.current?.firstElementChild as HTMLElement | null;
		if (!first) return;

		const remPx =
			Number.parseFloat(getComputedStyle(document.documentElement).fontSize) ||
			16;
		const measured = first.offsetHeight + GAP_REM * remPx;
		if (measured > 0 && Math.abs(measured - rowH) > 1) {
			setRowH(measured);
		}
	}, [items, viewportH]);

	if (items.length === 0) {
		return (
			<div className="list">
				<div className="empty">Nada encontrado.</div>
			</div>
		);
	}

	return (
		<div
			className="list"
			ref={scrollRef}
			onScroll={(e) => setScrollTop(e.currentTarget.scrollTop)}
		>
			<div className="list-sizer" style={{ height: totalH }}>
				<div
					className="list-window"
					ref={windowRef}
					style={{ transform: `translateY(${offsetY}px)` }}
				>
					{visible.map((it) => {
						const command = String(it.command || "");
						return (
							<EmoteRow
								key={command}
								item={it}
								isFavorite={favoriteSet.has(command)}
								onToggle={toggleFavorite}
							/>
						);
					})}
				</div>
			</div>
		</div>
	);
}
