/**
 * Logos oficiais, baixados da CoinGecko e versionados junto do resource: a
 * interface nunca busca imagem na internet ao abrir o banco.
 *
 * Para habilitar uma moeda nova em config/cryptos.lua, salve a imagem dela
 * aqui com o mesmo nome do campo Asset e acrescente as duas linhas.
 */
import btc from "./btc.png";
import eth from "./eth.png";
import usdt from "./usdt.png";
import bnb from "./bnb.png";
import usdc from "./usdc.png";
import xrp from "./xrp.png";
import sol from "./sol.png";
import trx from "./trx.png";
import doge from "./doge.png";
import xmr from "./xmr.png";
import ada from "./ada.png";
import link from "./link.png";
import xlm from "./xlm.jpg";
import bch from "./bch.png";
import ltc from "./ltc.png";
import hbar from "./hbar.png";
import avax from "./avax.png";
import shib from "./shib.png";
import uni from "./uni.png";
import dot from "./dot.jpg";
import etc from "./etc.png";
import atom from "./atom.png";
import apt from "./apt.png";

export const CRYPTO_ICONS: Record<string, string> = {
	btc,
	eth,
	usdt,
	bnb,
	usdc,
	xrp,
	sol,
	trx,
	doge,
	xmr,
	ada,
	link,
	xlm,
	bch,
	ltc,
	hbar,
	avax,
	shib,
	uni,
	dot,
	etc,
	atom,
	apt,
};
