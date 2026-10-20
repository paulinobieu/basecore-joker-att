AddEventHandler("onResourceStop",function(resource)
    if resource == GetCurrentResourceName() then
        print("[core-inventory] recurso finalizado")
    end
end)
