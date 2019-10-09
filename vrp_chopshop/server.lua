local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_chopshop")


local awards = {
    cogcabrio = 10000,
    exemplar = 5000,
    felon = 15000,
    ninef = 20000,
    ninef2 = 25000,
    bullet = 30000,
}

RegisterNetEvent('chopshop:award')
AddEventHandler('chopshop:award',function(model)
    local user_id = vRP.getUserId({source})
    vRP.giveMoney({user_id,awards[model]})
    vRPclient.notify(source,{"Ved at levere denne bil til chopshoppen fik du "..awards[model].." kr."})
end)