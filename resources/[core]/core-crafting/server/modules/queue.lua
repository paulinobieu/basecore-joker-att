-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
-- Fila viva de cada jogador: [Passport] = { Entries = {}, Dirty = false }.
-- Enquanto o passaporte está aqui, nenhuma leitura toca o banco.
local QueueCache = {}

-- Passaportes com SELECT em voo e os que caíram durante essa espera.
local Loading = {}
local Dropped = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENSUREQUEUE
-- Ponto único de leitura: devolve o cache e só busca no banco na primeira vez.
-----------------------------------------------------------------------------------------------------------------------------------------
function EnsureQueue(Passport)
    if not DatabaseReady() then
        return false
    end

    if QueueCache[Passport] then
        return QueueCache[Passport]
    end

    -- Outra chamada já está buscando a mesma fila: espera a resposta dela.
    if Loading[Passport] then
        while Loading[Passport] do
            Wait(25)
        end

        return QueueCache[Passport] or false
    end

    Loading[Passport] = true

    local Entries = FindQueue(Passport)

    Loading[Passport] = nil

    -- Jogador saiu enquanto o banco respondia: nada entra em cache.
    if Dropped[Passport] then
        Dropped[Passport] = nil
        return false
    end

    QueueCache[Passport] = { Entries = Entries, Dirty = false }

    return QueueCache[Passport]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- QUEUEENTRIES
-----------------------------------------------------------------------------------------------------------------------------------------
function QueueEntries(Passport)
    local Cached = EnsureQueue(Passport)

    return Cached and Cached.Entries or {}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINDENTRY
-----------------------------------------------------------------------------------------------------------------------------------------
function FindEntry(Passport, EntryId)
    for _, Entry in ipairs(QueueEntries(Passport)) do
        if Entry.Id == EntryId then
            return Entry
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PUSHENTRY
-- A produção nova entra depois da última: o tempo de espera é acumulado.
-----------------------------------------------------------------------------------------------------------------------------------------
function PushEntry(Passport, Recipe, Times, Amount, Duration)
    local Cached = EnsureQueue(Passport)
    if not Cached then
        return false
    end

    local Now      = os.time()
    local Sequence = 0
    local LastEnd  = Now

    for _, Entry in ipairs(Cached.Entries) do
        if Entry.Id > Sequence then
            Sequence = Entry.Id
        end

        if Entry.EndsAt > LastEnd then
            LastEnd = Entry.EndsAt
        end
    end

    local Entry = {
        Id       = Sequence + 1,
        Recipe   = Recipe,
        Times    = Times,
        Amount   = Amount,
        Duration = Duration,
        EndsAt   = LastEnd + Duration,
    }

    Cached.Entries[#Cached.Entries + 1] = Entry
    Cached.Dirty = true

    return Entry
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEENTRY
-----------------------------------------------------------------------------------------------------------------------------------------
function RemoveEntry(Passport, EntryId)
    local Cached = QueueCache[Passport]
    if not Cached then
        return
    end

    for Index, Entry in ipairs(Cached.Entries) do
        if Entry.Id == EntryId then
            table.remove(Cached.Entries, Index)
            Cached.Dirty = true

            return
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FLUSHQUEUES
-- Grava só o que mudou. A lista de pendentes é montada antes da escrita porque
-- o cache pode ser alterado durante a gravação.
-----------------------------------------------------------------------------------------------------------------------------------------
local function FlushQueues()
    local Pending = {}

    for Passport, Cached in pairs(QueueCache) do
        if Cached.Dirty then
            Pending[#Pending + 1] = Passport
        end
    end

    for _, Passport in ipairs(Pending) do
        local Cached = QueueCache[Passport]

        if Cached and Cached.Dirty then
            -- Zerado antes da escrita: mutação concorrente marca de novo.
            Cached.Dirty = false
            SaveQueue(Passport, Cached.Entries)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LIFECYCLE
-- A fila entra em memória no login, é gravada e liberada no logout, e tudo que
-- estiver sujo vai para o banco quando o resource para.
-----------------------------------------------------------------------------------------------------------------------------------------
Framework.OnPlayerLoaded(function(Passport)
    if not Passport then
        return
    end

    EnsureQueue(Passport)
end)

Framework.OnPlayerDropped(function(Passport)
    if not Passport then
        return
    end

    if Loading[Passport] then
        Dropped[Passport] = true
    end

    local Cached = QueueCache[Passport]
    if not Cached then
        return
    end

    if Cached.Dirty then
        Cached.Dirty = false
        SaveQueue(Passport, Cached.Entries)
    end

    QueueCache[Passport] = nil
end)

Framework.OnResourceStop(function()
    FlushQueues()
end)

CreateThread(function()
    local Interval = math.max(1, parseInt(Crafting.Cache.SaveInterval)) * 1000

    while true do
        Wait(Interval)

        FlushQueues()
    end
end)
