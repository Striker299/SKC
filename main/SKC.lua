--------------------------------------
-- SKC
--------------------------------------
-- TODO:
-- Change SaveLoot name to OnOpenMasterLoot
-- Remove entire scan / save of loot from OnOpenMasterLoot, instead just find first elligile item and print raid warning to distribute that
-- Create new function OnOpenLoot, which fires on LOOT_OPENED, and just prints the name of all epic or better items on the corpse to raid
-- package AI and LO with GuildData instead (GuildData is all data that only GL can send / must be verified to come from GL)
-- serialize communications
-- make loot officers only ones able to push (client checks that sender is loot officer)
-- make guild leader only one that sends LootOfficers and ActiveRaids (change name) i.e. not auto sync based on time stamps
-- client chekcs that sender of GuildData is in fact the guild leader
-- make init slash command for guild data
--------------------------------------
-- ADDON CONSTRUCTOR
--------------------------------------
SKC = LibStub("AceAddon-3.0"):NewAddon("SKC","AceComm-3.0","AceConsole-3.0");
SKC.lib_ser = LibStub:GetLibrary("AceSerializer-3.0");
SKC.lib_comp = LibStub:GetLibrary("LibCompress");
SKC.lib_enc = SKC.lib_comp:GetAddonEncodeTable();
--------------------------------------
-- DEV CONTROLS
--------------------------------------
SKC.DEV = {
	GL_OVRD = "Paskal", -- name of faux GL to override guild leader permissions (local)
    ML_OVRD = nil, -- name of faux ML override master looter permissions (local)
    LOOT_SAFE_MODE = false, -- true if saving loot is immediately rejected
    LOOT_DIST_DISABLE = true, -- true if loot distribution is disabled
    LOG_ACTIVE_OVRD = false, -- true to force logging
    GUILD_CHARS_OVRD = { -- characters which are pushed into GuildData
		-- Freznic = true,
	},
    ACTIVE_RAID_OVRD = false, -- true if SKC can be used outside of active raids
    LOOT_OFFICER_OVRD = false, -- true if SKC can be used without loot officer 
	VERBOSITY_LEVEL = 0,-- verbosity level (debug messages at or below this level will print)
	VERBOSE = { -- verbosity levels
		COMM = 1,
		LOOT = 2,
		GUI = 3,
		GUILD = 3,
	}
};
--------------------------------------
-- CONSTANTS
--------------------------------------
SKC.ADDON_VERSION = GetAddOnMetadata("NovaWorldBuffs", "Version");
SKC.DATE_FORMAT = "%m/%d/%Y %I:%M:%S %p";
SKC.DAYS_TO_SECS = 86400;
SKC.UI_DIMS = {
	MAIN_WIDTH = 815,
	MAIN_HEIGHT = 450,
	MAIN_BORDER_Y_TOP = -60,
	MAIN_BORDER_PADDING = 15,
	SK_TAB_TITLE_CARD_WIDTH = 80,
	SK_TAB_TITLE_CARD_HEIGHT = 40,
	LOOT_GUI_TITLE_CARD_WIDTH = 80,
	LOOT_GUI_TITLE_CARD_HEIGHT = 40,
	SK_FILTER_WIDTH = 255,
	SK_FILTER_HEIGHT = 205,
	SK_FILTER_Y_OFFST = -35,
	SKC_STATUS_WIDTH = 255,
	SKC_STATUS_HEIGHT = 115,
	DECISION_WIDTH = 250,
	DECISION_HEIGHT = 160,
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
	BTN_WIDTH = 75,
	BTN_HEIGHT = 40,
	LOOT_BTN_WIDTH = 60,
	LOOT_BTN_HEIGHT = 35,
	STATUS_BAR_BRDR_WIDTH = 210,
	STATUS_BAR_BRDR_HEIGHT = 40,
	STATUS_BAR_WIDTH_OFFST = 24,
	STATUS_BAR_HEIGHT_OFFST = 24,
	CSV_WIDTH = 660,
	CSV_HEIGHT = 300,
	CSV_EB_WIDTH = 600,
	CSV_EB_HEIGHT = 200,
};
SKC.THEME = { -- general color themes
	PRINT = {
		NORMAL = {r = 26/255, g = 1, b = 178/255, hex = "1affb2"},
		WARN = {r = 1, g = 0.8, b = 0, hex = "ffcc00"},
		ALERT = {r = 1, g = 0, b = 1, hex = "ff00ff"},
		ERROR = {r = 1, g = 0.2, b = 0, hex = "ff3300"},
		DEBUG = {r = 0, g = 0.8, b = 1, hex = "00ccff"},
		HELP = {r = 1, g = 204/255, b = 0, hex = "ffcc00"},
	},
	STATUS_BAR_COLOR = {0.0,0.6,0.0},
};
SKC.CHANNELS = { -- channels for inter addon communication (const)
	LOGIN_SYNC_CHECK = "?Q!@$8a1pc8QqYyH",
	LOGIN_SYNC_PUSH = "6-F?832qBmrJE?pR",
	LOGIN_SYNC_PUSH_RQST = "d$8B=qB4VsW&&Y^D",
	SYNC_PUSH = "8EtTWxyA$r6xi3=F",
	LOOT = "xBPE9,-Fjsc+A#rm",
	LOOT_DECISION = "ksg(Ak2.*/@&+`8Q",
	LOOT_DECISION_PRINT = "xP@&!9hQxY]1K&C4",
	LOOT_OUTCOME = "aP@yX9hQf}89K&C4",
};
local OnClick_EditDropDownOption; -- forward declare for drop down menu details
SKC.CLASSES = { -- wow classes
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
				val = 1,
				text = "Balance",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Balance") end,
			},
			Resto = {
				val = 2,
				text = "Resto",
				RR = "Healer",
				func = function (self) OnClick_EditDropDownOption("Spec","Resto") end
			},
			FeralTank = {
				val = 3,
				text = "FeralTank",
				RR = "Tank",
				func = function (self) OnClick_EditDropDownOption("Spec","FeralTank") end
			},
			FeralDPS = {
				val = 4,
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
				val = 5,
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
				val = 6,
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
				val = 7,
				text = "Holy",
				RR = "Healer",
				func = function (self) OnClick_EditDropDownOption("Spec","Holy") end
			},
			Prot = {
				val = 8,
				text = "Prot",
				RR = "Tank",
				func = function (self) OnClick_EditDropDownOption("Spec","Prot") end
			},
			Ret = {
				val = 9,
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
				val = 10,
				text = "Holy",
				RR = "Healer",
				func = function (self) OnClick_EditDropDownOption("Spec","Holy") end
			},
			Shadow = {
				val = 11,
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
				val = 12,
				text = "Any",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Any") end
			},
			Daggers = {
				val = 13,
				text = "Daggers",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Daggers") end
			},
			Swords = {
				val = 14,
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
			r = 0.0, 
			g = 0.44,
			b = 0.87,
			hex = "0070DE"
		},
		Specs = {
			Ele = {
				val = 15,
				text = "Ele",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Ele") end
			},
			Enh = {
				val = 16,
				text = "Enh",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","Enh") end
			},
			Resto = {
				val = 17,
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
				val = 18,
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
				val = 19,
				text = "DPS",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","DPS") end
			},
			Prot = {
				val = 20,
				text = "Prot",
				RR = "Tank",
				func = function (self) OnClick_EditDropDownOption("Spec","Prot") end
			},
			TwoHanded = {
				val = 21,
				text = "TwoHanded",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","TwoHanded") end
			},
			DualWield = {
				val = 22,
				text = "DualWield",
				RR = "DPS",
				func = function (self) OnClick_EditDropDownOption("Spec","DualWield") end
			},
		},
		DEFAULT_SPEC = "DPS",
	},
};
SKC.TIER_ARMOR_SETS = { -- map from armor set name to ordered list of individual item names (used as a shortcut for prio doc import)
	["Cenarion Raiment"] = {
		"Cenarion Belt",
		"Cenarion Boots",
		"Cenarion Bracers",
		"Cenarion Vestments",
		"Cenarion Gloves",
		"Cenarion Helm",
		"Cenarion Leggings",
		"Cenarion Spaulders",
	},
	["Stormrage Raiment"] = {
		"Stormrage Belt",
		"Stormrage Boots",
		"Stormrage Bracers",
		"Stormrage Chestguard",
		"Stormrage Cover",
		"Stormrage Handguards",
		"Stormrage Legguards",
		"Stormrage Pauldrons",
	},
	["Giantstalker Armor"] = {
		"Giantstalker's Belt",
		"Giantstalker's Boots",
		"Giantstalker's Bracers",
		"Giantstalker's Breastplate",
		"Giantstalker's Epaulets",
		"Giantstalker's Gloves",
		"Giantstalker's Helmet",
		"Giantstalker's Leggings",
	},
	["Dragonstalker Armor"] = {
		"Dragonstalker's Belt",
		"Dragonstalker's Bracers",
		"Dragonstalker's Breastplate",
		"Dragonstalker's Gauntlets",
		"Dragonstalker's Greaves",
		"Dragonstalker's Helm",
		"Dragonstalker's Legguards",
		"Dragonstalker's Spaulders",
	},
	["Arcanist Regalia"] = {
		"Arcanist Belt",
		"Arcanist Bindings",
		"Arcanist Crown",
		"Arcanist Boots",
		"Arcanist Gloves",
		"Arcanist Leggings",
		"Arcanist Mantle",
		"Arcanist Robes",
	},
	["Netherwind Regalia"] = {
		"Netherwind Belt",
		"Netherwind Bindings",
		"Netherwind Boots",
		"Netherwind Crown",
		"Netherwind Mantle",
		"Netherwind Gloves",
		"Netherwind Pants",
		"Netherwind Robes",
	},
	["Lawbringer Armor"] = {
		"Lawbringer Belt",
		"Lawbringer Boots",
		"Lawbringer Bracers",
		"Lawbringer Chestguard",
		"Lawbringer Gauntlets",
		"Lawbringer Helm",
		"Lawbringer Legplates",
		"Lawbringer Spaulders",	
	},
	["Judgement Armor"] = {
		"Judgement Belt",
		"Judgement Bindings",
		"Judgement Breastplate",
		"Judgement Crown",
		"Judgement Gauntlets",
		"Judgement Legplates",
		"Judgement Sabatons",
		"Judgement Spaulders",
	},
	["Vestments of Prophecy"] = {
		"Boots of Prophecy",
		"Circlet of Prophecy",
		"Girdle of Prophecy",
		"Gloves of Prophecy",
		"Pants of Prophecy",
		"Mantle of Prophecy",
		"Robes of Prophecy",
		"Vambraces of Prophecy",
	},
	["Vestments of Transcendence"] = {
		"Belt of Transcendence",
		"Bindings of Transcendence",
		"Boots of Transcendence",
		"Halo of Transcendence",
		"Handguards of Transcendence",
		"Leggings of Transcendence",
		"Pauldrons of Transcendence",
		"Robes of Transcendence",
	},
	["Nightslayer Armor"] = {
		"Nightslayer Belt",
		"Nightslayer Boots",
		"Nightslayer Bracelets",
		"Nightslayer Chestpiece",
		"Nightslayer Cover",
		"Nightslayer Gloves",
		"Nightslayer Pants",
		"Nightslayer Shoulder Pads",
	},
	["Bloodfang Armor"] = {
		"Bloodfang Belt",
		"Bloodfang Boots",
		"Bloodfang Bracers",
		"Bloodfang Chestpiece",
		"Bloodfang Gloves",
		"Bloodfang Hood",
		"Bloodfang Pants",
		"Bloodfang Spaulders",
	},
	["The Earthfury"] = {
		"Earthfury Belt",
		"Earthfury Boots",
		"Earthfury Bracers",
		"Earthfury Vestments",
		"Earthfury Epaulets",
		"Earthfury Gauntlets",
		"Earthfury Helmet",
		"Earthfury Legguards",
	},
	["The Ten Storms"] = {
		"Belt of Ten Storms",
		"Bracers of Ten Storms",
		"Breastplate of Ten Storms",
		"Epaulets of Ten Storms",
		"Gauntlets of Ten Storms",
		"Greaves of Ten Storms",
		"Helmet of Ten Storms",
		"Legplates of Ten Storms",
	},
	["Felheart Raiment"] = {
		"Felheart Belt",
		"Felheart Bracers",
		"Felheart Gloves",
		"Felheart Pants",
		"Felheart Robes",
		"Felheart Shoulder Pads",
		"Felheart Horns",
		"Felheart Slippers",
	},
	["Nemesis Raiment"] = {
		"Nemesis Belt",
		"Nemesis Boots",
		"Nemesis Bracers",
		"Nemesis Gloves",
		"Nemesis Leggings",
		"Nemesis Robes",
		"Nemesis Skullcap",
		"Nemesis Spaulders",	
	},
	["Battlegear of Might"] = {
		"Belt of Might",
		"Bracers of Might",
		"Breastplate of Might",
		"Gauntlets of Might",
		"Helm of Might",
		"Legplates of Might",
		"Pauldrons of Might",
		"Sabatons of Might",
	},
	["Battlegear of Wrath"] = {
		"Bracelets of Wrath",
		"Breastplate of Wrath",
		"Gauntlets of Wrath",
		"Helm of Wrath",
		"Legplates of Wrath",
		"Pauldrons of Wrath",
		"Sabatons of Wrath",
		"Waistband of Wrath",
	},

};
SKC.CLASS_SPEC_MAP = { -- used to quickly get class spec name from value
	"DruidBalance",
	"DruidResto",
	"DruidFeralTank",
	"DruidFeralDPS",
	"HunterAny",
	"MageAny",
	"PaladinHoly",
	"PaladinProt",
	"PaladinRet",
	"PriestHoly",
	"PriestShadow",
	"RogueAny",
	"RogueDaggers",
	"RogueSwords",
	"ShamanEle",
	"ShamanEnh",
	"ShamanResto",
	"WarlockAny",
	"WarriorDPS",
	"WarriorProt",
	"WarriorTwoHanded",
	"WarriorDualWield",
};
SKC.SPEC_MAP = { -- used to quickly get spec name from value
	"Balance",
	"Resto",
	"FeralTank",
	"FeralDPS",
	"Any",
	"Any",
	"Holy",
	"Prot",
	"Ret",
	"Holy",
	"Shadow",
	"Any",
	"Daggers",
	"Swords",
	"Ele",
	"Enh",
	"Resto",
	"Any",
	"DPS",
	"Prot",
	"TwoHanded",
	"DualWield",
};
SKC.CHARACTER_DATA = { -- fields used to define character
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
				val = 0,
				text = "DPS",
			},
			Healer = {
				val = 1,
				text = "Healer",
			},
			Tank = {
				val = 2,
				text = "Tank",
			},
		},
	},
	["Guild Role"] = {
		text = "Guild Role",
		OPTIONS = {
			None = {
				val = 0,
				text = "None",
				func = function (self) OnClick_EditDropDownOption("Guild Role","None") end,
			},
			Disenchanter = {
				val = 1,
				text = "Disenchanter",
				func = function (self) OnClick_EditDropDownOption("Guild Role","Disenchanter") end,
			},
			Banker = {
				val = 2,
				text = "Banker",
				func = function (self) OnClick_EditDropDownOption("Guild Role","Banker") end,
			},
		},
	},
	Status = {
		text = "Status",
		OPTIONS = {
			Main = {
				val = 0,
				text = "Main",
				func = function (self) OnClick_EditDropDownOption("Status","Main") end,
			},
			Alt = {
				val = 1,
				text = "Alt",
				func = function (self) OnClick_EditDropDownOption("Status","Alt") end,
			},
		},
	},
	Activity = {
		text = "Activity",
		OPTIONS = {
			Active = {
				val = 0,
				text = "Active",
				func = function (self) OnClick_EditDropDownOption("Activity","Active") end,
			},
			Inactive = {
				val = 1,
				text = "Inactive",
				func = function (self) OnClick_EditDropDownOption("Activity","Inactive") end,
			},
		},
	},	
};
SKC.LOOT_DECISION = {
	PENDING = 1,
	PASS = 2,
	SK = 3,
	ROLL = 4,
	TEXT_MAP = {
		"PENDING",
		"PASS",
		"SK",
		"ROLL",
	},
	OPTIONS = {
		MAX_DECISION_TIME = 30,
		TIME_STEP = 1,
		ML_WAIT_BUFFER = 5, -- additional time that master looter waits before triggering auto pass (accounts for transmission delays)
		KICKOFF_DELAY = 3, -- delay after finishing one loot distribution before next begins
	},
};
SKC.SYNC_PARAMS = {
	-- LoginSyncCheckTicker_InitDelay = 5, -- seconds
	-- LoginSyncCheckTicker_Intvl = 10, -- seconds between function calls
	-- LoginSyncCheckTicker_MaxTicks = 59, -- 1 tick = 1 sec
};
SKC.PRIO_TIERS = { -- possible prio tiers and associated numerical ordering
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
SKC.LOG_OPTIONS = {
	["Timestamp"] = {
		Text = "Timestamp",
	},
	["Master Looter"] = {
		Text = "Master Looter",
		Options = {
			THIS_PLAYER = UnitName("player"),
		},
	},
	["Event Type"] = {
		Text = "Event Type",
		Options = {
			Winner = "Winner",
			ManEdit = "Manual Edit",
			Response = "Response",
			DE = "Disenchant",
			GB = "Guild Bank",
			NE = "None Elligible",
			AL = "Auto Loot",
		},
	},
	["Subject"] = {
		Text = "Subject",
	},
	["Class"] = {
		Text = "Class",
	},
	["Spec"] = {
		Text = "Spec",
	},
	["Status"] = {
		Text = "Status",
	},
	["Action"] = {
		Text = "Action",
	},
	["Item"] = {
		Text = "Item",
	},
	["SK List"] = {
		Text = "SK List",
		Options = {
			MSK = "MSK",
			TSK = "TSK",
		}
	},
	["Prio"] = {
		Text = "Prio",
	},
	["Current SK Position"] = {
		Text = "Current SK Position",
	},
	["New SK Position"] = {
		Text = "New SK Position",
	},
	["Roll"] = {
		Text = "Roll",
	},
	["Item Receiver"] = {
		Text = "Item Receiver",
	},
};
SKC.RAID_NAME_MAP = {
	RFC = "Ragefire Chasm",
	WC = "Wailing Caverns",
	VC = "The Deadmines",
	ONY = "Onyxia's Lair",
	MC = "Molten Core",
	BWL = "Blackwing Lair",
	ZG = "Zul'Gurub",
	AQ20 = "Ruins of Ahn'Qiraj",
	AQ40 = "Temple of Ahn'Qiraj",
	NAXX = "Naxxramas",
};
SKC.STATUS_ENUM = {
	ACTIVE = {
		val = 0,
		text = "Active",
		color = {0,1,0},
	},
	DISABLED = {
		val = 1,
		text = "Disabled",
		color = {1,0,0},
	},
	INACTIVE_GL = {
		val = 2,
		text = "Inactive (GL)",
		color = {1,0,0},
	},
	INACTIVE_VER = {
		val = 3,
		text = "Inactive (VER)",
		color = {1,0,0},
	},
	INACTIVE_RAID = {
		val = 4,
		text = "Inactive (RAID)",
		color = {1,0,0},
	},
	INACTIVE_ML = {
		val = 5,
		text = "Inactive (ML)",
		color = {1,0,0},
	},
	INACTIVE_LO = {
		val = 6,
		text = "Inactive (LO)",
		color = {1,0,0},
	},
	INACTIVE_AI = {
		val = 7,
		text = "Inactive (AI)",
		color = {1,0,0},
	},
};
--------------------------------------
-- VARIABLES
--------------------------------------
SKC.Status = SKC.STATUS_ENUM.INACTIVE_GL; -- SKC status state enumeration
-- local tmp_sync_var = {}; -- temporary variable used to hold incoming data when synchronizing
SKC.UnFilteredCnt = 0; -- defines max count of sk cards to scroll over (XXX)
-- local SK_MessagesSent = 0;
-- local SK_MessagesReceived = 0;
SKC.event_states = { -- tracks if certain events have fired
	AddonLoaded = false,
	DropDownID = 0, -- used to track state of drop down menu
	SetSKInProgress = false; -- true when SK position is being set
	InitGuildSync = false; -- used to control for first time setup
	LoggingActive = SKC.DEV.LOG_ACTIVE_OVRD, -- latches true when raid is entered (controls RaidLog)
	LoginSyncPartner = nil, -- name of sender who answered LoginSyncCheck first
	ReadInProgress = {
		MSK = false,
		TSK = false,
		GuildData = false,
		LootPrio = false,
		Bench = false,
		ActiveRaids = false,
		LootOfficers = false,
	},
	PushInProgress = {
		MSK = false,
		TSK = false,
		GuildData = false,
		LootPrio = false,
		Bench = false,
		ActiveRaids = false,
		LootOfficers = false,
	},
};
-- local blacklist = {}; -- map of names for which SyncPushRead's are blocked (due to addon version or malformed messages)
SKC.Timers = {
	LoginSyncCheck = {-- ticker that requests sync each iteration until over or cancelled
		Ticker = nil, 
		Ticks = nil,
		ElapsedTime = nil,
	}, 
	Loot = { -- current loot timer
		Ticker = nil, -- ticker that requests sync each iteration until over or cancelled
		Ticks = nil,
		ElapsedTime = nil,
	}, 
};
-- SKC.event_states.LoginSyncCheckTicker_Ticks = event_states.LoginSyncCheckTicker_MaxTicks + 1;
SKC.DEBUG = {
	ReadTime = {
		GLP = nil,
		LOP = nil,
		GuildData = nil,
		MSK = nil,
		TSK = nil,
	},
	PushTime = {
		GLP = nil,
		LOP = nil,
		GuildData = nil,
		MSK = nil,
		TSK = nil,
	},
};
--------------------------------------
-- DB INIT
--------------------------------------
SKC.DB_DEFAULT = {
    char = {
		ENABLED = true,
        ADDON_VERSION = GetAddOnMetadata("SKC", "Version"),
		GLP = nil, -- GuildLeaderProtected
		LOP = nil, -- LootOfficersProtected
		GD = nil, -- GuildData
		MSK = nil, -- SK_List
		TSK = nil, -- SK_List
		LM = nil, -- LootManager
		FS = { -- filter states
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
		},
		LOG = {}, -- data logging
    },
};