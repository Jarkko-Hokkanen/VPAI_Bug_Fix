local VanillaPocketItemsMod = RegisterMod("Vanilla Pocket Active Items Mod", 1)


local VANILLA_CHARACTERS_WITH_ACTIVE_ITEMS = {
    [PlayerType.PLAYER_ISAAC] = true,
    [PlayerType.PLAYER_JUDAS] = true,
    [PlayerType.PLAYER_MAGDALENA] = true,
    [PlayerType.PLAYER_BLUEBABY] = true,
    [PlayerType.PLAYER_EVE] = true,
    [PlayerType.PLAYER_EDEN] = true,
    [PlayerType.PLAYER_THELOST] = true,
    [PlayerType.PLAYER_LILITH] = true,
    [PlayerType.PLAYER_KEEPER] = true,
    [PlayerType.PLAYER_APOLLYON] = true
}


local continue = false
local function IsContinue()
    local totPlayers = #Isaac.FindByType(EntityType.ENTITY_PLAYER)

    if totPlayers == 0 then
        if Game():GetFrameCount() == 0 then
            continue = false
        else
            local room = Game():GetRoom()
            local desc = Game():GetLevel():GetCurrentRoomDesc()

            if desc.SafeGridIndex == GridRooms.ROOM_GENESIS_IDX then
                if not room:IsFirstVisit() then
                    continue = true
                else
                    continue = false
                end
            else
                continue = true
            end
        end
    end

    return continue
end


---@type EntityPlayer[]
local playersToRemoveItems = {}


---@param player EntityPlayer
function VanillaPocketItemsMod:OnPlayerInit(player)
    if IsContinue() then return end

    local playerType = player:GetPlayerType()

    if VANILLA_CHARACTERS_WITH_ACTIVE_ITEMS[playerType] then
        playersToRemoveItems[#playersToRemoveItems+1] = player
    end
end
VanillaPocketItemsMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, VanillaPocketItemsMod.OnPlayerInit)

function VanillaPocketItemsMod:OnRender()
    for _, player in ipairs(playersToRemoveItems) do
        local activeItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
		local pocketBlacklist = (player:HasCollectible(585) or player:HasCollectible(622) or player:HasCollectible(628) or player:HasCollectible(636) 
		or player:HasCollectible(127) or player:HasCollectible(297) or player:HasCollectible(347) or player:HasCollectible(577) or player:HasCollectible(475) 
		or player:HasCollectible(483) or player:HasCollectible(490) or player:HasCollectible(515) or player:HasCollectible(536) or player:HasCollectible(638) 
		or player:HasCollectible(382) or player:HasCollectible(489) or player:HasCollectible(286) or player:HasCollectible(348) or player:HasCollectible(263) 
		or player:HasCollectible(290))

        if activeItem ~= 0 and player:HasCollectible(CollectibleType.COLLECTIBLE_ESAU_JR) ~= true and player:GetActiveMaxCharge(0) < 30 and pocketBlacklist ~= true then
            player:RemoveCollectible(activeItem, false, ActiveSlot.SLOT_PRIMARY)
            player:SetPocketActiveItem(activeItem, ActiveSlot.SLOT_POCKET)
            player:FullCharge(ActiveSlot.SLOT_POCKET)
        end
    end

    playersToRemoveItems = {}
end
VanillaPocketItemsMod:AddCallback(ModCallbacks.MC_POST_RENDER, VanillaPocketItemsMod.OnRender)


---@param player EntityPlayer
function VanillaPocketItemsMod:OnPeffectUpdate(player)
    local playerType = player:GetPlayerType()
    local activeItem = player:GetActiveItem(ActiveSlot.SLOT_POCKET)

    if playerType ~= PlayerType.PLAYER_JUDAS then return end
    if activeItem ~= CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then return end

    player:RemoveCollectible(activeItem, false, ActiveSlot.SLOT_POCKET)
end
VanillaPocketItemsMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, VanillaPocketItemsMod.OnPeffectUpdate)