-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-BANK · CRIPTOMOEDAS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Allowlist das moedas negociáveis e ajustes do provedor de cotação.
--
-- A cotação é buscada só pelo servidor, em um pedido único para todas as
-- moedas, e fica em cache. A interface recebe o snapshot pronto e nunca
-- decide preço.
--
-- Campos de cada moeda:
--   Asset    → chave interna, imutável. É o que fica gravado na carteira.
--   Provider → id da moeda na CoinGecko. Conferir manualmente antes de add.
--   Symbol   → sigla exibida.
--   Name     → nome exibido.
--   Decimals → casas decimais da carteira. O saldo em R$ é sempre inteiro.
--
-- Símbolo não é identificador: moedas diferentes repetem sigla. Sempre
-- confirme o id na CoinGecko antes de habilitar um ativo novo.
-----------------------------------------------------------------------------------------------------------------------------------------

Bank.Crypto = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- PROVEDOR
    -------------------------------------------------------------------------------------------------------------------------------------
    Provider = {
        --- Endpoint público, sem chave. O de mercado devolve preço e as três
        --- variações (1h, 24h e 7d) das moedas da allowlist em um pedido só.
        Endpoint = "https://api.coingecko.com/api/v3/coins/markets",

        --- Moeda da cotação, no código que a CoinGecko usa (brl, usd, eur...).
        --- Trocar aqui muda o preço que o banco pede. O símbolo mostrado na
        --- interface é o Bank.Symbol, em config/config.lua.
        Currency = "brl",

        --- Intervalo entre atualizações, em minutos. O plano gratuito atualiza
        --- a cada poucos minutos: puxar mais rápido só gasta franquia.
        Interval = 5,

        --- Tempo, em minutos, que a cotação continua válida para negociar.
        --- Passou disso, a interface mostra o preço mas trava a negociação.
        Freshness = 8,

        --- Tempo limite de cada pedido, em segundos.
        Timeout = 5,

        --- Variação máxima aceita entre duas atualizações, em fração. Acima
        --- disso o snapshot é considerado suspeito e a negociação trava.
        MaxDeviation = 0.5,
    },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- TAXA DA CORRETORA
    -------------------------------------------------------------------------------------------------------------------------------------
    --- Fração cobrada em cima de cada negociação, para os dois lados.
    Fee = 0.02,

    --- Compra e venda mínimas, em R$.
    Minimum = 100,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- MOEDAS NEGOCIÁVEIS
    -------------------------------------------------------------------------------------------------------------------------------------
    Assets = {
        { Asset = "btc",  Provider = "bitcoin",          Symbol = "BTC",  Name = "Bitcoin",          Decimals = 8 },
        { Asset = "eth",  Provider = "ethereum",         Symbol = "ETH",  Name = "Ethereum",         Decimals = 8 },
        { Asset = "usdt", Provider = "tether",           Symbol = "USDT", Name = "Tether",           Decimals = 4 },
        { Asset = "bnb",  Provider = "binancecoin",      Symbol = "BNB",  Name = "BNB",              Decimals = 6 },
        { Asset = "usdc", Provider = "usd-coin",         Symbol = "USDC", Name = "USDC",             Decimals = 4 },
        { Asset = "xrp",  Provider = "ripple",           Symbol = "XRP",  Name = "XRP",              Decimals = 4 },
        { Asset = "sol",  Provider = "solana",           Symbol = "SOL",  Name = "Solana",           Decimals = 6 },
        { Asset = "trx",  Provider = "tron",             Symbol = "TRX",  Name = "TRON",             Decimals = 4 },
        { Asset = "doge", Provider = "dogecoin",         Symbol = "DOGE", Name = "Dogecoin",         Decimals = 4 },
        { Asset = "ada",  Provider = "cardano",          Symbol = "ADA",  Name = "Cardano",          Decimals = 4 },
        { Asset = "link", Provider = "chainlink",        Symbol = "LINK", Name = "Chainlink",        Decimals = 6 },
        { Asset = "avax", Provider = "avalanche-2",      Symbol = "AVAX", Name = "Avalanche",        Decimals = 6 },
        { Asset = "dot",  Provider = "polkadot",         Symbol = "DOT",  Name = "Polkadot",         Decimals = 6 },
        { Asset = "ltc",  Provider = "litecoin",         Symbol = "LTC",  Name = "Litecoin",         Decimals = 8 },
        { Asset = "bch",  Provider = "bitcoin-cash",     Symbol = "BCH",  Name = "Bitcoin Cash",     Decimals = 8 },
        { Asset = "xlm",  Provider = "stellar",          Symbol = "XLM",  Name = "Stellar",          Decimals = 4 },
        { Asset = "hbar", Provider = "hedera-hashgraph", Symbol = "HBAR", Name = "Hedera",           Decimals = 4 },
        { Asset = "uni",  Provider = "uniswap",          Symbol = "UNI",  Name = "Uniswap",          Decimals = 6 },
        { Asset = "atom", Provider = "cosmos",           Symbol = "ATOM", Name = "Cosmos",           Decimals = 6 },
        { Asset = "etc",  Provider = "ethereum-classic", Symbol = "ETC",  Name = "Ethereum Classic", Decimals = 6 },
        { Asset = "apt",  Provider = "aptos",            Symbol = "APT",  Name = "Aptos",            Decimals = 6 },
        { Asset = "shib", Provider = "shiba-inu",        Symbol = "SHIB", Name = "Shiba Inu",        Decimals = 2 },
        { Asset = "xmr",  Provider = "monero",           Symbol = "XMR",  Name = "Monero",           Decimals = 6 },
    },
}
