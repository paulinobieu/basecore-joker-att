// Formatar uma string de valor monetário.
function formatCurrency(value,paymentType) {
    if (paymentType == 'secondary') { 
        return `◆ ${Number(parseInt(value)).toLocaleString('pt-BR')}`; 
    }
    return `R$ ${Number(parseInt(value)).toLocaleString('pt-BR')}`;
}

// Formatar com HTML (ícone para uso em divs, não em inputs).
function formatCurrencyHTML(value,paymentType) {
    if (paymentType == 'secondary') {
        return `<span class='gem-icon'></span>${Number(parseInt(value)).toLocaleString('pt-BR')}`;
    }
    return `R$ ${Number(parseInt(value)).toLocaleString('pt-BR')}`;
}

// =====================================================================
window.VEHICLE_IMAGE_URL = "https://cdn.corenetwork.dev/corevehicles";

// Logo exibida no topo da garagem. Deixe "" para usar o nome da garagem em texto.
window.GARAGE_LOGO_URL = "https://cdn.corenetwork.dev/IDCore/HUD_GIF.gif";

// Função para pegar a imagem de um veículo pelo modelo (index)
function getVehicleImage(vehicleIndex) {
    return `${window.VEHICLE_IMAGE_URL}/${vehicleIndex}.png`
}

// Função que dará replace na imagem de um veículo que não for encontrada (placeholder)
function replaceMissingVehicleImage(image) {
    image.onerror = ``;
    image.src = `${window.VEHICLE_IMAGE_URL}/not_found.png`;
    return true;
}

translations = [
    ["onclick='openDealerRentModal();'","style='cursor: not-allowed !important; pointer-events: none !important; opacity: .3 !important'"],
]




