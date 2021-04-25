---@type BuffomatAddon
local TOCNAME, BOM = ...
BOM.Class = BOM.Class or {}

---@class GPIMenuItem
---@field text string
---@field disabled boolean
---@field value any
---@field arg1 any
---@field arg2 any
---@field MenuDepth number
BOM.Class.GPIMenuItem = {}
BOM.Class.GPIMenuItem.__index = BOM.Class.GPIMenuItem


---@class GPIMinimapButtonConfigData
---@field position number|nil
---@field distance number|nil
---@field visible boolean|nil
---@field lock boolean|nil
---@field lockDistance boolean|nil
BOM.Class.GPIMinimapButtonConfigData = {}
BOM.Class.GPIMinimapButtonConfigData.__index = BOM.Class.GPIMinimapButtonConfigData


---@class GPIMinimapButton
---@field icon table
---@field isMouseDown boolean
---@field isDraggingButton boolean
---@field db GPIMinimapButtonConfigData Config database which will persist between addon reloads
---@field Tooltip string
---@field onClick function
BOM.Class.GPIMinimapButton = {}
BOM.Class.GPIMinimapButton.__index = BOM.Class.GPIMinimapButton


---@class Control A blizzard UI frame but may contain private fields used by internal library by GPI
---@field _GPIPRIVAT_events table<string, function> Events
---@field _GPIPRIVAT_updates table<function> private field
---@field _GPIPRIVAT_MovingStopCallback any private field
---@field _GPIPRIVAT_TableCallback function
---@field _GPIPRIVAT_Items table<GPIMenuItem> Popup item list?
---@field _GPIPRIVAT_MovingStopCallback function
---@field GPI_Cursor any
---@field GPI_Rotation number Rotation in degrees
---@field GPI_DoStart boolean
---@field GPI_DoStop boolean
---@field GPI_SIZETYPE string
---@field Lib_GPI_MinimapButton GPIMinimapButton Stores extra values for minimap button control
BOM.Class.Control = {}
BOM.Class.Control.__index = BOM.Class.Control

local CLASS_TAG = "ui_control"
