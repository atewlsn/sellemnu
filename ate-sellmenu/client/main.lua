local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('sellmenu', function(source, args, rawCommand)
    local shopName = table.concat(args, " ") 
    if not shopName or shopName == "" then
        print('adını belirt mal')
        return
    end

    OpenSellMenu(source, shopName)
end, false)

Citizen.CreateThread(function()
    for shopName, shopData in pairs(Config.Shops) do
        local pedModel = GetHashKey(Config.Shops[shopName].model)
        RequestModel(pedModel)
        while not HasModelLoaded(pedModel) do
            Wait(100)
        end
        local ped = CreatePed(4, pedModel, Config.Shops[shopName].coords, Config.Shops[shopName].heading, false, false)
        SetEntityAsMissionEntity(ped, true, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)

        Citizen.CreateThread(function()
            while true do
                local pedCoords = GetEntityCoords(ped)
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(pedCoords - playerCoords)
                if distance < 10 then 
                    QBCore.Functions.DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z + 1.0, "[E] Market Menüsü", 0.4) 
                    if distance < 1.5 and IsControlJustPressed(0, 38) then 
                        OpenSellMenu(soruce, shopName) 
                    end
                end
                Wait(0)
            end
        end)
    end
end)





RegisterNetEvent('sellmenu') 
AddEventHandler('sellmenu', function(shopName) 
    if type(shopName) == "string" then 
        OpenSellMenu(source, shopName) 
    else
        print("Geçersiz mağaza adı!")
    end
end)




function OpenSellMenu(source, shopName)
    local sellMenu = {}
    sellMenu[#sellMenu + 1] = {
        isMenuHeader = true,
        header = 'Satış Menüsü',
        icon = 'fas fa-cash-register'
    }

    local shopData = Config.Shops[shopName]
    if not shopData then
        QBCore.Functions.Notify("Belirtilen mağaza adı bulunamadı.", "error")
        return
    end

    if not shopData.items then
        QBCore.Functions.Notify("Mağaza öğeleri bulunamadı.", "error")
        return
    end

    for item, itemData in pairs(shopData.items) do
        local labelText =  "  " .. (itemData.label or "Etiket Yok")
        sellMenu[#sellMenu + 1] = {
            header = labelText,
            txt = '$' .. itemData.price, 
            params = {
                event = 'itemSellConfirm',
                args = {
                    shop = shopName,
                    item = item
                }
            }
        }
    end

    exports['qb-menu']:openMenu(sellMenu)
end


RegisterNetEvent('itemSellConfirm')
AddEventHandler('itemSellConfirm', function(data)
    local shop = data.shop
    local item = data.item

    if shop and item then
        print("Shop verisi:", shop)
        print("Item verisi:", item)

        local dialog = exports['qb-input']:ShowInput({
            header = 'Satış Yap',
            submitText = 'Onayla',
            inputs = {
                { type = 'number', isRequired = true, name = 'quantity', text = 'Adet' }
            }
        })

        if dialog then
            local quantity = tonumber(dialog.quantity)

            if quantity and quantity > 0 then
                local shopData = Config.Shops[shop]

                if shopData then
                    local items = shopData.items

                    if items and items[item] then
                        local price = items[item].price 
                        local totalPrice = price * quantity
                        TriggerServerEvent('ate-SellItem', item, quantity, totalPrice)
                    else
                        QBCore.Functions.Notify("Geçersiz öğe!", "error")
                    end
                else
                    QBCore.Functions.Notify("Geçersiz mağaza!", "error")
                end
            else
                QBCore.Functions.Notify("Geçersiz miktar!", "error")
            end
        end
    else
        print("Geçersiz mağaza veya öğe!")
    end
end)
