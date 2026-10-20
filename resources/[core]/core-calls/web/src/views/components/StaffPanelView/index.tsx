import { useCallsStore } from "@app/stores/Calls";
import { useVisibilityStore } from "@app/stores/Visibility";
import type { PanelInitial, StaffRanking, Ticket } from "@app/types";
import { cn } from "@app/utils";
import { fetchNui } from "@app/utils/fetchNui";
import { Badge, GlyphHeadset } from "@views/components/Badge";
import { useState } from "react";
import { useShallow } from "zustand/shallow";

type Tab = "pending" | "profile" | "ranking";

export function StaffPanelView() {
	const { tickets, initial, closeSurface } = useCallsStore(
		useShallow((s) => ({
			tickets: s.tickets,
			initial: s.initial,
			closeSurface: s.closeSurface,
		})),
	);
	const fetchHideFrame = useVisibilityStore((s) => s.fetchHideFrame);

	const [tab, setTab] = useState<Tab>("pending");
	const [period, setPeriod] = useState<"allTime" | "monthly">("allTime");

	if (!initial) return null;

	const handleClose = () => {
		closeSurface();
		fetchHideFrame();
	};

	return (
		<div className="app-container size-panel">
			<header className="app-header">
				<div className="app-header-brand">
					<span className="app-header-badge">
						<Badge>
							<GlyphHeadset />
						</Badge>
					</span>
					<div className="app-header-info">
						<span className="app-header-title">Central de Chamados</span>
						<span className="app-header-subtitle">Gerenciar chamados</span>
					</div>
				</div>
				<button
					type="button"
					className="app-header-close"
					onClick={handleClose}
					aria-label="Fechar"
				>
					<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="14" height="14">
						<path d="M18 6L6 18M6 6L18 18" />
					</svg>
				</button>
			</header>

			<nav className="tab-bar">
				<TabBtn active={tab === "pending"} onClick={() => setTab("pending")} icon={<IconList />} label="Pendentes" />
				<TabBtn active={tab === "profile"} onClick={() => setTab("profile")} icon={<IconUser />} label="Perfil" />
				<TabBtn active={tab === "ranking"} onClick={() => setTab("ranking")} icon={<IconTrophy />} label="Ranking" />
			</nav>

			<div className="app-main">
				{tab === "pending" && <TicketList tickets={tickets} />}
				{tab === "profile" && <ProfileView profile={initial.profile} />}
				{tab === "ranking" && (
					<RankingView
						ranking={initial.ranking}
						period={period}
						setPeriod={setPeriod}
					/>
				)}
			</div>

			<footer className="app-footer">
				<span>{tickets.length} chamado(s) em aberto</span>
				<span>
					<kbd>ESC</kbd>fechar
				</span>
			</footer>
		</div>
	);
}

function TabBtn({
	active,
	onClick,
	icon,
	label,
}: {
	active: boolean;
	onClick: () => void;
	icon: React.ReactNode;
	label: string;
}) {
	return (
		<button
			type="button"
			className={cn("tab-btn", active && "active")}
			onClick={onClick}
		>
			{icon}
			<span>{label}</span>
		</button>
	);
}

function TicketList({ tickets }: { tickets: Ticket[] }) {
	if (tickets.length === 0) {
		return <div className="ticket-empty">Nenhum chamado pendente.</div>;
	}

	return (
		<div className="ticket-list">
			{tickets.map((ticket) => (
				<article key={ticket.id} className="ticket-card">
					<header className="ticket-head">
						<div className="ticket-head-main">
							<span className="ticket-name">{ticket.name || "—"}</span>
							<span className="ticket-id">#{ticket.id}</span>
						</div>
						<span className="ticket-hour">{ticket.hour || "—"}</span>
					</header>

					{ticket.text ? (
						<p className="ticket-body">{ticket.text}</p>
					) : null}

					<div className="ticket-foot">
						<button
							type="button"
							className="ticket-decline"
							onClick={() =>
								fetchNui({
									path: "declineTicket",
									payload: { id: ticket.id },
									mockData: { ok: true },
								})
							}
						>
							Recusar
						</button>
						<button
							type="button"
							className="ticket-accept"
							onClick={() =>
								fetchNui({
									path: "acceptTicket",
									payload: { id: ticket.id },
									mockData: { ok: true },
								})
							}
						>
							Aceitar
						</button>
					</div>
				</article>
			))}
		</div>
	);
}

function profileInitials(name: string): string {
	const parts = (name || "").trim().split(/\s+/).filter(Boolean);
	if (parts.length === 0) return "?";
	if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
	return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

function ProfileView({ profile }: { profile: PanelInitial["profile"] }) {
	const ratio =
		profile.total > 0
			? Math.round((profile.positives / profile.total) * 100)
			: 0;

	return (
		<div className="profile-wrap">
			<div className="profile-hero">
				<div className="profile-avatar">{profileInitials(profile.name)}</div>
				<div className="profile-hero-main">
					<div className="profile-hero-name">{profile.name}</div>
					<div className="profile-hero-role">{profile.role}</div>
				</div>
				<div className="profile-hero-id">#{profile.id}</div>
			</div>

			<div className="stat-grid">
				<StatCard label="Total atendimentos" value={profile.total} />
				<StatCard label="Atendimentos rapidos" value={profile.fast} />
				<StatCard label="Avaliacoes positivas" value={profile.positives} variant="success" />
				<StatCard label="Avaliacoes negativas" value={profile.negatives} variant="danger" />
			</div>

			<div className="profile-ratio">
				<div className="profile-ratio-head">
					<span className="profile-ratio-label">Aproveitamento</span>
					<span className="profile-ratio-value">{ratio}%</span>
				</div>
				<div className="profile-ratio-bar">
					<span style={{ width: `${ratio}%` }} />
				</div>
			</div>
		</div>
	);
}

function StatCard({
	label,
	value,
	variant = "default",
}: {
	label: string;
	value: number;
	variant?: "default" | "success" | "danger";
}) {
	return (
		<div className={cn("stat-card", variant !== "default" && variant)}>
			<span className="stat-card-label">{label}</span>
			<span className="stat-card-value">
				{value.toLocaleString("pt-BR")}
			</span>
		</div>
	);
}

function RankingView({
	ranking,
	period,
	setPeriod,
}: {
	ranking: PanelInitial["ranking"];
	period: "allTime" | "monthly";
	setPeriod: (p: "allTime" | "monthly") => void;
}) {
	const data: StaffRanking[] = ranking[period] || [];
	const max = Math.max(1, ...data.map((d) => d.total));

	return (
		<div>
			<div className="rank-period">
				<button
					type="button"
					className={cn("rank-period-btn", period === "allTime" && "active")}
					onClick={() => setPeriod("allTime")}
				>
					Sempre
				</button>
				<button
					type="button"
					className={cn("rank-period-btn", period === "monthly" && "active")}
					onClick={() => setPeriod("monthly")}
				>
					Mensal
				</button>
			</div>

			{data.length === 0 ? (
				<div className="ticket-empty">Sem dados nesse periodo.</div>
			) : (
				<ol className="rank-list">
					{data.map((row, idx) => (
						<li
							className={cn("rank-item", idx === 0 && "leader")}
							key={row.staff}
						>
							<div className="rank-item-pos">{idx + 1}</div>
							<div className="rank-item-main">
								<div className="rank-item-id">
									<span className="rank-item-name">{row.name}</span>
									<span className="rank-item-role">{row.role}</span>
								</div>
								<div className="rank-item-bar">
									<span style={{ width: `${(row.total / max) * 100}%` }} />
								</div>
							</div>
							<div className="rank-item-total">
								{row.total.toLocaleString("pt-BR")}
							</div>
						</li>
					))}
				</ol>
			)}
		</div>
	);
}

function IconList() {
	return (
		<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden>
			<path d="M4 6h16M4 12h16M4 18h12" strokeLinecap="round" />
		</svg>
	);
}

function IconUser() {
	return (
		<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden>
			<circle cx="12" cy="8" r="4" />
			<path d="M4 20c0-4 4-6 8-6s8 2 8 6" strokeLinecap="round" />
		</svg>
	);
}

function IconTrophy() {
	return (
		<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden>
			<path d="M8 4h8v4a4 4 0 11-8 0V4z" />
			<path d="M4 6h4v2a3 3 0 01-3 3H4V6zM20 6h-4v2a3 3 0 003 3h1V6z" />
			<path d="M9 14h6l-1 4h-4l-1-4zM8 20h8" strokeLinecap="round" />
		</svg>
	);
}
