local LimiteProps = 0
local Ligoter, Kidnapper, MisInVeh = false

local Gangs = {}

------------------------ FONCTIONS ------------------------

CreateThread(function()
    while ESX.GetPlayerData().job == nil do
		Wait(10)
    end

    if Config.UseJob2 then
        while ESX.GetPlayerData().job2 == nil do
            Wait(10)
        end
    end

    if ESX.IsPlayerLoaded() then
		ESX.PlayerData = ESX.GetPlayerData()
    end

    ESX.TriggerServerCallback("hGangsBuilder:GetGangs", function(GangsData) 
        Gangs = GangsData

        Wait(50)
        CreateBlips()
    end)
end)

RegisterNetEvent("hGangsBuilder:NewGang")
AddEventHandler("hGangsBuilder:NewGang", function(Gangs)
    Gangs = GangsData

    Wait(50)
    CreateBlips()
end)

RegisterNetEvent("hGangsBuilder:RefreshGangs")
AddEventHandler("hGangsBuilder:RefreshGangs", function(GangsData)
    Gangs = GangsData
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
	ESX.PlayerData.job2 = job2
end)

RegisterNetEvent("hGangsBuilder:Ligote")
AddEventHandler("hGangsBuilder:Ligote", function()
    local PlayerPed = PlayerPedId()

    if not Ligoter then
        Ligoter = true
        RequestAnimDict('mp_arresting')

        while not HasAnimDictLoaded('mp_arresting') do
            Wait(100)
        end
        
        TaskPlayAnim(PlayerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)

        SetEnableHandcuffs(PlayerPed, true)
        SetPlayerCanDoDriveBy(PlayerPed, false)
        SetCurrentPedWeapon(PlayerPed, GetHashKey('WEAPON_UNARMED'), true)
        SetPedCanPlayGestureAnims(PlayerPed, false)
        DisplayRadar(false)

        while Ligoter do
            DisablePlayerFiring(PlayerPed, true)
            SetCanAttackFriendly(PlayerPed, false, true)
            Wait(10)
        end
    else
        Ligoter = false
        ClearPedSecondaryTask(PlayerPed)
        SetEnableHandcuffs(PlayerPed, false)
        SetPlayerCanDoDriveBy(PlayerPed, true)
        SetPedCanPlayGestureAnims(PlayerPed, true)
        DisplayRadar(true)
    end
end)

RegisterNetEvent("hGangsBuilder:Kidnapper")
AddEventHandler("hGangsBuilder:Kidnapper", function(copId)
    local playerPed
	local targetPed

    if not Kidnapper then
        Kidnapper = true
        targetPed = GetPlayerPed(GetPlayerFromServerId(tonumber(copId)))

        if not IsPedSittingInAnyVehicle(targetPed) then
            AttachEntityToEntity(PlayerPedId(), targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        else
            Kidnapper = false
            DetachEntity(PlayerPedId(), true, false)
        end
    else
        Kidnapper = false
        DetachEntity(PlayerPedId(), true, false)
    end
end)

RegisterNetEvent("hGangsBuilder:MettreSortirVehicule")
AddEventHandler("hGangsBuilder:MettreSortirVehicule", function()
    local PlayerPed = PlayerPedId()
    local vehicle = ESX.Game.GetClosestVehicle()

    if Ligoter and not MisInVeh then
        MisInVeh = true
        local maxSieges, SiegeLibre = GetVehicleMaxNumberOfPassengers(vehicle)

        for i=maxSieges-1,0,-1 do
            if IsVehicleSeatFree(vehicle, i) then
                SiegeLibre = i
                break
            end
        end

        if SiegeLibre then
            TaskWarpPedIntoVehicle(PlayerPed, vehicle, SiegeLibre)
        else
            ESX.ShowNotification("~o~Aucune Place Libre")
        end
    else
        MisInVeh = false
        TaskLeaveVehicle(PlayerPed, vehicle, 16)
    end
end)

function KeyboardOutput(TextEntry, ExampleText, MaxStringLength)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry .. ':')
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
    blockinput = true
    
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        blockinput = false
        return result
    else
        Citizen.Wait(500)
        blockinput = false
        return nil
    end
end

------------------------ Blips/Points ------------------------

local BlipsExist = {}

function CreateBlips()
    for k,v in pairs(BlipsExist) do
        RemoveBlip(v)
    end

    BlipsExist = {}

    for k,v in pairs(Gangs) do
        --Blip
        local blipcoords = json.decode(v.gangBlip.blipcoords)
        blip = AddBlipForCoord(blipcoords.x, blipcoords.y, blipcoords.z)
        table.insert(BlipsExist, blip)

        --Blip Attributs
        SetBlipSprite(blip, v.gangBlip.blipsprite)
        SetBlipColour(blip, v.gangBlip.blipcouleur)
        SetBlipScale(blip, v.gangBlip.bliptaille)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(v.gangBlip.bliplabel)
        EndTextCommandSetBlipName(blip)

        if v.gangBlip.zone then
            zone = AddBlipForRadius(blipcoords.x, blipcoords.y, blipcoords.z, 1000.0)
            table.insert(BlipsExist, zone)
    
            --Blip Attributs
            SetBlipSprite(zone, 1)
            SetBlipColour(zone, v.gangBlip.blipcouleur)
            SetBlipAlpha(zone, 150)
        end
    end
end

CreateThread(function()
    while true do
        wait = 750

        local MyCoords = GetEntityCoords(PlayerPedId())

        for k,v in pairs(Gangs) do
            if (Config.UseJob2 and ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.name == v.gangInfos.gangName) or (not Config.UseJob2 and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == v.gangInfos.gangName) then
                
                ----VESTIAIRE----
                local pointvestiaire = json.decode(v.gangPoints.pointvestiaire)
                local dist = Vdist(MyCoords, pointvestiaire.x, pointvestiaire.y, pointvestiaire.z)

                if dist <= 4.5 then
                    wait = 5
                    
                    if dist <= 1.5 then
                        wait = 0
                        ESX.ShowHelpNotification("~INPUT_CONTEXT~ pour acceder au ~o~Vestiaire ~s~!")
    
                        if IsControlJustPressed(0, 51) then
                            OpenVestiaireMenu(v.gangInfos.gangName)
                        end
                    end
    
                    DrawMarker(27, pointvestiaire.x, pointvestiaire.y, pointvestiaire.z+0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.8, 255, 255, 255, 255, false, true, 2, true)
                end
    
                ----GARAGE----
                pointgarage = json.decode(v.gangPoints.pointgarage)
                pointspawn  = json.decode(v.gangPoints.pointspawnveh)
                dist = Vdist(MyCoords, pointgarage.x, pointgarage.y, pointgarage.z)
    
                if dist <= 4.5 then
                    wait = 5
                    
                    if dist <= 1.5 then
                        wait = 0
                        ESX.ShowHelpNotification("~INPUT_CONTEXT~ pour acceder au ~o~Garage ~s~!")
    
                        if IsControlJustPressed(0, 51) then
                            OpenGarageMenu(v.gangInfos.gangName, vector3(pointspawn.x, pointspawn.y, pointspawn.z), v.gangPoints.headingspawnveh)
                        end
                    end
    
                    DrawMarker(27, pointgarage.x, pointgarage.y, pointgarage.z+0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.8, 255, 255, 255, 255, false, true, 2, true)
                end

                ----GARAGE----
                pointdelete = json.decode(v.gangPoints.pointrangementveh)
                dist = Vdist(MyCoords, pointdelete.x, pointdelete.y, pointdelete.z)
    
                if dist <= 4.5 and IsPedInAnyVehicle(PlayerPedId()) then
                    wait = 5
                    
                    if dist <= 1.5 and IsPedInAnyVehicle(PlayerPedId()) then
                        wait = 0
                        ESX.ShowHelpNotification("~INPUT_CONTEXT~ pour ranger le ~o~Véhicule ~s~!")
    
                        if IsControlJustPressed(0, 51) and IsPedInAnyVehicle(PlayerPedId()) then
                            ESX.Game.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                        end
                    end
    
                    DrawMarker(27, pointdelete.x, pointdelete.y, pointdelete.z+0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.8, 255, 255, 255, 255, false, true, 2, true)
                end
    
                ----COFFRE----
                pointcoffre = json.decode(v.gangPoints.pointcoffre)
                dist = Vdist(MyCoords, pointcoffre.x, pointcoffre.y, pointcoffre.z)
    
                if dist <= 4.5 then
                    wait = 5
                    
                    if dist <= 1.5 then
                        wait = 0
                        ESX.ShowHelpNotification("~INPUT_CONTEXT~ pour acceder au ~o~Coffre ~s~!")
    
                        if IsControlJustPressed(0, 51) then
                            OpenCoffreMenu(v.gangInfos.gangName)
                        end
                    end
    
                    DrawMarker(27, pointcoffre.x, pointcoffre.y, pointcoffre.z+0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.8, 255, 255, 255, 255, false, true, 2, true)
                end
    
                ----BOSS----
                if (Config.UseJob2 and ESX.PlayerData.job2.grade_name == "boss") or (not Config.UseJob2 and ESX.PlayerData.job.grade_name == "boss") then
                    pointboss = json.decode(v.gangPoints.pointboss)
                    dist = Vdist(MyCoords, pointboss.x, pointboss.y, pointboss.z)
        
                    if dist <= 4.5 then
                        wait = 5
                        
                        if dist <= 1.5 then
                            wait = 0
                            ESX.ShowHelpNotification("~INPUT_CONTEXT~ pour acceder au ~o~Actions Boss ~s~!")
        
                            if IsControlJustPressed(0, 51) then
                                OpenBossMenu(v.gangInfos.gangName, v.gangCoffre.blackMoney)
                            end
                        end
        
                        DrawMarker(27, pointboss.x, pointboss.y, pointboss.z+0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.8, 255, 255, 255, 255, false, true, 2, true)
                    end
                end
            else
                wait = 2500
            end
        end

        Wait(wait)
    end
end)

CreateThread(function()
    while true do
        wait = 750

        for k,v in pairs(Gangs) do
            if (Config.UseJob2 and ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.name == v.gangInfos.gangName) or (not Config.UseJob2 and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == v.gangInfos.gangName) then
                wait = 5

                if IsControlJustPressed(0, 168) then
                    OpenF7Menu()
                end
            end
        end

        Wait(wait)
    end
end)

-------------------------MENUS-------------------------

--Vestiaire

local VestiaireMenu = RageUI.CreateMenu("Vestiaire", "Changer de Tenue",8,200)

VestiaireMenu:SetRectangleBanner(0,0,0,255)

local open = false

VestiaireMenu.Closed = function()
	open = false
end

function OpenVestiaireMenu(gangName)
	if open then
		open = false
		RageUI.Visible(VestiaireMenu, false)
		return
	else
		open = true
		RageUI.Visible(VestiaireMenu, true)

		Citizen.CreateThread(function()
			while open do
				Wait(0)
				RageUI.IsVisible(VestiaireMenu, true,true,true, function()

                    RageUI.Separator(" ↓   ~y~Tenues   ~s~↓")

                    RageUI.Checkbox("Tenue Gang",nil, TenueCheck,{},function(Hovered,Active,Selected,Checked)
						if Selected then
							TenueCheck = Checked;
                        
							if Checked then
                                for k,v in pairs(Config.Tenues[gangName]) do
                                    TriggerEvent('skinchanger:change', 'tshirt_1', v.tshirt_1)
                                    TriggerEvent('skinchanger:change', 'tshirt_2', v.tshirt_2)
                                    TriggerEvent('skinchanger:change', 'torso_1', v.torso_1)
                                    TriggerEvent('skinchanger:change', 'torso_2', v.torso_2)
                                    TriggerEvent('skinchanger:change', 'arms', v.arms)
                                    TriggerEvent('skinchanger:change', 'arms_1', v.arms_2)
                                    TriggerEvent('skinchanger:change', 'pants_1', v.pants_1)
                                    TriggerEvent('skinchanger:change', 'pants_2', v.pants_2)
                                    TriggerEvent('skinchanger:change', 'shoes_1', v.shoes_1)
                                    TriggerEvent('skinchanger:change', 'shoes_2', v.shoes_2)
                                end
							else
                                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                                    TriggerEvent('skinchanger:loadSkin', skin) 
                                end)
							end
						end
					end)

                    RageUI.Separator(" ↓   ~y~Sac   ~s~↓")

                    RageUI.Checkbox("~r~Sac",nil, SacCheck,{},function(Hovered,Active,Selected,Checked)
						if Selected then
							SacCheck = Checked;
                        
							if Checked then
								TriggerEvent('skinchanger:change', 'bags_1', 44)
							else
                                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                                    TriggerEvent('skinchanger:loadSkin', skin) 
                                end)
							end
						end
					end)

                end)

            end
        end)
    end
end

--Garage

local GarageMenu = RageUI.CreateMenu("Garage", "Sortir un Véhicule",8,200)

GarageMenu:SetRectangleBanner(0,0,0,255)

local open = false

GarageMenu.Closed = function()
	open = false
end

function OpenGarageMenu(gangName, SpawnPos, Heading)
	if open then
		open = false
		RageUI.Visible(GarageMenu, false)
		return
	else
		open = true
		RageUI.Visible(GarageMenu, true)

		Citizen.CreateThread(function()
			while open do
				Wait(0)
				RageUI.IsVisible(GarageMenu, true,true,true, function()

                    for k,v in pairs(Config.Vehicules[gangName]) do
                            RageUI.ButtonWithStyle(v.label, nil, { RightBadge = RageUI.BadgeStyle.Car  }, true, function(Hovered, Active, Selected)
                                if Selected then
                                    RageUI.CloseAll()

                                    print(v.name)

                                    if ESX.Game.IsSpawnPointClear(SpawnPos, 5.0) then
                                        ESX.Game.SpawnVehicle(v.name, SpawnPos, Heading+0.0, function(Vehicle)
											ESX.Game.SetVehicleProperties(Vehicle, {
												fuelLevel = 100.0,
												dirtLevel = 0.0,
												modEngine = 5,
												modBrakes = 5,
												modTransmission = 5,
												modTurbo = true,
                                                plate = ''
											}) 

                                            SetVehicleCustomPrimaryColour(Vehicle, Config.VehiculesColors[gangName].r,Config.VehiculesColors[gangName].g,Config.VehiculesColors[gangName].b)
                                            SetVehicleCustomSecondaryColour(Vehicle, Config.VehiculesColors[gangName].r,Config.VehiculesColors[gangName].g,Config.VehiculesColors[gangName].b)
                                            TaskWarpPedIntoVehicle(PlayerPedId(), Vehicle, -1)
                                        end)
                                    else
                                        ESX.ShowNotification("~o~Aucune Place Disponnible !")
                                    end
                                end
                            end)
                    end
                    
                end)

            end
        end)
    end
end

--Coffre

local CoffreMenu = RageUI.CreateMenu("Coffre", "Interactions",8,200)

local PlayerInventoryMenu = RageUI.CreateSubMenu(CoffreMenu, "Coffre", "Interactions",8,200)
local GangInventoryMenu = RageUI.CreateSubMenu(CoffreMenu, "Coffre", "Interactions",8,200)
local PlayerLoadoutMenu = RageUI.CreateSubMenu(CoffreMenu, "Coffre", "Interactions",8,200)
local GangLoadoutMenu = RageUI.CreateSubMenu(CoffreMenu, "Coffre", "Interactions",8,200)

CoffreMenu:SetRectangleBanner(0,0,0,255)
PlayerInventoryMenu:SetRectangleBanner(0,0,0,255)
GangInventoryMenu:SetRectangleBanner(0,0,0,255)
PlayerLoadoutMenu:SetRectangleBanner(0,0,0,255)
GangLoadoutMenu:SetRectangleBanner(0,0,0,255)

local open = false

CoffreMenu.Closed = function()
	open = false
end

function OpenCoffreMenu(gangName)
	if open then
		open = false
		RageUI.Visible(CoffreMenu, false)
		return
	else
		open = true
		RageUI.Visible(CoffreMenu, true)

		CreateThread(function()
			while open do
				Wait(0)

				RageUI.IsVisible(CoffreMenu, true,true,true, function()

                    RageUI.ButtonWithStyle("Déposer Objet",nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            MyInventory = {}

                            ESX.TriggerServerCallback("hGangsBuilder:GetMyInventory", function(inventory) 
                                MyInventory = inventory
                            end)
                        end
                    end, PlayerInventoryMenu)

                    RageUI.ButtonWithStyle("Prendre Objet",nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            GangInventory = {}

                            ESX.TriggerServerCallback("hGangsBuilder:GetGangInventory", function(inventory) 
                                GangInventory = inventory
                            end, gangName)
                        end
                    end, GangInventoryMenu)
                
                    RageUI.ButtonWithStyle("Déposer Arme(s)",nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            MyLoadout = {}

                            ESX.TriggerServerCallback("hGangsBuilder:GetMyLoadout", function(loadout) 
                                MyLoadout = loadout
                            end)
                        end
                    end, PlayerLoadoutMenu)
    
                    RageUI.ButtonWithStyle("Prendre Arme(s)",nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            GangLoadout = {}

                            ESX.TriggerServerCallback("hGangsBuilder:GetGangLoadout", function(loadout) 
                                GangLoadout = loadout
                            end, gangName)
                        end
                    end, GangLoadoutMenu)

                end)

                RageUI.IsVisible(PlayerInventoryMenu, true,true,true, function()

                    for k,v in pairs(MyInventory) do
                        if v.count > 0 then
                            RageUI.ButtonWithStyle("[~o~"..v.count.."~s~] - "..v.label,nil, {RightLabel = "Déposer"}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    TriggerServerEvent("hGangsBuilder:DeposeItem", gangName, v)
                                    RageUI.GoBack()
                                end
                            end)
                        end

                    end

                end)

                RageUI.IsVisible(GangInventoryMenu, true,true,true, function()

                    for k,v in pairs(GangInventory) do
                        if v.count > 0 then
                            RageUI.ButtonWithStyle("[~o~"..v.count.."~s~] - "..v.label,nil, {RightLabel = "Prendre"}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    TriggerServerEvent("hGangsBuilder:RetireItem", gangName, v)
                                    RageUI.GoBack()
                                end
                            end)
                        end
                        
                    end

                end)

                RageUI.IsVisible(PlayerLoadoutMenu, true,true,true, function()

                    for k,v in pairs(MyLoadout) do

                        RageUI.ButtonWithStyle("[~o~"..v.ammo.."~s~] - ~r~"..v.label,nil, {RightLabel = "Déposer"}, true, function(Hovered, Active, Selected)
                            if Selected then
                                TriggerServerEvent("hGangsBuilder:DeposeWeapon", gangName, v)
                                RageUI.GoBack()
                            end
                        end)
                        
                    end

                end)

                RageUI.IsVisible(GangLoadoutMenu, true,true,true, function()

                    for k,v in pairs(GangLoadout) do
                        if v.count > 0 then
                            RageUI.ButtonWithStyle("[~o~"..v.ammo.."~s~] - ~b~"..v.count.."x ~r~"..v.label,nil, {RightLabel = "Prendre"}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    TriggerServerEvent("hGangsBuilder:RetireWeapon", gangName, v)
                                    RageUI.GoBack()
                                end
                            end)
                        end
                        
                    end

                end)
            end
        end)
    end
end

--Boss Menu

local BlackMoney = 0
local ActionIndex = 1

function RefreshMoney(gangName)
    for k,v in pairs(Gangs) do
        if v.gangInfos.gangName == gangName then
            BlackMoney = v.gangCoffre.blackMoney
        end
    end
end

local BossMenu = RageUI.CreateMenu("Actions", "Actions: ",8,200)

local MembresMenu = RageUI.CreateSubMenu(BossMenu, "Actions", "Actions: ",8,200)

BossMenu:SetRectangleBanner(0,0,0,255)
MembresMenu:SetRectangleBanner(0,0,0,255)

local open = false

BossMenu.Closed = function()
	open = false
end

function OpenBossMenu(gangName)
    RefreshMoney(gangName)

	if open then
		open = false
		RageUI.Visible(BossMenu, false)
		return
	else
		open = true
		RageUI.Visible(BossMenu, true)

		CreateThread(function()
			while open do
				Wait(0)

				RageUI.IsVisible(BossMenu, true,true,true, function()

                    RageUI.Separator("Argent Sale: ~r~"..BlackMoney.."$")

                    RageUI.ButtonWithStyle("Déposer de l'argent Sale",nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            local Amount = KeyboardOutput("Montant", "", 10)

                            if tonumber(Amount) then
                                TriggerServerEvent("hGangsBuilder:DeposeMoney", gangName, tonumber(Amount))
                                Wait(150)
                                RefreshMoney(gangName)
                            else
                                ESX.ShowNotification("~r~Veuillez saisir un Nombre !")
                            end
                        end
                    end)

                    RageUI.ButtonWithStyle("Retirer de l'argent Sale",nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            local Amount = KeyboardOutput("Montant", "", 10)

                            if tonumber(Amount) then
                                TriggerServerEvent("hGangsBuilder:RetireMoney", gangName, tonumber(Amount))
                                Wait(150)
                                RefreshMoney(gangName)
                            else
                                ESX.ShowNotification("~r~Veuillez saisir un Nombre !")
                            end
                        end
                    end)

                    RageUI.ButtonWithStyle("Gestion Membres",nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            Membres = {}

                            ESX.TriggerServerCallback("hGangsBuilder:GetMembres", function(membres) 
                                Membres = membres
                            end, gangName)
                        end
                    end, MembresMenu)

                    local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
						RageUI.ButtonWithStyle("Recruter", nil, { RightLabel = "", Color = {BackgroundColor = RageUI.ItemsColour.RedDark} }, true, function(Hovered, Active, Selected)
							if Selected then
								local Grade = KeyboardOutput("Grade", "", 2)

								if tonumber(Grade) then
									TriggerServerEvent("hGangsBuilder:setJob", GetPlayerServerId(closestPlayer), nil, gangName, tonumber(Grade), 'Recruter')
								else
									ESX.ShowNotification("~o~Veuillez saisir un Nombre !")
								end
							end
						end)
					end

                end)

                
				RageUI.IsVisible(MembresMenu, true,true,true, function()
                    for k,v in pairs(Membres) do
                        if Config.UseJob2 then
                            RageUI.List(v.name.." - "..v.job2.grade_label, {"Promouvoir", "Licensier"}, ActionIndex, nil, { RightLabel = "" }, true, function(Hovered, Active, Selected, Index)
                                ActionIndex = Index
    
                                if Selected then
                                    if Index == 1 then
                                        local PromoteGrade = KeyboardOutput("Nouveau grade (en chiffre)", "", 2)
    
                                        if tonumber(PromoteGrade) then
                                            TriggerServerEvent("hGangsBuilder:setJob2", nil, v.identifier, gangName, tonumber(PromoteGrade), 'Promouvoir')
                                            RageUI.GoBack()
                                        else
                                            ESX.ShowNotification("~o~Veuillez saisir un Nombre !")
                                        end
                                    else
                                        TriggerServerEvent("hGangsBuilder:setJob2", nil, v.identifier, gangName, v.job2.grade, 'Virer')
                                        RageUI.GoBack()
                                    end
                                end
                            end)
                        else
                            RageUI.List(v.name.." - "..v.job.grade_label, {"Promouvoir", "Licensier"}, ActionIndex, nil, { RightLabel = "" }, true, function(Hovered, Active, Selected, Index)
                                ActionIndex = Index
    
                                if Selected then
                                    if Index == 1 then
                                        local PromoteGrade = KeyboardOutput("Nouveau grade (en chiffre)", "", 2)
    
                                        if tonumber(PromoteGrade) then
                                            TriggerServerEvent("hGangsBuilder:setJob", nil, v.identifier, gangName, tonumber(PromoteGrade), 'Promouvoir')
                                            RageUI.GoBack()
                                        else
                                            ESX.ShowNotification("~o~Veuillez saisir un Nombre !")
                                        end
                                    else
                                        TriggerServerEvent("hGangsBuilder:setJob", nil, v.identifier, gangName, v.job.grade, 'Virer')
                                        RageUI.GoBack()
                                    end
                                end
                            end)
                        end
                    end
                end)

            end
        end)
    end
end

--Menu F7

local F7Menu = RageUI.CreateMenu("Menu Gang", "Vos Actions",8,200)
local InteractJoueurs = RageUI.CreateSubMenu(F7Menu, "Menu Gang", "Interactions Joueurs",8,200)
local FouilleMenu = RageUI.CreateSubMenu(InteractJoueurs, "Menu Gang", "Fouiller le Joueur",8,200)
local InteractVehicules = RageUI.CreateSubMenu(F7Menu, "Menu Gang", "Interactions Véhicules",8,200)
local PlaceObjets = RageUI.CreateSubMenu(F7Menu, "Menu Gang", "Placer des Objets",8,200)

F7Menu:SetRectangleBanner(0,0,0,255)
InteractJoueurs:SetRectangleBanner(0,0,0,255)
FouilleMenu:SetRectangleBanner(0,0,0,255)
InteractVehicules:SetRectangleBanner(0,0,0,255)
PlaceObjets:SetRectangleBanner(0,0,0,255)

local open = false

F7Menu.Closed = function()
	open = false
end

function OpenF7Menu()
	if open then
		open = false
		RageUI.Visible(F7Menu, false)
		return
	else
		open = true
		RageUI.Visible(F7Menu, true)

		Citizen.CreateThread(function()
			while open do
				Wait(0)
				RageUI.IsVisible(F7Menu, true,true,true, function()

                    RageUI.ButtonWithStyle("~r~Interactions Joueurs", nil, { RightLabel = "→→→"  }, true, function(Hovered, Active, Selected)
                    end, InteractJoueurs)

                    RageUI.ButtonWithStyle("~b~Interactions Véhicules", nil, { RightLabel = "→→→"  }, true, function(Hovered, Active, Selected)

                    end, InteractVehicules)

                    RageUI.ButtonWithStyle("~o~Placer des Objets", nil, { RightLabel = "→→→"  }, true, function(Hovered, Active, Selected)

                    end , PlaceObjets)

                end)

                RageUI.IsVisible(InteractJoueurs, true,true,true, function()

                    RageUI.Separator("↓   ~o~Actions   ↓")

                    local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

                    if closestPlayer == -1 or closestPlayerDistance > 3.0 then
                    else
                        RageUI.ButtonWithStyle("Fouiller", nil, { RightLabel = "→→→"  }, true, function(Hovered,Active,Selected)
                            if Selected then
                                IdPlayerFouiller = GetPlayerServerId(closestPlayer)
                                PlayerItems = {}
                                PlayerWeapons = {}

                                ESX.TriggerServerCallback("hGangsBuilder:GetItemsWeapons", function(inventory, weapons)
                                    for k,v in pairs(inventory) do
                                        if v.count > 0 then
                                            table.insert(PlayerItems, v)
                                        end
                                    end
                                    for k,v in pairs(weapons) do
                                        table.insert(PlayerWeapons, v)
                                    end

                                end, GetPlayerServerId(closestPlayer))
                            end
                        end, FouilleMenu)
                    end

                    RageUI.Checkbox("~r~Ligoter",nil, LigoterCheck,{},function(Hovered,Active,Selected,Checked)
						if Selected then
							LigoterCheck = Checked;
                            local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()
                        
							if Checked then
                                if closestPlayer == -1 or closestPlayerDistance > 3.0 then
                                    ESX.ShowNotification("~o~Personne à Proximité ! ")
                                else
                                    TriggerServerEvent("hGangsBuilder:Ligote", GetPlayerServerId(closestPlayer))
                                end
							else
                                if closestPlayer == -1 or closestPlayerDistance > 3.0 then
                                    ESX.ShowNotification("~o~Personne à Proximité ! ")
                                else
                                    TriggerServerEvent("hGangsBuilder:Ligote", GetPlayerServerId(closestPlayer))
                                end
							end
						end
					end)

                    RageUI.Checkbox("Kidnapper",nil, KidnapperCheck,{},function(Hovered,Active,Selected,Checked)
						if Selected then
							KidnapperCheck = Checked;
                            local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()
                        
							if Checked then
                                if closestPlayer == -1 or closestPlayerDistance > 3.0 then
                                    ESX.ShowNotification("~o~Personne à Proximité ! ")
                                else
                                    TriggerServerEvent("hGangsBuilder:Kidnapper", GetPlayerServerId(closestPlayer))
                                end
							else
                                if closestPlayer == -1 or closestPlayerDistance > 3.0 then
                                    ESX.ShowNotification("~o~Personne à Proximité ! ")
                                else
                                    TriggerServerEvent("hGangsBuilder:Kidnapper", GetPlayerServerId(closestPlayer))
                                end
							end
						end
					end)

                    RageUI.Checkbox("Mettre/Sortir du Véhicule",nil, MettreSortirVehCheck,{},function(Hovered,Active,Selected,Checked)
						if Selected then
							MettreSortirVehCheck = Checked;
                            local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()
                            local closestVehicle, closestVehicleDistance = ESX.Game.GetClosestVehicle()
                        
							if Checked then
                                if closestPlayer == -1 or closestPlayerDistance > 3.0 then
                                    ESX.ShowNotification("~o~Personne à Proximité ! ")
                                else
                                    if closestVehicle == -1 or closestVehicleDistance > 3.0 then
                                        ESX.ShowNotification("~o~Aucun Véhicule à Proximité ! ")
                                    else
                                        TriggerServerEvent("hGangsBuilder:MettreSortirVehicule", GetPlayerServerId(closestPlayer))
                                    end
                                end
							else
                                if closestPlayer == -1 or closestPlayerDistance > 3.0 then
                                    ESX.ShowNotification("~o~Personne à Proximité ! ")
                                else
                                    if closestVehicle == -1 or closestVehicleDistance > 3.0 then
                                        ESX.ShowNotification("~o~Aucun Véhicule à Proximité ! ")
                                    else
                                        TriggerServerEvent("hGangsBuilder:MettreSortirVehicule", GetPlayerServerId(closestPlayer))
                                    end
                                end
							end
						end
					end)

                end)

                RageUI.IsVisible(FouilleMenu, true,true,true, function()
                    RageUI.Separator("↓   ~g~Items   ↓")

                    for k,v in pairs(PlayerItems) do

                        RageUI.ButtonWithStyle("~o~["..v.count.."] ~g~"..v.label, nil, { RightLabel = "→"  }, true, function(Hovered,Active,Selected)
                            if Selected then
                                TriggerServerEvent("hGangsBuilder:RetireItem", IdPlayerFouiller, v)
                                RageUI.GoBack()
                            end
                        end)

                    end

                    RageUI.Separator("↓   ~r~Armes   ↓")

                    for k,v in pairs(PlayerWeapons) do

                        RageUI.ButtonWithStyle("~o~["..v.ammo.."Muns] ~r~"..v.label, nil, { RightLabel = "→"  }, true, function(Hovered,Active,Selected)
                            if Selected then
                                TriggerServerEvent("hGangsBuilder:RetireWeapon", IdPlayerFouiller, v)
                                RageUI.GoBack()
                            end
                        end)

                    end
                end)

                RageUI.IsVisible(InteractVehicules, true,true,true, function()

                    RageUI.ButtonWithStyle("Forcer la Serrure", nil, { RightLabel = "→"  }, true, function(Hovered,Active,Selected)
						if Selected then
                            local MyCoords = GetEntityCoords(PlayerPedId())

                            local closestVehicle, closestVehicleDistance = ESX.Game.GetClosestVehicle(MyCoords)

                            if closestVehicle == -1 or closestVehicleDistance > 3.0 then
                                ESX.ShowNotification("~o~Aucun Véhicule à Proximité")
                            else

                                TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_WELDING', 0, true)
                                Wait(20000)
                                ClearPedTasksImmediately(PlayerPedId())
    
                                SetVehicleDoorsLocked(closestVehicle, 1)
                                SetVehicleDoorsLockedForAllPlayers(closestVehicle, false)
                                ESX.ShowNotification("~o~Véhicule Déverouillé !")
                            end
						end
					end)

                end)

                RageUI.IsVisible(PlaceObjets, true,true,true, function()

                    RageUI.Separator("---------- ~o~Limite:[~r~"..LimiteProps.."~s~/~r~15] ~s~----------")

                    RageUI.Separator("↓   ~g~Objets   ~s~↓")

                    RageUI.ButtonWithStyle("~g~Cône", nil, { RightLabel = "~b~Placer"  }, true, function(Hovered,Active,Selected)
						if Selected then
                            if LimiteProps ~= 15 then
                                LimiteProps = LimiteProps + 1

                                local MyCoords = GetEntityCoords(PlayerPedId())

                                ESX.Game.SpawnObject('prop_roadcone02a', MyCoords, function(Objet)
                                    SetEntityHeading(Objet, GetEntityHeading(PlayerPedId()))
                                    PlaceObjectOnGroundProperly(Objet)
                                end)

                                print("Le Joueur "..GetPlayerName(PlayerId()).." à Placer un Cône !")
                                ESX.ShowNotification("~g~Vous avez Placer un Cône !")
                            else
                                ESX.ShowNotification("~o~Vous avez ateint votre ~r~Limite ~o~de Props pouvant être Placer !")
                            end
						end
					end)

                    
                    RageUI.ButtonWithStyle("~g~Barriere", nil, { RightLabel = "~b~Placer"  }, true, function(Hovered,Active,Selected)
						if Selected then
                            if LimiteProps ~= 15 then
                                LimiteProps = LimiteProps + 1

                                local MyCoords = GetEntityCoords(PlayerPedId())

                                ESX.Game.SpawnObject('prop_barrier_work06a', MyCoords, function(Objet)
                                    SetEntityHeading(Objet, GetEntityHeading(PlayerPedId()))
                                    PlaceObjectOnGroundProperly(Objet)
                                end)

                                print("Le Joueur "..GetPlayerName(PlayerId()).." à Placer une Barrière !")
                                ESX.ShowNotification("~g~Vous avez Placer une Barrière !")
                            else
                                ESX.ShowNotification("~o~Vous avez ateint votre ~r~Limite ~o~de Props pouvant être Placer !")
                            end
						end
					end)

                    RageUI.ButtonWithStyle("~g~Pile de Petits Cartons", nil, { RightLabel = "~b~Placer"  }, true, function(Hovered,Active,Selected)
						if Selected then
                            if LimiteProps ~= 15 then
                                LimiteProps = LimiteProps + 1

                                local MyCoords = GetEntityCoords(PlayerPedId())

                                ESX.Game.SpawnObject('prop_boxpile_06a', MyCoords, function(Objet)
                                    SetEntityHeading(Objet, GetEntityHeading(PlayerPedId()))
                                    PlaceObjectOnGroundProperly(Objet)
                                end)

                                print("Le Joueur "..GetPlayerName(PlayerId()).." à Placer une Pile de Petits Cartons !")
                                ESX.ShowNotification("~g~Vous avez Placer une Pile de Petits Cartons !")
                            else
                                ESX.ShowNotification("~o~Vous avez ateint votre ~r~Limite ~o~de Props pouvant être Placer !")
                            end
						end
					end)

                    RageUI.ButtonWithStyle("~g~Pile de Grands Cartons", nil, { RightLabel = "~b~Placer"  }, true, function(Hovered,Active,Selected)
						if Selected then
                            if LimiteProps ~= 15 then
                                LimiteProps = LimiteProps + 1

                                local MyCoords = GetEntityCoords(PlayerPedId())

                                ESX.Game.SpawnObject('prop_boxpile_07d', MyCoords, function(Objet)
                                    SetEntityHeading(Objet, GetEntityHeading(PlayerPedId()))
                                    PlaceObjectOnGroundProperly(Objet)
                                end)

                                print("Le Joueur "..GetPlayerName(PlayerId()).." à Placer une Pile de Grands Cartons !")
                                ESX.ShowNotification("~g~Vous avez Placer une Pile de Grands Cartons !")
                            else
                                ESX.ShowNotification("~o~Vous avez ateint votre ~r~Limite ~o~de Props pouvant être Placer !")
                            end
						end
					end)

                    RageUI.ButtonWithStyle("~g~Pile d'Argent", nil, { RightLabel = "~b~Placer"  }, true, function(Hovered,Active,Selected)
						if Selected then
                            if LimiteProps ~= 15 then
                                LimiteProps = LimiteProps + 1

                                local MyCoords = GetEntityCoords(PlayerPedId())

                                ESX.Game.SpawnObject('hei_prop_cash_crate_half_full', MyCoords, function(Objet)
                                    SetEntityHeading(Objet, GetEntityHeading(PlayerPedId()))
                                    PlaceObjectOnGroundProperly(Objet)
                                end)

                                print("Le Joueur "..GetPlayerName(PlayerId()).." à Placer une Pile d'Argent !")
                                ESX.ShowNotification("~g~Vous avez Placer une Pile d'Argent !")
                            else
                                ESX.ShowNotification("~o~Vous avez ateint votre ~r~Limite ~o~de Props pouvant être Placer !")
                            end
						end
					end)

                    RageUI.Separator("↓   ~o~Supprimer   ~s~↓")

                    RageUI.ButtonWithStyle("~r~Supprimer des Props", nil, { RightLabel = "~b~Supprimer"  }, true, function(Hovered,Active,Selected)
						if Selected then
                            if LimiteProps ~= 0 then
                                LimiteProps = LimiteProps - 1
                            
                                local MyCoords = GetEntityCoords(PlayerPedId())
                                local Objet = ESX.Game.GetClosestObject(MyCoords)
    
                                ESX.Game.DeleteObject(Objet)
    
                                print("Le Joueur "..GetPlayerName(PlayerId()).." à enlever un Props !")
                                ESX.ShowNotification("~o~Vous avez enlevez un Props !")
                            else
                                ESX.ShowNotification("~o~Vous n'avez Aucun Props de Placer !")
                            end
						end
					end)
                end)

            end
        end)
    end
end