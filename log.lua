local DISCORD_WEBHOOK = 'webhook_url'

ESX = exports['es_extended']:getSharedObject()

function sendToDiscord(name, message, color)
    local currentTime = getCurrentTimeInFinland() 
    local connect = {
        {
            ["color"] = color,
            ["title"] = ":loudspeaker: " .. name,
            ["description"] = message,
            ["footer"] = {
                ["text"] = currentTime, 
            },
        }
    }
    PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers) end, 'POST', json.encode({username = "FiveM Log Bot", embeds = connect}), { ['Content-Type'] = 'application/json' })
end


function getCurrentTimeInFinland()
    local timestamp = os.time()
    local utcTime = os.date("!*t", timestamp)
    local finlandTime = os.date("*t", timestamp + 3 * 3600)
    return string.format("%02d.%02d.%04d %02d:%02d:%02d", finlandTime.day, finlandTime.month, finlandTime.year, finlandTime.hour, finlandTime.min, finlandTime.sec)
end


function getSteamName(playerId)
    for _, id in ipairs(GetPlayerIdentifiers(playerId)) do
        if string.find(id, "steam:") then
            local steamId64 = tonumber(string.sub(id, 7), 16)
            local steamUrl = "https://steamcommunity.com/profiles/" .. steamId64
            return steamUrl
        end
    end
    return "N/A"
end


function getDiscordTag(discordId)
    local userId = string.sub(discordId, 9)
    return "<@" .. userId .. ">"
end


AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local playerId = source
    deferrals.defer()

    Citizen.Wait(0)

    local identifiers = GetPlayerIdentifiers(playerId)
    local steamIdentifier, discordIdentifier, ip = "N/A", "N/A", "N/A"
    local steamUrl = "N/A"
    for _, id in ipairs(identifiers) do
        if string.find(id, "steam:") then
            steamIdentifier = id
            steamUrl = getSteamName(playerId)
        elseif string.find(id, "discord:") then
            discordIdentifier = id
        elseif string.find(id, "") then
            ip = id
        end
    end

    local discordTag = getDiscordTag(discordIdentifier)

    deferrals.done()
    sendToDiscord("Pelaaja Yhdistää :arrow_right:", string.format(
        ":bust_in_silhouette: **Nimi:** %s\n\n:hash: **Steam ID:** %s\n\n:link: **Steam Profiili:** [Klikkaa tästä](%s)\n\n:person_standing: **Steam Nimi:** %s\n\n:hash: **Discord ID:** %s\n\n:label: **Discord Tägäys:** %s\n\n:globe_with_meridians: **IP:** %s", 
        playerName, steamIdentifier, steamUrl, GetPlayerName(playerId), discordIdentifier, discordTag, ip), 3066993)
end)


AddEventHandler('playerDropped', function(reason)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local playerName = GetPlayerName(playerId)
    local steamIdentifier, discordIdentifier, ip = "N/A", "N/A", "N/A"
    local steamUrl = "N/A"

    for _, id in ipairs(GetPlayerIdentifiers(playerId)) do
        if string.find(id, "steam:") then
            steamIdentifier = id
            steamUrl = getSteamName(playerId)
        elseif string.find(id, "discord:") then
            discordIdentifier = id
        elseif string.find(id, "") then
            ip = id
        end
    end

    local discordTag = getDiscordTag(discordIdentifier)

    local inventory = xPlayer.getInventory()
    local items = ""
    for _, item in ipairs(inventory) do
        if item.count > 0 then
            items = items .. string.format(":small_blue_diamond: **%s**: %d\n\n", item.label, item.count)
        end
    end

    local rpName = xPlayer.getName()
    local playerGroup = xPlayer.getGroup()
    local timeStamp = getCurrentTimeInFinland()

    local message = string.format(
        ":outbox_tray: **Nimi:** %s\n\n:information_desk_person: **RP Hahmon Nimi:** %s\n\n:hash: **Steam ID:** %s\n\n:link: **Steam Profiili:** [Klikkaa tästä](%s)\n\n:person_standing: **Steam Nimi:** %s\n\n:hash: **Discord ID:** %s\n\n:label: **Discord Tägäys:** %s\n\n:globe_with_meridians: **IP:** %s\n\n:moneybag: **Käteinen:** $%s\n\n:bank: **Pankki:** $%s\n\n:money_with_wings: **Likainen Raha:** $%s\n\n:shield: **Ryhmä:** %s\n\n:alarm_clock: **Aika:** %s\n\n:shopping_cart: **Esineet:**\n\n%s",
        playerName, rpName, steamIdentifier, steamUrl, GetPlayerName(playerId), discordIdentifier, discordTag, ip, xPlayer.getMoney(), xPlayer.getAccount('bank').money, xPlayer.getAccount('black_money').money, playerGroup, timeStamp, items
    )

    sendToDiscord("Pelaaja Poistui :x:", message, 15158332)
end)