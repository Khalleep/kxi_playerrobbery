ESX = exports["es_extended"]:getSharedObject()

exports.ox_target:addGlobalPlayer({
    name = 'robPlayer',
    icon = 'fa-solid fa-gun',
    label = 'Rob Player',
    canInteract = function(entity)
        local playerData = ESX.GetPlayerData()
        if playerData.job.name == "police" then
            return false
        end
        
        local weapon = GetSelectedPedWeapon(PlayerPedId())
        if weapon == GetHashKey("WEAPON_UNARMED") then
            return false
        end

        return not IsEntityDead(entity)
    end,
    onSelect = function(data)
        startPlayerRobbery(data.entity)
    end,
})

function startPlayerRobbery(closestPlayerPed)
    local doesPlayerHaveHandsUp = IsEntityPlayingAnim(closestPlayerPed, 'missminuteman_1ig_2', 'handsup_enter', 3)
    if not doesPlayerHaveHandsUp then
        lib.notify({
            title = 'Action Failed',
            description = 'The person does not have their hands up!',
            type = 'error'
        })
        return false
    end

    local progressSuccess = exports.bl_ui:Progress(3, 50)
    if not progressSuccess then
        lib.notify({
            title = 'Action Failed',
            description = 'Try harder!',
            type = 'error'
        })
        return false
    end

    ExecuteCommand('me Robbing the person')
    local success = lib.progressBar({
        duration = 9200,
        label = 'Robbing the person',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
        },
        anim = {
            dict = 'amb@world_human_stand_fire@male@idle_a',
            clip = 'idle_a'
        },
    })
    if success then
        exports.tk_dispatch:addCall({
            title = 'Dispatch: Robbery - Person Targeted',
            code = '021A',
            priority = '021A',
            coords = GetEntityCoords(PlayerPedId()),
            showLocation = true,
            showGender = true,
            playSound = true,
            blip = {
                color = 3,
                sprite = 110,
                scale = 1.0,
            },
            jobs = {'police'}
        })
        exports.ox_inventory:openNearbyInventory()
    else
        lib.notify({
            title = 'Action Failed',
            description = 'You canceled the robbery!',
            type = 'error'
        })
    end
end