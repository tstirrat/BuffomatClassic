--local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

local buffomatModule = BomModuleManager.buffomatModule
local constModule = BomModuleManager.constModule
local itemCacheModule = BomModuleManager.itemCacheModule

---@class BomSpellSetupModule
local spellSetupModule = {}
BomModuleManager.spellSetupModule = spellSetupModule

local buffDefinitionModule = BomModuleManager.buffDefinitionModule
local toolboxModule = BomModuleManager.toolboxModule
local profileModule = BomModuleManager.profileModule

---Flag set to true when custom spells and cancel-spells were imported from the config
local bomBuffsImportedFromConfig = false

---Formats a spell icon + spell name as a link
-- TODO: Move to SpellDef class
---@param spellInfo BomSpellCacheElement spell info from the cache via BOM.GetSpellInfo
function spellSetupModule:FormatSpellLink(spellInfo)
  if spellInfo == nil then
    return "NIL SPELL"
  end
  if spellInfo.spellId == nil then
    return "NIL SPELLID"
  end

  return "|Hspell:" .. spellInfo.spellId
          .. "|h|r |cff71d5ff"
          .. BOM.FormatTexture(spellInfo.icon)
          .. spellInfo.name
          .. "|r|h"
end

function spellSetupModule:Setup_MaybeAddCustomSpells()
  if bomBuffsImportedFromConfig then
    return
  end

  bomBuffsImportedFromConfig = true

  --for x, entry in ipairs(buffomatModule.shared.CustomSpells) do
  --  tinsert(BOM.allBuffomatBuffs, toolboxModule:CopyTable(entry))
  --end

  --for x, entry in ipairs(buffomatModule.shared.CustomCancelBuff) do
  --  tinsert(BOM.cancelBuffs, toolboxModule:CopyTable(entry))
  --end
end

function spellSetupModule:Setup_ResetCaches()
  BOM.selectedBuffs = {}
  BOM.cancelForm = {}
  BOM.allSpellIds = {}
  BOM.spellIdtoBuffId = {}
  BOM.spellIdIsSingleLookup = {}
  BOM.configToSpellLookup = --[[---@type BomAllBuffsTable]] {}

  buffomatModule.shared.Cache = buffomatModule.shared.Cache or {}
  buffomatModule.shared.Cache.Item2 = buffomatModule.shared.Cache.Item2 or {}
end

function spellSetupModule:Setup_CancelBuffs()
  for i, cancelBuff in ipairs(BOM.cancelBuffs) do
    -- save "buffId"
    --spell.buffId = spell.buffId or spell.singleId

    if cancelBuff.singleFamily then
      for sindex, sID in ipairs(cancelBuff.singleFamily) do
        BOM.spellIdtoBuffId[sID] = cancelBuff.buffId
      end
    end

    -- GetSpellNames and set default duration
    local spellInfo = BOM.GetSpellInfo(cancelBuff.highestRankSingleId)

    if spellInfo then
      local spellInfoValue = --[[---@not nil]] spellInfo

      cancelBuff.singleText = spellInfoValue.name
      spellInfoValue.rank = GetSpellSubtext(cancelBuff.highestRankSingleId) or ""
      cancelBuff.singleLink = self:FormatSpellLink((--[[---@not nil]] spellInfo))
      cancelBuff.spellIcon = spellInfoValue.icon
    end

    toolboxModule:iMerge(BOM.allSpellIds, cancelBuff.singleFamily)

    for j, profil in ipairs(profileModule.ALL_PROFILES) do
      if buffomatModule.character[profil].CancelBuff[cancelBuff.buffId] == nil then
        buffomatModule.character[profil].CancelBuff[cancelBuff.buffId] = buffDefinitionModule:New(0)
        buffomatModule.character[profil].CancelBuff[cancelBuff.buffId].Enable = cancelBuff.default or false
      end
    end
  end
end

---@param buffDef BomBuffDefinition
---@param add boolean
function spellSetupModule:Setup_EachSpell_Consumable(add, buffDef)
  -- call results are cached if they are successful, should not be a performance hit
  local itemInfo = BOM.GetItemInfo(--[[---@not nil]] buffDef:GetFirstItem())

  if not buffDef.isScanned and itemInfo then
    if (not itemInfo
            or not (--[[---@not nil]] itemInfo).itemName
            or not (--[[---@not nil]] itemInfo).itemLink
            or not (--[[---@not nil]] itemInfo).itemTexture)
            and buffomatModule.shared.Cache.Item2[buffDef.items]
    then
      itemInfo = buffomatModule.shared.Cache.Item2[buffDef.items]

    elseif (not itemInfo
            or not (--[[---@not nil]] itemInfo).itemName
            or not (--[[---@not nil]] itemInfo).itemLink
            or not (--[[---@not nil]] itemInfo).itemTexture)
            and itemCacheModule.cache[--[[---@not nil]] buffDef:GetFirstItem()]
    then
      itemInfo = itemCacheModule.cache[--[[---@not nil]] buffDef:GetFirstItem()]
    end

    if itemInfo
            and (--[[---@not nil]] itemInfo).itemName
            and (--[[---@not nil]] itemInfo).itemLink
            and (--[[---@not nil]] itemInfo).itemTexture
    then
      add = true
      buffDef.singleText = (--[[---@not nil]] itemInfo).itemName
      buffDef.singleLink = BOM.FormatTexture((--[[---@not nil]] itemInfo).itemTexture)
              .. (--[[---@not nil]] itemInfo).itemLink
      buffDef.itemIcon = (--[[---@not nil]] itemInfo).itemTexture
      buffDef.isScanned = true

      buffomatModule.shared.Cache.Item2[buffDef.items] = itemInfo
    else
      --buffomatModule:P("Item not found! Spell=" .. tostring(spell.singleId)
      --      .. " Item=" .. tostring(spell.item))

      -- Go delayed fetch
      local item = Item:CreateFromItemID(buffDef.items)
      item:ContinueOnItemLoad(function()
        local name = item:GetItemName()
        local link = item:GetItemLink()
        local icon = item:GetItemIcon()
        buffomatModule.shared.Cache.Item2[buffDef.items] = { itemName = name,
                                                             itemLink = link,
                                                             itemIcon = icon }
      end)
    end
  else
    add = true
  end

  --if buffDef.items == nil then
  --  buffDef.items = { buffDef.items }
  --end

  return add
end

---@param spell BomBuffDefinition
function spellSetupModule:Setup_EachSpell_CacheUpdate(spell)
  -- get highest rank and store SpellID=buffId
  if spell.singleFamily then
    for sindex, eachSingleId in ipairs(spell.singleFamily) do
      BOM.spellIdtoBuffId[eachSingleId] = spell.buffId
      BOM.spellIdIsSingleLookup[eachSingleId] = true
      BOM.configToSpellLookup[eachSingleId] = spell

      if IsSpellKnown(eachSingleId) then
        spell.highestRankSingleId = eachSingleId
      end
    end
  end

  if spell.highestRankSingleId then
    BOM.spellIdtoBuffId[spell.highestRankSingleId] = spell.buffId
    BOM.spellIdIsSingleLookup[spell.highestRankSingleId] = true
    BOM.configToSpellLookup[spell.highestRankSingleId] = spell
  end

  if spell.groupFamily then
    for sindex, eachGroupId in ipairs(spell.groupFamily) do
      BOM.spellIdtoBuffId[eachGroupId] = spell.buffId
      BOM.configToSpellLookup[eachGroupId] = spell

      if IsSpellKnown(eachGroupId) then
        spell.highestRankGroupId = eachGroupId
      end
    end
  end

  if spell.highestRankGroupId then
    BOM.spellIdtoBuffId[spell.highestRankGroupId] = spell.buffId
    BOM.configToSpellLookup[spell.highestRankGroupId] = spell
  end
end

---@param buffDef BomBuffDefinition
function spellSetupModule:Setup_EachSpell_SetupNonConsumable(buffDef)
  -- Load spell info and save some good fields for later use
  local spellInfo = BOM.GetSpellInfo(buffDef.highestRankSingleId)

  if spellInfo ~= nil then
    local spellInfoValue = --[[---@not nil]] spellInfo

    buffDef.singleText = spellInfoValue.name
    spellInfoValue.rank = GetSpellSubtext(buffDef.highestRankSingleId) or ""
    buffDef.singleLink = self:FormatSpellLink(spellInfoValue)
    buffDef.spellIcon = spellInfoValue.icon

    if buffDef.type == "tracking" then
      buffDef.trackingIconId = spellInfoValue.icon
      buffDef.trackingSpellName = spellInfoValue.name
    end

    if not buffDef.isInfo
            and not buffDef.isConsumable
            and buffDef.singleDuration
            and buffomatModule.shared.Duration[spellInfoValue.name] == nil
            and IsSpellKnown(buffDef.highestRankSingleId) then
      buffomatModule.shared.Duration[spellInfoValue.name] = buffDef.singleDuration
    end
  end -- spell info returned success
end

---@param spell BomBuffDefinition
function spellSetupModule:Setup_EachSpell_SetupGroupBuff(spell)
  local spellInfo = BOM.GetSpellInfo(spell.highestRankGroupId)

  if spellInfo ~= nil then
    local spellInfoValue = --[[---@not nil]] spellInfo

    spell.groupText = spellInfoValue.name
    spellInfoValue.rank = GetSpellSubtext(spell.highestRankGroupId) or ""
    spell.groupLink = self:FormatSpellLink(spellInfoValue)

    if spell.groupDuration
            and buffomatModule.shared.Duration[spellInfoValue.name] == nil
            and IsSpellKnown(spell.highestRankGroupId)
    then
      buffomatModule.shared.Duration[spellInfoValue.name] = spell.groupDuration
    end
  end
end

---Adds a spell to the palette of spells to configure and use, for each profile
---@param spell BomBuffDefinition
function spellSetupModule:Setup_EachSpell_Add(spell)
  tinsert(BOM.selectedBuffs, spell)
  toolboxModule:iMerge(BOM.allSpellIds, spell.singleFamily, spell.groupFamily,
          spell.highestRankSingleId, spell.highestRankGroupId)

  if spell.cancelForm then
    toolboxModule:iMerge(BOM.cancelForm, spell.singleFamily, spell.groupFamily,
            spell.highestRankSingleId, spell.highestRankGroupId)
  end

  --setDefaultValues!
  for j, eachProfile in ipairs(profileModule.ALL_PROFILES) do
    ---@type BomBuffDefinition
    local profileSpell = buffomatModule.character[eachProfile].Spell[spell.buffId]

    if profileSpell == nil then
      buffomatModule.character[eachProfile].Spell[spell.buffId] = buffDefinitionModule:New(0)
      profileSpell = buffomatModule.character[eachProfile].Spell[spell.buffId]

      profileSpell.Class = profileSpell.Class or {}
      profileSpell.ForcedTarget = profileSpell.ForcedTarget or {}
      profileSpell.ExcludedTarget = profileSpell.ExcludedTarget or {}
      profileSpell.Enable = spell.default or false

      if spell:HasClasses() then
        local SelfCast = true
        profileSpell.SelfCast = false

        for ci, class in ipairs(constModule.CLASSES) do
          profileSpell.Class[class] = tContains(spell.targetClasses, class)
          SelfCast = profileSpell.Class[class] and false or SelfCast
        end

        profileSpell.ForcedTarget = {}
        profileSpell.ExcludedTarget = {}
        profileSpell.SelfCast = SelfCast
      end
    else
      profileSpell.Class = profileSpell.Class or {}
      profileSpell.ForcedTarget = profileSpell.ForcedTarget or {}
      profileSpell.ExcludedTarget = profileSpell.ExcludedTarget or {}
    end

  end -- for all profile names
end

---For each spell known to Buffomat check whether the player can use it and the
---category where it will go. Build mapping tables to quickly find spells
---@param buff BomBuffDefinition
function spellSetupModule:Setup_EachBuff(buff)
  buff.SkipList = {}
  BOM.configToSpellLookup[buff.buffId] = buff

  self:Setup_EachSpell_CacheUpdate(buff)

  -- GetSpellNames and set default duration
  if buff.highestRankSingleId and not buff.isConsumable then
    self:Setup_EachSpell_SetupNonConsumable(buff)
  end

  if buff.highestRankGroupId then
    self:Setup_EachSpell_SetupGroupBuff(buff)
  end

  -- has Spell? Manacost?
  local add = false

  -- Add single buffs which are known
  if IsSpellKnown(buff.highestRankSingleId) then
    add = true
    buff.singleMana = 0
    local cost = GetSpellPowerCost(buff.singleText)

    if type(cost) == "table" then
      for j = 1, #cost do
        if cost[j] and cost[j].name == "MANA" then
          buff.singleMana = cost[j].cost or 0
        end
      end
    end
  end

  -- Add group buffs which are known
  if buff.groupText and IsSpellKnown(buff.highestRankGroupId) then
    add = true
    buff.groupMana = 0
    local cost = GetSpellPowerCost(buff.groupText)

    if type(cost) == "table" then
      for j = 1, #cost do
        if cost[j] and cost[j].name == "MANA" then
          buff.groupMana = cost[j].cost or 0
        end
      end
    end
  end

  if buff.isConsumable then
    add = self:Setup_EachSpell_Consumable(add, buff)
  end

  if buff.isInfo then
    add = true
  end

  if add then
    self:Setup_EachSpell_Add(buff)
  end -- if spell is OK to be added
end

---Scan all spells known to Buffomat and see if they are available to the player
function spellSetupModule:SetupAvailableSpells()
  local character = buffomatModule.character
  for i, eachProfile in ipairs(profileModule.ALL_PROFILES) do
    character[eachProfile].Spell = character[eachProfile].Spell or {}
    character[eachProfile].CancelBuff = character[eachProfile].CancelBuff or {}
    character[eachProfile].Spell["blessing"] = character[eachProfile].Spell["blessing"] or {}
  end

  self:Setup_MaybeAddCustomSpells()

  --Spells selected for the current class/settings/profile etc
  self:Setup_ResetCaches()

  if BOM.reputationTrinketZones.Link == nil
          or BOM.ridingSpeedZones.Link == nil then
    do
      local repSpellInfo = BOM.GetSpellInfo(BOM.reputationTrinketZones.spell)
      BOM.reputationTrinketZones.Link = self:FormatSpellLink(--[[---@not nil]] repSpellInfo)

      local ridingSpellInfo = BOM.GetSpellInfo(BOM.ridingSpeedZones.spell)
      BOM.ridingSpeedZones.Link = self:FormatSpellLink(--[[---@not nil]] ridingSpellInfo)
    end
  end

  self:Setup_CancelBuffs()

  ---@param buff BomBuffDefinition
  for _buffId, buff in pairs(BOM.allBuffomatBuffs) do
    self:Setup_EachBuff(buff)
  end -- for all BOM-supported spells
end
