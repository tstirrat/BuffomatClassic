---@type BuffomatAddon
local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---@class BuffomatAddon
---@field ALL_PROFILES table<string> Lists all buffomat profile names (group, solo... etc)
---@field RESURRECT_CLASS table<string> Classes who can resurrect others
---@field MANA_CLASSES table<string> Classes with mana resource
---@field locales BuffomatTranslations (same as BOM.L)
---@field L BuffomatTranslations (same as BOM.locales)
---@field AllBuffomatSpells table<number, SpellDef> All spells known to Buffomat
---@field CancelBuffs table<number, SpellDef> All spells to be canceled on detection
---@field ItemCache table<number, table> Precreated precached items
---
---@field ForceProfile string|nil Nil will choose profile name automatically, otherwise this profile will be used
---@field ArgentumDawn table Equipped AD trinket: Spell to and zone ids to check
---@field BuffExchangeId table<number, table<number>> Combines spell ids of spellrank flavours into main spell id
---@field BuffIgnoreAll table<number> Having this buff on target excludes the target (phaseshifted imp for example)
---@field CachedHasItems table Items in player's bag
---@field CancelBuffSource string Unit who casted the buff to be auto-canceled
---@field Carrot table Equipped Riding trinket: Spell to and zone ids to check
---@field CheckForError boolean Used by error suppression code
---@field CurrentProfile State Current profile from CharacterState.Profiles
---@field CharacterState CharacterState Copy of state only for the current character, with separate states per profile
---@field SharedState State Copy of state shared with all accounts
---@field DeclineHasResurrection boolean Set to true on combat start, stop, holding Alt, cleared on party update
---@field EnchantList table<number, table<number>> Spell ids  mapping to enchant ids
---@field EnchantToSpell table<number, number> Reverse-maps enchant ids back to spells
---@field ForceTracking number|nil Defines icon id for enforced tracking
---@field ForceUpdate boolean Requests immediate spells/buffs refresh
---@field IsMoving boolean Indicated that the player is moving (updated in event handlers)
---@field ItemList table<table<number>> Group different ranks of item together
---@field ItemListSpell table<number, number> Map itemid to spell?
---@field ItemListTarget table<number, string> Remember who casted item buff on you?
---@field lastTarget string|nil Last player's target
---@field ManaLimit number Player max mana
---@field PartyUpdateNeeded boolean Requests player party update
---@field PlayerCasting boolean Indicates that the player is currently casting (updated in event handlers)
---@field SelectedSpells table<number, SpellDef>
---@field SpellIdIsSingle table<number, boolean> Whether spell ids are single buffs
---@field SpellTabsCreatedFlag boolean Indicated spells tab already populated with controls
---@field SpellToSpell table<number, number> Maps spells ids to other spell ids
---@field TBC boolean Whether we are running TBC classic
---@field WipeCachedItems boolean Command to reset cached items
---@field MinimapButton GPIMinimapButton Minimap button control
---@field Options Options
---
---@field ICON_PET string
---@field ICON_OPT_ENABLED string
---@field ICON_OPT_DISABLED string
---@field ICON_SELF_CAST_ON string
---@field ICON_SELF_CAST_OFF string
---@field CLASS_ICONS_ATLAS string
---@field CLASS_ICONS_ATLAS_TEX_COORD string
---@field ICON_EMPTY string
---@field ICON_SETTING_ON string
---@field ICON_SETTING_OFF string
---@field ICON_WHISPER_ON string
---@field ICON_WHISPER_OFF string
---@field ICON_BUFF_ON string
---@field ICON_BUFF_OFF string
---@field ICON_DISABLED string
---@field ICON_TARGET_ON string
---@field ICON_TARGET_OFF string
---@field ICON_TARGET_EXCLUDE string
---@field ICON_CHECKED string
---@field ICON_CHECKED_OFF string
---@field ICON_GROUP string
---@field ICON_GROUP_ITEM string
---@field ICON_GROUP_NONE string
---@field ICON_GEAR string
---@field IconAutoOpenOn string
---@field IconAutoOpenOnCoord table<number>
---@field IconAutoOpenOff string
---@field IconAutoOpenOffCoord table<number>
---@field IconDeathBlockOn string
---@field IconDeathBlockOff string
---@field IconDeathBlockOffCoord table<number>
---@field IconNoGroupBuffOn string
---@field IconNoGroupBuffOnCoord table<number>
---@field IconNoGroupBuffOff string
---@field IconNoGroupBuffOffCoord table<number>
---@field IconSameZoneOn string
---@field IconSameZoneOnCoord table<number>
---@field IconSameZoneOff string
---@field IconSameZoneOffCoord table<number>
---@field IconResGhostOn string
---@field IconResGhostOnCoord table<number>
---@field IconResGhostOff string
---@field IconResGhostOffCoord table<number>
---@field IconReplaceSingleOff string
---@field IconReplaceSingleOffCoord table<number>
---@field IconReplaceSingleOn string
---@field IconReplaceSingleOnCoord table<number>
---@field IconArgentumDawnOff string
---@field IconArgentumDawnOn string
---@field IconArgentumDawnOnCoord table<number>
---@field IconCarrotOff string
---@field IconCarrotOn string
---@field IconCarrotOnCoord table<number>
---@field IconMainHandOff string
---@field IconMainHandOn string
---@field IconMainHandOnCoord table<number>
---@field IconSecondaryHandOff string
---@field IconSecondaryHandOn string
---@field IconSecondaryHandOnCoord table<number>
---@field ICON_TANK string
---@field ICON_TANK_COORD table<number>
---@field ICON_PET string
---@field ICON_PET_COORD table<number>
---@field IconInPVPOff string
---@field IconInPVPOn string
---@field IconInPVPOnCoord table<number>
---@field IconInWorldOff string
---@field IconInWorldOn string
---@field IconInWorldOnCoord table<number>
---@field IconInInstanceOff string
---@field IconInInstanceOn string
---@field IconInInstanceOnCoord table<number>
---@field IconUseRankOff string
---@field IconUseRankOn string
---
---@field TOC_VERSION string Addon version from TOC file
---@field TOC_TITLE string Addon name
---@field MACRO_ICON string
---@field MACRO_ICON_DISABLED string
---@field MACRO_ICON_FULLPATH string
---@field ICON_FORMAT string
---@field PICTURE_FORMAT string
---@field MACRO_NAME string
---@field MAX_AURAS number
---@field BLESSING_ID string
---@field LOADING_SCREEN_TIMEOUT number
---@field BehaviourSettings table<string, boolean> Key names and Defaults for 'Profile' settings
---@field QuickSingleBuff Control Button for single/group buff toggling next to cast button
BOM.Class.BuffomatAddon = {}
BOM.Class.BuffomatAddon.__index = BOM.Class.BuffomatAddon

local CLASS_TAG = "buffomat_addon"
