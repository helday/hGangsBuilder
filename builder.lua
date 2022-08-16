----------------------------------------------------------------------------------------------------------------------------

local Categorie = "Informations"
local CategorieIndex = 1

local BuilderMenu = RageUI.CreateMenu("Gangs Builder", "Créer votre Gang",8,200)

local CreationGang = RageUI.CreateSubMenu(BuilderMenu, "Gangs Builder", "Créer votre Gang",8,200)
local CreationGrades = RageUI.CreateSubMenu(CreationGang, "Gangs Builder", "Créer un Grade",8,200)

BuilderMenu:SetRectangleBanner(0,0,0,255)
CreationGang:SetRectangleBanner(0,0,0,255)
CreationGrades:SetRectangleBanner(0,0,0,255)

local open = false

BuilderMenu.Closed = function()
	open = false
end

function OpenBuilder()
    local GangData = {
        Grades = {},
        Blips = {}
    }

    local NameGang, LabelGang = "Aucun", "Aucun"
    local NomGrade, LabelGrade, SalaireGrade = "Aucun", "Aucun", "Aucun"
    local LabelBlip, SpriteBlip, CouleurBlip, TailleBlip, Zone = "Aucun", "Aucun", "Aucun", "Aucun", false

	if open then
		open = false
		RageUI.Visible(BuilderMenu, false)
		return
	else
		open = true
		RageUI.Visible(BuilderMenu, true)

		CreateThread(function()
			while open do
				Wait(0)

				RageUI.IsVisible(BuilderMenu, true,true,true, function()

                    RageUI.ButtonWithStyle("Créer un Gang", nil, { RightLabel = "→→→" }, true, function(Hovered, Active, Selected)
                    end, CreationGang)

                    RageUI.Separator("↓   Gangs   ↓")

                end)

                RageUI.IsVisible(CreationGang, true,true,true, function()

                    RageUI.List("Catégorie", { "Informations", "Blips", "Points", "Confirmation" }, CategorieIndex, nil, {}, true, function(Hovered, Active, Selected, Index)
                        if Index == 1 then
                            Categorie = "Informations"
                        elseif Index == 2 then
                            Categorie = "Blips"
                        elseif Index == 3 then
                            Categorie = "Points"
                        elseif Index == 4 then
                            Categorie = "Confirmation"
                        end
                    end, function(Index)
                        CategorieIndex = Index
                    end)

                    RageUI.Line()

                    if Categorie == "Informations" then

                        RageUI.ButtonWithStyle("Nom", nil, { RightLabel = NameGang }, true, function(Hovered, Active, Selected)
                            if Selected then
                                local Name = KeyboardOutput("Nom du Gang", "", 25)
                                
                                if tostring(Name) then
                                    GangData.Name = tostring(Name)
                                    NameGang = tostring(Name)
                                else
                                    ESX.ShowNotification("~r~Nom Invalide !")
                                end
                            end
                        end)
    
                        RageUI.ButtonWithStyle("Label", nil, { RightLabel = LabelGang }, true, function(Hovered, Active, Selected)
                            if Selected then
                                local Label = KeyboardOutput("Label du Gang", "", 25) 
    
                                if tostring(Label) then
                                    GangData.Label = tostring(Label)
                                    LabelGang = tostring(Label)
                                else
                                    ESX.ShowNotification("~r~Nom Invalide !")
                                end
                            end
                        end)

                        RageUI.ButtonWithStyle("Créer un Grade", nil, { RightLabel = "→→→" }, true, function(Hovered, Active, Selected)
                        end, CreationGrades)

                        RageUI.Separator("↓   Grades   ↓")

                        for k,v in pairs(GangData.Grades) do
                            RageUI.ButtonWithStyle("[~o~"..v.name.."~s~] ~s~"..v.label, nil, { RightLabel = "~g~"..v.salaire.."$" }, true, function(Hovered, Active, Selected)
                            end)
                        end

                    elseif Categorie == "Blips" then

                        RageUI.ButtonWithStyle("Position", nil, { RightLabel = "~b~Placer ~s~→" }, true, function(Hovered, Active, Selected)
                            if Selected then
                                local MyCoords = GetEntityCoords(PlayerPedId())
    
                                BlipPosition = vector3(MyCoords.x, MyCoords.y, MyCoords.z)
    
                                ESX.ShowNotification("Position Enregistré !")
                            end
                        end)

                        RageUI.Checkbox("Zone",nil, ZoneCheck,{},function(Hovered,Active,Selected,Checked)
                            if Selected then
                                ZoneCheck = Checked;
                            
                                if Checked then
                                    Zone = true
                                else
                                    Zone = false
                                end
                            end
                        end)

                        RageUI.ButtonWithStyle("Label", nil, { RightLabel = LabelBlip }, true, function(Hovered, Active, Selected)
                            if Selected then
                                local Label = KeyboardOutput("Label du Blip", "", 25)
                                
                                if tostring(Label) then
                                    LabelBlip = tostring(Label)
                                else
                                    ESX.ShowNotification("~r~Label Invalide !")
                                end
                            end
                        end)

                        RageUI.ButtonWithStyle("ID Sprite", nil, { RightLabel = SpriteBlip }, true, function(Hovered, Active, Selected)
                            if Selected then
                                local Sprite = KeyboardOutput("Sprite du Blip", "", 3)
                                
                                if tonumber(Sprite) then
                                    SpriteBlip = tonumber(Sprite)
                                else
                                    ESX.ShowNotification("~r~Sprite Invalide !")
                                end
                            end
                        end)

                        RageUI.ButtonWithStyle("ID Couleur", nil, { RightLabel = CouleurBlip }, true, function(Hovered, Active, Selected)
                            if Selected then
                                local Couleur = KeyboardOutput("Couleur du Blip", "", 3)
                                
                                if tonumber(Couleur) then
                                    CouleurBlip = tonumber(Couleur)
                                else
                                    ESX.ShowNotification("~r~Couleur Invalide !")
                                end
                            end
                        end)

                        RageUI.ButtonWithStyle("Taille", nil, { RightLabel = TailleBlip }, true, function(Hovered, Active, Selected)
                            if Selected then
                                local Taille = KeyboardOutput("Taille du Blip", "", 3)
                                
                                if tonumber(Taille) then
                                    TailleBlip = tonumber(Taille)
                                else
                                    ESX.ShowNotification("~r~Taille Invalide !")
                                end
                            end
                        end)

                        RageUI.Line()

                        RageUI.ButtonWithStyle("Valider", nil, { RightLabel = "→→→", Color = { BackgroundColor = RageUI.ItemsColour.GreenDark, HightLightColor = RageUI.ItemsColour.GreenDark } }, true, function(Hovered, Active, Selected)
                            if Selected then
                                print(Zone)
                                table.insert(GangData.Blips, {
                                    Position = BlipPosition,
                                    Zone = Zone,
                                    Label = LabelBlip,
                                    Sprite = SpriteBlip,
                                    Couleur = CouleurBlip,
                                    Taille = TailleBlip
                                })
                            end
                        end)

                    elseif Categorie == "Points" then
    
                        RageUI.ButtonWithStyle("Point Vestiaire", nil, { RightLabel = "~b~Placer ~s~→" }, true, function(Hovered, Active, Selected)
                            if Selected then
                                local MyCoords = GetEntityCoords(PlayerPedId())
    
                                GangData.Vestiaire = vector3(MyCoords.x, MyCoords.y, MyCoords.z -1)
    
                                ESX.ShowNotification("Position Enregistré !")
                            end
                        end)
    
                        RageUI.ButtonWithStyle("Point Garage", nil, {  RightLabel = "~b~Placer ~s~→" }, true, function(Hovered, Active, Selected)
                            if Selected then
                                local MyCoords = GetEntityCoords(PlayerPedId())
    
                                GangData.Garage = vector3(MyCoords.x, MyCoords.y, MyCoords.z -1)
    
                                ESX.ShowNotification("Position Enregistré !")
                            end
                        end)
    
                        RageUI.ButtonWithStyle("Point Boss", nil, { RightLabel = "~b~Placer ~s~→" }, true, function(Hovered, Active, Selected)
                            if Selected then
                                local MyCoords = GetEntityCoords(PlayerPedId())
    
                                GangData.Boss = vector3(MyCoords.x, MyCoords.y, MyCoords.z -1)
    
                                ESX.ShowNotification("Position Enregistré !")
                            end
                        end)
    
                        RageUI.ButtonWithStyle("Point Coffre", nil, {  RightLabel = "~b~Placer ~s~→" }, true, function(Hovered, Active, Selected)
                            if Selected then
                                local MyCoords = GetEntityCoords(PlayerPedId())
    
                                GangData.Coffre = vector3(MyCoords.x, MyCoords.y, MyCoords.z -1)
    
                                ESX.ShowNotification("Position Enregistré !")
                            end
                        end)
    
                        RageUI.ButtonWithStyle("Point Spawn Véhicules", nil, {  RightLabel = "~b~Placer ~s~→" }, true, function(Hovered, Active, Selected)
                            if Selected then
                                local MyCoords = GetEntityCoords(PlayerPedId())
    
                                GangData.SpawnVeh = vector3(MyCoords.x, MyCoords.y, MyCoords.z -1)
    
                                ESX.ShowNotification("Position Enregistré !")
                            end
                        end)
    
                        RageUI.ButtonWithStyle("Point Rotation Véhicule", nil, { RightLabel = "~b~Placer ~s~→" }, true, function(Hovered, Active, Selected)
                            if Selected then
                                local MyHeading = GetEntityHeading(PlayerPedId())
    
                                GangData.HeadingVeh = MyHeading
    
                                ESX.ShowNotification("Position Enregistré !")
                            end
                        end)
    
                        RageUI.ButtonWithStyle("Point Rangement Véhicules", nil, {  RightLabel = "~b~Placer ~s~→" }, true, function(Hovered, Active, Selected)
                            if Selected then
                                local MyCoords = GetEntityCoords(PlayerPedId())
    
                                GangData.RangeVeh = vector3(MyCoords.x, MyCoords.y, MyCoords.z -1)
    
                                ESX.ShowNotification("Position Enregistré !")
                            end
                        end)

                    elseif Categorie == "Confirmation" then

                        RageUI.ButtonWithStyle("Confirmer", nil, { RightLabel = "→→→", Color = { BackgroundColor = RageUI.ItemsColour.GreenDark, HightLightColor = RageUI.ItemsColour.GreenDark } }, true, function(Hovered, Active, Selected)
                            if Selected then

                                if GangData.Name == nil then
                                    ESX.ShowNotification('Aucun nom !')
                                    return
                                end
                    
                                if GangData.Label == nil then
                                    ESX.ShowNotification('Aucun label !')
                                    return
                                end

                                if not next(GangData.Blips) then
                                    ESX.ShowNotification('Aucun blips !')
                                    return
                                end

                                if not next(GangData.Grades) then
                                    ESX.ShowNotification('Aucun grades !')
                                    return
                                end
                    
                                if GangData.Vestiaire == nil then
                                    ESX.ShowNotification('Aucun vestiaire !')
                                    return
                                end
                    
                                if GangData.Garage == nil then
                                    ESX.ShowNotification('Aucune garage !')
                                    return
                                end
                    
                                if GangData.Coffre == nil then
                                    ESX.ShowNotification('Aucun coffre !')
                                    return
                                end
                    
                                if GangData.Boss == nil then
                                    ESX.ShowNotification('Aucun point pour le menu boss !')
                                    return
                                end

                                if GangData.SpawnVeh == nil then
                                    ESX.ShowNotification('Aucune point spawn du véhicule !')
                                    return
                                end
                    
                                if GangData.HeadingVeh == nil then
                                    ESX.ShowNotification('Aucune rotation du véhicule !')
                                    return
                                end
                    
                                if GangData.RangeVeh == nil then
                                    ESX.ShowNotification('Aucun point de rangement véhicule !')
                                    return
                                end
                    
                                RageUI.CloseAll()
                                TriggerServerEvent("hGangsBuilder:AddGang", GangData)
                            end
                        end)

                    end

                end)

                RageUI.IsVisible(CreationGrades, true,true,true, function()

                    RageUI.ButtonWithStyle("Nom du Grade", nil, { RightLabel = NomGrade }, true, function(Hovered, Active, Selected)
                        if Selected then
                            local Nom = KeyboardOutput("Nom du Grade", "", 25)
                                
                            if tostring(Nom) then
                                NomGrade = tostring(Nom)
                            else
                                ESX.ShowNotification("~r~Nom Invalide !")
                            end
                        end
                    end)

                    RageUI.ButtonWithStyle("Label du Grade", nil, { RightLabel = LabelGrade }, true, function(Hovered, Active, Selected)
                        if Selected then
                            local Label = KeyboardOutput("Label du Grade", "", 25)
                                
                            if tostring(Label) then
                                LabelGrade = tostring(Label)
                            else
                                ESX.ShowNotification("~r~Label Invalide !")
                            end
                        end
                    end)

                    RageUI.ButtonWithStyle("Salaire", nil, { RightLabel = SalaireGrade }, true, function(Hovered, Active, Selected)
                        if Selected then
                            local Salaire = KeyboardOutput("Salaire", "", 25)
                                
                            if tonumber(Salaire) then
                                SalaireGrade = tonumber(Salaire)
                            else
                                ESX.ShowNotification("~r~Salaire Invalide !")
                            end
                        end
                    end)

                    if NomGrade ~= "Aucun" and LabelGrade ~= "Aucun" and SalaireGrade ~= "Aucun" and NomGrade ~= "" and LabelGrade ~= "" and SalaireGrade ~= "" then
                        RageUI.ButtonWithStyle("Valider", nil, { RightLabel = "→→→", Color = { BackgroundColor = RageUI.ItemsColour.GreenDark, HightLightColor = RageUI.ItemsColour.GreenDark } }, true, function(Hovered, Active, Selected)
                            if Selected then
                                table.insert(GangData.Grades, {
                                    name = NomGrade, 
                                    label = LabelGrade, 
                                    salaire = SalaireGrade
                                })
                                RageUI.GoBack()
                            end
                        end)
                    else
                        RageUI.ButtonWithStyle("Valider", nil, { RightBadge = RageUI.BadgeStyle.Lock, Color = { BackgroundColor = RageUI.ItemsColour.GreenDark, HightLightColor = RageUI.ItemsColour.GreenDark } }, true, function(Hovered, Active, Selected)
                        end)
                    end

                end)
            end
        end)
    end
end

RegisterNetEvent("hGangsBuilder:OpenMenu")
AddEventHandler("hGangsBuilder:OpenMenu", function()
    OpenBuilder()
end)