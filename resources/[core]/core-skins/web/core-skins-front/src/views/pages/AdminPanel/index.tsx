import { type ReactNode, useCallback, useEffect, useMemo, useState } from "react";
import { fetchNui } from "@app/utils/fetchNui";
import { formatNumber } from "@app/utils/misc";
import { useVisibility } from "@app/stores/Visibility";
import { useKeyPress } from "@app/hooks/useKeyPress";
import { RARITY_MAP } from "@app/stores/constants";
import skinFallbackImage from "@views/assets/images/skin-item.png";
import "./admin.css";

// ── Types ──────────────────────────────────────────────────────────────────────

interface PlayerRow {
	id: number;
	name: string;
	avatar: string | null;
	online: boolean;
}

interface AdminSkin {
	model_name: string;
	name: string;
	image: string;
	rarity: string;
	weapon: string;
	quantity: number;
	equipped: boolean;
	price: number;
}

interface PlayerDetail {
	id: number;
	name: string;
	avatar: string | null;
	online: boolean;
	useFrameworkCoins: boolean;
	skinsCoins: number;
	vouchers: number;
	skins: AdminSkin[];
	stats: {
		skinsDistinct: number;
		skinsTotal: number;
		boxesOpened: number;
		collectionValue: number;
	};
}

interface CatalogueSkin {
	model_name: string;
	name: string;
	image: string;
	rarity: string;
	price: number;
}

interface CatalogueCategory {
	id: string;
	name: string;
	skins: CatalogueSkin[];
}

type CatalogueMode = "player" | "all";

// ── Mocks (browser dev) ──────────────────────────────────────────────────────────

const MOCK_PLAYERS: PlayerRow[] = [
	{ id: 4964, name: "Bieu do Grau", avatar: null, online: true },
	{ id: 1201, name: "Maria Silva", avatar: null, online: true },
	{ id: 882, name: "Carlos Mendes", avatar: null, online: false },
];

const MOCK_DETAIL: PlayerDetail = {
	id: 4964,
	name: "Bieu do Grau",
	avatar: null,
	online: true,
	useFrameworkCoins: false,
	skinsCoins: 8000,
	vouchers: 786,
	skins: [
		{ model_name: "AK_Storm", name: "AK-103 Storm", image: skinFallbackImage, rarity: "lendario", weapon: "WEAPON_ASSAULTRIFLE", quantity: 1, equipped: true, price: 40 },
		{ model_name: "AK_Future", name: "AK Future", image: skinFallbackImage, rarity: "epico", weapon: "WEAPON_ASSAULTRIFLE", quantity: 2, equipped: false, price: 20 },
	],
	stats: { skinsDistinct: 2, skinsTotal: 3, boxesOpened: 47, collectionValue: 80 },
};

const MOCK_CATALOGUE: CatalogueCategory[] = [
	{
		id: "WEAPON_ASSAULTRIFLE",
		name: "AK",
		skins: [
			{ model_name: "AK_Storm", name: "AK-103 Storm", image: skinFallbackImage, rarity: "lendario", price: 40 },
			{ model_name: "AK_Future", name: "AK Future", image: skinFallbackImage, rarity: "epico", price: 20 },
		],
	},
];

const INPUT_CLS =
	"w-full h-12 px-4 rounded-md bg-white/5 border border-white/10 text-white placeholder-white/40 text-sm outline-none focus:border-[rgb(var(--primaryColor))] transition-colors";
const CARD_BG = "rgba(255, 255, 255, 0.02)";

function rarityRgb(rarity: string) {
	return (RARITY_MAP[rarity] || RARITY_MAP.comum).rgb;
}

// ── Component ───────────────────────────────────────────────────────────────────

export function AdminPanel() {
	const fetchHideFrame = useVisibility((s) => s.fetchHideFrame);
	const visible = useVisibility((s) => s.visible);

	const [query, setQuery] = useState("");
	const [players, setPlayers] = useState<PlayerRow[]>([]);
	const [selectedId, setSelectedId] = useState<number | null>(null);
	const [detail, setDetail] = useState<PlayerDetail | null>(null);
	const [loadingDetail, setLoadingDetail] = useState(false);
	const [busy, setBusy] = useState(false);
	const [toast, setToast] = useState("");

	const [coinInput, setCoinInput] = useState("");
	const [voucherInput, setVoucherInput] = useState("");

	const [catalogueOpen, setCatalogueOpen] = useState(false);
	const [catalogueMode, setCatalogueMode] = useState<CatalogueMode>("player");
	const [catalogue, setCatalogue] = useState<CatalogueCategory[]>([]);
	const [catalogueQuery, setCatalogueQuery] = useState("");
	const [catalogueSkin, setCatalogueSkin] = useState<CatalogueSkin | null>(null);
	const [catalogueAmount, setCatalogueAmount] = useState("1");

	const [confirmWipe, setConfirmWipe] = useState(false);

	const [giveAllOpen, setGiveAllOpen] = useState(false);
	const [giveAllId, setGiveAllId] = useState("");

	useKeyPress("Escape", fetchHideFrame);

	const showToast = useCallback((message: string) => {
		setToast(message);
		setTimeout(() => setToast(""), 3000);
	}, []);

	// ── Search ────────────────────────────────────────────────────────────────

	const search = useCallback(async (term: string) => {
		const data = await fetchNui<PlayerRow[]>({
			path: "get:admin:search",
			payload: { term },
			mockData: MOCK_PLAYERS,
		});
		if (Array.isArray(data)) setPlayers(data);
	}, []);

	useEffect(() => {
		const id = setTimeout(() => search(query.trim()), 350);
		return () => clearTimeout(id);
	}, [query, search]);

	// ── Detail ────────────────────────────────────────────────────────────────

	const loadDetail = useCallback(async (passport: number) => {
		setSelectedId(passport);
		setLoadingDetail(true);
		const data = await fetchNui<PlayerDetail | false>({
			path: "get:admin:player",
			payload: { passport },
			mockData: MOCK_DETAIL,
		});
		setLoadingDetail(false);
		if (data) {
			setDetail(data);
			setCoinInput("");
			setVoucherInput("");
		}
	}, []);

	const backToList = () => {
		setSelectedId(null);
		setDetail(null);
	};

	const applyDetail = useCallback((data: PlayerDetail | false | null) => {
		if (data) setDetail(data);
	}, []);

	// ── Actions ──────────────────────────────────────────────────────────────

	const currencyAction = async (
		currency: "coins" | "vouchers",
		op: "give" | "remove" | "set",
	) => {
		if (!detail || busy) return;
		const raw = currency === "coins" ? coinInput : voucherInput;
		const amount = Math.floor(Number(raw));
		if (!Number.isFinite(amount) || amount < 0) return;
		setBusy(true);
		const result = await fetchNui<PlayerDetail | false>({
			path: "post:admin:currency",
			payload: { passport: detail.id, currency, op, amount },
			mockData: MOCK_DETAIL,
		});
		setBusy(false);
		applyDetail(result);
		if (result) showToast("Saldo atualizado.");
	};

	const removeSkin = async (skin: AdminSkin) => {
		if (!detail || busy) return;
		setBusy(true);
		const result = await fetchNui<PlayerDetail | false>({
			path: "post:admin:removeSkin",
			payload: { passport: detail.id, skinId: skin.model_name },
			mockData: MOCK_DETAIL,
		});
		setBusy(false);
		applyDetail(result);
		if (result) showToast(`Skin "${skin.name}" removida.`);
	};

	const wipeSkins = async () => {
		if (!detail || busy) return;
		setBusy(true);
		const result = await fetchNui<PlayerDetail | false>({
			path: "post:admin:wipeSkins",
			payload: { passport: detail.id },
			mockData: { ...MOCK_DETAIL, skins: [], stats: { ...MOCK_DETAIL.stats, skinsDistinct: 0, skinsTotal: 0, collectionValue: 0 } },
		});
		setBusy(false);
		setConfirmWipe(false);
		applyDetail(result);
		if (result) showToast("Skins do jogador zeradas.");
	};

	// ── Catalogue ──────────────────────────────────────────────────────────────

	const openCatalogue = async (mode: CatalogueMode) => {
		if (mode === "player" && !detail) return;
		setCatalogueMode(mode);
		setCatalogueSkin(null);
		setCatalogueAmount("1");
		setCatalogueQuery("");
		setCatalogueOpen(true);
		if (catalogue.length === 0) {
			const data = await fetchNui<CatalogueCategory[]>({
				path: "get:admin:catalogue",
				mockData: MOCK_CATALOGUE,
			});
			if (Array.isArray(data)) setCatalogue(data);
		}
	};

	const confirmCatalogue = async () => {
		if (!catalogueSkin || busy) return;
		const amount = Math.max(1, Math.floor(Number(catalogueAmount) || 1));
		setBusy(true);
		if (catalogueMode === "player") {
			if (!detail) {
				setBusy(false);
				return;
			}
			const result = await fetchNui<PlayerDetail | false>({
				path: "post:admin:giveSkin",
				payload: { passport: detail.id, skinId: catalogueSkin.model_name, amount },
				mockData: MOCK_DETAIL,
			});
			setBusy(false);
			applyDetail(result);
			if (result) showToast(`Skin "${catalogueSkin.name}" enviada.`);
		} else {
			const result = await fetchNui<{ count: number } | false>({
				path: "post:admin:giveAll",
				payload: { skinId: catalogueSkin.model_name, amount },
				mockData: { count: 12 },
			});
			setBusy(false);
			if (result) showToast(`Skin enviada para ${result.count} jogador(es) online.`);
		}
		setCatalogueOpen(false);
	};

	const giveAllSkins = async () => {
		const passport = Math.floor(Number(giveAllId));
		if (!Number.isFinite(passport) || passport <= 0 || busy) return;
		setBusy(true);
		const result = await fetchNui<{ count: number; player: PlayerDetail | false } | false>({
			path: "post:admin:giveAllSkins",
			payload: { passport },
			mockData: { count: 71, player: MOCK_DETAIL },
		});
		setBusy(false);
		setGiveAllOpen(false);
		if (result) {
			showToast(`${result.count} skins entregues ao #${passport}.`);
			if (result.player && detail && detail.id === passport) applyDetail(result.player);
		}
	};

	const flatCatalogue = useMemo(() => {
		const term = catalogueQuery.trim().toLowerCase();
		const all = catalogue.flatMap((c) => c.skins.map((s) => ({ ...s, weapon: c.name })));
		if (!term) return all;
		return all.filter(
			(s) => s.name.toLowerCase().includes(term) || s.weapon.toLowerCase().includes(term),
		);
	}, [catalogue, catalogueQuery]);

	// ── Render ─────────────────────────────────────────────────────────────────

	return (
		<div
			className={`skinsadm fixed inset-0 z-[2] flex items-center justify-center transition-opacity duration-500 ${visible ? "opacity-100" : "pointer-events-none opacity-0"}`}
		>
			<div className="admin-frame">
				<div className="effect-circle effect-circle--a" />
				<div className="effect-circle effect-circle--b" />

				<div className="admin-panel flex h-[46rem] w-[78rem] items-start justify-start">
					{/* Sidebar */}
					<div className="flex h-full w-[15rem] shrink-0 flex-col pb-4">
						<div className="mt-[1.31rem] mb-5 flex items-center gap-3 pl-4">
							<div className="relative grid size-[3.2rem] flex-shrink-0 place-items-center">
								<DiamondMark />
								<BrandIcon />
							</div>
							<div className="flex min-w-0 flex-col leading-none">
								<span className="font-bold text-[0.75rem] uppercase tracking-[0.18em] text-white">Painel</span>
								<span className="font-extrabold text-[1.125rem] uppercase tracking-[0.04em] text-[rgb(var(--primaryColor))]">Skins</span>
							</div>
						</div>

						<div className="mb-4 flex flex-col gap-[.44rem] px-4">
							<span className="mb-1 font-semibold text-white/30 text-xs uppercase tracking-wider">Principal</span>
							<NavItem active={!detail} icon={<UsersIcon />} text="Jogadores" onClick={backToList} />
						</div>

						<div className="flex flex-col gap-[.44rem] px-4">
							<span className="mb-1 font-semibold text-white/30 text-xs uppercase tracking-wider">Ações</span>
							<NavItem icon={<GiftIcon />} text="Dar a todos online" onClick={() => openCatalogue("all")} />
							<NavItem
								icon={<StackIcon />}
								text="Dar todas as skins"
								onClick={() => {
									setGiveAllId(detail ? String(detail.id) : "");
									setGiveAllOpen(true);
								}}
							/>
						</div>

						<div className="mt-auto px-4 pt-4">
							<button
								type="button"
								onClick={fetchHideFrame}
								className="flex h-[2.75rem] w-full items-center justify-center gap-2 rounded-md border border-white/10 font-semibold text-[0.8rem] text-white/70 transition-colors hover:bg-white/5 hover:text-white"
							>
								Fechar painel
							</button>
						</div>
					</div>

					<div className="h-full w-px bg-white/[.07]" />

					{/* Content */}
					<div className="flex h-full min-w-0 flex-1 flex-col">
						<h1 className="mt-[1.31rem] mb-1 ml-[1.56rem] font-bold text-white text-xl">Jogadores</h1>

						<div className="scrollbar-custom min-h-0 flex-1 overflow-y-auto px-[1.56rem] pt-3 pb-6">
							{!detail ? (
								<ListView
									query={query}
									setQuery={setQuery}
									players={players}
									selectedId={selectedId}
									onSelect={loadDetail}
								/>
							) : (
								<DetailView
									detail={detail}
									loading={loadingDetail}
									busy={busy}
									coinInput={coinInput}
									voucherInput={voucherInput}
									setCoinInput={setCoinInput}
									setVoucherInput={setVoucherInput}
									onBack={backToList}
									onCurrency={currencyAction}
									onRemoveSkin={removeSkin}
									onGiveSkin={() => openCatalogue("player")}
									onWipe={() => setConfirmWipe(true)}
								/>
							)}
						</div>
					</div>
				</div>

				{toast && (
					<div className="absolute bottom-[1.4rem] left-1/2 z-[60] -translate-x-1/2">
						<div className="btn-accent rounded-md px-[1.1rem] py-[0.6rem] text-[0.82rem]">{toast}</div>
					</div>
				)}
			</div>

			{/* Catalogue modal */}
			<Modal open={catalogueOpen} onClose={() => setCatalogueOpen(false)} className="max-w-[48rem]">
				<div className="flex w-full flex-col p-6">
					<div className="mb-5 flex items-center gap-3">
						<span className="admin-modal-icon"><GiftIcon /></span>
						<h2 className="font-bold text-lg text-white">
							{catalogueMode === "player" ? "Enviar skin ao jogador" : "Dar skin a todos online"}
						</h2>
					</div>

					<div className="relative mb-4">
						<input
							value={catalogueQuery}
							onChange={(e) => setCatalogueQuery(e.target.value)}
							placeholder="Buscar skin..."
							className={`${INPUT_CLS} pl-10`}
						/>
						<span className="absolute left-3 top-1/2 -translate-y-1/2 text-white/35"><SearchIcon /></span>
					</div>

					<div className="scrollbar-custom grid h-[20rem] auto-rows-min content-start grid-cols-5 gap-[10px] overflow-y-auto pr-1">
						{flatCatalogue.map((skin) => {
							const active = catalogueSkin?.model_name === skin.model_name;
							const rgb = rarityRgb(skin.rarity);
							return (
								<button
									key={skin.model_name}
									type="button"
									onClick={() => setCatalogueSkin(skin)}
									className="flex flex-col items-center gap-[6px] rounded-md p-[8px] transition-colors"
									style={{
										border: active ? "1px solid rgb(var(--primaryColor))" : `1px solid rgba(${rgb},0.22)`,
										background: active ? "rgba(var(--primaryColor),0.12)" : CARD_BG,
									}}
								>
									<img
										src={skin.image || skinFallbackImage}
										alt={skin.name}
										className="h-[54px] w-full object-contain"
										onError={(e) => { (e.target as HTMLImageElement).src = skinFallbackImage; }}
									/>
									<span className="w-full truncate text-center font-semibold text-[11px] text-white">{skin.name}</span>
									<span className="text-[10px] text-white/40">{formatNumber(skin.price)}</span>
								</button>
							);
						})}
					</div>

					<div className="mt-5 flex items-center gap-3">
						<input
							type="number"
							min={1}
							value={catalogueAmount}
							onChange={(e) => setCatalogueAmount(e.target.value)}
							className="h-12 w-[7rem] rounded-md border border-white/10 bg-white/5 px-4 text-sm text-white outline-none focus:border-[rgb(var(--primaryColor))]"
						/>
						<button type="button" onClick={() => setCatalogueOpen(false)} className="btn-cancel h-12 flex-1 rounded-md text-sm">CANCELAR</button>
						<button type="button" disabled={!catalogueSkin || busy} onClick={confirmCatalogue} className="btn-accent h-12 flex-1 rounded-md text-sm">
							{catalogueMode === "player" ? "ENVIAR" : "ENVIAR A TODOS"}
						</button>
					</div>
				</div>
			</Modal>

			{/* Confirm wipe */}
			<Modal open={confirmWipe && !!detail} onClose={() => setConfirmWipe(false)}>
				<div className="flex w-full flex-col p-6">
					<div className="mb-5 flex items-center gap-3">
						<span className="admin-modal-icon"><TrashIcon /></span>
						<h2 className="font-bold text-lg text-white">Zerar skins</h2>
					</div>
					<p className="mb-8 text-sm text-white/55">
						Remover <b className="text-white">todas</b> as skins de{" "}
						<b className="text-white">{detail?.name}</b> (#{detail?.id})? Esta ação não pode ser desfeita.
					</p>
					<div className="flex items-center gap-3">
						<button type="button" onClick={() => setConfirmWipe(false)} className="btn-cancel h-12 flex-1 rounded-md text-sm">CANCELAR</button>
						<button type="button" disabled={busy} onClick={wipeSkins} className="btn-danger h-12 flex-1 rounded-md text-sm">ZERAR</button>
					</div>
				</div>
			</Modal>

			{/* Dar todas as skins a um ID */}
			<Modal open={giveAllOpen} onClose={() => setGiveAllOpen(false)}>
				<div className="flex w-full flex-col p-6">
					<div className="mb-5 flex items-center gap-3">
						<span className="admin-modal-icon"><StackIcon /></span>
						<h2 className="font-bold text-lg text-white">Dar todas as skins</h2>
					</div>
					<label className="mb-2 block font-medium text-sm text-white/60">ID do jogador (passaporte)</label>
					<input
						type="number"
						min={1}
						value={giveAllId}
						onChange={(e) => setGiveAllId(e.target.value)}
						placeholder="EX: 4964"
						className={`${INPUT_CLS} mb-8`}
					/>
					<div className="flex items-center gap-3">
						<button type="button" onClick={() => setGiveAllOpen(false)} className="btn-cancel h-12 flex-1 rounded-md text-sm">CANCELAR</button>
						<button type="button" disabled={busy || !giveAllId} onClick={giveAllSkins} className="btn-accent h-12 flex-1 rounded-md text-sm">ENTREGAR TUDO</button>
					</div>
				</div>
			</Modal>
		</div>
	);
}

// ── List view ──────────────────────────────────────────────────────────────────

function ListView({
	query,
	setQuery,
	players,
	selectedId,
	onSelect,
}: {
	query: string;
	setQuery: (v: string) => void;
	players: PlayerRow[];
	selectedId: number | null;
	onSelect: (id: number) => void;
}) {
	return (
		<div className="flex flex-col gap-4">
			<div className="relative">
				<input
					type="text"
					placeholder="Buscar por nome ou passaporte..."
					value={query}
					onChange={(e) => setQuery(e.target.value)}
					className="h-[3.125rem] w-full rounded-md border border-white/[.03] px-4 pl-10 text-base text-white/85 outline-none placeholder:text-white/50"
					style={{ background: CARD_BG }}
				/>
				<span className="absolute left-3 top-1/2 -translate-y-1/2 text-white/35"><SearchIcon /></span>
			</div>

			<div className="flex flex-col gap-[.5rem]">
				{players.length === 0 && (
					<div className="mt-6 text-center text-[0.9rem] text-white/40">Nenhum jogador encontrado.</div>
				)}
				{players.map((player) => {
					const active = player.id === selectedId;
					return (
						<div
							key={player.id}
							className="flex items-center gap-3 rounded-md border px-4 py-3 transition-colors"
							style={{
								background: CARD_BG,
								borderColor: active ? "rgba(var(--primaryColor),0.4)" : "rgba(255,255,255,0.03)",
							}}
						>
							<Avatar url={player.avatar} />
							<div className="flex min-w-0 flex-1 flex-col">
								<span className="truncate font-semibold text-[0.95rem] text-white">{player.name}</span>
								<span className="font-medium text-[0.8rem] text-white/45">#{player.id}</span>
							</div>
							<StatusBadge online={player.online} />
							<button
								type="button"
								onClick={() => onSelect(player.id)}
								className="btn-accent h-[2.25rem] rounded-md px-4 text-[0.78rem]"
							>
								GERENCIAR
							</button>
						</div>
					);
				})}
			</div>
		</div>
	);
}

// ── Detail view ──────────────────────────────────────────────────────────────────

function DetailView({
	detail,
	loading,
	busy,
	coinInput,
	voucherInput,
	setCoinInput,
	setVoucherInput,
	onBack,
	onCurrency,
	onRemoveSkin,
	onGiveSkin,
	onWipe,
}: {
	detail: PlayerDetail;
	loading: boolean;
	busy: boolean;
	coinInput: string;
	voucherInput: string;
	setCoinInput: (v: string) => void;
	setVoucherInput: (v: string) => void;
	onBack: () => void;
	onCurrency: (c: "coins" | "vouchers", op: "give" | "remove" | "set") => void;
	onRemoveSkin: (s: AdminSkin) => void;
	onGiveSkin: () => void;
	onWipe: () => void;
}) {
	return (
		<div className="flex flex-col gap-4">
			<button
				type="button"
				onClick={onBack}
				className="flex h-[3.125rem] w-full items-center gap-2 rounded-md border border-white/[.03] px-4 text-base text-white/85 transition-all hover:bg-white/[.05]"
				style={{ background: CARD_BG }}
			>
				<ArrowLeftIcon /> Voltar para busca
			</button>

			{/* Info card */}
			<Card title="Informações do Jogador">
				<div className="flex items-center gap-4 p-5">
					<Avatar url={detail.avatar} big />
					<div className="flex flex-1 flex-col gap-[3px]">
						<span className="font-bold text-lg text-white">{detail.name}</span>
						<div className="flex items-center gap-2">
							<span className="font-medium text-[0.85rem] text-white/45">#{detail.id}</span>
							<StatusBadge online={detail.online} />
						</div>
					</div>
					<button type="button" onClick={onWipe} className="btn-danger h-[2.4rem] rounded-md px-4 text-[0.78rem]">ZERAR SKINS</button>
				</div>
				<div className="grid grid-cols-4 gap-3 px-5 pb-5">
					<Stat label="Skins" value={`${detail.stats.skinsDistinct}`} sub={`${detail.stats.skinsTotal} no total`} />
					<Stat label="Caixas abertas" value={formatNumber(detail.stats.boxesOpened)} />
					<Stat label="Valor coleção" value={formatNumber(detail.stats.collectionValue)} />
					<Stat label="Vouchers" value={formatNumber(detail.vouchers)} />
				</div>
			</Card>

			{/* Currency card */}
			<Card title="Moedas">
				<div className="flex flex-col gap-3 p-5">
					{detail.useFrameworkCoins ? (
						<div className="rounded-md border border-white/[.06] p-3 text-[0.8rem] text-white/45" style={{ background: CARD_BG }}>
							SkinsCoins gerenciados pelo framework (Gemstone) — use os comandos do framework.
						</div>
					) : (
						<CurrencyRow label="SkinsCoins" balance={detail.skinsCoins} value={coinInput} onChange={setCoinInput} disabled={busy} onOp={(op) => onCurrency("coins", op)} />
					)}
					<CurrencyRow label="Vouchers" balance={detail.vouchers} value={voucherInput} onChange={setVoucherInput} disabled={busy} onOp={(op) => onCurrency("vouchers", op)} />
				</div>
			</Card>

			{/* Skins card */}
			<Card
				title={`Skins do jogador (${detail.skins.length})`}
				action={
					<button type="button" onClick={onGiveSkin} className="btn-accent h-[1.95rem] rounded px-3 text-[0.72rem]">+ ENVIAR SKIN</button>
				}
			>
				<div className="p-5">
					{loading ? (
						<div className="py-6 text-center text-[0.9rem] text-white/40">Carregando...</div>
					) : detail.skins.length === 0 ? (
						<div className="py-6 text-center text-[0.9rem] text-white/40">Este jogador não possui skins.</div>
					) : (
						<div className="grid grid-cols-5 gap-3">
							{detail.skins.map((skin) => (
								<SkinCard key={skin.model_name} skin={skin} disabled={busy} onRemove={() => onRemoveSkin(skin)} />
							))}
						</div>
					)}
				</div>
			</Card>
		</div>
	);
}

// ── Sub-components ───────────────────────────────────────────────────────────────

function Card({ title, action, children }: { title: string; action?: ReactNode; children: ReactNode }) {
	return (
		<div className="overflow-hidden rounded-md border border-white/[.03]" style={{ background: CARD_BG }}>
			<div className="flex h-[2.6875rem] items-center justify-between bg-white/[.02] px-[.94rem] font-medium text-[0.9375rem] text-white/55">
				<span>{title}</span>
				{action}
			</div>
			{children}
		</div>
	);
}

function Stat({ label, value, sub }: { label: string; value: string; sub?: string }) {
	return (
		<div className="flex flex-col gap-[2px] rounded-md border border-white/[.03] p-3" style={{ background: CARD_BG }}>
			<span className="font-bold text-lg text-white">{value}</span>
			<span className="font-medium text-[0.72rem] text-white/45">{label}</span>
			{sub && <span className="text-[0.62rem] text-white/30">{sub}</span>}
		</div>
	);
}

function CurrencyRow({
	label,
	balance,
	value,
	onChange,
	onOp,
	disabled,
}: {
	label: string;
	balance: number;
	value: string;
	onChange: (v: string) => void;
	onOp: (op: "give" | "remove" | "set") => void;
	disabled: boolean;
}) {
	return (
		<div className="flex items-center gap-3 rounded-md border border-white/[.05] p-3" style={{ background: CARD_BG }}>
			<div className="flex w-[10rem] flex-col">
				<span className="font-semibold text-[0.9rem] text-white">{label}</span>
				<span className="font-medium text-[0.8rem] text-white/45">{formatNumber(balance)}</span>
			</div>
			<input
				type="number"
				min={0}
				value={value}
				onChange={(e) => onChange(e.target.value)}
				placeholder="0"
				className="h-11 flex-1 rounded-md border border-white/10 bg-white/5 px-3 text-sm text-white outline-none placeholder:text-white/40 focus:border-[rgb(var(--primaryColor))]"
			/>
			<button type="button" disabled={disabled} onClick={() => onOp("give")} className="btn-accent h-11 rounded-md px-4 text-[0.78rem]">DAR</button>
			<button type="button" disabled={disabled} onClick={() => onOp("remove")} className="h-11 rounded-md border border-white/10 bg-white/[.04] px-4 font-semibold text-[0.78rem] text-white/80 transition-colors hover:bg-white/[.08] disabled:opacity-40">TIRAR</button>
			<button type="button" disabled={disabled} onClick={() => onOp("set")} className="h-11 rounded-md border border-white/10 bg-white/[.04] px-4 font-semibold text-[0.78rem] text-white/80 transition-colors hover:bg-white/[.08] disabled:opacity-40">DEFINIR</button>
		</div>
	);
}

function SkinCard({ skin, onRemove, disabled }: { skin: AdminSkin; onRemove: () => void; disabled: boolean }) {
	const rgb = rarityRgb(skin.rarity);
	return (
		<div className="relative flex flex-col items-center gap-[6px] overflow-hidden rounded-md border p-[8px]" style={{ borderColor: `rgba(${rgb},0.22)`, background: CARD_BG }}>
			<div className="absolute left-0 top-0 h-[2px] w-full" style={{ background: `rgb(${rgb})` }} />
			{skin.equipped && (
				<span className="absolute right-[6px] top-[8px] rounded px-[6px] py-[1px] font-bold text-[9px] text-white" style={{ background: `rgb(${rgb})` }}>EQUIP</span>
			)}
			{skin.quantity > 1 && (
				<span className="absolute left-[6px] top-[8px] rounded bg-black/60 px-[6px] py-[1px] font-bold text-[9px] text-white/80">x{skin.quantity}</span>
			)}
			<img
				src={skin.image || skinFallbackImage}
				alt={skin.name}
				className="h-[58px] w-full object-contain"
				onError={(e) => { (e.target as HTMLImageElement).src = skinFallbackImage; }}
			/>
			<span className="w-full truncate text-center font-semibold text-[11px] text-white">{skin.name}</span>
			<button
				type="button"
				disabled={disabled}
				onClick={onRemove}
				className="h-7 w-full rounded border border-white/[.05] bg-white/[.01] font-bold text-[10px] text-white/40 transition-all hover:bg-red-500/80 hover:text-white disabled:opacity-40"
			>
				REMOVER
			</button>
		</div>
	);
}

function Modal({ open, onClose, children, className }: { open: boolean; onClose: () => void; children: ReactNode; className?: string }) {
	if (!open) return null;
	return (
		<div data-modal-open className="fixed inset-0 z-[70] flex items-center justify-center bg-black/60" onClick={onClose}>
			<div className={`admin-frame w-full ${className ?? "max-w-[32rem]"}`} onClick={(e) => e.stopPropagation()}>
				<div className="effect-circle effect-circle--a" />
				<div className="effect-circle effect-circle--b" />
				<div
					className="relative z-[1] w-full overflow-hidden rounded-[11px] border-[0.6px] border-[rgba(255,255,255,0.3)]"
					style={{ background: "linear-gradient(164.65deg, rgba(10,10,10,0.99) 47.85%, rgba(11,11,11,0.792) 99.58%)" }}
				>
					{children}
				</div>
			</div>
		</div>
	);
}

function Avatar({ url, big }: { url: string | null; big?: boolean }) {
	const size = big ? "size-[3rem]" : "size-[2.4rem]";
	return (
		<div className={`${size} shrink-0 overflow-hidden rounded-full border border-white/15`} style={{ background: "rgba(255,255,255,0.05)" }}>
			{url ? (
				<img src={url} alt="" className="h-full w-full object-cover" onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
			) : null}
		</div>
	);
}

function StatusBadge({ online }: { online: boolean }) {
	return (
		<span
			className="rounded px-[8px] py-[2px] font-semibold text-[10px]"
			style={{
				color: online ? "#9CF35B" : "#FF4B4B",
				background: online ? "#9CF35B0D" : "#FF4B4B0D",
			}}
		>
			{online ? "ONLINE" : "OFFLINE"}
		</span>
	);
}

function NavItem({ icon, text, active, onClick }: { icon: ReactNode; text: string; active?: boolean; onClick: () => void }) {
	return (
		<button
			type="button"
			onClick={onClick}
			className="flex h-[2.6rem] items-center gap-3 rounded-md px-3 font-medium text-[0.85rem] transition-colors"
			style={{
				background: active ? "rgba(var(--primaryColor),0.12)" : "transparent",
				border: active ? "1px solid rgba(var(--primaryColor),0.4)" : "1px solid transparent",
				color: active ? "#fff" : "rgba(255,255,255,0.5)",
			}}
		>
			<span className={active ? "text-[rgb(var(--primaryColor))]" : "text-white/40"}>{icon}</span>
			{text}
		</button>
	);
}

// ── Icons ────────────────────────────────────────────────────────────────────────

function BrandIcon() {
	return (
		<svg className="relative z-[1] text-white" width="15" height="15" viewBox="0 0 512 512" fill="none">
			<path fill="currentColor" d="m267.788 262.954l-42.198 42.199a237.1 237.1 0 0 0 180.038 36.641l-11.394-57.128a178.75 178.75 0 0 1-126.446-21.712m-115.621 212.76l6.012-1.251a21.794 21.794 0 0 0 16.88-25.808l-9.564-45.742a14.53 14.53 0 0 1 3.947-13.241l38.505-38.505a17.525 17.525 0 0 0 0-24.784l-15.752-15.752l71.944-71.944l-45.76-45.76l-32.275 32.274a10.223 10.223 0 0 0-14.457 14.457l5.61 5.61L77.15 345.373l.01 26.088l30.672 29.938c15.682-5.829 15.516 2.581 19.305 20.687l9.023 43.135a13.54 13.54 0 0 0 16.023 10.493zm-2.853-106.467a10.186 10.186 0 0 1 0-14.405l20.198-20.198a10.186 10.186 0 0 1 14.404 0l7.246 7.246a10.186 10.186 0 0 1 0 14.405l-20.224 20.224a10.186 10.186 0 0 1-14.404 0l-7.238-7.237zm96.342-176.696a10.6 10.6 0 0 1-1.12-1.348a12.03 12.03 0 0 1 1.776-15.393l82.656-82.656c4.804-4.804 12.295-5.102 16.74-.656l24.74 24.74c4.236 4.235 4.192 11.297-.096 16.146l-77.57 87.704c-4.28 4.84-11.228 5.732-15.945 2.363a10.6 10.6 0 0 1-1.348-1.12l-29.798-29.798zM419.096 36l15.753 15.752l-16.794 11.088l-37.053 37.053l-10.055-10.055l37.062-37.062zm-63 24.267a5.41 5.41 0 0 1 0-7.648l3.431-3.43a5.41 5.41 0 0 1 7.649 0l12.251 12.25l-11.079 11.08z" />
		</svg>
	);
}

function DiamondMark() {
	return (
		<svg className="pointer-events-none absolute inset-0 h-full w-full" viewBox="0 0 36 36" fill="none">
			<rect x="18" y="2" width="22.63" height="22.63" rx="4" transform="rotate(45 18 2)" fill="rgb(var(--primaryColor))" fillOpacity="0.2" stroke="rgb(var(--primaryColor))" strokeWidth="1.2" />
			<rect x="18" y="6" width="16.97" height="16.97" rx="3" transform="rotate(45 18 6)" fill="rgb(var(--primaryColor))" fillOpacity="0.5" />
		</svg>
	);
}

function SearchIcon() {
	return (
		<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
			<circle cx="11" cy="11" r="7" />
			<path d="M21 21l-4.3-4.3" />
		</svg>
	);
}

function ArrowLeftIcon() {
	return (
		<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
			<path d="M19 12H5" /><path d="M12 19l-7-7 7-7" />
		</svg>
	);
}

function UsersIcon() {
	return (
		<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
			<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" /><circle cx="9" cy="7" r="4" /><path d="M22 21v-2a4 4 0 0 0-3-3.87" /><path d="M16 3.13a4 4 0 0 1 0 7.75" />
		</svg>
	);
}

function GiftIcon() {
	return (
		<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
			<rect x="3" y="8" width="18" height="4" rx="1" /><path d="M12 8v13" /><path d="M19 12v7a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2v-7" /><path d="M7.5 8a2.5 2.5 0 0 1 0-5C11 3 12 8 12 8s1-5 4.5-5a2.5 2.5 0 0 1 0 5" />
		</svg>
	);
}

function StackIcon() {
	return (
		<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
			<path d="M12 2 2 7l10 5 10-5-10-5Z" /><path d="m2 17 10 5 10-5" /><path d="m2 12 10 5 10-5" />
		</svg>
	);
}

function TrashIcon() {
	return (
		<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
			<path d="M3 6h18" /><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" /><path d="M6 6v14a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V6" /><path d="M10 11v6" /><path d="M14 11v6" />
		</svg>
	);
}
