--[[
	deathdrop
		by David-AW
			(Updated for TES3MP 0.8 by Learwolf)
			(Edited to remove bound items by Allaboutrandom)
	
	INSTALLATION:
		
		1) Drop this script (deathdrop.lua) into your `\server\scripts\custom` folder.
		2) Add the following text to a new line in your `customScripts.lua`:
			require("custom/deathdrop")
		3) Save `customScripts.lua` and restart the server.
		
--]]


deathdrop = {}



local function dbg(msg)	-- Helps with debugging
   tes3mp.LogMessage(enumerations.log.VERBOSE, "[ deathDrop - CKM ]: " .. msg)
end


local boundItems = {"bound_battle_axe", "bound_dagger", "bound_longbow", "bound_longsword", "bound_mace", "bound_spear", "bound_boots", "bound_cuirass", "bound_gauntlet_left", "bound_gauntlet_right", "bound_helm", "bound_shield"} -- Make a list of bound items	
local boundItemCount = 1

customEventHooks.registerValidator("OnPlayerDeath", function(eventStatus, pid) --Detect player death
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then -- Make sure the player is online
		
		local player = Players[pid] -- Get their pid
		
-- This is where my code starts, please forgive it's amateurish quality	
		for playerInventoryCount = 1, #player.data.inventory do -- For each inventory slot
			for boundItemCount = 1, #boundItems[playerInventoryCount] do -- Search each index in boundItems	
				dbg("success: playerInv " .. playerInventoryCount .. ", boundItem " .. boundItemCount) -- This tells me if the for loop is working successfully
				local boundItemCurrent = boundItems[boundItemCount] -- Make a variable which stores the refID of a boundItem at the index of the counter for the second for loop
				local boundLoc = inventoryHelper.getItemIndex(player.data.inventory, boundItemCurrent) -- Make a variable which is composed of the index of the inventory slot which contains whatever the refID of the current boundItem is
				if boundLoc then
					player.data.inventory[boundLoc] = nil --Set the inventory item at the previous variable to nil, removing it
				end			
			end
		end
-- And here is where it ends -Allaboutrandom


		local cellDescription = player.data.location.cell

			local pX = tes3mp.GetPosX(pid) -- gets player position.
			local pY = tes3mp.GetPosY(pid) + 1
			local pZ = tes3mp.GetPosZ(pid)
			local rX = tes3mp.GetRotX(pid)
			local rZ = tes3mp.GetRotZ(pid)
			
			
			for index,item in pairs(player.data.equipment) do
				tes3mp.UnequipItem(pid, index) -- creates unequipItem packet
				tes3mp.SendEquipment(pid) -- sends packet to pid
			end
			
			local temp = tableHelper.deepCopy(player.data.inventory)
			
			player.data.inventory = {} -- clear inventory data in the files
			player.data.equipment = {}
			player:LoadEquipment()
			player:LoadInventory()
			
			tes3mp.ClearInventoryChanges(pid) -- clear inventory data on the server
			tes3mp.SendInventoryChanges(pid)

			for index,item in pairs(temp) do
				
				item.location = {posX = pX, posY = pY, posZ = pZ, rotX = rX, rotY = 0, rotZ = rZ}
				
				item.count = item.count or 1
				item.charge = item.charge or -1
				item.enchantmentCharge = item.enchantmentCharge or -1
				item.soul = item.soul or ""
				
			end
			logicHandler.CreateObjects(cellDescription, temp, "place")
	end
end)

return deathdrop