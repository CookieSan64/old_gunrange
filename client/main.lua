local cDif = nil -- Difficulty level
local mTargets = 0 -- Max targets
local coutDown = 300 -- 3sec Countdown timer
local wTime = 0 -- Time between targets
local sShoot = false --
local spwnT = false --
local target = nil --
local cTCoords = {} -- Current target coords 
local points = 0 --
local count = 0 --
local showBoard = false
local GUI = {} --
GUI.Time = 0

ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function(id)
    while true do
        Citizen.Wait(1)

        local coords = GetEntityCoords(GetPlayerPed(-1))

        if (GetDistanceBetweenCoords(coords, 821.52, -2163.37, 29.65, true) <
            20.0) then
            DrawMarker(1, 821.52, -2163.37, 28.6, 0.0, 0.0, 0.0, 0, 0.0, 0.0,
                       1.0, 1.0, 0.2, 255, 0, 0, 60, false, true, 2, false,
                       false, false, false)
        end
        if sShoot then
            if spwnT then
                drawTxt(1.40, 0.52, 1.0, 1.0, 0.53, _U('points') .. points ..
                            "\n" .. _U('targets') .. count, 255, 255, 255, 240)
            else
                Citizen.Wait(5000)
                sShoot = false
                if Config.ChatMessages == true then
                    TriggerServerEvent('old_gunrange:showresulttoNearbyPlayers', difficulty, points, targets)
                end
                TriggerServerEvent('old_gunrange:updateScoreboard', cDif,
                                   points, mTargets)
                TriggerEvent('old_gunrange:stop')
            end
            if target ~= nil then
                for m, n in pairs(weapons) do
                    if HasEntityBeenDamagedByWeapon(target, GetHashKey(
                                                        weapons[m].weapon), 0) then
                        if HasBulletImpactedInBox(cTCoords[1] + 0.06,
                                                  cTCoords[2] + 0.12,
                                                  cTCoords[3] + 0.46,
                                                  cTCoords[1] - 0.06,
                                                  cTCoords[2],
                                                  cTCoords[3] + 0.6, true, true) then
                            points = points + 5
                        elseif HasBulletImpactedInBox(cTCoords[1] + 0.11,
                                                      cTCoords[2] + 0.12,
                                                      cTCoords[3] + 0.41,
                                                      cTCoords[1] - 0.11,
                                                      cTCoords[2],
                                                      cTCoords[3] + 0.69, true,
                                                      true) then
                            points = points + 4
                        elseif HasBulletImpactedInBox(cTCoords[1] + 0.16,
                                                      cTCoords[2] + 0.12,
                                                      cTCoords[3] + 0.33,
                                                      cTCoords[1] - 0.16,
                                                      cTCoords[2],
                                                      cTCoords[3] + 0.76, true,
                                                      true) then
                            points = points + 3
                        elseif HasBulletImpactedInBox(cTCoords[1] + 0.21,
                                                      cTCoords[2] + 0.12,
                                                      cTCoords[3] + 0.25,
                                                      cTCoords[1] - 0.21,
                                                      cTCoords[2],
                                                      cTCoords[3] + 0.85, true,
                                                      true) then
                            points = points + 2
                        else
                            points = points + 1
                        end
                        DeleteObject(target)
                        target = nil
                        cTCoords = {}
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if sShoot then
            if coutDown == 0 then
                if spwnT then
                    if Config.ForceFirstView then
                        SetFollowPedCamViewMode(4)
                    end
                    count = count + 1
                    local number = math.random(#Config.targets)
                    cTCoords = Config.targets[number]
                    local model = GetHashKey('prop_range_target_01')
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    target = CreateObject(model, cTCoords[1], cTCoords[2],
                                          cTCoords[3], true, true, true)
                    SetEntityHeading(target, 2.3)
                    Wait(wTime)
                    DeleteObject(target)
                    target = nil
                    cTCoords = {}

                    if count == mTargets then spwnT = false end
                else
                    if Config.ForceFirstView then
                        SetFollowPedCamViewMode(2)
                    end
                    drawTxt(0.85, 0.82, 1.0, 1.0, 2.13,
                            _U('you_got') .. points .. _U('points'), 255, 255,
                            255, 240)
                end
            else
                coutDown = coutDown - 1
                drawTxt(0.9, 0.82, 1.0, 1.0, 2.13, coutDown / 100, 255, 255,
                        255, 240)
            end
        end
    end
end)

function drawTxt(x, y, width, height, scale, text, r, g, b, a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end

AddEventHandler('old_gunrange:hasEnteredMarker', function(zone)
    local player = GetPlayerPed(-1)
    if zone == 'old_gunrange' then
        if sShoot ~= true then
            CurrentAction = 'start'
            CurrentActionMsg = _U('actionMessage') -- "Appuyez sur ~INPUT_PICKUP~ pour ouvrir le menu."
            CurrentActionData = {}
        end
    elseif zone == 'scores' then
        CurrentAction = 'scores'
        CurrentActionMsg = _U('show_board')
        CurrentActionData = {}
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        local coords = GetEntityCoords(GetPlayerPed(-1))
        local isInMarker = false
        local currentZone = nil
        if (GetDistanceBetweenCoords(coords, 821.52, -2163.37, 29.65, true) <= 2) then
            isInMarker = true
            currentZone = 'old_gunrange'
        end
        if isInMarker and not hasAlreadyEnteredMarker then
            hasAlreadyEnteredMarker = true
            lastZone = currentZone
            TriggerEvent('old_gunrange:hasEnteredMarker', currentZone)
        end
        if not isInMarker and hasAlreadyEnteredMarker then
            hasAlreadyEnteredMarker = false
            TriggerEvent('old_gunrange:hasExitedMarker', lastZone)
        end
    end
end)
AddEventHandler('old_gunrange:hasExitedMarker', function(zone)
    CurrentAction = nil
    showBoard = false
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if CurrentAction ~= nil then
            SetTextComponentFormat('STRING')
            AddTextComponentString(CurrentActionMsg)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            if IsControlPressed(0, 86) and (GetGameTimer() - GUI.Time) > 150 then
                if CurrentAction == 'start' then
                    ESX.TriggerServerCallback('old_gunrange:canshoot',
                                               function(approved)
                        if approved then
                            openDifficultyMenu()
                        else
                            ESX.ShowNotification(_U('wait_for_turn'))
                        end
                    end)
                elseif CurrentAction == 'scores' then
                    showSBoard()
                end
                CurrentAction = nil
                GUI.Time = GetGameTimer()
            end
        end
    end
end)

function openDifficultyMenu()
    count = 0
    points = 0
    coutDown = 300
    local elements = {
        {label = _U('easy'), time = 2000}, {label = _U('normal'), time = 1300},
        {label = _U('hard'), time = 1000}, {label = _U('harder'), time = 800},
        {label = _U('impossible'), time = 500}
    }
    ESX.UI.Menu.Open('default', GetCurrentResourceName(),'old_gunrange_difficulty',
    {
        title = _U('difficulty'),
        align = 'right',
        elements = elements
    }, function(data, menu)
        local elements2 = {
            {label = '10', targets = 10}, {label = '12', targets = 12},
            {label = '14', targets = 14}, {label = '16', targets = 16},
            {label = '18', targets = 18}, {label = '20', targets = 20}
        }
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'targets_amount',
        {
            title = _U('targets'),
            align = 'right',
            elements = elements2
        }, function(data2, menu2)
            wTime = data.current.time
            cDif = data.current.label
            mTargets = data2.current.targets
            sShoot = true
            spwnT = true
            TriggerServerEvent('old_gunrange:startShooting', wTime, mTargets)
            ESX.UI.Menu.CloseAll()
        end, function(data2, menu2) menu2.close() end)
    end, function(data, menu) ESX.UI.Menu.CloseAll() end)
end

RegisterNetEvent('old_gunrange:sendresultsforplayers')
AddEventHandler('old_gunrange:sendresultsforplayers',
                function(fname, lname, dif, points, t)
    local coords = GetEntityCoords(GetPlayerPed(-1))
    if (GetDistanceBetweenCoords(coords, 821.52, -2163.37, 29.65, true) < 20.0) then
        TriggerEvent('chatMessage', "^4" .. _U('old_gunrange'), {0, 153, 204},
        "^2 " .. '\n' .. fname .. ' ' .. lname .. '\n' ..
        _U('points') .. points .. '\n' .. _U('difficulty') ..
        dif .. '\n' .. _U('targets') .. t)
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
end

function showSBoard()
    ESX.TriggerServerCallback('old_gunrange:GetScores', function(s)
        scores = s
        showBoard = true
        Citizen.CreateThread(function()
            while showBoard do
                Citizen.Wait(1)
                DrawText3D(815.38, -2161.978, 31.2, _U('last_10'))
                if #scores > 0 then
                    for i = 1, #scores do
                        DrawText3D(815.38, -2161.978, 31.2 - (i / 14),
                                   _U('name') .. scores[i].name .. " | " ..
                                       _U('difficulty_2') .. scores[i].dif ..
                                       " | " .. _U('targets_2') .. scores[i].tar ..
                                       " | " .. _U('points_2') ..
                                       scores[i].score)
                    end
                end
            end
        end)
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        local coords = GetEntityCoords(GetPlayerPed(-1))
        local isInScoreZone = false
        -- Vérifiez si le joueur est dans la zone de score en utilisant les coordonnées définies dans le fichier config.lua
        if (GetDistanceBetweenCoords(coords, Config.ScoreZone.Coords.x, Config.ScoreZone.Coords.y, Config.ScoreZone.Coords.z, true) <= 2) then
            isInScoreZone = true
            TriggerEvent('old_gunrange:playerEnteredScoreZone') -- Déclenchez l'événement lorsque le joueur entre dans la zone de score
        end
    end
end)

Citizen.CreateThread(function()
    for k, v in pairs(Config.Gunrange) do
        local blip = AddBlipForCoord(v.Blip.Coords)
        SetBlipSprite(blip, v.Blip.Sprite)
        SetBlipDisplay(blip, v.Blip.Display)
        SetBlipScale(blip, v.Blip.Scale)
        SetBlipColour(blip, v.Blip.Colour)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(_U('map_blip'))
        EndTextCommandSetBlipName(blip)
    end
end)
