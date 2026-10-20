import {
	currencySymbol,
	formatCurrency,
	formatDateTime,
	parseAmount,
	sanitizeAmount,
} from "@app/utils/format";
import { useModalAction } from "@app/hooks/useModalAction";
import { type Asset, useBankStore } from "@app/stores/Bank";
import { cn } from "@app/utils";
import {
	IconCoinBitcoin,
	IconTrendingDown,
	IconTrendingUp,
	IconWallet,
} from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Card } from "@views/components/Card";
import { Empty } from "@views/components/Empty";
import { Field } from "@views/components/Field";
import { Modal } from "@views/components/Modal";
import { Segmented } from "@views/components/Segmented";
import { Select } from "@views/components/Select";
import { CRYPTO_ICONS } from "@views/assets/crypto";
import { Stat } from "@views/components/Stat";
import { useMemo, useState } from "react";
import { useShallow } from "zustand/shallow";

/** O preço da moeda pode ter centavos; o dinheiro do jogo nunca tem. */
function formatPrice(value: number) {
	return value.toLocaleString("pt-BR", {
		minimumFractionDigits: 2,
		maximumFractionDigits: 2,
	});
}

/**
 * Grade da tabela. Cabeçalho e linhas compartilham a definição, então as
 * colunas não têm como sair do lugar. As frações distribuem a sobra entre
 * nome, carteira e preço em vez de empilhar tudo à direita.
 */
const GRID =
	"grid grid-cols-[2rem_minmax(0,1.4fr)_minmax(0,1fr)_minmax(0,1.15fr)_minmax(0,.85fr)_minmax(0,.85fr)_minmax(0,.85fr)_6rem] items-center gap-[.875rem]";

/** Variação percentual com seta e cor, usada nas três colunas. */
function Change({ value }: { value: number }) {
	const up = value >= 0;

	return (
		<span
			className={cn(
				"flex items-center justify-end gap-[.1875rem] whitespace-nowrap font-black text-[.6875rem]",
				up ? "text-positive" : "text-negative",
			)}
		>
			{up ? (
				<IconTrendingUp stroke={3} className="size-[.75rem]" />
			) : (
				<IconTrendingDown stroke={3} className="size-[.75rem]" />
			)}
			{value.toFixed(2).replace(".", ",")}%
		</span>
	);
}

export function Cryptos() {
	const { account, market, busy } = useBankStore(
		useShallow((state) => ({
			account: state.account,
			market: state.market,
			busy: state.busy,
		})),
	);

	const { feedback, submit, clear } = useModalAction();

	const [trading, setTrading] = useState<Asset | null>(null);
	const [mode, setMode] = useState<"buy" | "sell">("buy");
	const [amount, setAmount] = useState("");

	const balance = account?.balance ?? 0;
	const wallet = account?.wallet ?? [];
	const walletValue = wallet.reduce(
		(total, holding) => total + holding.value,
		0,
	);

	const holdings = useMemo(
		() =>
			Object.fromEntries(
				wallet.map((holding) => [holding.asset, holding.amount]),
			),
		[wallet],
	);

	const held = trading ? (holdings[trading.asset] ?? 0) : 0;
	const typed =
		mode === "buy" ? parseAmount(amount) : Number.parseFloat(amount) || 0;

	// A prévia é só informativa: o servidor recalcula tudo na hora de fechar.
	const preview = useMemo(() => {
		if (!trading || trading.price <= 0 || typed <= 0) return 0;

		if (mode === "buy") {
			return (typed * (1 - market.fee)) / trading.price;
		}

		return Math.floor(typed * trading.price * (1 - market.fee));
	}, [trading, typed, mode, market.fee]);

	function openTrade(asset: Asset) {
		setTrading(asset);
		setMode("buy");
		setAmount("");
	}

	function closeTrade() {
		setTrading(null);
		clear();

		if (feedback?.kind === "success") setAmount("");
	}

	const blocked = !market.fresh;

	return (
		<div className="flex h-full w-full flex-col gap-[.875rem] p-[1.25rem]">
			<div className="flex h-[8.5rem] flex-shrink-0 gap-[.875rem]">
				<Stat
					accent
					className="flex-1"
					label="Carteira"
					value={walletValue}
					icon={IconCoinBitcoin}
					footnote={
						wallet.length > 0
							? `${wallet.length} ${wallet.length === 1 ? "moeda" : "moedas"} · valor de mercado`
							: "Você ainda não tem moedas"
					}
				/>

				<Stat
					className="flex-1"
					label="Saldo disponível"
					value={balance}
					icon={IconWallet}
					footnote={account?.name}
				/>

				<Stat
					className="flex-1"
					label="Taxa da corretora"
					value={Math.round(market.fee * 100)}
					symbol={false}
					suffix="%"
					icon={IconTrendingUp}
					footnote={
						market.updatedAt > 0
							? `Cotação de ${formatDateTime(market.updatedAt).time}${blocked ? " · desatualizada" : ""}`
							: "Cotação indisponível"
					}
				/>
			</div>

			<Card
				title="Mercado de criptomoedas"
				icon={IconCoinBitcoin}
				className="min-h-0 flex-1"
				action={
					<span
						className={cn(
							"flex h-[1.875rem] items-center rounded-[.25rem] px-[.625rem] font-black text-[.6875rem] uppercase",
							blocked
								? "bg-negative/15 text-negative"
								: "bg-positive/15 text-positive",
						)}
					>
						{blocked ? "Negociação suspensa" : "Ao vivo"}
					</span>
				}
			>
				{market.assets.length === 0 ? (
					<Empty
						icon={IconCoinBitcoin}
						label="Mercado indisponível"
						hint="A cotação volta assim que o banco conseguir consultar"
					/>
				) : (
					<>
						<div
							className={cn(
								GRID,
								"flex-shrink-0 px-[.75rem] pb-[.5rem] font-black text-[.625rem] text-ink-ghost uppercase tracking-wide",
							)}
						>
							<span />
							<span>Criptomoeda</span>
							<span className="text-right">Carteira</span>
							<span className="text-right">Preço</span>
							<span className="text-right">1h</span>
							<span className="text-right">24h</span>
							<span className="text-right">7d</span>
							<span className="text-right">Ações</span>
						</div>

						<div className="customScrollbar flex min-h-0 flex-1 flex-col gap-[.375rem] overflow-y-auto pr-[.25rem]">
							{market.assets.map((asset) => {
								const owned = holdings[asset.asset] ?? 0;

								return (
									<div
										key={asset.asset}
										className={cn(
											GRID,
											"row-surface flex-shrink-0 px-[.75rem] py-[.5rem]",
										)}
									>
										<img
											src={CRYPTO_ICONS[asset.asset]}
											alt={asset.name}
											className="size-[2rem] rounded-full"
										/>

										<div className="flex min-w-0 flex-col">
											<span className="truncate font-black text-[.8125rem] text-ink leading-tight">
												{asset.name}
											</span>
											<span className="font-semibold text-[.6875rem] text-ink-ghost leading-tight">
												{asset.symbol}
											</span>
										</div>

										<span className="truncate text-right font-bold text-[.75rem] text-ink-faint">
											{owned > 0 ? owned.toFixed(asset.decimals) : "—"}
										</span>

										<span className="truncate text-right font-black text-[.8125rem] text-ink">
											{currencySymbol()} {formatPrice(asset.price)}
										</span>

										<Change value={asset.hour} />
										<Change value={asset.day} />
										<Change value={asset.week} />

										<Button
											variant="accent"
											disabled={blocked || asset.price <= 0}
											onClick={() => openTrade(asset)}
										>
											Negociar
										</Button>
									</div>
								);
							})}
						</div>
					</>
				)}
			</Card>

			<Modal
				open={trading !== null}
				title="Converter moedas"
				subtitle={
					trading
						? `${trading.name} · ${currencySymbol()} ${formatPrice(trading.price)}`
						: ""
				}
				icon={IconCoinBitcoin}
				onClose={closeTrade}
				feedback={feedback}
				footer={
					<>
						<Button
							size="lg"
							className="flex-1"
							onClick={() => setTrading(null)}
						>
							Cancelar
						</Button>
						<Button
							size="lg"
							variant="accent"
							className="flex-1"
							disabled={busy || typed <= 0 || preview <= 0}
							onClick={() =>
								submit("post:trade", {
									asset: trading?.asset,
									mode,
									amount: mode === "buy" ? typed : amount,
								})
							}
						>
							Confirmar
						</Button>
					</>
				}
			>
				<Segmented
					stretch
					value={mode}
					onChange={(value) => {
						setMode(value);
						setAmount("");
					}}
					options={[
						{ value: "buy", label: "Comprar" },
						{ value: "sell", label: "Vender" },
					]}
				/>

				<Select
					label="De"
					value={mode === "buy" ? "brl" : (trading?.asset ?? "")}
					options={
						mode === "buy"
							? [
									{
										value: "brl",
										label: "Real",
										hint: `Saldo ${formatCurrency(balance)}`,
									},
								]
							: [
									{
										value: trading?.asset ?? "",
										label: trading?.name ?? "",
										hint: `Carteira ${held} ${trading?.symbol ?? ""}`,
									},
								]
					}
					onChange={() => undefined}
				/>

				<Field
					label={mode === "buy" ? "Quanto gastar" : "Quanto vender"}
					prefix={mode === "buy" ? "$" : undefined}
					placeholder="0"
					inputMode="decimal"
					value={amount}
					onChange={(event) =>
						setAmount(
							mode === "buy"
								? sanitizeAmount(event.target.value)
								: event.target.value.replace(/[^\d.]/g, ""),
						)
					}
					hint={
						mode === "buy"
							? `Mínimo de ${formatCurrency(market.minimum)} · disponível ${formatCurrency(balance)}`
							: `Você tem ${held} ${trading?.symbol ?? ""}`
					}
				/>

				<Select
					label="Para"
					value={mode === "buy" ? (trading?.asset ?? "") : "brl"}
					options={
						mode === "buy"
							? [
									{
										value: trading?.asset ?? "",
										label: trading?.name ?? "",
										hint: `Você recebe ${preview.toFixed(trading?.decimals ?? 8)} ${trading?.symbol ?? ""}`,
									},
								]
							: [
									{
										value: "brl",
										label: "Real",
										hint: `Você recebe ${formatCurrency(preview)}`,
									},
								]
					}
					onChange={() => undefined}
				/>

				<span className="font-semibold text-[.6875rem] text-white/25 leading-relaxed">
					A corretora cobra {Math.round(market.fee * 100)}% da operação. O valor
					final é calculado pelo banco no momento da confirmação.
				</span>
			</Modal>
		</div>
	);
}
