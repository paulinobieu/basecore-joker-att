-- # notify: função de notificação.

local lang = {

    ['INVALID_ID'] = {
        'ID de personagem inválido!',
        'negado'
    },

    ['INVALID_IDENTITY'] = {
        'Identidade inválida',
        'negado'
    },

    ['INVALID_ACTION'] = {
        'Ação inválida',
        'negado'
    },

    ['INVALID_PASSPORT'] = {
        'Passaporte inválido.',
        'negado'
    },

    ['INVALID_VALUE'] = {
        'Valor inválido.',
        'negado'
    },

    ['COOLDOWN'] = {
        'Aguarde para realizar outra ação.',
        'negado'
    },

    ['NO_PERMISSION'] = {
        'Sem permissão',
        'negado'
    },

    ['INVALID_VEHICLE'] = {
        'Veículo indisponível no momento.',
        'negado'
    },

    ['GARAGE_UNAVAILABLE'] = {
        'Garagem indisponível no momento.',
        'negada'
    },

    ['VEHICLE_NOT_FOUND'] = {
        'Veículo não encontrado.',
        'negado'
    },

    ['NOT_YOUR_VEHICLE'] = {
        'Você não é o proprietário deste veículo!',
        'negado'
    },

    ['VEHICLE_PARKED_OUT'] = {
        'Veículo retirado',
        'sucesso'
    },

    ['VEHICLE_PARKED_IN'] = {
        'Veículo guardado.',
        'sucesso'
    },

    ['VEHICLE_LOCKED'] = {
        'Veículo trancado.',
        'sucesso'
    },

    ['VEHICLE_UNLOCKED'] = {
        'Veículo destrancado.',
        'sucesso'
    },

    ['VEHICLE_ALREADY_OUT'] = {
        'O veículo já está fora da garagem!',
        'negado'
    },

    ['VEHICLE_TOO_FAR'] = {
        'O veículo está muito longe!',
        'negado'
    },

    ['VEHICLE_ALREADY_IN'] = {
        'O veículo já está na garagem!',
        'negado'
    },

    ['SPACE_UNAVAILABLE'] = {
        'Não há vagas disponíveis no momento.',
        'negado'
    },

    ['VEHICLE_UNAVAILABLE'] = {
        'Veículo indisponível no momento',
        'negado'
    },

    ['CANT_BORROW_TO_YOURSELF'] = {
        'Você não pode conceder uma chave do veículo para sí mesmo.',
        'negado'
    },

    ['VEHICLE_ALREADY_BORROWED'] = {
        'Você só pode conceder uma chave extra do veículo por vez.',
        'negado'
    },

    ['VEHICLE_BORROWED'] = {
        'Chave do veículo concedida!',
        'sucesso'
    },

    ['VEHICLE_UNBORROWED'] = {
        'Chave do veículo revogada!',
        'sucesso'
    },

    ['CANT_BORROW_THIS_VEHICLE'] = {
        'Você não pode conceder chaves deste modelo de veículo.',
        'negado'
    },

    ['CANT_BORROW_RENTAL_VEHICLES'] = {
        'Você não pode conceder chaves de veículos <b>alugados</b>.',
        'negado'
    },

    ['CANT_SELL_THIS_VEHICLE'] = {
        'Você não pode vender este modelo de veículo.',
        'negado'
    },

    ['CANT_SELL_RENTAL_VEHICLES'] = {
        'Você não pode vender veículos alugados.',
        'negado'
    },

    ['ALREADY_SELLING_VEHICLE'] = {
        'Você enviou uma proposta de venda deste veículo recentemente. Aguarde até que ela seja respondida.',
        'negado'
    },

    ['PERSON_MUST_BE_NEAR'] = {
        'A pessoa precisa estar próxima.',
        'negado'
    },

    ['DOSNT_HAVE_SPACE_AT_GARAGE'] = {
        'Sem vagas disponíveis em sua garagem.',
        'negado'
    },

    ['PERSON_DOSNT_HAVE_SPACE_AT_GARAGE'] = {
        'A pessoa não possuí espaço na garagem.',
        'negado'
    },

    ['VEHICLE_SELL_COMPLETED'] = {
        'Você vendeu o veículo @vehicle por @price.',
        'sucesso'
    },

    ['VEHICLE_PURCHASE_COMPLETE'] = {
        'Você comprou o veículo @vehicle por @price.',
        'sucesso'
    },

    ['VEHICLE_SELL_DECLINED'] = {
        'Sua proposta de venda do veículo @vehicle foi recusada.',
        'negado'
    },

    ['MONEY_NOT_ENOUGH'] = {
        'Dinheiro insuficiente.',
        'negado'
    },

    ['UNKNOWN_ERROR'] = {
        'Ocorreu um erro. Tente novamente.',
        'negado'
    },

    ['VEHICLE_SELL_PROPOSE_SENT'] = {
        'Proposta de venda enviada!',
        'sucesso'
    },

    ['CANT_SELL_PARKED_OUT_VEHICLES'] = {
        'Você não pode vender um veículo que está fora da garagem!',
        'negado'
    },

    ['PURCHASE_CANCELLED'] = {
        'A venda foi cancelada.',
        'negado'
    },

    ['PAYMENT_COMPLETED'] = {
        'Pagamento efetuado!',
        'sucesso'
    },

    ['VEHICLE_OUT_OF_STOCK'] = {
        'Ops, parece que este veículo está sem estoque no momento.',
        'negado',
        7000
    },

    ['PURCHASE_COMPLETED'] = {
        'Você adquiriu o veículo, parabéns!',
        'sucesso'
    },

    ['RENT_COMPLETED'] = {
        'Você alugou o veículo, bom uso!',
        'sucesso'
    },

    ['WAIT_PROCESSING'] = {
        'Aguarde, processando seu pedido..',
        'aviso'
    },

    ['INVALID_DAYS_AMOUNT'] = {
        'Quantidade de dias inválida.',
        'negado'
    },

    ['MODEL_ALREADY_RENTED'] = {
        'Você já possuí um aluguel ativo deste modelo de veículo. Você pode renová-lo a qualquer momento, na aba <b>Seus Veículos</b>.',
        'aviso',
        10000
    },

    ['YOU_CANT_RENEW_THIS_VEHICLE'] = {
        'Você não pode renovar o aluguel este veículo.',
        'negado'
    },

    ['VEHICLE_STOCK_UPDATED'] = {
        'Estoque do veículo @vehicle atualizado para @stock unidades!',
        'sucesso'
    },

    ['YOU_CANT_MODIFY_THIS_VEHICLE'] = {
        'Você não pode realizar modificações em veículos alugados.',
        'negado'
    },

    ['ALREADY_RENTED'] = {
        'Você já alugou este veículo. Devolva-o antes de alugar outro!',
        'negado'
    },

    ['NOT_RENTED'] = {
        'Você não alugou este veículo.',
        'negado'
    },

    ['NO_INVOICES_PENDING'] = {
        'Nenhum pedido pendente.',
        'aviso'
    },

    ['MECH_INVOICE_CREATED'] = {
        'Pedido criado! Aguarde até que um mecânico lhe atenda.',
        'sucesso'
    },

    ['INVOICE_CANCELLED'] = {
        'Pedido cancelado!',
        'sucesso'
    },

    ['INVOICE_CANCELLED_2'] = {
        'Seu pedido de tunagem para o veículo @vehicle (@plate) foi cancelado!',
        'aviso'
    },

    ['INVOICE_CALL_COOLDOWN'] = {
        'O cliente já foi chamado recentemente, aguarde para chamá-lo novamente.',
        'negado'
    },

    ['INVOICE_CLIENT_CALLED'] = {
        'Cliente chamado!',
        'sucesso'
    },

    ['MECHANIC_CALL'] = {
        'Um(a) mecânico(a) está lhe convidando para iniciar o atendimento do seu pedido de modificações no veículo <b>@vehicle (@plate)</b>. Dirija-se à mecânica!',
        'aviso',
        15000
    },

    ['CLIENT_MUST_BE_NEAR'] = {
        'O cliente deve estar próximo ao veículo para que a cobrança seja feita.',
        'negado'
    },

    ['PAYMENT_REQUESTED'] = {
        'Cobrança solicitada ao cliente, aguardando pagamento...',
        'aviso'
    },

    ['INVOICE_PAYMENT_COOLDOWN'] = {
        'Uma cobrança já foi enviada ao cliente, aguarde.',
        'negado'
    },

    ['INVOICE_PAYMENT_DECLINED'] = {
        'O cliente não completou o pagamento.',
        'aviso'
    },

    ['PAYMENT_SUCCESSFULL'] = {
        'O cliente realizou o pagamento, aplicando modificações...',
        'sucesso'
    },

    ['INVOICE_COMPLETED'] = {
        'Pedido concluído, você recebeu uma comissão de R$ @comission!',
        'sucesso'
    },

    ['TOO_FAR_FROM_MECHANIC'] = {
        'Não é possível aplicar modificações fora da área da mecânica.',
        'negado'
    },

    ['MUST_BE_DRIVING_TO_APPLY'] = {
        'Você precisa estar no volante do veículo para aplicar as modificações.',
        'negado'
    },

    ['NEW_INVOICE_RECEIVED'] = {
        '(Mecânica) Novo pedido recebido, verifique utilizando @command.',
        'aviso'
    },

    ['CVM_DELETED'] = {
        'Veículo removido!',
        'sucesso'
    },

    ['CVM_PARKED_IN'] = {
        'O veículo encontra-se na garagem.',
        'aviso'
    },

    ['CVM_TELEPORTED_TO'] = {
        'Teletransportado até o veículo.',
        'sucesso'
    },

    ['CVM_RENEWED'] = {
        'Duração do veículo atualizada!',
        'sucesso'
    },

    ['INVALID_PLATE'] = {
        'Placa inválida. A placa deve conter 08 digitos e não pode ter caracteres especiais ou espaços!',
        'negado'
    },

    ['CVM_ADDED'] = {
        'Veículo gerado!',
        'sucesso'
    },

    ['CVM_VEHICLE_NOT_REGISTERED'] = {
        'Veículo não cadastrado!',
        'negado'
    },

    ['PLATE_IN_USE'] = {
        'A placa inserida já está em uso!',
        'negado'
    },

    ['MODEL_ALREADY_RENTED'] = {
        'Este ID já possuí um aluguel ativo deste modelo de veículo. Renove-o ao invés de gerar um novo veículo de alguuel, do mesmo modelo!</b>.',
        'negado',
        10000
    },

    ['NONE_VEHICLE_NEAR'] = {
        'Nenhum veículo próximo!',
        'negado'
    },

    ['DEALER_NOT_BUYING_VEHICLES'] = {
        'A concessionária não está comprando veículos no momento.',
        'negado'
    },

    ['PERM_DISCOUNT'] = {
        'Você recebeu um desconto de @discount% em sua compra!',
        'aviso'
    },

    ['GARAGE_PAYMENT_NEEDED'] = {
        'Dinheiro insuficiente!<br>Para retirar veículos nesta garagem, é necessário pagar uma taxa de <b>R$ @value</b>!',
        'aviso',
        5000
    },

    ['GARAGE_FULL'] = {
        'Você atingiu o limite de veículos da sua garagem.',
        'negado',
        5000
    },

    ['SELL_COMPLETED'] = {
        'Veículo vendido para a concessionária com sucesso.',
        'sucesso'
    },

    ['CVM_MODEL_ALREADY_RENTED'] = {
        'Este modelo já está alugado e ainda não expirou.',
        'negado',
        5000
    },

    ['AI_VEHICLE_HOTWIRE_HINT'] = {
        'Veículo desligado. Pressione <b>@key</b> para tentar ligar os fios.',
        'aviso',
        5000
    },

    ['AI_VEHICLE_HOTWIRE_SUCCESS'] = {
        'Você conseguiu ligar os fios do veículo.',
        'sucesso'
    },

    ['AI_VEHICLE_HOTWIRE_FAILED'] = {
        'Você não conseguiu ligar os fios do veículo.',
        'negado'
    }

}

local notifyColorMap = {
    ['negado'] = 'vermelho',
    ['sucesso'] = 'verde',
    ['aviso'] = 'amarelo',
}

notify = function(src, msgKey, extras, title)

    if not lang[msgKey] then
        return
    end

    local msg = lang[msgKey][1]
    local color = notifyColorMap[lang[msgKey][2]] or lang[msgKey][2]
    local time = lang[msgKey][3] or 3000
    title = title or 'Veículos'

    if extras and type(extras) == 'table' then
        for i, v in pairs(extras) do
            msg = msg:gsub(i, v)
        end
    end

    if IsDuplicityVersion() then
        if not src or src == 0 then
            return
        end
        TriggerClientEvent('Notify', src, title, msg, color, time)
    else
        TriggerEvent('Notify', title, msg, color, time)
    end

end
