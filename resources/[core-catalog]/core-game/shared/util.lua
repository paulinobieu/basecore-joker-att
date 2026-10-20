-- ══════════════════════════════════════════════
--              CORE NETWORK LTDA
-- ══════════════════════════════════════════════
-- Todos os direitos reservados © Core Network Ltda.
--
-- ATENÇÃO: arquivo de configuração aberto para adaptação. NÃO altere nada
-- aqui se você não tem conhecimento de programação — mudanças incorretas
-- podem quebrar o funcionamento do sistema.
-- ══════════════════════════════════════════════

util = {}

local defaultTag = "CORE"
local tagMaxLen  = 5

function util.sanitizeTag(value, maxLen)
    if type(value) ~= "string" then return defaultTag end

    local tag = value:upper():gsub("[^A-Z0-9]", ""):sub(1, maxLen or tagMaxLen)

    if tag == "" then return defaultTag end

    return tag
end

function util.filterMapsForMode(gameMode)
    local mapsData = globalConfig.mapsData
    local maps     = globalConfig.maps
    local result   = {}

    for i = 1, #maps do
        local name = maps[i]
        local data = mapsData[name]

        if data then
            local modes   = data.modes
            local allowed = not modes or #modes == 0

            if not allowed then
                for m = 1, #modes do
                    if modes[m] == gameMode then
                        allowed = true
                        break
                    end
                end
            end

            if allowed and gameMode == "plant_defuse" and not data.bombs then
                allowed = false
            end

            if allowed then
                result[#result + 1] = name
            end
        end
    end

    return result
end

local validImageExt = {
    [".png"] = true,
    [".gif"] = true,
}

-- Normaliza/valida URL de imagem (avatar de jogador/time). Retorna a URL
-- pronta pra salvar, ou false se inválida.
--
-- Além da extensão .png/.gif, trata links de PÁGINA do Giphy: URLs como
-- https://giphy.com/gifs/nome-abc123 ou https://giphy.com/media/<id>/giphy.gif
-- respondem com o site HTML do Giphy (não com o arquivo) — dentro do CEF isso
-- carrega a página inteira e a imagem nem aparece. Convertemos pro link
-- direto https://media.giphy.com/media/<id>/giphy.gif.
function util.sanitizeImageUrl(value, maxLength)
    if type(value) ~= "string" or value == "" or #value > (maxLength or 255) then
        return false
    end

    local host, path = value:match("^https?://([^/%s]+)(/[^%s]*)$")
    if not host then return false end

    host = host:lower()

    -- Caminho sem querystring/fragmento (pra avaliar rota e extensão).
    local cleanPath = path:match("^([^%?#]+)") or path

    if host == "giphy.com" or host == "www.giphy.com" then
        -- giphy.com/media/<id>/arquivo.gif -> media.giphy.com/media/<id>/giphy.gif
        local mediaId = cleanPath:match("^/media/([%w]+)/[^/]+%.[gG][iI][fF]$")
            or cleanPath:match("^/media/[^/]+/([%w]+)/[^/]+%.[gG][iI][fF]$")
        if mediaId then
            return ("https://media.giphy.com/media/%s/giphy.gif"):format(mediaId)
        end

        -- giphy.com/gifs/nome-do-gif-<id> -> media.giphy.com/media/<id>/giphy.gif
        local slug = cleanPath:match("^/gifs/([^/]+)/?$")
        if slug then
            local id = slug:match("([%w]+)$")
            if id then
                return ("https://media.giphy.com/media/%s/giphy.gif"):format(id)
            end
        end

        -- Qualquer outra rota do site do Giphy é página HTML.
        return false
    end

    -- Subdomínios do Giphy que não são CDN de mídia também são páginas.
    if host:match("%.giphy%.com$") and not host:match("^media%d*%.giphy%.com$") and host ~= "i.giphy.com" then
        return false
    end

    if validImageExt[cleanPath:sub(-4):lower()] ~= true then
        return false
    end

    return value
end

function util.isValidImageUrl(value, maxLength)
    return util.sanitizeImageUrl(value, maxLength) ~= false
end
