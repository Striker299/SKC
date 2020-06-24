--------------------------------------
-- NAMESPACES
--------------------------------------
local _, core = ...; -- returns name of addon and namespace (core)
core.SKC_Main = {}; -- adds SKC_Main table to addon namespace

local SKC_Main = core.SKC_Main; -- assignment by reference in lua, ugh
local SKC_UIMain;
--------------------------------------
-- LOCAL CONSTANTS
--------------------------------------
local UI_DIMENSIONS = { -- ui dimensions
	MAIN_WIDTH = 840,
	MAIN_HEIGHT = 450,
	SK_TAB_TOP_OFFST = -60,
	SK_TAB_TITLE_CARD_WIDTH = 80,
	SK_TAB_TITLE_CARD_HEIGHT = 40,
	SK_FILTER_WIDTH = 270,
	SK_FILTER_HEIGHT = 155,
	DECISION_WIDTH = 270,
	DECISION_HEIGHT = 180,
	SK_DETAILS_WIDTH = 270,
	SK_DETAILS_HEIGHT = 355,
	ITEM_WIDTH = 40,
	ITEM_HEIGHT = 40,
	SK_LIST_WIDTH = 175,
	SK_LIST_HEIGHT = 325,
	SK_LIST_BORDER_OFFST = 15,
	SK_CARD_SPACING = 6,
	SK_CARD_WIDTH = 100,
	SK_CARD_HEIGHT = 20,
};

local THEME = { -- general color themes
	PRINT = {
		NORMAL = {r = 0, g = 0.8, b = 1, hex = "00ccff"},
		WARN = {r = 1, g = 0.8, b = 0, hex = "ffcc00"},
		ERROR = {r = 1, g = 0.2, b = 0, hex = "ff3300"},
		IMPORTANT = {r = 1, g = 0, b = 1, hex = "ff00ff"},
	},
	STATUS_BAR_COLOR = {0.0,0.6,0.0},
};

local OnClick_EditDropDownOption; -- forward declare for drop down menu details
local CLASSES = { -- wow classes
	Druid = {
		text = "Druid",
		color = {
			r = 1.0,
			g = 0.49,
			b = 0.04,
			hex = "FF7D0A"
		},
		Specs = {
			Balance = {
				text = "Balance",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Balance") end,
			},
			Resto = {
				text = "Resto",
				RR = "Healer",
				func = function (self) OnClick_EditDropDownOption("Spec","Resto") end
			},
			FeralTank = {
				text = "FeralTank",
				RR = "Tank",
				func = function (self) OnClick_EditDropDownOption("Spec","FeralTank") end
			},
			FeralDPS = {
				text = "FeralDPS",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","FeralDPS") end
			},
		},
		DEFAULT_SPEC = "Resto",
	},
	Hunter = {
		text = "",
		color = {
			r = 0.67, 
			g = 0.83,
			b = 0.45,
			hex = "ABD473"
		},
		Specs = {
			Any = {
				text = "Any",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Any") end
			},
		},
		DEFAULT_SPEC = "Any",
	},
	Mage = {
		text = "",
		color = {
			r = 0.41, 
			g = 0.80,
			b = 0.94,
			hex = "69CCF0"
		},
		Specs = {
			Any = {
				text = "Any",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Any") end
			},
		},
		DEFAULT_SPEC = "Any",
	},
	Paladin = {
		text = "",
		color = {
			r = 0.96, 
			g = 0.55,
			b = 0.73,
			hex = "F58CBA"
		},
		Specs = {
			Holy = {
				text = "Holy",
				RR = "Healer",
				func = function (self) OnClick_EditDropDownOption("Spec","Holy") end
			},
			Prot = {
				text = "Prot",
				RR = "Tank",
				func = function (self) OnClick_EditDropDownOption("Spec","Prot") end
			},
			Ret = {
				text = "Ret",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Ret") end
			},
		},
		DEFAULT_SPEC = "Holy",
	},
	Priest = {
		text = "",
		color = {
			r = 1.00, 
			g = 1.00,
			b = 1.00,
			hex = "FFFFFF"
		},
		Specs = {
			Holy = {
				text = "Holy",
				RR = "Healer",
				func = function (self) OnClick_EditDropDownOption("Spec","Holy") end
			},
			Shadow = {
				text = "Shadow",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Shadow") end
			},
		},
		DEFAULT_SPEC = "Holy",
	},
	Rogue = {
		text = "",
		color = {
			r = 1.00, 
			g = 0.96,
			b = 0.41,
			hex = "FFF569"
		},
		Specs = {
			Any = {
				text = "Any",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Any") end
			},
			Daggers = {
				text = "Daggers",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Daggers") end
			},
			Swords = {
				text = "Swords",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Swords") end
			},
		},
		DEFAULT_SPEC = "Any",
	},
	Shaman = {
		text = "",
		color = {
			r = 0.96, 
			g = 0.55,
			b = 0.73,
			hex = "F58CBA"
		},
		Specs = {
			Ele = {
				text = "Ele",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Ele") end
			},
			Enh = {
				text = "Enh",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Enh") end
			},
			Resto = {
				text = "Resto",
				RR = "Healer",
				func = function (self) OnClick_EditDropDownOption("Spec","Resto") end
			},
		},
		DEFAULT_SPEC = "Resto",
	},
	Warlock = {
		text = "",
		color = {
			r = 0.58, 
			g = 0.51,
			b = 0.79,
			hex = "9482C9"
		},
		Specs = {
			Any = {
				text = "Any",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Any") end
			},
		},
		DEFAULT_SPEC = "Any",
	},
	Warrior = {
		text = "",
		color = {
			r = 0.78, 
			g = 0.61,
			b = 0.43,
			hex = "C79C6E"
		},
		Specs = {
			DPS = {
				text = "DPS",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","DPS") end
			},
			Prot = {
				text = "Prot",
				RR = "Tank",
				func = function (self) OnClick_EditDropDownOption("Spec","Prot") end
			},
			TwoHanded = {
				text = "TwoHanded",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","TwoHanded") end
			},
			DualWield = {
				text = "DualWield",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","DualWield") end
			},
		},
		DEFAULT_SPEC = "DPS",
	},
};

local CHARACTER_DATA = { -- fields used to define character
	Name = {
		text = "Name",
		OPTIONS = {},
	},
	Class = {
		text = "Class",
		OPTIONS = {},
	},
	Spec = {
		text = "Spec",
		OPTIONS = {},
	},
	["Raid Role"] = {
		text = "Raid Role",
		OPTIONS = {
			DPS = {
				text = "DPS",
			},
			Healer = {
				text = "Healer",
			},
			Tank = {
				text = "Tank",
			},
		},
	},
	["Guild Role"] = {
		text = "Guild Role",
		OPTIONS = {
			None = {
				text = "None",
				func = function (self) OnClick_EditDropDownOption("Guild Role","None") end,
			},
			Disenchanter = {
				text = "Disenchanter",
				func = function (self) OnClick_EditDropDownOption("Guild Role","Disenchanter") end,
			},
			Banker = {
				text = "Banker",
				func = function (self) OnClick_EditDropDownOption("Guild Role","Banker") end,
			},
		},
	},
	Status = {
		text = "Status",
		OPTIONS = {
			Main = {
				text = "Main",
				func = function (self) OnClick_EditDropDownOption("Status","Main") end,
			},
			Alt = {
				text = "Alt",
				func = function (self) OnClick_EditDropDownOption("Status","Alt") end,
			},
		},
	},
	Activity = {
		text = "Activity",
		OPTIONS = {
			Active = {
				text = "Active",
				func = function (self) OnClick_EditDropDownOption("Activity","Active") end,
			},
			Inactive = {
				text = "Inactive",
				func = function (self) OnClick_EditDropDownOption("Activity","Inactive") end,
			},
		},
	},	
};

local LOOT_DECISION = {
	PASS = "PASS",
	SK = "SK",
	ROLL = "ROLL",
	MAX_TIME = 30,
	TIME_STEP = 1,
	RARITY_THRESHOLD = 2, -- threshold to initiate loot decision (2 = greens, 3 = blues)
};

local PRIO_TIERS = { -- possible prio tiers and associated numerical ordering
	SK = {
		Main = {
			P1 = 1,
			P2 = 2,
			P3 = 3,
			P4 = 4,
			P5 = 5,
			OS = 6,
		},
		Alt = {
			P1 = 7,
			P2 = 8,
			P3 = 9,
			P4 = 10,
			P5 = 11,
			OS = 12,
		},
	},
	ROLL = {
		Main = {
			MS = 13,
			OS = 14,
		},
		Alt = {
			MS = 15,
			OS = 16,
		},
	},
	PASS = 17,
};

--------------------------------------
-- SAVED / SHARED VARIABLES
--------------------------------------
SKC_Main.SYNC_CHANNEL = "&95n%nR2!&;QZJSh"; -- TODO: used for sync data (const)
SKC_Main.DISTRIBUTION_CHANNEL = "xBPE9,-Fjbc+A#rm"; -- ML sends a loot decision (const)
SKC_Main.DECISION_CHANNEL = "ksg(AkE.*/@&+`8Q"; -- ML receives a loot decision (const)
SKC_Main.LootDecision = nil; -- personal loot decision
SKC_Main.MasterLooter = nil; -- name of master looter
SKC_Main.SK_Item = nil; -- name of item currently being SK'd for
SKC_Main.SK_MessagesSent = 0;
SKC_Main.SK_MessagesReceived = 0;
SKC_Main.FilterStates = {
	SK1 = {
		DPS = true,
		Healer = true,
		Tank = true,
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
	},
};
--------------------------------------
-- LOCAL VARIABLES
--------------------------------------
local AddonLoaded = false; -- used to know if addon is loaded and saved variables available
local LootTimer = nil; -- current loot timer
local DD_State = 0; -- used to track state of drop down menu
local SetSK_Flag = false; -- true when SK position is being set
--------------------------------------
-- CLASSES
--------------------------------------
-- Prio class
Prio = {
	reserved = false, -- true if main prio over alts
	DE = true, -- true if item should be disenchanted before going to guild bank
	prio = {}, -- map of SpecClass to prio level (P1,P2,P3,P4,P5,OS)
};
Prio.__index = Prio;

function Prio:new(prio)
	if prio == nil then
		-- initalize fresh
		local obj = {};
		setmetatable(obj,Prio);
		obj.prio = {}; -- default is equal prio for all (considered OS for all)
		obj.reserved = false;
		obj.DE = true;
		return obj;
	else
		-- set metatable of existing table
		setmetatable(prio,Prio);
		return prio;
	end
end

-- LootPrio
LootPrio = {
	items = {},-- hash table mapping itemName to Prio object
	default = nil; -- default prio used when item is not in items
}; 
LootPrio.__index = LootPrio;

function LootPrio:new(loot_prio)
	if loot_prio == nil then
		-- initalize fresh
		local obj = {};
		obj.items = {};
		obj.default = Prio:new(nil);
		setmetatable(obj,LootPrio);
		return obj;
	else
		-- set metatable of existing table
		setmetatable(loot_prio,LootPrio);
		for key,value in pairs(loot_prio) do
			loot_prio[key] = Prio:new(value);
		end
		return loot_prio;
	end
end

local function GetSpecClassColor(spec_class)
	-- Returns color code for given SpecClass
	for class,tbl in pairs(CLASSES) do
		if string.find(spec_class,class) ~= nil then
			return tbl.color.r, tbl.color.g, tbl.color.b, tbl.color.hex;
		end
	end
	return nil,nil,nil,nil;
end

function LootPrio:PrintPrio(itemName)
	-- prints the prio of given item
	-- prints default if nil
	local data;
	if itemName == nil or self.items[itemName] == nil then
		data = self.default;
		SKC_Main:Print("IMPORTANT","Default Loot Prio:")
	else
		data = self.items[itemName];
		SKC_Main:Print("IMPORTANT","Loot Prio for "..itemName..":")
	end
	-- print reserved states
	if data.reserved then
		SKC_Main:Print("IMPORTANT","Reserved: TRUE");
	else
		SKC_Main:Print("IMPORTANT","Reserved: FALSE");
	end
	-- create map from prio level to concatenated string of SpecClass's
	local spec_class_map = {};
	for i = 1,SKC_Main.MaxPrioTiers do
		spec_class_map[i] = {};
	end
	-- SKC_Main:Print("NORMAL",#(spec_class_map[1]));
	for key,value in pairs(data.prio) do
		-- SKC_Main:Print("NORMAL","Prio");
		-- SKC_Main:Print("NORMAL","Prio Tier ["..key.."]: "..value);
		spec_class_map[value][#(spec_class_map[value]) + 1] = key;
	end
	for tier,tbl in ipairs(spec_class_map) do
		SKC_Main:Print("IMPORTANT","Prio Tier ["..tier.."]:");
		for idx,spec_class in pairs(tbl) do
			local hex = select(4, GetSpecClassColor(spec_class));
			DEFAULT_CHAT_FRAME:AddMessage("  "..string.format("|cff%s%s|r",hex:upper(),spec_class));
		end
	end
	return;
end

-- SK_Node class
SK_Node = {
	above = nil, -- character name above this character in ths SK list
	below = nil, -- character name below this character in the SK list
	loot_decision = LOOT_DECISION.PASS, -- character current loot decision (PASS, SK, ROLL)
	loot_prio = PRIO_TIERS.PASS, -- priority on given loot item
	live = false, -- used to indicate a slot that is currently in the live list
};
SK_Node.__index = SK_Node;

function SK_Node:new(sk_node,above,below)
	if sk_node == nil then
		-- initalize fresh
		local obj = {};
		setmetatable(obj,SK_Node);
		obj.above = above or nil;
		obj.below = below or nil;
		obj.loot_decision = LOOT_DECISION.PASS;
		loot_prio = PRIO_TIERS.PASS;
		obj.live = false;
		return obj;
	else
		-- set metatable of existing table
		setmetatable(sk_node,SK_Node);
		return sk_node;
	end
end

-- SK_List class
SK_List = { --a doubly linked list table where each node is referenced by player name. Each node is a SK_Node:
	top = nil, -- top name in list
	bottom = nil, -- bottom name in list
	list = {}, -- list of SK_Node
};
SK_List.__index = SK_List;

function SK_List:new(sk_list)
	if sk_list == nil then
		-- initalize fresh
		local obj = {};
		setmetatable(obj,SK_List);
		obj.top = nil; 
		obj.bottom = nil; 
		obj.list = {};
		return obj;
	else
		-- set metatable of existing table and all sub tables
		setmetatable(sk_list,SK_List);
		for key,value in pairs(sk_list.list) do
			sk_list.list[key] = SK_Node:new(value,nil,nil);
		end
		return sk_list;
	end
end

function SK_List:CheckIfFucked()
	-- checks integrity of list
	if self.list[self.bottom].below ~= nil then
		SKC_Main:Print("ERROR","Your database is fucked.")
		return true;
	end
	return false;
end

function SK_List:Reset(in_raid_list)
	-- Resets all player loot decisions to PASS and prio to 1
	-- in_raid_list is 
	for name,sk_node in pairs(self.list) do 
		sk_node.loot_decision = LOOT_DECISION.PASS;
		sk_node.loot_prio = SKC_Main.MaxPrioTiers + 1; -- prio tier for OS
		sk_node.in_raid = false;
	end
	return;
end

function SK_List:ReturnList()
	-- Returns list in ordered array
	-- check data integrity
	if self:CheckIfFucked() then return({}) end;
	-- Scan list in order
	local list_out = {};
	local idx = 1;
	local current_name = self.top;
	while (current_name ~= nil) do
		list_out[idx] = current_name;
		current_name = self.list[current_name].below;
		idx = idx + 1;
	end
	return(list_out);
end

function SK_List:InsertBelow(name,new_above_name)
	-- Insert item below new_above_name
	if name == nil then
		SKC_Main:Print("ERROR","nil name to SK_List:InsertBelow()");
		return false;
	end
	-- check special cases
	if self.top == nil then
		-- First node in list
		self.top = name;
		self.bottom = name;
		self.list[name] = SK_Node:new(self.list[name],name,nil);
		return true;
	elseif name == new_above_name then
		-- do nothing
		return true;
	end
	if new_above_name == nil then
		SKC_Main:Print("ERROR","nil new_above_name to SK_List:InsertBelow()");
		return false;
	end
	-- check that new_above_name is in list
	if self.list[new_above_name] == nil then
		SKC_Main:Print("ERROR",new_above_name.." not in list");
		return false 
	end
	-- Instantiates if does not exist
	if self.list[name] == nil then
		-- new node
		self.list[name] = SK_Node:new(self.list[name],nil,nil);
	else
		-- existing node
		if self.list[name].above == new_above_name then
			-- already in correct order
			return true;
		end
		-- remove name from list
		local above_tmp = self.list[name].above;
		local below_tmp = self.list[name].below;
		if name == self.top then
			-- name is current top
			self.list[below_tmp].above = below_tmp;
			self.top = below_tmp;
		elseif name == self.bottom then
			-- name is current bottom node
			self.list[above_tmp].below = nil;
			self.bottom = above_tmp;
		else
			-- name is middle node
			self.list[below_tmp].above = above_tmp;
			self.list[above_tmp].below = below_tmp;
		end
	end
	-- insert to new location
	self.list[name].above = new_above_name;
	self.list[name].below = self.list[new_above_name].below;
	-- adjust below for new_above_name
	self.list[new_above_name].below = name;
	-- check if new bottom or top and adjust
	if self.list[name].below == nil then self.bottom = name end
	if self.list[name].above == name then self.top = name end
	return true;
end

function SK_List:PushBack(name)
	-- Pushes name to back (bottom) of list (creates if does not exist)
	return self:InsertBelow(name,self.bottom);
end

function SK_List:SetSK(name,new_above_name)
	-- Removes player from list and sets them to specific location
	-- returns error if names not already i list
	if self.list[name] == nil or self.list[new_above_name] == nil then
		SKC_Main:Print("ERROR",name.." or "..new_above_name.." not in list");
		return false
	else
		return self:InsertBelow(name,new_above_name);
	end
end

-- SK_Node = {
-- 	above = nil, -- character name above this character in ths SK list
-- 	below = nil, -- character name below this character in the SK list
-- 	loot_decision = LOOT_DECISION.PASS, -- character current loot decision (PASS, SK, ROLL)
-- 	loot_prio = PRIO_TIERS.PASS, -- priority on given loot item
-- 	live = false, -- used to indicate a slot that is currently in the live list
-- };

function SK_List:SK()
	-- Scan list and SK player with highest priority to bottom of list
	-- returns name of player that was SK'd
	local sk_name = nil;
	-- check data integrity
	if self:CheckIfFucked() then return sk_name end;
	local current_name = self.top;
	while (current_name ~= nil) do
		-- check if character SK'd and higher prio than current
		if self.list[current_name].loot_decision == LOOT_DECISION.SK then
			if sk_name == nil or self.list[current_name].loot_prio < self.list[sk_name].loot_prio then
				-- first SK or higher prio found
				sk_name = current_name;
			end
		end
	end
	if sk_name ~= nil then
		-- SK
		self:PushBack(sk_name);
	end
	return sk_name;
end

-- CharacterData class
CharacterData = {
	Name = nil, -- character name
	Class = nil, -- character class
	Spec = nil, -- character specialization
	["Raid Role"] = nil, --DPS, Healer, or Tank
	["Guild Role"] = nil, --Disenchanter, Guild Banker, or None
	Status = nil, -- Main or Alt
	Activity = nil, -- Active or Inactive
	["Loot History"] = {}, -- Table that maps timestamp to table with item (Rejuvenating Gem) and distribution method (SK1, Roll, DE, etc)
}
CharacterData.__index = CharacterData;

function CharacterData:new(character_data,name,class)
	if character_data == nil then
		-- initalize fresh
		local obj = {};
		setmetatable(obj,CharacterData);
		obj.Name = name or nil;
		obj.Class = class or nil;
		obj.Spec = CLASSES[class].DEFAULT_SPEC;
		obj["Raid Role"] = CLASSES[class].Specs[obj.Spec].RR;
		obj["Guild Role"] = CHARACTER_DATA["Guild Role"].OPTIONS.None.text;
		obj.Status = CHARACTER_DATA.Status.OPTIONS.Main.text;
		obj.Activity = CHARACTER_DATA.Activity.OPTIONS.Active.text;
		obj["Loot History"] = {};
		return obj;
	else
		-- set metatable of existing table
		setmetatable(character_data,CharacterData);
		return character_data;
	end
 end

-- GuildData class
GuildData = {} --a hash table that maps character name to CharacterData
GuildData.__index = GuildData;

function GuildData:new(guild_data)
	if guild_data == nil then
		-- initalize fresh
		local obj = {};
		setmetatable(obj,GuildData);
		return obj;
	else
		-- set metatable of existing table and all sub tables
		setmetatable(guild_data,GuildData);
		for key,value in pairs(guild_data) do CharacterData:new(value,nil,nil) end
		return guild_data;
	end
end

function GuildData:length()
	local count = 0;
	for _ in pairs(self) do count = count + 1 end
	return count;
end

function GuildData:Add(name,class)
	self[name] = CharacterData:new(nil,name,class);
	return;
end

--------------------------------------
-- LOCAL FUNCTIONS
--------------------------------------
local function GetAllSpecClass()
	-- Return a table of all SpecClass combinations
	local tbl_out = {};
	for class,tbl in pairs(CLASSES) do
		local class_txt = class.text;
		for key,value in pairs(tbl.spec) do
			local spec_txt = value.text;
			tbl_out[#tbl_out + 1] = spec_txt..class_txt;
		end
	end
	return(tbl_out);
end

local function OnMouseWheel_ScrollFrame(self,delta)
    -- delta: 1 scroll up, -1 scroll down
	-- value at top is 0, value at bottom is size of child
	-- scroll so that one wheel is 3 SK cards
	local scroll_range = self:GetVerticalScrollRange();
	local inc = 3 * (UI_DIMENSIONS.SK_CARD_HEIGHT + UI_DIMENSIONS.SK_CARD_SPACING)
    local newValue = math.min( scroll_range , math.max( 0 , self:GetVerticalScroll() - (inc*delta) ) );
    self:SetVerticalScroll(newValue);
    return
end

local function OnCheck_FilterFunction (self, button)
	SKC_Main.FilterStates["SK1"][self.text:GetText()] = self:GetChecked();
	SKC_Main:UpdateSK("SK1");
	return;
end

local function Refresh_Details(name)
	local data = SKC_DB.GuildData[name];
	SKC_UIMain["Details_border"]["Name"].Data:SetText(data.Name);
	SKC_UIMain["Details_border"]["Class"].Data:SetText(data.Class);
	SKC_UIMain["Details_border"]["Class"].Data:SetTextColor(CLASSES[data.Class].color.r,CLASSES[data.Class].color.g,CLASSES[data.Class].color.b,1.0);
	SKC_UIMain["Details_border"]["Spec"].Data:SetText(data.Spec);
	SKC_UIMain["Details_border"]["Raid Role"].Data:SetText(data["Raid Role"]);
	SKC_UIMain["Details_border"]["Guild Role"].Data:SetText(data["Guild Role"]);
	SKC_UIMain["Details_border"]["Status"].Data:SetText(data.Status);
	SKC_UIMain["Details_border"]["Activity"].Data:SetText(data.Activity);
end

local function OnLoad_EditDropDown_Spec(self)
	local class = SKC_UIMain["Details_border"]["Class"].Data:GetText();
	for key,value in pairs(CLASSES[class].Specs) do
		UIDropDownMenu_AddButton(value);
	end
	return;
end

local function OnLoad_EditDropDown_GuildRole(self)
	UIDropDownMenu_AddButton(CHARACTER_DATA["Guild Role"].OPTIONS.None);
	UIDropDownMenu_AddButton(CHARACTER_DATA["Guild Role"].OPTIONS.Disenchanter);
	UIDropDownMenu_AddButton(CHARACTER_DATA["Guild Role"].OPTIONS.Banker);
	return;
end

local function OnLoad_EditDropDown_Status(self)
	UIDropDownMenu_AddButton(CHARACTER_DATA.Status.OPTIONS.Alt);
	UIDropDownMenu_AddButton(CHARACTER_DATA.Status.OPTIONS.Main);
	return;
end

local function OnLoad_EditDropDown_Activity(self)
	UIDropDownMenu_AddButton(CHARACTER_DATA.Activity.OPTIONS.Active);
	UIDropDownMenu_AddButton(CHARACTER_DATA.Activity.OPTIONS.Inactive);
	return;
end

function OnClick_EditDropDownOption(field,value) -- Must be global
	local name = SKC_UIMain["Details_border"]["Name"].Data:GetText();
	local class = SKC_UIMain["Details_border"]["Class"].Data:GetText();
	-- Edit GuildData
	SKC_DB.GuildData[name][field] = value;
	-- Ensure Raid Role is in sync
	local spec = SKC_DB.GuildData[name].Spec;
	SKC_DB.GuildData[name]["Raid Role"] = CLASSES[class].Specs[spec].RR;
	-- Refresh details
	Refresh_Details(name);
	-- Reset menu toggle
	DD_State = 0;
	return;
end

local function OnClick_EditDetails(self, button)
	if not self:IsEnabled() then return end
	-- SKC_UIMain.EditFrame:Show();
	local ID = self:GetID();
	-- Populate drop down options
	local field;
	if ID == 3 then
		field = "Spec";
		if DD_State ~= ID then UIDropDownMenu_Initialize(SKC_UIMain["Details_border"][field].DD,OnLoad_EditDropDown_Spec) end
	elseif ID == 5 then
		-- Guild Role
		field = "Guild Role";
		if DD_State ~= ID then UIDropDownMenu_Initialize(SKC_UIMain["Details_border"][field].DD,OnLoad_EditDropDown_GuildRole) end
	elseif ID == 6 then
		-- Status
		field = "Status";
		if DD_State ~= ID then UIDropDownMenu_Initialize(SKC_UIMain["Details_border"][field].DD,OnLoad_EditDropDown_Status) end
	elseif ID == 7 then
		-- Activity
		field = "Activity";
		if DD_State ~= ID then UIDropDownMenu_Initialize(SKC_UIMain["Details_border"][field].DD,OnLoad_EditDropDown_Activity) end
	else
		SKC_Main:Print("ERROR","Menu not found.");
		return;
	end
	ToggleDropDownMenu(1, nil, SKC_UIMain["Details_border"][field].DD, SKC_UIMain["Details_border"][field].DD, 0, 0);
	if DD_State == ID then
		DD_State = 0;
	else
		DD_State = ID;
	end
	return;
end

local function OnClick_SK_Card(self, button)
	if button=='LeftButton' and self.Text:GetText() ~= nill and DD_State == 0 then
		-- Populate data
		Refresh_Details(self.Text:GetText());
		-- Enable edit buttons
		SKC_UIMain["Details_border"]["Spec"].Btn:Enable();
		SKC_UIMain["Details_border"]["Guild Role"].Btn:Enable();
		SKC_UIMain["Details_border"]["Status"].Btn:Enable();
		SKC_UIMain["Details_border"]["Activity"].Btn:Enable();
		SKC_UIMain["Details_border"].SingleSK_Btn:Enable();
		SKC_UIMain["Details_border"].FullSK_Btn:Enable();
	end
end

local function OnClick_FullSK(self)
	-- On click event for full SK of details targeted character
	local name = SKC_UIMain["Details_border"]["Name"].Data:GetText();
	-- Execute full SK
	local sk_list = "SK1";
	local success = SKC_DB.SK_Lists[sk_list].Full:PushBack(name);
	if success then 
		SKC_Main:Print("IMPORTANT","Full SK on "..name);
	else
		SKC_Main:Print("ERROR","Full SK on "..name.." rejected");
	end
	-- Refresh SK List
	SKC_Main:UpdateSK(sk_list);
	return;
end

local function OnClick_SingleSK(self)
	-- On click event for full SK of details targeted character
	local name = SKC_UIMain["Details_border"]["Name"].Data:GetText();
	-- Execute full SK
	local sk_list = "SK1";
	local success = true;
	if name ~= SKC_DB.SK_Lists[sk_list].Full.bottom then
		success = SKC_DB.SK_Lists[sk_list].Full:InsertBelow(name,SKC_DB.SK_Lists[sk_list].Full.list[name].below);
	end
	if success then 
		SKC_Main:Print("IMPORTANT","Single SK on "..name);
	else
		SKC_Main:Print("ERROR","Single SK on "..name.." rejected");
	end
	-- Refresh SK List
	SKC_Main:UpdateSK(sk_list);
	return;
end

local function OnClick_SetSK(self)
	-- On click event to set SK position of details targeted character
	-- Prompt user to click desired position number in list
	SetSK_Flag = true;
	local name = SKC_UIMain["Details_border"]["Name"].Data:GetText();
	SKC_Main:Print("IMPORTANT","Click desired position in SK list for "..name);
	return;
end

local function OnClick_NumberCard(self)
	-- On click event for number card in SK list
	if SetSK_Flag then
		local name = SKC_UIMain["Details_border"]["Name"].Data:GetText();
		-- Refresh SK List
		SKC_Main:UpdateSK(sk_list);
	end
end

local function OnMouseDown_ShowItemTooltip(self, button)
	--[[
		function ChatFrame_OnHyperlinkShow(chatFrame, link, text, button)
			SetItemRef(link, text, button, chatFrame);
		end
		https://wowwiki.fandom.com/wiki/API_ChatFrame_OnHyperlinkShow
		https://wowwiki.fandom.com/wiki/API_strfind

		chatFrame 
			table (Frame) - ChatFrame in which the link was clicked.
		link 
			String - The link component of the clicked hyperlink. (e.g. "item:6948:0:0:0...")
		text 
			String - The label component of the clicked hyperlink. (e.g. "[Hearthstone]")
		button 
			String - Button clicking the hyperlink button. (e.g. "LeftButton")
		
		itemLink ex:
			|cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r
		itemString ex:
			item:3299::::::::20:257::::::
		itemLabel ex:
			[Fractured Canine]
	--]]
	local decision_border_key = "Decision_border";
	local frame = SKC_UIMain[decision_border_key];
	local itemLink = SKC_UIMain[decision_border_key].ItemLink:GetText();
	local itemString = string.match(itemLink,"item[%-?%d:]+");
	local itemLabel = string.match(itemLink,"|h.+|h");
	SetItemRef(itemString, itemLabel, button, frame);
end

local function GetScrollMax()
	return((SKC_DB.UnFilteredCnt)*(UI_DIMENSIONS.SK_CARD_HEIGHT + UI_DIMENSIONS.SK_CARD_SPACING));
end

local function SetSKItem()
	-- https://wow.gamepedia.com/ItemMixin
	-- local itemID = 19395; -- Rejuv
	-- Need to wrap in callback function to wait for item data to load
	local item = Item:CreateFromItemLink(SKC_Main.SK_Item)
	item:ContinueOnItemLoad(function()
		-- item:GetItemLink();
		local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(SKC_Main.SK_Item);
		-- Set texture icon and link
		local decision_border_key = "Decision_border";
		SKC_UIMain[decision_border_key].ItemTexture:SetTexture(texture);
		SKC_UIMain[decision_border_key].ItemLink:SetText(link);
	end)
end

local function SendLootDecision()
	C_ChatInfo.SendAddonMessage(SKC_Main.DECISION_CHANNEL,SKC_Main.LootDecision,"WHISPER",SKC_Main.MasterLooter);
end

local function InitTimerBarValue()
	SKC_UIMain["Decision_border"].TimerBar:SetValue(0);
	SKC_UIMain["Decision_border"].TimerText:SetText(LOOT_DECISION.MAX_TIME);
end

local function TimerBarHandler()
	local time_elapsed = SKC_UIMain["Decision_border"].TimerBar:GetValue() + LOOT_DECISION.TIME_STEP;

	-- updated timer bar
	SKC_UIMain["Decision_border"].TimerBar:SetValue(time_elapsed);
	SKC_UIMain["Decision_border"].TimerText:SetText(LOOT_DECISION.MAX_TIME - time_elapsed);

	if time_elapsed >= LOOT_DECISION.MAX_TIME then
		-- out of time
		-- send loot response
		SKC_Main:Print("WARN","Time expired. You PASS on "..SKC_Main.SK_Item);
		SKC_Main.LootDecision = LOOT_DECISION.PASS;
	end

	return;
end

local function StartLootTimer()
	InitTimerBarValue();
	if LootTimer ~= nil and not LootTimer:IsCancelled() then LootTimer:Cancel() end
	-- start new timer
	LootTimer = C_Timer.NewTicker(LOOT_DECISION.TIME_STEP, TimerBarHandler, LOOT_DECISION.MAX_TIME/LOOT_DECISION.TIME_STEP);
	return;
end

local function StripRealmName(full_name)
	local name,_ = strsplit("-",full_name,2);
	return(name);
end

local function OnClick_PASS(self,button)
	if self:IsEnabled() then
		SKC_Main.LootDecision = LOOT_DECISION.PASS;
		LootTimer:Cancel()
		SendLootDecision();
	end
	return;
end

local function OnClick_SK(self,button)
	if self:IsEnabled() then
		SKC_Main.LootDecision = LOOT_DECISION.SK;
		LootTimer:Cancel()
		SendLootDecision();
	end
	return;
end

local function OnClick_ROLL(self,button)
	if self:IsEnabled() then
		SKC_Main.LootDecision = LOOT_DECISION.ROLL;
		LootTimer:Cancel()
		SendLootDecision();
	end
	return;
end

--------------------------------------
-- SKC_Main FUNCTIONS
--------------------------------------
function SKC_Main:Toggle(force_show)
	local menu = SKC_UIMain or SKC_Main:CreateMenu();
	menu:SetShown(force_show or not menu:IsShown());
	DD_State = 0;
end

function SKC_Main:GetThemeColor(type)
	local c = THEME.PRINT[type];
	return c.r, c.g, c.b, c.hex;
end

function SKC_Main:Print(type,...)
    local hex = select(4, SKC_Main:GetThemeColor(type));
	local prefix = string.format("|cff%s%s|r", hex:upper(), "SKC:");
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
end

function SKC_Main:StartPersonalLootDecision()
	-- Begins personal loot decision process
	SKC_Main:Print("IMPORTANT","Would you like to SK for "..SKC_Main.SK_Item.."?");
	SKC_Main.LootDecision = LOOT_DECISION.PASS;
	-- Show UI
	SKC_Main:Toggle(true);
	-- Enable buttons
	SKC_UIMain["Decision_border"].Pass_Btn:Enable();
	SKC_UIMain["Decision_border"].SK_Btn:Enable();
	-- Set item
	SetSKItem();
	-- Initiate timer
	StartLootTimer();
	return;
end

function SKC_Main:DetermineWinner()
	-- Determine winner of loot decison
	-- TODO: Add loot prio logic here:
	-- 		for SK guys, store top SK char with highest prio (smallest number)
	-- 		add roll guys to list
	-- 		if SK heap isnt empty, pop top for winner
	-- 		if SK heap is empty, do rolls
	-- 		if roll list is empty, allocate to GB or DE
	-- 		if no DE, allocate to GB
	-- 		if no GB, give to ML
	-- Ensure data integrity of list before scanning
	if self:CheckIfFucked() then return(false) end;
	-- scan list in order
	local roll_list = {};
	local name_tmp = self.top;
	local idx = 1;
	while name_tmp ~= nil do
		local loot_decision_tmp = self.list[name_tmp].loot_decision;
		if loot_decision_tmp == LOOT_DECISION.SK then
			-- If character SK'd, they win!
			SKC_Main:Print("IMPORTANT",winner.." won "..SKC_Main.SK_Item.." by SK!");
			-- SK character
			-- local sk_success = SKC_DB.SK_Lists["SK1"]:FullSK(name);
			-- Give loot!
			local awarded_success = SKC_Main:AwardLoot(name);
			return(sk_success and awarded_success);

		elseif loot_decision_tmp == LOOT_DECISION.ROLL then
			-- Add character to roll list
			roll_list[idx] = name_tmp;
		end
		name_tmp = self.list[name_tmp].below;
	end
end

function SKC_Main:DetermineLootPrio(name)
	-- Returns loot prio for given character for given SK item
	-- Alt's have loot SpecClass tier + 100 (only works so long as max # tiers < 100)
	-- OS (spec not found in prio doc) is equal to max tier + 1
	
end

function SKC_Main:AddonMessageRead(self,prefix,msg,channel,sender)
	if prefix == SKC_Main.SYNC_CHANNEL then
		DEFAULT_CHAT_FRAME:AddMessage("We should: "..msg);
	elseif prefix == SKC_Main.DISTRIBUTION_CHANNEL then
		--[[ 
			Listening: Everyone
		 	Talking: ML
		 --]]
		-- save master looter
		SKC_Main.MasterLooter = StripRealmName(sender);
		-- save item
		SKC_Main.SK_Item = msg;
		-- initiate personal loot decision
		SKC_Main:StartPersonalLootDecision();
	elseif prefix == SKC_Main.DECISION_CHANNEL then
		--[[ 
			Listening: ML
		 	Talking: Everyone
		 --]]
		 -- Increment message counter
		SKC_Main.SK_MessagesReceived = SKC_Main.SK_MessagesReceived + 1;
		-- Alert ML of decision
		local name = StripRealmName(sender);
		SKC_Main:Print("NORMAL",name.." wants to "..msg..".");
		-- Save loot decision
		-- SKC_DB.SK_Lists["SK1"].list[name].loot_decision = msg;
		-- Determine loot prio of character
		-- SKC_DB.SK_Lists["SK1"].list[name].loot_prio = SKC_Main:DetermineLootPrio(name);
		-- check if all messages received
		if SKC_Main.SK_MessagesReceived >= SKC_Main.SK_MessagesSent then
			-- Determine winner and allocate loot
			local success = SKC_Main:DetermineWinner();
		end
	end
	return;
end

function SKC_Main:AwardLoot(name)
	-- Awards SKC_Main.SK_Item to given character
	for i_loot = 1, GetNumLootItems() do
		if GetLootSlotLink(i_loot) == SKC_Main.SK_Item then
			for i_char = 1,40 do
				if StripRealmName(GetMasterLootCandidate(i_loot,i_char)) == name then
					GiveMasterLoot(i_loot, i_char);
					SKC_Main:Print("IMPORTANT","Awarded "..SKC_Main.SK_Item.." to "..name..".");
					return true;
				end
			end
		end
	end
	SKC_Main:Print("ERROR","Could not award "..SKC_Main.SK_Item.." to "..name..".");
	return false;
end

function SKC_Main:InitiateLootDecision()
	-- Scans items / characters and initiates loot decisions for valid characters
	-- For Reference: local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(i_loot)
	if not IsMasterLooter() then return end
	-- Reset guild loot decisions and loot prio
	-- SKC_DB.SK_Lists["SK1"]:Reset();
	-- Reset message count
	SKC_Main.SK_MessagesReceived = 0;
	SKC_Main.SK_MessagesSent = 0;
	-- Determine item to start distribution event
	-- Initiate for first item
	local i_loot = 1;
	-- get item data
	local lootType = GetLootSlotType(i_loot); -- 1 for items, 2 for money, 3 for archeology(and other currencies?)
	local _, lootName, _, _, lootRarity, _, _, _, _ = GetLootSlotInfo(i_loot)
	-- Only perform SK for items of rarity threshold or higher
	if lootType == 1 and lootRarity >= SKC_Main.RARITY_THRESHOLD then
		-- Valid item
		SKC_Main.SK_Item = GetLootSlotLink(i_loot);
		SKC_Main:Print("NORMAL","Distributing "..SKC_Main.SK_Item);
		-- Scan all possible characters to distribute loot
		for i_char = 1,40 do
			local char_name = GetMasterLootCandidate(i_loot,i_char);
			if char_name ~= nil then
				-- send loot decision message
				SKC_Main.SK_MessagesSent = SKC_Main.SK_MessagesSent + 1;
				C_ChatInfo.SendAddonMessage(SKC_Main.DISTRIBUTION_CHANNEL,SKC_Main.SK_Item,"WHISPER",char_name);
			end
		end
	end
	return;
end

function SKC_Main:OnAddonLoad()
	AddonLoaded = true;
	local hard_reset = true;
	-- Initialize 
	if SKC_DB == nil or hard_reset then 
		SKC_DB = {};
	end
	if SKC_DB.SK_Lists == nil or hard_reset then 
		SKC_DB.SK_Lists = {};
	end
	if SKC_DB.LootPrio == nil or hard_reset then 
		SKC_DB.LootPrio = {};
	end
	-- Initialize or refresh metatables
	SKC_DB.SK_Lists.SK1 = {};
	SKC_DB.SK_Lists.SK1.Full = SK_List:new(SKC_DB.SK_Lists.SK1.Full);
	SKC_DB.SK_Lists.SK1.Live = SK_List:new(SKC_DB.SK_Lists.SK1.Live);
	SKC_DB.SK_Lists.SK2 = {};
	SKC_DB.SK_Lists.SK2.Full = SK_List:new(SKC_DB.SK_Lists.SK2.Full);
	SKC_DB.SK_Lists.SK2.Live = SK_List:new(SKC_DB.SK_Lists.SK2.Live);
	SKC_DB.SK_Lists.SK3 = {};
	SKC_DB.SK_Lists.SK3.Full = SK_List:new(SKC_DB.SK_Lists.SK3.Full);
	SKC_DB.SK_Lists.SK3.Live = SK_List:new(SKC_DB.SK_Lists.SK3.Live);
	SKC_DB.GuildData = GuildData:new(SKC_DB.GuildData);
	SKC_DB.LootPrio = LootPrio:new(SKC_DB.LootPrio);
	SKC_DB.UnFilteredCnt = 0;
end

function SKC_Main:SyncLiveWithRaid()
	-- Sync live lists with current raid

	-- Scan raid list and add missing members

	-- Scan live list and remove non-bench / non-raid members

end

function SKC_Main:StartSKC()
	if not IsMasterLooter() then return end
	SKC_Main:Print("IMPORTANT","SKC enabled.");
	SKC_Main:Print("NORMAL","Use '/bench add' to add non-raid members to the live lists.")
end

function SKC_Main:FetchGuildInfo()
	SKC_DB.InGuild = IsInGuild();
	if not SKC_DB.InGuild then
		SKC_Main:Print("ERROR","You are not in a guild.")
	end
	SKC_DB.NumGuildMembers = GetNumGuildMembers()
	-- Determine # of level 60s and add any new 60s
	local cnt = 0;
	for idx = 1, SKC_DB.NumGuildMembers do
		full_name, rank, rankIndex, level, class, zone, note, 
		officernote, online, status, classFileName, 
		achievementPoints, achievementRank, isMobile, isSoREligible, standingID = GetGuildRosterInfo(idx);
		if level == 60 then
			cnt = cnt + 1;
			local name = StripRealmName(full_name);
			if SKC_DB.GuildData[name] == nil then
				-- new player, add to DB and SK lists
				SKC_DB.GuildData:Add(name,class);
				SKC_DB.SK_Lists.SK1.Full:PushBack(name);
				SKC_DB.SK_Lists.SK2.Full:PushBack(name);
				SKC_DB.SK_Lists.SK3.Full:PushBack(name);
				SKC_Main:Print("NORMAL","["..cnt.."] "..name.." added to database!");
			end
		end
	end
	SKC_DB.Count60 = cnt;
	SKC_DB.UnFilteredCnt = cnt;
end

function SKC_Main:UpdateSK(sk_list)
	-- Addon not yet loaded, return
	if not AddonLoaded then return end

	-- Hide all cards
	for idx = 1, SKC_DB.Count60 do
		SKC_UIMain[sk_list].NumberFrame[idx]:Hide();
		SKC_UIMain[sk_list].NameFrame[idx]:Hide();
	end

	-- Populate non filtered cards
	local print_order = SKC_DB.SK_Lists[sk_list].Full:ReturnList();
	local idx = 1;
	for key,value in ipairs(print_order) do
		local class_tmp = SKC_DB.GuildData[value].Class;
		local raid_role_tmp = SKC_DB.GuildData[value]["Raid Role"];
		local status_tmp = SKC_DB.GuildData[value].Status;
		local activity_tmp = SKC_DB.GuildData[value].Activity;
		-- only add cards to list which are not being filtered
		if SKC_Main.FilterStates["SK1"][class_tmp] and 
		   SKC_Main.FilterStates["SK1"][raid_role_tmp] and
		   SKC_Main.FilterStates["SK1"][status_tmp] and
		   SKC_Main.FilterStates["SK1"][activity_tmp] then
			-- Add number text
			SKC_UIMain[sk_list].NumberFrame[idx].Text:SetText(key)
			SKC_UIMain[sk_list].NumberFrame[idx]:Show();
			-- Add name text
			SKC_UIMain[sk_list].NameFrame[idx].Text:SetText(value)
			-- create class color background
			SKC_UIMain[sk_list].NameFrame[idx].bg:SetColorTexture(CLASSES[class_tmp].color.r,CLASSES[class_tmp].color.g,CLASSES[class_tmp].color.b,0.25);
			SKC_UIMain[sk_list].NameFrame[idx]:Show();
			-- increment
			idx = idx + 1;
		end
	end
	SKC_DB.UnFilteredCnt = idx;
	-- update scroll length
	SKC_UIMain[sk_list].SK_List_SF:GetScrollChild():SetSize(UI_DIMENSIONS.SK_LIST_WIDTH,GetScrollMax());
end

function SKC_Main:CreateUIBorder(title,width,height,x_pos,y_pos)
	-- Create Border
	local border_key = title.."_border";
	SKC_UIMain[border_key] = CreateFrame("Frame",border_key,SKC_UIMain,"TranslucentFrameTemplate");
	SKC_UIMain[border_key]:SetSize(width,height);
	SKC_UIMain[border_key]:SetPoint("TOP",SKC_UIMain,"TOP",x_pos,y_pos);
	SKC_UIMain[border_key].Bg:SetAlpha(0.0);
	-- Create Title
	local title_key = "title";
	SKC_UIMain[border_key][title_key] = CreateFrame("Frame",title_key,SKC_UIMain[border_key],"TranslucentFrameTemplate");
	SKC_UIMain[border_key][title_key]:SetSize(UI_DIMENSIONS.SK_TAB_TITLE_CARD_WIDTH,UI_DIMENSIONS.SK_TAB_TITLE_CARD_HEIGHT);
	SKC_UIMain[border_key][title_key]:SetPoint("BOTTOM",SKC_UIMain[border_key],"TOP",0,-20);
	SKC_UIMain[border_key][title_key].Text = SKC_UIMain[border_key][title_key]:CreateFontString(nil,"ARTWORK")
	SKC_UIMain[border_key][title_key].Text:SetFontObject("GameFontNormal")
	SKC_UIMain[border_key][title_key].Text:SetPoint("CENTER",0,0)
	SKC_UIMain[border_key][title_key].Text:SetText(title)

	return border_key
end

function SKC_Main:CreateMenu()
	-- If addon not yet loaded, reject
	if not AddonLoaded then return end

	-- Fetch guild info into SK DB
	SKC_Main:FetchGuildInfo()

    SKC_UIMain = CreateFrame("Frame", "SKC_UIMain", UIParent, "UIPanelDialogTemplate");
	SKC_UIMain:SetSize(UI_DIMENSIONS.MAIN_WIDTH,UI_DIMENSIONS.MAIN_HEIGHT);
	SKC_UIMain:SetPoint("CENTER");
	SKC_UIMain:SetMovable(true)
	SKC_UIMain:EnableMouse(true)
	SKC_UIMain:RegisterForDrag("LeftButton")
	SKC_UIMain:SetScript("OnDragStart", SKC_UIMain.StartMoving)
	SKC_UIMain:SetScript("OnDragStop", SKC_UIMain.StopMovingOrSizing)
	SKC_UIMain:SetAlpha(0.8);
	
	-- Add title
    SKC_UIMain.Title:ClearAllPoints();
	SKC_UIMain.Title:SetPoint("LEFT", SKC_UIMainTitleBG, "LEFT", 6, 0);
	SKC_UIMain.Title:SetText("SKC");

	-- Create filter panel
	local filter_border_key = SKC_Main:CreateUIBorder("Filters",UI_DIMENSIONS.SK_FILTER_WIDTH,UI_DIMENSIONS.SK_FILTER_HEIGHT,-250,UI_DIMENSIONS.SK_TAB_TOP_OFFST)
	-- create details fields
	local faction_class;
	if UnitFactionGroup("player") == "Horde" then faction_class="Shaman" else faction_class="Paladin" end
	local filter_roles = {"DPS","Healer","Tank","Main","Alt","Inactive","Active","Druid","Hunter","Mage","Priest","Rogue","Warlock","Warrior",faction_class};
	for idx,value in ipairs(filter_roles) do
		if value ~= "SKIP" then
			local row = math.floor((idx - 1) / 3); -- zero based
			local col = (idx - 1) % 3; -- zero based
			SKC_UIMain[filter_border_key][value] = CreateFrame("CheckButton", nil, SKC_UIMain[filter_border_key], "UICheckButtonTemplate");
			SKC_UIMain[filter_border_key][value]:SetSize(25,25);
			SKC_UIMain[filter_border_key][value]:SetChecked(SKC_Main.FilterStates["SK1"][value]);
			SKC_UIMain[filter_border_key][value]:SetScript("OnClick",OnCheck_FilterFunction)
			SKC_UIMain[filter_border_key][value]:SetPoint("TOPLEFT", SKC_UIMain[filter_border_key], "TOPLEFT", 22 + 73*col , -20 + -24*row);
			SKC_UIMain[filter_border_key][value].text:SetFontObject("GameFontNormalSmall");
			SKC_UIMain[filter_border_key][value].text:SetText(value);
			if idx > 7 then
				-- assign class colors
				SKC_UIMain[filter_border_key][value].text:SetTextColor(CLASSES[value].color.r,CLASSES[value].color.g,CLASSES[value].color.b,1.0);
			end
		end
	end

	-- Create SK list panel
	local sk_list = "SK1";
	SKC_UIMain[sk_list] = CreateFrame("Frame",sk_list,SKC_UIMain,"InsetFrameTemplate");
	SKC_UIMain[sk_list]:SetSize(UI_DIMENSIONS.SK_LIST_WIDTH,UI_DIMENSIONS.SK_LIST_HEIGHT);
	SKC_UIMain[sk_list]:SetPoint("TOP",SKC_UIMain,"TOP",0,UI_DIMENSIONS.SK_TAB_TOP_OFFST - UI_DIMENSIONS.SK_LIST_BORDER_OFFST);
	local sk_list_border_key = SKC_Main:CreateUIBorder(sk_list,UI_DIMENSIONS.SK_LIST_WIDTH + 2*UI_DIMENSIONS.SK_LIST_BORDER_OFFST,UI_DIMENSIONS.SK_LIST_HEIGHT + 2*UI_DIMENSIONS.SK_LIST_BORDER_OFFST,0,UI_DIMENSIONS.SK_TAB_TOP_OFFST)

	-- Create scroll frame on SK list
    SKC_UIMain[sk_list].SK_List_SF = CreateFrame("ScrollFrame","SK_List_SF",SKC_UIMain[sk_list],"UIPanelScrollFrameTemplate2");
    SKC_UIMain[sk_list].SK_List_SF:SetPoint("TOPLEFT",SKC_UIMain[sk_list],"TOPLEFT",0,-2);
	SKC_UIMain[sk_list].SK_List_SF:SetPoint("BOTTOMRIGHT",SKC_UIMain[sk_list],"BOTTOMRIGHT",0,2);
	SKC_UIMain[sk_list].SK_List_SF:SetClipsChildren(true);
	SKC_UIMain[sk_list].SK_List_SF:SetScript("OnMouseWheel",OnMouseWheel_ScrollFrame);
	SKC_UIMain[sk_list].SK_List_SF.ScrollBar:SetPoint("TOPLEFT",SKC_UIMain[sk_list].SK_List_SF,"TOPRIGHT",-22,-21);

	-- Create scroll child
	local scroll_child = CreateFrame("Frame",nil,SKC_UIMain[sk_list].SK_List_SF);
	scroll_child:SetSize(UI_DIMENSIONS.SK_LIST_WIDTH,GetScrollMax());
	SKC_UIMain[sk_list].SK_List_SF:SetScrollChild(scroll_child);

	-- Create SK cards
	SKC_UIMain[sk_list].NumberFrame = {};
	SKC_UIMain[sk_list].NameFrame = {};
	for idx = 1, SKC_DB.Count60 do
		-- Create order frames
		SKC_UIMain[sk_list].NumberFrame[idx] = CreateFrame("Frame",nil,SKC_UIMain[sk_list].SK_List_SF,"InsetFrameTemplate");
		SKC_UIMain[sk_list].NumberFrame[idx]:SetSize(30,UI_DIMENSIONS.SK_CARD_HEIGHT);
		SKC_UIMain[sk_list].NumberFrame[idx]:SetPoint("TOPLEFT",SKC_UIMain[sk_list].SK_List_SF:GetScrollChild(),"TOPLEFT",8,-1*((idx-1)*(UI_DIMENSIONS.SK_CARD_HEIGHT + UI_DIMENSIONS.SK_CARD_SPACING) + UI_DIMENSIONS.SK_CARD_SPACING));
		SKC_UIMain[sk_list].NumberFrame[idx].Text = SKC_UIMain[sk_list].NumberFrame[idx]:CreateFontString(nil,"ARTWORK")
		SKC_UIMain[sk_list].NumberFrame[idx].Text:SetFontObject("GameFontHighlightSmall")
		SKC_UIMain[sk_list].NumberFrame[idx].Text:SetPoint("CENTER",0,0)

		-- Create named card frames
		SKC_UIMain[sk_list].NameFrame[idx] = CreateFrame("Frame",nil,SKC_UIMain[sk_list].SK_List_SF,"InsetFrameTemplate");
		SKC_UIMain[sk_list].NameFrame[idx]:SetSize(UI_DIMENSIONS.SK_CARD_WIDTH,UI_DIMENSIONS.SK_CARD_HEIGHT);
		SKC_UIMain[sk_list].NameFrame[idx]:SetPoint("TOPLEFT",SKC_UIMain[sk_list].SK_List_SF:GetScrollChild(),"TOPLEFT",43,-1*((idx-1)*(UI_DIMENSIONS.SK_CARD_HEIGHT + UI_DIMENSIONS.SK_CARD_SPACING) + UI_DIMENSIONS.SK_CARD_SPACING));
		SKC_UIMain[sk_list].NameFrame[idx].Text = SKC_UIMain[sk_list].NameFrame[idx]:CreateFontString(nil,"ARTWORK")
		SKC_UIMain[sk_list].NameFrame[idx].Text:SetFontObject("GameFontHighlightSmall")
		SKC_UIMain[sk_list].NameFrame[idx].Text:SetPoint("CENTER",0,0)
		-- Add texture for color
		SKC_UIMain[sk_list].NameFrame[idx].bg = SKC_UIMain[sk_list].NameFrame[idx]:CreateTexture(nil,"BACKGROUND");
		SKC_UIMain[sk_list].NameFrame[idx].bg:SetAllPoints(true);
		-- Bind function for click event
		SKC_UIMain[sk_list].NameFrame[idx]:SetScript("OnMouseDown",OnClick_SK_Card);
	end

	-- Update SK cards
	SKC_Main:UpdateSK("SK1")

	-- Create details panel
	local details_border_key = SKC_Main:CreateUIBorder("Details",UI_DIMENSIONS.SK_DETAILS_WIDTH,UI_DIMENSIONS.SK_DETAILS_HEIGHT,250,UI_DIMENSIONS.SK_TAB_TOP_OFFST);
	-- create details fields
	local details_fields = {"Name","Class","Spec","Raid Role","Guild Role","Status","Activity","Loot History"};
	for idx,value in ipairs(details_fields) do
		-- fields
		SKC_UIMain[details_border_key][value] = CreateFrame("Frame",SKC_UIMain[details_border_key])
		SKC_UIMain[details_border_key][value].Field = SKC_UIMain[details_border_key]:CreateFontString(nil,"ARTWORK");
		SKC_UIMain[details_border_key][value].Field:SetFontObject("GameFontNormal");
		SKC_UIMain[details_border_key][value].Field:SetPoint("RIGHT",SKC_UIMain[details_border_key],"TOPLEFT",100,-20*idx-10);
		SKC_UIMain[details_border_key][value].Field:SetText(value..":");
		-- data
		SKC_UIMain[details_border_key][value].Data = SKC_UIMain[details_border_key]:CreateFontString(nil,"ARTWORK");
		SKC_UIMain[details_border_key][value].Data:SetFontObject("GameFontHighlight");
		SKC_UIMain[details_border_key][value].Data:SetPoint("CENTER",SKC_UIMain[details_border_key][value].Field,"RIGHT",45,0);
		if idx == 3 or 
		   idx == 5 or
		   idx == 6 or
		   idx == 7 then
			-- edit buttons
			SKC_UIMain[details_border_key][value].Btn = CreateFrame("Button", nil, SKC_UIMain, "GameMenuButtonTemplate");
			SKC_UIMain[details_border_key][value].Btn:SetID(idx);
			SKC_UIMain[details_border_key][value].Btn:SetPoint("LEFT",SKC_UIMain[details_border_key][value].Field,"RIGHT",95,0);
			SKC_UIMain[details_border_key][value].Btn:SetSize(40, 20);
			SKC_UIMain[details_border_key][value].Btn:SetText("Edit");
			SKC_UIMain[details_border_key][value].Btn:SetNormalFontObject("GameFontNormalSmall");
			SKC_UIMain[details_border_key][value].Btn:SetHighlightFontObject("GameFontHighlightSmall");
			SKC_UIMain[details_border_key][value].Btn:SetScript("OnMouseDown",OnClick_EditDetails);
			SKC_UIMain[details_border_key][value].Btn:Disable();
			-- associated drop down menu
			SKC_UIMain[details_border_key][value].DD = CreateFrame("Frame",nil, SKC_UIMain, "UIDropDownMenuTemplate");
			UIDropDownMenu_SetAnchor(SKC_UIMain[details_border_key][value].DD, 0, 0, "TOPLEFT", SKC_UIMain[details_border_key][value].Btn, "TOPRIGHT");
		end
	end
	-- Initialize with instructions
	SKC_UIMain[details_border_key]["Name"].Data:SetText("            Click on a character."); -- lol, so elegant

	-- Add SK buttons
	-- full SK
	SKC_UIMain[details_border_key].FullSK_Btn = CreateFrame("Button", nil, SKC_UIMain, "GameMenuButtonTemplate");
	SKC_UIMain[details_border_key].FullSK_Btn:SetPoint("BOTTOM",SKC_UIMain[details_border_key],"BOTTOM",0,15);
	SKC_UIMain[details_border_key].FullSK_Btn:SetSize(75, 40);
	SKC_UIMain[details_border_key].FullSK_Btn:SetText("Full SK");
	SKC_UIMain[details_border_key].FullSK_Btn:SetNormalFontObject("GameFontNormal");
	SKC_UIMain[details_border_key].FullSK_Btn:SetHighlightFontObject("GameFontHighlight");
	SKC_UIMain[details_border_key].FullSK_Btn:SetScript("OnMouseDown",OnClick_FullSK);
	SKC_UIMain[details_border_key].FullSK_Btn:Disable();
	-- single SK
	SKC_UIMain[details_border_key].SingleSK_Btn = CreateFrame("Button", nil, SKC_UIMain, "GameMenuButtonTemplate");
	SKC_UIMain[details_border_key].SingleSK_Btn:SetPoint("RIGHT",SKC_UIMain[details_border_key].FullSK_Btn,"LEFT",-5,0);
	SKC_UIMain[details_border_key].SingleSK_Btn:SetSize(75, 40);
	SKC_UIMain[details_border_key].SingleSK_Btn:SetText("Single SK");
	SKC_UIMain[details_border_key].SingleSK_Btn:SetNormalFontObject("GameFontNormal");
	SKC_UIMain[details_border_key].SingleSK_Btn:SetHighlightFontObject("GameFontHighlight");
	SKC_UIMain[details_border_key].SingleSK_Btn:SetScript("OnMouseDown",OnClick_SingleSK);
	SKC_UIMain[details_border_key].SingleSK_Btn:Disable();
	-- set SK
	SKC_UIMain[details_border_key].SetSK_Btn = CreateFrame("Button", nil, SKC_UIMain, "GameMenuButtonTemplate");
	SKC_UIMain[details_border_key].SetSK_Btn:SetPoint("LEFT",SKC_UIMain[details_border_key].FullSK_Btn,"RIGHT",5,0);
	SKC_UIMain[details_border_key].SetSK_Btn:SetSize(75, 40);
	SKC_UIMain[details_border_key].SetSK_Btn:SetText("Set SK");
	SKC_UIMain[details_border_key].SetSK_Btn:SetNormalFontObject("GameFontNormal");
	SKC_UIMain[details_border_key].SetSK_Btn:SetHighlightFontObject("GameFontHighlight");
	SKC_UIMain[details_border_key].SetSK_Btn:SetScript("OnMouseDown",OnClick_SetSK);
	SKC_UIMain[details_border_key].SetSK_Btn:Disable();


	-- Decision region
	local decision_border_key = SKC_Main:CreateUIBorder("Decision",UI_DIMENSIONS.DECISION_WIDTH,UI_DIMENSIONS.DECISION_HEIGHT,-250,UI_DIMENSIONS.SK_TAB_TOP_OFFST-UI_DIMENSIONS.SK_FILTER_HEIGHT-20);

	-- set texture / hidden frame for button click
	SKC_UIMain[decision_border_key].ItemTexture = SKC_UIMain[decision_border_key]:CreateTexture(nil, "ARTWORK");
	SKC_UIMain[decision_border_key].ItemTexture:SetSize(UI_DIMENSIONS.ITEM_WIDTH,UI_DIMENSIONS.ITEM_HEIGHT);
	SKC_UIMain[decision_border_key].ItemTexture:SetPoint("TOP",SKC_UIMain[decision_border_key],"TOP",0,-45)
	SKC_UIMain[decision_border_key].ItemClickBox = CreateFrame("Frame", nil, SKC_UIMain);
	SKC_UIMain[decision_border_key].ItemClickBox:SetSize(UI_DIMENSIONS.ITEM_WIDTH,UI_DIMENSIONS.ITEM_HEIGHT);
	SKC_UIMain[decision_border_key].ItemClickBox:SetPoint("CENTER",SKC_UIMain[decision_border_key].ItemTexture,"CENTER");
	SKC_UIMain[decision_border_key].ItemClickBox:SetScript("OnMouseDown",OnMouseDown_ShowItemTooltip);
	-- set name / link
	SKC_UIMain[decision_border_key].ItemLink = SKC_UIMain[decision_border_key]:CreateFontString(nil,"ARTWORK");
	SKC_UIMain[decision_border_key].ItemLink:SetFontObject("GameFontNormal");
	SKC_UIMain[decision_border_key].ItemLink:SetPoint("TOP",SKC_UIMain[decision_border_key],"TOP",0,-25);
	SKC_UIMain[decision_border_key]:SetHyperlinksEnabled(true)
	SKC_UIMain[decision_border_key]:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)
	-- set decision buttons
	-- SK 
	SKC_UIMain[decision_border_key].SK_Btn = CreateFrame("Button", nil, SKC_UIMain, "GameMenuButtonTemplate");
	SKC_UIMain[decision_border_key].SK_Btn:SetPoint("TOPRIGHT",SKC_UIMain[decision_border_key].ItemTexture,"BOTTOM",-40,-5);
	SKC_UIMain[decision_border_key].SK_Btn:SetSize(65,35);
	SKC_UIMain[decision_border_key].SK_Btn:SetText("SK");
	SKC_UIMain[decision_border_key].SK_Btn:SetNormalFontObject("GameFontNormal");
	SKC_UIMain[decision_border_key].SK_Btn:SetHighlightFontObject("GameFontHighlight");
	SKC_UIMain[decision_border_key].SK_Btn:SetScript("OnMouseDown",OnClick_SK);
	SKC_UIMain[decision_border_key].SK_Btn:Disable();
	-- Roll 
	SKC_UIMain[decision_border_key].Roll_Btn = CreateFrame("Button", nil, SKC_UIMain, "GameMenuButtonTemplate");
	SKC_UIMain[decision_border_key].Roll_Btn:SetPoint("TOP",SKC_UIMain[decision_border_key].ItemTexture,"BOTTOM",0,-5);
	SKC_UIMain[decision_border_key].Roll_Btn:SetSize(65,35);
	SKC_UIMain[decision_border_key].Roll_Btn:SetText("Roll");
	SKC_UIMain[decision_border_key].Roll_Btn:SetNormalFontObject("GameFontNormal");
	SKC_UIMain[decision_border_key].Roll_Btn:SetHighlightFontObject("GameFontHighlight");
	SKC_UIMain[decision_border_key].Roll_Btn:SetScript("OnMouseDown",OnClick_ROLL);
	SKC_UIMain[decision_border_key].Roll_Btn:Disable();
	-- Pass
	SKC_UIMain[decision_border_key].Pass_Btn = CreateFrame("Button", nil, SKC_UIMain, "GameMenuButtonTemplate");
	SKC_UIMain[decision_border_key].Pass_Btn:SetPoint("TOPLEFT",SKC_UIMain[decision_border_key].ItemTexture,"BOTTOM",40,-5);
	SKC_UIMain[decision_border_key].Pass_Btn:SetSize(65,35);
	SKC_UIMain[decision_border_key].Pass_Btn:SetText("Pass");
	SKC_UIMain[decision_border_key].Pass_Btn:SetNormalFontObject("GameFontNormal");
	SKC_UIMain[decision_border_key].Pass_Btn:SetHighlightFontObject("GameFontHighlight");
	SKC_UIMain[decision_border_key].Pass_Btn:SetScript("OnMouseDown",OnClick_PASS);
	SKC_UIMain[decision_border_key].Pass_Btn:Disable();
	-- timer bar
	SKC_UIMain[decision_border_key].TimerBorder = CreateFrame("Frame",nil,SKC_UIMain,"TranslucentFrameTemplate");
	SKC_UIMain[decision_border_key].TimerBorder:SetSize(210,40);
	SKC_UIMain[decision_border_key].TimerBorder:SetPoint("TOP",SKC_UIMain[decision_border_key].Roll_Btn,"BOTTOM",0,-3);
	SKC_UIMain[decision_border_key].TimerBorder.Bg:SetAlpha(1.0);
	-- status bar
	SKC_UIMain[decision_border_key].TimerBar = CreateFrame("StatusBar",nil,SKC_UIMain);
	SKC_UIMain[decision_border_key].TimerBar:SetSize(186,16);
	SKC_UIMain[decision_border_key].TimerBar:SetPoint("CENTER",SKC_UIMain[decision_border_key].TimerBorder,"CENTER",0,-1);
	-- background texture
	SKC_UIMain[decision_border_key].TimerBar.bg = SKC_UIMain[decision_border_key].TimerBar:CreateTexture(nil,"BACKGROUND",nil,-7);
	SKC_UIMain[decision_border_key].TimerBar.bg:SetAllPoints(SKC_UIMain[decision_border_key].TimerBar);
	SKC_UIMain[decision_border_key].TimerBar.bg:SetColorTexture(unpack(THEME.STATUS_BAR_COLOR));
	SKC_UIMain[decision_border_key].TimerBar.bg:SetAlpha(0.8);
	-- bar texture
	SKC_UIMain[decision_border_key].TimerBar.Bar = SKC_UIMain[decision_border_key].TimerBar:CreateTexture(nil,"BACKGROUND",nil,-6);
	SKC_UIMain[decision_border_key].TimerBar.Bar:SetColorTexture(0,0,0);
	SKC_UIMain[decision_border_key].TimerBar.Bar:SetAlpha(1.0);
	-- set status texture
	SKC_UIMain[decision_border_key].TimerBar:SetStatusBarTexture(SKC_UIMain[decision_border_key].TimerBar.Bar);
	-- add text
	SKC_UIMain[decision_border_key].TimerText = SKC_UIMain[decision_border_key]:CreateFontString(nil,"ARTWORK")
	SKC_UIMain[decision_border_key].TimerText:SetFontObject("GameFontHighlightSmall")
	SKC_UIMain[decision_border_key].TimerText:SetPoint("CENTER",SKC_UIMain[decision_border_key].TimerBar,"CENTER")
	SKC_UIMain[decision_border_key].TimerText:SetText(LOOT_DECISION.MAX_TIME)
	-- values
	SKC_UIMain[decision_border_key].TimerBar:SetMinMaxValues(0,LOOT_DECISION.MAX_TIME);
	SKC_UIMain[decision_border_key].TimerBar:SetValue(0);
    
	SKC_UIMain:Hide();
	return SKC_UIMain;
end

--------------------------------------
-- EVENTS
--------------------------------------
local f1 = CreateFrame("Frame");
f1:RegisterEvent("ADDON_LOADED");
f1:SetScript("OnEvent", SKC_Main.OnAddonLoad);

local f2 = CreateFrame("Frame");
f2:RegisterEvent("OPEN_MASTER_LOOT_LIST");
f2:SetScript("OnEvent", SKC_Main.InitiateLootDecision);

local f3 = CreateFrame("Frame");
f3:RegisterEvent("CHAT_MSG_ADDON");
f3:SetScript("OnEvent", SKC_Main.AddonMessageRead);

local f4 = CreateFrame("Frame");
f4:RegisterEvent("RAID_ROSTER_UPDATE");
f4:SetScript("OnEvent", SKC_Main.SyncLiveWithRaid);

local f5 = CreateFrame("Frame");
f5:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
f5:SetScript("OnEvent", SKC_Main.StartSKC);
