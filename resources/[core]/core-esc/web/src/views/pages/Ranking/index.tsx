import { useEffect, useMemo } from "react";
import { List, AutoSizer } from "react-virtualized";
import { useNavigate } from "react-router-dom";
import { useShallow } from "zustand/shallow";
import { cn } from "@app/utils";
import { routes } from "@app/router/routes";
import { useImageValidation } from "@app/hooks/useImageValidation";
import { useVisibilityStore } from "@app/stores/Visibility";
import { SpinLoader } from "@views/components/SpinLoader";
import { BackArrow } from "@views/components/BackArrow";
import trophy2 from "@views/assets/images/trophy2.gif";
import fallbackAvatar from "@views/assets/images/fallback-avatar-2.webp";
import { type Category, useRankingStore } from "./store";

function RankRow({
	avatar,
	id,
	name,
	rank,
	score,
	showRank,
}: {
	avatar: string;
	id: number;
	name: string;
	rank: number;
	score: number;
	showRank?: boolean;
}) {
	const selectedCategory = useRankingStore((s) => s.selectedCategory);
	const { imageUrl, isImageValid } = useImageValidation(avatar);
	const formattedScore = useMemo(() => {
		if (!(selectedCategory != null && selectedCategory.showValue))
			return "*****";
		const value = score.toLocaleString("pt-BR", {
			style: "currency",
			currency: "BRL",
			minimumFractionDigits: 0,
			maximumFractionDigits: 2,
		});
		return (selectedCategory == null ? void 0 : selectedCategory.id) === "money"
			? value
			: value.replace("R$", "");
	}, [score, selectedCategory]);
	return (
		<div className="flex min-h-[3.125rem] w-full items-center border border-[#5E5E5E4D] border-t-0 border-solid px-5">
			{showRank && (
				<div
					className={cn(
						"mr-[2.8125rem] flex w-[3.125rem] items-center gap-0.5 font-medium text-[.9375rem]",
						rank > 3 && "pl-6",
					)}
				>
					{rank <= 3 && (
						<img
							src={trophy2}
							className="size-[1.375rem] min-w-[1.375rem] object-contain"
							alt="tropy"
						/>
					)}
					{rank}
					º
				</div>
			)}
			<img
				src={isImageValid ? imageUrl : fallbackAvatar}
				alt="avatar"
				className="mr-[.9375rem] size-[2.125rem] rounded-sm border border-primaryColor/50 border-solid object-cover"
			/>
			<div className="mr-auto flex flex-col items-start">
				<h1 className="font-medium text-white/80 text-xs">{name}</h1>
				{id > 0 && (
					<span className="text-white/60 text-xs">#{id}</span>
				)}
			</div>
			<span className="font-medium text-xs">{formattedScore}</span>
		</div>
	);
}

function PlayerRankRow({
	acessRankKey,
	showRank,
}: {
	acessRankKey: "rank" | "weeklyRank" | "dailyRank";
	showRank: boolean;
}) {
	const { playerId, rankList } = useRankingStore(
		useShallow((s) => ({ playerId: s.playerId, rankList: s[acessRankKey] })),
	);
	const player = useMemo(
		() =>
			rankList.find((r) => r.id === playerId) || {
				rank: 999,
				avatar: "",
				id: 0,
				name: "Você",
				score: 0,
			},
		[playerId, rankList],
	);
	const { avatar, id, rank, score } = player;
	const { imageUrl, isImageValid } = useImageValidation(avatar);
	return (
		<div className="flex min-h-[3.125rem] w-full items-center rounded-sm border border-primaryColor border-solid bg-primaryColor/20 px-5">
			{showRank && (
				<div
					className={cn(
						"mr-[2.8125rem] flex w-[3.125rem] items-center gap-0.5 font-medium text-[.9375rem]",
						rank > 3 && "pl-6",
					)}
				>
					{rank <= 3 && (
						<img
							src={trophy2}
							className="size-[1.375rem] min-w-[1.375rem] object-contain"
							alt="tropy"
						/>
					)}
					{rank}
					º
				</div>
			)}
			<img
				src={isImageValid ? imageUrl : "https://github.com/filipedeschamps.png"}
				alt="avatar"
				className="mr-[.9375rem] size-[2.125rem] rounded-sm border border-primaryColor/50 border-solid object-cover"
			/>
			<div className="mr-auto flex flex-col items-start">
				<h1 className="font-medium text-white/80 text-xs">Você</h1>
				<span className="text-white/60 text-xs">#{id}</span>
			</div>
			<span className="font-medium text-xs">{score}</span>
		</div>
	);
}

function DailyHighlights() {
	const dailyRank = useRankingStore((s) => s.dailyRank);
	const selectedCategory = useRankingStore((s) => s.selectedCategory);
	if ((dailyRank?.length ?? 0) <= 0) return <></>;
	const rowRenderer = ({
		index,
		key,
		style,
	}: {
		index: number;
		key: string;
		style: React.CSSProperties;
	}) => {
		const item = dailyRank[index];
		return (
			<div key={key} style={style}>
				<RankRow key={item.id} {...item} />
			</div>
		);
	};
	return (
		<div className="flex h-fit w-[26.875rem] flex-col rounded-[.625rem] border border-white/10 border-solid bg-[#101217E5] py-[.9375rem]">
			<h1 className="px-[.9375rem] font-medium text-[1.125rem]">
				Destaques diário
			</h1>
			<div className="my-[.9375rem] h-[.0625rem] w-full bg-[#D9D9D912]" />
			<div className="h-[18.125rem] w-full px-[.9375rem]">
				<header className="flex h-10 w-full items-center rounded-tl-[.1875rem] rounded-tr-[.1875rem] border border-[#5E5E5E4D] bg-[#5E5E5E24] px-5">
					<span className="mr-auto text-white/60 text-xs">Usuário</span>
					<span className="text-white/60 text-xs">Pontuação</span>
				</header>
				<div className="hideScroll flex h-[15.625rem] w-full flex-col overflow-auto">
					<AutoSizer>
						{({ height, width }) =>
							!height || !width || height <= 0 || width <= 0 ? (
								<div className="font-bold text-base capitalize">
									<SpinLoader />
									Carregando...
								</div>
							) : (
								<List
									width={width}
									height={height}
									rowCount={
										Number.isNaN(dailyRank.length) ? 0 : dailyRank.length
									}
									rowHeight={50}
									rowRenderer={rowRenderer}
									overscanRowCount={5}
									scrollToIndex={undefined}
									className="hideScroll"
									style={{ outline: "none" }}
								/>
							)
						}
					</AutoSizer>
				</div>
			</div>
			{(selectedCategory == null ? void 0 : selectedCategory.id) !== "facs" && (
				<>
					<div className="my-[.9375rem] h-[.0625rem] w-full bg-[#D9D9D912]" />
					<div className="px-[.9375rem]">
						<PlayerRankRow acessRankKey="rank" showRank={true} />
					</div>
				</>
			)}
		</div>
	);
}

const SearchIcon = () => (
	<svg
		width="1.5rem"
		height="1.5rem"
		viewBox="0 0 24 24"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
	>
		<path
			fillRule="evenodd"
			clipRule="evenodd"
			d="M11 5C14.3137 5 17 7.68629 17 11C17 12.4768 16.4649 13.8277 15.5801 14.873L19.3535 18.6465C19.5488 18.8417 19.5488 19.1583 19.3535 19.3535C19.1583 19.5488 18.8417 19.5488 18.6465 19.3535L14.873 15.5801C13.8277 16.4649 12.4768 17 11 17C7.68629 17 5 14.3137 5 11C5 7.68629 7.68629 5 11 5ZM11 6C8.23858 6 6 8.23858 6 11C6 13.7614 8.23858 16 11 16C13.7614 16 16 13.7614 16 11C16 8.23858 13.7614 6 11 6Z"
			fill="#DDDDDD"
			fillOpacity="0.4"
		/>
	</svg>
);

function SearchFilter() {
	const { filter, setFilter } = useRankingStore(
		useShallow((s) => ({ filter: s.filter, setFilter: s.setFilter })),
	);
	return (
		<div className="flex h-[1.875rem] w-full items-center gap-[.3125rem] rounded-[.1875rem] border border-[#5E5E5E4D] border-solid bg-[#5E5E5E24] px-[.3125rem] transition-all duration-500 focus-within:border-[#5E5E5E]">
			<SearchIcon />
			<input
				placeholder="Pesquisar"
				className="flex-1 bg-transparent text-xs outline placeholder:text-white/60"
				value={filter}
				onChange={(e) => setFilter(e.target.value)}
			/>
		</div>
	);
}

function GeneralRanking() {
	const { rank, filter, selectedCategory } = useRankingStore(
		useShallow((s) => ({
			rank: s.rank,
			filter: s.filter,
			selectedCategory: s.selectedCategory,
		})),
	);
	const filtered = useMemo(
		() =>
			rank.filter((r) =>
				`${r.name} ${r.id}`
					.toLocaleLowerCase()
					.includes(filter.toLocaleLowerCase()),
			),
		[rank, filter],
	);
	const rowRenderer = ({
		index,
		key,
		style,
	}: {
		index: number;
		key: string;
		style: React.CSSProperties;
	}) => {
		const item = filtered[index];
		return (
			<div key={key} style={style}>
				<RankRow key={item.id} {...item} showRank={true} />
			</div>
		);
	};
	return (
		<div className="flex h-fit w-[48.75rem] flex-col rounded-[.625rem] border border-white/10 border-solid bg-[#101217E5] py-[.9375rem]">
			<div className="w-full px-[.9375rem]">
				<SearchFilter />
			</div>
			<div className="my-[.9375rem] h-[.0625rem] w-full bg-[#D9D9D912]" />
			<div className="h-[33.75rem] w-full px-[.9375rem]">
				<header className="flex h-10 w-full items-center rounded-tl-[.1875rem] rounded-tr-[.1875rem] border border-[#5E5E5E4D] bg-[#5E5E5E24] px-5">
					<span className="mr-[2.8125rem] text-white/60 text-xs">Posição</span>
					<span className="mr-auto text-white/60 text-xs">Usuário</span>
					<span className="text-white/60 text-xs">Pontuação</span>
				</header>
				<div className="hideScroll flex h-[31.25rem] w-full flex-col overflow-auto">
					<AutoSizer>
						{({ height, width }) =>
							!height || !width || height <= 0 || width <= 0 ? (
								<div className="font-bold text-base capitalize">
									<SpinLoader />
									Carregando...
								</div>
							) : (
								<List
									width={width}
									height={height}
									rowCount={
										Number.isNaN(filtered.length) ? 0 : filtered.length
									}
									rowHeight={50}
									rowRenderer={rowRenderer}
									overscanRowCount={5}
									scrollToIndex={undefined}
									className="hideScroll"
									style={{ outline: "none" }}
								/>
							)
						}
					</AutoSizer>
				</div>
			</div>
			{(selectedCategory == null ? void 0 : selectedCategory.id) !== "facs" && (
				<>
					<div className="my-[.9375rem] h-[.0625rem] w-full bg-[#D9D9D912]" />
					<div className="px-[.9375rem]">
						<PlayerRankRow acessRankKey="rank" showRank={true} />
					</div>
				</>
			)}
		</div>
	);
}

function WeeklyHighlights() {
	const weeklyRank = useRankingStore((s) => s.weeklyRank);
	const selectedCategory = useRankingStore((s) => s.selectedCategory);
	if ((weeklyRank?.length ?? 0) <= 0) return <></>;
	const rowRenderer = ({
		index,
		key,
		style,
	}: {
		index: number;
		key: string;
		style: React.CSSProperties;
	}) => {
		const item = weeklyRank[index];
		return (
			<div key={key} style={style}>
				<RankRow key={item.id} {...item} />
			</div>
		);
	};
	return (
		<div className="flex h-fit w-[26.875rem] flex-col rounded-[.625rem] border border-white/10 border-solid bg-[#101217E5] py-[.9375rem]">
			<h1 className="px-[.9375rem] font-medium text-[1.125rem]">
				Destaques semanal
			</h1>
			<div className="my-[.9375rem] h-[.0625rem] w-full bg-[#D9D9D912]" />
			<div className="h-[18.125rem] w-full px-[.9375rem]">
				<header className="flex h-10 w-full items-center rounded-tl-[.1875rem] rounded-tr-[.1875rem] border border-[#5E5E5E4D] bg-[#5E5E5E24] px-5">
					<span className="mr-auto text-white/60 text-xs">Usuário</span>
					<span className="text-white/60 text-xs">Pontuação</span>
				</header>
				<div className="flex h-[15.625rem] w-full flex-col">
					<AutoSizer>
						{({ height, width }) =>
							!height || !width || height <= 0 || width <= 0 ? (
								<div className="font-bold text-base capitalize">
									<SpinLoader />
									Carregando...
								</div>
							) : (
								<List
									width={width}
									height={height}
									rowCount={
										Number.isNaN(weeklyRank.length) ? 0 : weeklyRank.length
									}
									rowHeight={50}
									rowRenderer={rowRenderer}
									overscanRowCount={5}
									scrollToIndex={undefined}
									className="hideScroll"
									style={{ outline: "none" }}
								/>
							)
						}
					</AutoSizer>
				</div>
			</div>
			{(selectedCategory == null ? void 0 : selectedCategory.id) !== "facs" && (
				<>
					<div className="my-[.9375rem] h-[.0625rem] w-full bg-[#D9D9D912]" />
					<div className="px-[.9375rem]">
						<PlayerRankRow acessRankKey="rank" showRank={true} />
					</div>
				</>
			)}
		</div>
	);
}

function BackButton() {
	const navigate = useNavigate();
	return (
		<button
			type="button"
			className="flex h-[1.875rem] w-[5.8125rem] items-center justify-center gap-2.5 rounded-[.1875rem] bg-[#5E5E5E3D] pr-4 font-semibold text-sm transition-all duration-500 hover:bg-[#5e5e5eef] active:bg-[#5e5e5eef] active:brightness-75"
			onClick={() => {
				navigate(routes.home);
			}}
		>
			<BackArrow />
			Voltar
		</button>
	);
}

function CategoryButton({ id, name, showValue }: Category) {
	const { selectedCategory, setSelectedCategory } = useRankingStore(
		useShallow((s) => ({
			selectedCategory: s.selectedCategory,
			setSelectedCategory: s.setSelectedCategory,
		})),
	);
	return (
		<button
			type="button"
			className={cn(
				"flex h-[1.875rem] items-center justify-center rounded-[.1875rem] bg-[#5E5E5E26] px-5 font-medium text-sm text-white/80 outline outline-1 outline-transparent transition-all duration-500 hover:bg-primaryColor/20 hover:text-primaryColor hover:outline-primaryColor",
				(selectedCategory == null ? void 0 : selectedCategory.id) === id &&
					"bg-primaryColor/20 text-primaryColor outline-primaryColor",
			)}
			onClick={() => {
				setSelectedCategory({ id, name, showValue });
			}}
		>
			{name}
		</button>
	);
}

function CategoryList() {
	const categories = useRankingStore((s) => s.categories);
	return (
		<div className="flex items-center gap-2.5">
			{(categories?.length ?? 0) > 0 &&
				categories.map((c) => <CategoryButton key={c.id} {...c} />)}
		</div>
	);
}

function Ranking() {
	const visible = useVisibilityStore((s) => s.visible);
	const { rank, dailyRank, weeklyRank, getCategories, getPlayerId } =
		useRankingStore(
			useShallow((s) => ({
				rank: s.rank,
				dailyRank: s.dailyRank,
				weeklyRank: s.weeklyRank,
				getCategories: s.getCategories,
				getPlayerId: s.getPlayerId,
			})),
		);
	useEffect(() => {
		visible && (getCategories(), getPlayerId());
	}, [visible, getCategories, getPlayerId]);
	return (
		<div className="flex h-full w-full flex-col">
			<BackButton />
			<h1 className="mt-[1.125rem] font-medium text-[1.375rem]">Ranking</h1>
			<div className="my-3.5 h-[.0625rem] w-full bg-[#d9d9d9]/[.07]" />
			<CategoryList />
			<main className="mt-[1.5625rem] flex gap-[1.875rem]">
				{(rank?.length ?? 0) > 0 && <GeneralRanking />}
				{(weeklyRank?.length ?? 0) > 0 && (
					<WeeklyHighlights />
				)}
				{(dailyRank?.length ?? 0) > 0 && (
					<DailyHighlights />
				)}
			</main>
		</div>
	);
}

export { Ranking };
