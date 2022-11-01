---@class BomModuleModule
---@field allBuffsModule BomAllBuffsModule
---@field allConsumesElixirsModule BomAllConsumesElixirsModule
---@field allConsumesEnchantmentsModule BomAllConsumesEnchantmentsModule
---@field allConsumesFlasksModule BomAllConsumesFlasksModule
---@field allConsumesFoodModule BomAllConsumesFoodModule
---@field allConsumesOtherModule BomAllConsumesOtherModule
---@field allConsumesScrollsModule BomAllConsumesScrollsModule
---@field allSpellsDeathknightModule BomAllSpellsDeathknightModule
---@field allSpellsDruidModule BomAllSpellsDruidModule
---@field allSpellsHunterModule BomAllSpellsHunterModule
---@field allSpellsMageModule BomAllSpellsMageModule
---@field allSpellsPaladinModule BomAllSpellsPaladinModule
---@field allSpellsPriestModule BomAllSpellsPriestModule
---@field allSpellsRogueModule BomAllSpellsRogueModule
---@field allSpellsShamanModule BomAllSpellsShamanModule
---@field allSpellsWarlockModule BomAllSpellsWarlockModule
---@field allSpellsWarriorModule BomAllSpellsWarriorModule
---@field buffChecksModule BomBuffChecksModule
---@field buffDefinitionModule BomBuffDefinitionModule
---@field buffModule BomBuffModule
---@field buffomatModule BomBuffomatModule
---@field buffRowModule BomBuffRowModule
---@field characterSettingsModule BomCharacterSettingsModule
---@field constModule BomConstModule
---@field controlModule BomControlModule
---@field eventsModule BomEventsModule
---@field groupBuffTargetModule BomGroupBuffTargetModule
---@field itemCacheModule BomItemCacheModule
---@field itemIdsModule BomItemIdsModule
---@field itemListCacheModule BomItemListCacheModule
---@field languageChineseModule BomLanguageChineseModule
---@field languageEnglishModule BomLanguageEnglishModule
---@field languageFrenchModule BomLanguageFrenchModule
---@field languageGermanModule BomLanguageGermanModule
---@field languageRussianModule BomLanguageRussianModule
---@field languagesModule BomLanguagesModule
---@field legacyOptionsModule BomLegacyOptionsModule
---@field macroModule BomMacroModule
---@field managedUiModule BomManagedUiModule
---@field myButtonModule BomUiMyButtonModule
---@field optionsModule BomOptionsModule
---@field optionsPopupModule BomOptionsPopupModule
---@field profileModule BomProfileModule
---@field rowBuilderModule BomRowBuilderModule
---@field sharedSettingsModule BomSharedSettingsModule
---@field spellButtonsTabModule BomSpellButtonsTabModule
---@field spellCacheModule BomSpellCacheModule
---@field spellIdsModule BomSpellIdsModule
---@field spellSetupModule BomSpellSetupModule
---@field taskListModule BomTaskListModule
---@field taskModule BomTaskModule
---@field taskScanModule BomTaskScanModule
---@field texturesModule BomTexturesModule
---@field toolboxModule BomToolboxModule
---@field uiButtonModule BomUiButtonModule
---@field uiMinimapButtonModule BomUiMinimapButtonModule
---@field unitBuffTargetModule BomUnitBuffTargetModule
---@field unitCacheModule BomUnitCacheModule
---@field unitModule BomUnitModule
BomModuleManager = {}

---For each known module call function by fnName and optional context will be
---passed as 1st argument, can be ignored (defaults to nil)
---module:EarlyModuleInit (called early on startup)
---module:LateModuleInit (called late on startup, after entered world)
function BomModuleManager:CallInEachModule(fnName, context)
  for _, module in pairs(--[[---@type table]] self) do
    local fn = module[fnName]
    if fn then
      fn(context)
    end
  end
end