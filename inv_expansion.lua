function CheckInventoryExpansion()
	local expansionItemIds = { 5507, 6507, 9007 }
	local used = false
	AutoExpansionToggle(false)
	for _, itemId in ipairs(expansionItemIds) do
		if GetItemQuantity(itemId) > 0 and IsInMap() then
			AutoExpansionToggle(true)
			AutoExpansionSetExpansionID(itemId)
			used = true
			Sleep(1)
		end
	end
	return used
end

function CheckWarehouseExpansion()
	local expansionItemIds = { 5508, 6508, 9008 }
	local used = false
	AutoExpansionToggle(false)
	for _, itemId in ipairs(expansionItemIds) do
		if GetItemQuantity(itemId) > 0 and IsInMap() then
			AutoExpansionToggle(true)
			AutoExpansionSetExpansionID(itemId)
			used = true
			Sleep(1)
		end
	end
	return used
end

function CheckArchiveExpansion()
	local expansionItemIds = { 5004, 6004, 9006, 9413, 10250, 10251 }
	local used = false
	AutoExpansionToggle(false)
	for _, itemId in ipairs(expansionItemIds) do
		if GetItemQuantity(itemId) > 0 and IsInMap() then
			AutoExpansionToggle(true)
			AutoExpansionSetExpansionID(itemId)
			Sleep(1)
			used = true
		end
	end
	return used
end

function OpenLevelBox()
	local tamer = GetTamer()
	local level = tamer:Level()
	local used = false
	local boxes = {
		{70051, 1}, 
		{70052, 2}, 
		{70053, 3}, 
		{70054, 4}, 
		{70055, 5},
		{70056, 6}, 
		{70057, 7}, 
		{70058, 8}, 
		{70059, 9}, 
		{70060, 10},
		{70061, 11}, 
		{70062, 12}, 
		{70063, 13},
		{70064, 14}, 
		{70065, 15},
		{70066, 16},
		{70067, 17}, 
		{70068, 18}, 
		{70069, 19},
		{70070, 20},
		{70071, 21}, 
		{70072, 22}, 
		{70073, 23}, 
		{70074, 24}, 
		{70075, 25},
		{70076, 26}, 
		{70077, 27}, 
		{70078, 28}, 
		{70079, 29}, 
		{70080, 30},
		{70081, 31}, 
		{70082, 32}, 
		{70083, 33}, 
		{70084, 34}, 
		{70085, 35},
		{70086, 36}, 
		{70087, 37}, 
		{70088, 38}, 
		{70089, 39}, 
		{70090, 40},
		{70091, 45}, 
		{70092, 50}, 
		{70093, 55}, 
		{70094, 60},
		{70095, 70},
		{70096, 80}, 
		{70097, 90}, 
		{70098, 99}
	}
	for _, box in ipairs(boxes) do
		local itemId, requiredLevel = box[1], box[2]
		if CheckLevelAndOpen(level, itemId, requiredLevel) then
			used = true
		end
	end
	AutoBoxToggle(false)
	return used
end

function CheckLevelAndOpen(CurrentLevel, ItemId, RequiredLevel)
	if CurrentLevel >= RequiredLevel and GetItemQuantity(ItemId) > 0 and IsInMap() then
		AutoBoxToggle(true)
		AutoBoxSetBoxID(ItemId)
		Sleep(1)
		return true
	end
	return false
end



function main()
	while ScriptRun() do
        if IsInMap() then
			local tamer = GetTamer()
			local level = tamer:Level()
			if level >= 10 then
				if OpenLevelBox() then
					log("LevelUp GiftBox used.")
				end
				if CheckWarehouseExpansion() then
					log("Warehouse expansion items used.")
				end
				if CheckInventoryExpansion() then
					log("Inventory expansion items used.")
				end
				if CheckArchiveExpansion() then
					log("Archive expansion items used.")
				end
			else
				log("Tamer level is below 10. Stopping script.")
				ScriptStop()
				break
			end
        else
            ShowLogOnScreen("waiting game window")
        end
	end
end

main()