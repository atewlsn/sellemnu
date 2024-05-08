local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('ate-SellItem', function(itemname, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not itemname or not amount then
        print("Eksik bilgi!")
        return
    end

    local GetItem = Player.Functions.GetItemByName(itemname)
    if not GetItem or GetItem.amount < amount then
        TriggerClientEvent('QBCore:Notify', src, 'Üzerinde yeterli miktarda eşya yok!', 'error')
        return
    end

    local shop = nil
    local price = nil

    for shopName, shopData in pairs(Config.Shops) do
        if shopData.items and shopData.items[itemname] then
            shop = shopName
            price = shopData.items[itemname].price -- Fiyatı doğru şekilde alın
            break
        end
    end

    if shop and price then
        if Player.Functions.RemoveItem(itemname, amount) then
            local money = price * amount
            Player.Functions.AddMoney('cash', money)
            TriggerClientEvent('QBCore:Notify', src, 'Satış işlemi başarıyla gerçekleşti! Toplam kazanılan para: $' .. money, 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Üzerinde yeterli miktarda eşya yok!', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Eşya mağazada bulunamadı!', 'error')
    end
end)
