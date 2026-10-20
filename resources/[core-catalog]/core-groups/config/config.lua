-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-GROUPS · CONFIGURAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Tablet de organizações: springboard de apps, dashboard, gerenciamento de
-- membros, metas, banco, logs e configurações de cada grupo.
--
-- ATENÇÃO: arquivo aberto para adaptação. Não altere nada aqui se você não tem
-- conhecimento de programação — mudanças incorretas podem quebrar o sistema.
--
-- Índice deste arquivo:
--   1. Sistema & Acesso
--   1.1 Hierarquia do painel Administrativo
--   1.2 Vínculo do cidadão (em quantas organizações ele cabe)
--   2. Metas
--   3. Banco
--   4. Rádio & Uniforme
--   5. Fonte de dados (personagens)
-----------------------------------------------------------------------------------------------------------------------------------------

Groups = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1. SISTEMA & ACESSO
-----------------------------------------------------------------------------------------------------------------------------------------
-- command: comando que abre o tablet · permission: grupo que libera o painel
-- Administrativo · accent: cor de destaque padrão da NUI.
Groups.system = {
    command    = "painel",  -- comando de chat/console que abre o tablet
    permission = "Admin",   -- permissão que libera o painel Administrativo no tablet
    accent     = "#ca416b", -- cor de destaque (accent) padrão da interface

    -- Aparência preenchida automaticamente ao criar um app no Administrativo.
    -- A imagem deve ser uma URL pública; deixe vazia para usar o logo do Core.
    defaultAppColor = "#ca416b",
    defaultAppIcon  = "",

    -- Fundo da tela do tablet (aparece atrás dos ícones do springboard).
    -- Aceita uma cor ("#161616", "rgb(22,22,22)") ou a URL de uma imagem
    -- ("https://i.imgur.com/exemplo.png"). Vazio = cinza padrão do tema.
    background = "",

    -- Animação de tablet na mão enquanto o painel está aberto.
    -- bone 28422 = mão direita, 60309 = mão esquerda. Os valores de offset e
    -- rotation quase sempre precisam de ajuste fino — abra o painel no servidor
    -- e vá corrigindo até o prop encaixar direito na mão do personagem.
    animation  = {
        enabled  = true,
        dict     = "amb@world_human_tourist_map@male@base",
        anim     = "base",
        prop     = "prop_cs_tablet",
        bone     = 28422,
        offset   = { x = 0.0, y = 0.0, z = 0.0 },
        rotation = { x = 0.0, y = 0.0, z = 0.0 },
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1.1 HIERARQUIA DO PAINEL ADMINISTRATIVO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Quem ENTRA no Administrativo é quem tem Groups.system.permission. O que cada
-- um PODE FAZER lá dentro vem do NÍVEL dessa permissão na sua base: no vRP o
-- nível 1 é o cargo mais alto da hierarquia do grupo, o 2 vem logo abaixo, e
-- assim por diante.
--
-- Cada capacidade é independente — monte o nível como quiser:
--
--   openPanel    · o ícone Administrativo aparece no tablet. Sem isso o admin
--                  não entra no painel de jeito nenhum.
--   viewApps     · lista as organizações e abre a configuração delas.
--   createApp    · cria organização/empresa.
--   editApp      · edita nome, cor, ícone, tipo e sistema de metas.
--   deleteApp    · exclui a organização e TODA a configuração dela.
--   manageRanks  · cria, renomeia, reordena e dá permissão aos cargos (inclui
--                  sincronizar a hierarquia da base).
--   previewApp   · abre a organização como líder ("Ver como líder").
--   previewWrite · dentro dessa visualização, pode AGIR: contratar, demitir,
--                  sacar do cofre, publicar aviso, salvar configuração...
--                  Desligado, o admin enxerga tudo e não muda nada.
--   viewLogs     · vê o log do painel administrativo (quem fez o quê).
--
-- ATENÇÃO: previewWrite sem previewApp não serve para nada — o admin precisa
-- conseguir abrir a organização antes de agir dentro dela.
Groups.system.admin = {
    levels = {
        -- Nível 1 — controle total, inclusive excluir organização.
        [1] = {
            openPanel    = true,
            viewApps     = true,
            createApp    = true,
            editApp      = true,
            deleteApp    = true,
            manageRanks  = true,
            previewApp   = true,
            previewWrite = true,
            viewLogs     = true,
        },

        -- Nível 2 — cria e edita, mas não exclui.
        [2] = {
            openPanel    = true,
            viewApps     = true,
            createApp    = true,
            editApp      = true,
            deleteApp    = false,
            manageRanks  = true,
            previewApp   = true,
            previewWrite = true,
            viewLogs     = true,
        },

        -- Nível 3 — só observa: abre como líder, mas nada de criar ou alterar.
        [3] = {
            openPanel    = true,
            viewApps     = true,
            createApp    = false,
            editApp      = false,
            deleteApp    = false,
            manageRanks  = false,
            previewApp   = true,
            previewWrite = false,
            viewLogs     = true,
        },
    },

    -- Usado por quem tem a permissão em um nível que NÃO está na lista acima
    -- (4, 5, ...) e por quem tem a permissão sem nível nenhum. O padrão é o mais
    -- restritivo possível: entra e olha. Para bloquear o painel por completo,
    -- deixe todas as capacidades como false.
    default = {
        openPanel    = true,
        viewApps     = true,
        createApp    = false,
        editApp      = false,
        deleteApp    = false,
        manageRanks  = false,
        previewApp   = false,
        previewWrite = false,
        viewLogs     = false,
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1.2 VÍNCULO DO CIDADÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Em quantas organizações o mesmo passaporte cabe ao mesmo tempo. A conta é
-- feita na CONTRATAÇÃO: quem já está no limite é recusado e a liderança que
-- estava recrutando vê o motivo na tela.
--
-- O padrão é o clássico: uma empresa e uma organização ilegal por pessoa.
--
-- ATENÇÃO: mudar o limite não expulsa ninguém. Quem já está em mais grupos do
-- que o novo limite permite continua onde está — a regra só vale para novas
-- contratações.
Groups.membership = {
    -- Máximo por TIPO. 0 = sem limite.
    --
    --   legal  = 1, ilegal = 1  · uma empresa e uma facção (padrão)
    --   legal  = 0, ilegal = 1  · empresa à vontade, uma facção só
    --   legal  = 2, ilegal = 2  · até duas de cada
    maxPerType = {
        legal  = 1, -- empresas (mecânica, hospital, polícia...)
        ilegal = 1, -- organizações ilegais
    },

    -- Máximo somando os dois tipos. 0 = sem limite (valem só os de cima).
    -- Ex.: maxPerType 2 e 2 com maxTotal 3 = no máximo 3 no total, respeitando
    -- o teto de 2 em cada tipo.
    maxTotal = 0,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. METAS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Meta DIÁRIA de farm, só para organização ilegal (empresa não usa metas).
--
-- Quem manda no TIPO de meta é o painel administrativo: o admin escolhe uma das
-- categorias abaixo ao criar/editar a organização e os itens vêm junto. A
-- organização só ajusta, nas próprias configurações, QUANTO de cada item é
-- exigido por dia e QUANTO paga a meta completa.
--
-- O jogador farma o item no inventário e ENTREGA pelo painel. A quantidade é
-- consultada no vRP e os itens entregues ficam no Baú de Metas da organização.
-- O pagamento é pró-rata:
-- cada unidade entregue vale `recompensa / total exigido na meta`, e sai do
-- cofre da organização.
--
-- O quadro semanal (SEG→DOM) zera no início de cada semana: os registros da
-- semana anterior são apagados no primeiro dia do novo ciclo.
Groups.goals = {
    -- Tipos de meta. Os itens de cada tipo são exatamente os que a rota
    -- correspondente do core-routes entrega, então o que a organização coleta
    -- na rota é o que ela entrega na meta.
    --
    -- chave = identificador do tipo · label = nome exibido na interface
    -- items  = { spawn = item na sua base, label = nome exibido }
    --
    -- A ordem aqui não importa: o painel lista os tipos em ordem alfabética.
    types = {
        -- core-routes: Routes.Lavagem
        lavagem = {
            label = "Lavagem",
            items = {
                { spawn = "papelfarm",    label = "Nota Fiscal" },
                { spawn = "washbleach",   label = "Alvejante" },
                { spawn = "aluminiofarm", label = "Alumínio" },
                { spawn = "carbonofarm",  label = "Carbono" },
                { spawn = "tarp",         label = "Lona" },
            },
        },

        -- core-routes: Routes.Ilegal (pontos Contrabando1..4)
        contrabando = {
            label = "Contrabando",
            items = {
                { spawn = "microchipfarm", label = "Microchip" },
                { spawn = "aluminiofarm",  label = "Alumínio" },
                { spawn = "plastic",       label = "Plástico" },
                { spawn = "cdfarm",        label = "CD" },
                { spawn = "carbonofarm",   label = "Carbono" },
                { spawn = "techtrash",     label = "Lixo Eletrônico" },
                { spawn = "tarp",          label = "Lona" },
                { spawn = "sugar",         label = "Açúcar" },
            },
        },

        -- core-routes: Routes.Arma
        arma = {
            label = "Arma",
            items = {
                { spawn = "canofuzil",    label = "Cano de Fuzil" },
                { spawn = "canopistola",  label = "Cano de Pistola" },
                { spawn = "canosub",      label = "Cano de SMG" },
                { spawn = "gatilhofarm",  label = "Gatilho de Arma" },
                { spawn = "molafarm",     label = "Mola de Arma" },
            },
        },

        -- core-routes: Routes.Municao
        municao = {
            label = "Munição",
            items = {
                { spawn = "capsula",      label = "Capsula de Pistola" },
                { spawn = "capsulafuzil", label = "Capsula de Fuzil" },
                { spawn = "capsulasub",   label = "Capsula de SMG" },
                { spawn = "polvorafarm",  label = "Polvora" },
            },
        },

        -- core-routes: Routes.Desmanche
        desmanche = {
            label = "Desmanche",
            items = {
                { spawn = "carbonofarm",  label = "Carbono" },
                { spawn = "cdfarm",       label = "CD" },
                { spawn = "aluminiofarm", label = "Alumínio" },
                { spawn = "techtrash",    label = "Lixo Eletrônico" },
                { spawn = "copper",       label = "Cobre" },
                { spawn = "rubber",       label = "Borracha" },
                { spawn = "plastic",      label = "Plástico" },
            },
        },

        -- core-routes: Routes.Metanfetamina
        metanfetamina = {
            label = "Metanfetamina",
            items = {
                { spawn = "metadone", label = "Ampola de Metadona" },
            },
        },

        -- core-routes: Routes.Skunk
        skunk = {
            label = "Skunk",
            items = {
                { spawn = "skunkfarm", label = "Folha de Skunk" },
            },
        },

        -- core-routes: Routes.Cocaina
        cocaina = {
            label = "Cocaína",
            items = {
                { spawn = "cocainafarm", label = "Folha de Cocaína" },
            },
        },

        -- core-routes: Routes.Ecstasy
        ecstasy = {
            label = "Ecstasy",
            items = {
                { spawn = "exatasyfarm", label = "Flor de Ecstasy" },
            },
        },

        -- core-routes: Routes.Heroina
        heroina = {
            label = "Heroína",
            items = {
                { spawn = "heroinafarm", label = "Folha de Heroína" },
            },
        },

        -- core-routes: Routes.HPI
        hpi = {
            label = "Hospital Ilegal",
            items = {
                { spawn = "quimicofarm2", label = "Químico" },
                { spawn = "plastic",      label = "Plástico" },
                { spawn = "glass",        label = "Vidro" },
            },
        },
    },

    -- Recompensa padrão (R$) de uma meta diária 100% concluída, usada quando a
    -- organização ainda não configurou a dela.
    defaultReward = 500,

    -- Segundos de espera entre duas entregas do mesmo jogador.
    claimCooldown = 5,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 3. BANCO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cofre da organização. O depósito tira do banco pessoal do jogador e o saque
-- devolve para ele — quem pode sacar é definido pela permissão do cargo.
Groups.bank = {
    -- Limite por operação (0 = sem limite).
    maxDeposit  = 0,
    maxWithdraw = 0,

    -- Segundos de espera entre duas operações do mesmo jogador.
    cooldown    = 3,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 4. RÁDIO & UNIFORME
-----------------------------------------------------------------------------------------------------------------------------------------
-- radio: integração com o core-radio. A frequência é sempre um valor cheio
-- (237, nunca 237.5) e é definida por organização no painel de configurações.
--
-- uniform: o uniforme guarda a roupa que o personagem está usando no momento em
-- que a liderança salva o slot (masculino/feminino). Quem clica em "Usar
-- Uniforme" recebe a roupa do slot do próprio gênero.
Groups.actions = {
    radio = {
        enabled = true,

        -- Faixa aceita na hora de definir a frequência da organização.
        min     = 1,
        max     = 9999,
    },

    uniform = {
        enabled  = true,

        -- Segundos de espera entre dois usos do uniforme.
        cooldown = 5,
    },

    -- Marcar Localização: cria a rota no GPS até o QG/empresa da organização.
    location = {
        enabled = true,
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 5. FONTE DE DADOS (PERSONAGENS)
-----------------------------------------------------------------------------------------------------------------------------------------
-- A contratação busca o nome pelo ID e a ficha do membro mostra o telefone. Os
-- nomes de tabela e coluna mudam por servidor — ajuste aqui (a lógica está em
-- server/framework.lua, seção PERSONAGENS).
Groups.database = {
    characters = {
        table    = "characters",
        id       = "id",
        name     = "Name",
        lastname = "Lastname",
        phone    = "Phone",
    },
}
