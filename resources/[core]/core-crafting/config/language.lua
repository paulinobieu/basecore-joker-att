-----------------------------------------------------------------------------------------------------------------------------------------
-- IDIOMA
-----------------------------------------------------------------------------------------------------------------------------------------
-- Todos os textos e notificações do resource. Traduza só os valores à direita.
-- %s / %d são substituídos em tempo de execução — mantenha-os na frase.
-----------------------------------------------------------------------------------------------------------------------------------------

Crafting.Language = {
    -- Identidade usada no título das notificações.
    Title = "Fabricação",

    -- Interação no mundo.
    InteractOpen = "Usar bancada",

    -- Acesso.
    NoPermission = "Você não tem acesso a esta bancada!",
    TooFar       = "Você está longe demais da bancada!",

    -- Fabricação.
    InvalidRecipe = "Receita indisponível nesta bancada!",
    QueueFull     = "Sua fila de fabricação está cheia!",
    NoMaterial    = "Faltam %sx %s!",
    Started       = "%s entrou na fila de fabricação!",

    -- Coleta.
    NotReady    = "Esta fabricação ainda não terminou!",
    NoSpace     = "Sua mochila não aguenta o peso da produção!",
    MaxAmount   = "Você atingiu o limite de %s!",
    Collected   = "Você coletou %s!",

    -- Cancelamento.
    AlreadyDone = "Esta fabricação já terminou, é só coletar!",
    Canceled    = "Fabricação cancelada!",
    Refunded    = "Fabricação cancelada e materiais devolvidos!",

    -- Falhas genéricas.
    NotFound = "Fabricação não encontrada!",
    Failed   = "Não foi possível concluir a ação!",
}
