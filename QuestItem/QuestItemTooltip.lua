----------------------------------------------------------
-- Add tooltip information to the existing GameTooltip
----------------------------------------------------------
----------------------------------------------------------
function QuestItem_AddTooltip(frame, name, link, quantity, count)
	QuestItem_OldTooltip(frame, name, link, quality, count);
	if(QuestItem_Settings["Enabled"] == nil or QuestItem_Settings["Enabled"] == false) then
		return;
	end
	
	local tooltip = getglobal("GameTooltip");
	local embed = true;
    if ( not tooltip ) then
		return;
    end
	
    local tooltipInfo = QuestItem_ScanTooltip("GameTooltip");
    if ( tooltipInfo[1] ) then
		
		-- Item not found in the database - look for it of it is a quest item
		if(not QuestItems[name] or QuestItem_SearchString(QuestItems[name].QuestName, QUESTITEM_UNIDENTIFIED) ) then
			-- Check if the item is a Quest Item
			if(QuestItem_IsQuestItem(tooltip) ) then
				local name = tooltipInfo[1].left;

				local QuestName, total, count, texture = QuestItem_FindQuest(name);
				if(not QuestName) then
					QuestItem_UpdateItem(name, QUESTITEM_UNIDENTIFIED, quantity, 0, 3)
				else
					QuestItem_UpdateItem(name, QuestName, quantity, total, 0)
				end
			end
		end
		-- Quest was found in the database
		if(QuestItems[name]) then
			-- There is data for the current player
			if(QuestItems[name][UnitName("player")]) then
				-- Total and Count is set, and is grater than 0 - don't want to display i.e 1/0
				if( (QuestItems[name].Total and QuestItems[name].Total > 0) and (QuestItems[name][UnitName("player")].Count and QuestItems[name][UnitName("player")].Count > 0) ) then
					TT_AddLine(QuestItems[name].QuestName .. " " .. QuestItems[name][UnitName("player")].Count .. "/" .. QuestItems[name].Total, nil, embed);
				else
					TT_AddLine(QuestItems[name].QuestName, nil, embed);
				end
				TT_LineColor(0.4, 0.5, 0.8);
				
				-- Check status for quest - if it can't be found change status to abandoned/complete
				if(QuestItems[name][UnitName("player")].QuestStatus ~= 0) then
					if(not QuestItem_FindQuest(name)) then
						QuestItems[name][UnitName("player")].QuestStatus = 1;
					end
				end
				-- Do not display status on the quest if it is unidentified
				if(not QuestItem_SearchString(QuestItems[name].QuestName, QUESTITEM_UNIDENTIFIED) ) then
					-- Display quest status
					if(QuestItems[name][UnitName("player")].QuestStatus == 0) then
						TT_AddLine(QUESTITEM_QUESTACTIVE, nil, embed);
						TT_LineColor(0, 1, 0);
					elseif(QuestItems[name][UnitName("player")].QuestStatus == 1 or QuestItems[name][UnitName("player")].QuestStatus == 2) then
						TT_AddLine(QUESTITEM_COMPLETEABANDONED, nil, embed);
						TT_LineColor(0.7, 0.7, 07);
					end
				end
			else
				TT_AddLine(QuestItems[name].QuestName, nil, embed);
				TT_LineColor(0.4, 0.5, 0.8);
			end
			TT_Show(frame);
		end
	end
end


------------------------------
-- QuestItemItemButton_OnEnter
-- Currently not in use
------------------------------
------------------------------
function QuestItemItemButton_OnEnter()
	QuestItem_Debug("QuestItemItemButton_OnEnter");
	QuestItemTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
	-- Todo: Display tooltip
	QuestItem_AddTooltipInfo(this:GetText());
end

--------------------------------------------
-- QuestItem_ContainerFrameItemButton_OnEnter
-- Currently not in use
--------------------------------------------
--------------------------------------------
function QuestItem_ContainerFrameItemButton_OnEnter()
	lOriginal_ContainerFrameItemButton_OnEnter();
	QuestItem_Debug("QuestItem_ContainerFrameItemButton_OnEnter");
	if( not InRepairMode() and not MerchantFrame:IsVisible() ) then
		local frameID = this:GetParent():GetID();
		local buttonID = this:GetID();
		local link = GetContainerItemLink(frameID, buttonID);
		local name = LootLink_NameFromLink(link);
		
		if( name and ItemLinks[name] ) then
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(frameID, buttonID);
			QuestItem_AddTooltip(frame, name, itemCount)
			GameTooltip:Show();
		end
	end
end

-------------------------
-- QuestItem_NameFromLink
-------------------------
-------------------------
function QuestItem_NameFromLink(link)
	local name;
	if( not link ) then
		return nil;
	end
	for name in string.gfind(link, "|c%x+|Hitem:%d+:%d+:%d+:%d+|h%[(.-)%]|h|r") do
		return name;
	end
	return nil;
end
