--------------------------------------
-- INITIALIZE
--------------------------------------
--------------------------------------
-- DB INIT
--------------------------------------
local DB_DEFAULT = {
    char = {
        ADDON_VERSION = GetAddOnMetadata("SKC", "Version"),
        GLP = nil,
    },
};
--------------------------------------
-- ADDON INIT
--------------------------------------
function SKC:OnInitialize()
    -- Initialize saved database
	self.db = LibStub("AceDB-3.0"):New("SKC_DB",DB_DEFAULT);
	self:Print("test")
	-- Register slash commands
	self:RegisterChatCommand("rl",ReloadUI);
	self:RegisterChatCommand("skc","SlashHandler");
	-- Register comms
	self:RegisterComm(LOGIN_SYNC_CHECK,self.LoginSyncCheckRead);
	-- LOGIN_SYNC_PUSH = "6-F?832qBmrJE?pR",
	-- LOGIN_SYNC_PUSH_RQST = "d$8B=qB4VsW&&Y^D",
	-- SYNC_PUSH = "8EtTWxyA$r6xi3=F",
	-- LOOT = "xBPE9,-Fjsc+A#rm",
	-- LOOT_DECISION = "ksg(Ak2.*/@&+`8Q",
	-- LOOT_DECISION_PRINT = "xP@&!9hQxY]1K&C4",
	-- LOOT_OUTCOME = "aP@yX9hQf}89K&C4",
	-- for _,channel in pairs(CHANNELS) do
	-- 	self:RegisterComm(channel,self.AddonMessageRead);
	-- 	-- TODO, need to make specific callback to read each channel....
	-- end
	return;
end

local function OnAddonLoad(addon_name)
	if addon_name ~= "SKC" then return end
	InitGuildSync = false; -- only initialize if hard reset or new install
	-- Initialize DBs
	if SKC_DB == nil or HARD_DB_RESET then
		HardReset();
		if HARD_DB_RESET then 
			SKC_Main:Print("IMPORTANT","Hard Reset: Manual");
		end
		SKC_Main:Print("IMPORTANT","Welcome (/skc help)");
	else
		SKC_Main:Print("IMPORTANT","Welcome back (/skc)");
	end
	-- if SKC_DB.AddonVersion == nil or SKC_DB.AddonVersion ~= ADDON_VERSION then
	-- 	-- addon version never set
	-- 	HardReset();
	-- 	SKC_Main:Print("IMPORTANT","Hard Reset: New addon version "..SKC_DB.AddonVersion);
	-- end
	if SKC_DB.GLP == nil then
		SKC_DB.GLP = nil;
	end
	if SKC_DB.LOP == nil then
		SKC_DB.LOP = nil;
	end
	if SKC_DB.GuildData == nil then
		SKC_DB.GuildData = nil;
	end
	if SKC_DB.MSK == nil then 
		SKC_DB.MSK = nil;
	end
	if SKC_DB.TSK == nil then 
		SKC_DB.TSK = nil;
	end
	if SKC_DB.RaidLog == nil then
		SKC_DB.RaidLog = {};
	end
	if SKC_DB.LootManager == nil then
		SKC_DB.LootManager = nil
	end
	if SKC_DB.FilterStates == nil then
		SKC_DB.FilterStates = {
			DPS = true,
			Healer = true,
			Tank = true,
			Live = false,
			Main = true,
			Alt = true,
			Active = true,
			Inactive = false,
			Druid = true,
			Hunter = true,
			Mage = true,
			Paladin = UnitFactionGroup("player") == "Alliance",
			Priest = true;
			Rogue = true,
			Shaman = UnitFactionGroup("player") == "Horde",
			Warlock = true,
			Warrior = true,
		};
	end
	-- always reset live filter state because its confusing to see a blank list
	SKC_DB.FilterStates.Live = false;
	-- Initialize or refresh metatables
	SKC_DB.GLP = GuildLeaderProtected:new(SKC_DB.GLP);
	SKC_DB.LOP = LootOfficerProtected:new(SKC_DB.LOP);
	SKC_DB.GuildData = GuildData:new(SKC_DB.GuildData);
	SKC_DB.MSK = SK_List:new(SKC_DB.MSK);
	SKC_DB.TSK = SK_List:new(SKC_DB.TSK);
	SKC_DB.LootManager = LootManager:new(SKC_DB.LootManager);
	-- Addon loaded
	event_states.AddonLoaded = true;
	-- Manage loot logging
	ManageLootLogging();
	-- Update live list
	UpdateLiveList();
	-- Populate data
	SKC_Main:PopulateData();
	return;
end

local function SyncGuildData()
	-- synchronize GuildData with guild roster
	if not CheckAddonLoaded(COMM_VERBOSE) then
		if COMM_VERBOSE then SKC_Main:Print("WARN","Reject SyncGuildData()") end
		return;
	end
	if event_states.ReadInProgress.GuildData or event_states.PushInProgress.GuildData then
		if GUILD_SYNC_VERBOSE then SKC_Main:Print("ERROR","Rejected SyncGuildData, sync in progress") end
		return;
	end
	if not IsInGuild() then
		if GUILD_SYNC_VERBOSE then SKC_Main:Print("ERROR","Rejected SyncGuildData, not in guild") end
		return;
	end
	if not CheckIfAnyGuildMemberOnline() then
		if GUILD_SYNC_VERBOSE then SKC_Main:Print("ERROR","Rejected SyncGuildData, no online guild members") end
		return;
	end
	if GetNumGuildMembers() <= 1 then
		-- guild is only one person, no members to fetch data for
		if GUILD_SYNC_VERBOSE then SKC_Main:Print("ERROR","Rejected SyncGuildData, no guild members") end
		return;
	end
	if not SKC_Main:isGL() then
		-- only fetch data if guild leader
		if GUILD_SYNC_VERBOSE then SKC_Main:Print("WARN","Rejected SyncGuildData, not guild leader") end
	else
		-- Scan guild roster and add new players
		local guild_roster = {};
		for idx = 1, GetNumGuildMembers() do
			local full_name, _, _, level, class = GetGuildRosterInfo(idx);
			local name = StripRealmName(full_name);
			if level == 60 or CHARS_OVRD[name] then
				guild_roster[name] = true;
				if not SKC_DB.GuildData:Exists(name) then
					-- new player, add to DB and SK lists
					SKC_DB.GuildData:Add(name,class);
					SKC_DB.MSK:PushBack(name);
					SKC_DB.TSK:PushBack(name);
					if not InitGuildSync then SKC_Main:Print("NORMAL",name.." added to databases") end
				end
				-- check activity level and update
				UpdateActivity(name);
			end
		end
		-- Scan guild data and remove players
		for name,data in pairs(SKC_DB.GuildData.data) do
			if guild_roster[name] == nil then
				SKC_DB.MSK:Remove(name);
				SKC_DB.TSK:Remove(name);
				SKC_DB.GuildData:Remove(name);
				if not InitGuildSync then SKC_Main:Print("ERROR",name.." removed from databases") end
			end
		end
		-- miscellaneous
		UnFilteredCnt = SKC_DB.GuildData:length();
		if InitGuildSync and (SKC_DB.GuildData:length() ~= 0) then
			-- init sync completed
			SKC_Main:Print("WARN","Populated fresh GuildData ("..SKC_DB.GuildData:length()..")");
			if COMM_VERBOSE then SKC_Main:Print("NORMAL","Generic TS: "..SKC_DB.GuildData.edit_ts_generic..", Raid TS: "..SKC_DB.GuildData.edit_ts_raid) end
			-- add self (GL) to loot officers
			SKC_DB.GLP:AddLO(UnitName("player"));
			InitGuildSync = false;
		end
		-- set required version to current version
		SKC_DB.GLP:SetAddonVer(SKC_DB.AddonVersion);
		if GUILD_SYNC_VERBOSE then SKC_Main:Print("NORMAL","SyncGuildData success!") end
	end
	-- sync with guild
	if event_states.LoginSyncCheckTicker == nil then
		C_Timer.After(event_states.LoginSyncCheckTicker_InitDelay,StartSyncCheckTimer);
	end
	return;
end




-- -- WARNING: self automatically becomes events frame!
-- function core:init(event, name)
--     if (name ~= "SKC") then return end 

--     -- allows using left and right buttons to move through chat 'edit' box
--     for i = 1, NUM_CHAT_WINDOWS do
--         _G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false);
--     end
    
--     ----------------------------------
--     -- Register Slash Commands!
--     ----------------------------------
--     SLASH_RELOADUI1 = "/rl"; -- new slash command for reloading UI
--     SlashCmdList.RELOADUI = ReloadUI;

--     SLASH_FRAMESTK1 = "/fs"; -- new slash command for showing framestack tool
--     SlashCmdList.FRAMESTK = function()
--         LoadAddOn("Blizzard_DebugTools");
--         FrameStackTooltip_Toggle(false);
--     end

--     SLASH_SKC1 = "/skc";
--     SlashCmdList.SKC = HandleSlashCommands;
-- end

-- local events = CreateFrame("Frame");
-- events:RegisterEvent("ADDON_LOADED");
-- events:SetScript("OnEvent", core.init);

--------------------------------------
-- EVENTS
--------------------------------------
local function EventHandler(self,event,...)
	-- if event == "CHAT_MSG_ADDON" then
	-- 	AddonMessageRead(...);
	-- else
	if event == "ADDON_LOADED" then
		OnAddonLoad(...);
	elseif event == "GUILD_ROSTER_UPDATE" then
		-- Sync GuildData (if GL) and create ticker to send sync requests
		SyncGuildData();
	elseif event == "GROUP_ROSTER_UPDATE" or event == "PARTY_LOOT_METHOD_CHANGED" then
		ManageLootLogging();
		UpdateLiveList();
		UpdateDetailsButtons();
	elseif event == "OPEN_MASTER_LOOT_LIST" then
		SaveLoot();
	elseif event == "PLAYER_ENTERING_WORLD" then
		if COMM_VERBOSE then SKC_Main:Print("NORMAL","Firing PLAYER_ENTERING_WORLD") end
		ManageLootLogging();
	end
	
	return;
end

local events = CreateFrame("Frame");
-- events:RegisterEvent("CHAT_MSG_ADDON");
events:RegisterEvent("ADDON_LOADED");
events:RegisterEvent("GUILD_ROSTER_UPDATE");
events:RegisterEvent("GROUP_ROSTER_UPDATE");
events:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
events:RegisterEvent("OPEN_MASTER_LOOT_LIST");
events:RegisterEvent("PLAYER_ENTERING_WORLD");
events:SetScript("OnEvent", EventHandler);