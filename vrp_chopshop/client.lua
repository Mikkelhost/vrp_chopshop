vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "vrp_chopshop")

local chopshops = {
    {blipid=380, color=17, x=485.67654418945, y=-1306.5758056641, z=28.287578582764}
}
local vehicles = {
    {model="cogcabrio", name="Enus Cognoscenti Cabrio"},
    {model="exemplar", name="Dewbauchee Exemplar"},
    {model="felon", name="Lampadati Felon"},
    {model="ninef", name="Obey 9F"},
    {model="ninef2", name="Obey 9F Cabrio"},
    {model="bullet", name="bullet"},
}
local inJob = false
local timeout = false
local timeoutTime = 600000
local timeTillAvailable = 0

math.randomseed(GetGameTimer());

function ply_drawTxt(text,font,centre,x,y,scale,r,g,b,a)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(centre)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x , y)
end

function generateVehicle()
    local index = math.random(1,3)
    return vehicles[index].model
end

local vehToChop = nil
local index = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k, shop in pairs(chopshops) do
            DrawMarker(1, shop.x, shop.y, shop.z, 0, 0, 0, 0, 0, 0, 3.001, 3.0001, 0.7001, 0, 0, 225, 155, 0, 0, 0, 0)
            if GetDistanceBetweenCoords(shop.x, shop.y, shop.z, GetEntityCoords(GetPlayerPed(-1))) < 3 and inJob == false and timeout == false then -- Chopsoppen mangler biler
                ply_drawTxt("Tryk [~g~E~w~] for at få info om en levering",0,1,0.5,0.8,0.6,255,255,255,255)
                if IsControlJustPressed(0,38) then
                    print(#vehicles)
                    index = math.random(#vehicles)
                    inJob = true
                    vehToChop = vehicles[index].model
                    vRP.notify({"Du skal finde en "..vehicles[index].name})
                    print(inJob)
                end
            elseif GetDistanceBetweenCoords(shop.x, shop.y, shop.z, GetEntityCoords(GetPlayerPed(-1))) < 3 and inJob == true and IsPedInAnyVehicle(GetPlayerPed(-1),true) and timeout == false then
                local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                if IsVehicleModel(vehicle, GetHashKey(vehToChop)) then
                    ply_drawTxt("Tryk [~g~E~w~] for at aflevere bilen og modtag din belønning",0,1,0.5,0.8,0.6,255,255,255,255)
                    if IsControlJustPressed(0,38) then
                        SetEntityAsMissionEntity(vehicle,true,true)
                        DeleteVehicle(vehicle)
                        inJob = false
                        timeout = true
                        vehToChop = nil
                        timeTillAvailable = GetGameTimer()
                        TriggerServerEvent('chopshop:award',vehicles[index].model)
                        print(inJob)
                    end
                else
                    ply_drawTxt("Det er ikke den rigtige bil, find en "..vehicles[index].name,0,1,0.5,0.8,0.6,255,255,255,255)
                end
            elseif GetDistanceBetweenCoords(shop.x, shop.y, shop.z, GetEntityCoords(GetPlayerPed(-1))) < 3 and timeout then
                --ply_drawTxt("Du er kan ikke tage et nyt job før om "..tostring(math.ceil((timeTillAvailable/1000+timeoutTime/1000)-(GetGameTimer()/1000))).." sekunder",0,1,0.5,0.8,0.6,255,255,255,255) DEBUG
                ply_drawTxt("Chopshoppen mangler ikke nogle leveringer lige nu. Kom tilbage senere.",0,1,0.5,0.8,0.6,255,255,255,255)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if inJob then
            ply_drawTxt("Chopshop anmodning:",0,1,0.06,0.5,0.3,255,255,255,255)
            ply_drawTxt(vehicles[index].name,0,1,0.06,0.517,0.3,255,255,255,255)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if timeout == true then
            if GetGameTimer() > timeTillAvailable + timeoutTime then
                timeout = false
            end
        end
    end
end)
