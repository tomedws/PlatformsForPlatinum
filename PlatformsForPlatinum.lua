-----------------------------------------------------------------------------------------------
-- Client Lua Script for PlatformsForPlatinum
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- PlatformsForPlatinum Module Definition
-----------------------------------------------------------------------------------------------
local PlatformsForPlatinum = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function PlatformsForPlatinum:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self 

  self.currentlyCrafting = false

  return o
end

function PlatformsForPlatinum:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- PlatformsForPlatinum OnLoad
-----------------------------------------------------------------------------------------------
function PlatformsForPlatinum:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("PlatformsForPlatinum.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- PlatformsForPlatinum OnDocLoaded
-----------------------------------------------------------------------------------------------
function PlatformsForPlatinum:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
    self.wndMain = Apollo.LoadForm(self.xmlDoc, "PlatformsForPlatinumForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
    self.wndMain:Show(false, true)

    Apollo.RegisterSlashCommand("plat", "OnPlatformsForPlatinumOn", self)

    Apollo.RegisterTimerHandler("CraftingTimer", "OnCraftingTimer", self)
    Apollo.CreateTimer("CraftingTimer", 3.25, true)
    Apollo.StopTimer("CraftingTimer")

    self.startButton = self.wndMain:FindChild("ControlsContainer:ButtonContainer:StartButton")
    self.stopButton = self.wndMain:FindChild("ControlsContainer:ButtonContainer:StopButton")
    self.platformCount = self.wndMain:FindChild("ControlsContainer:CountContainer:Count")

    self.stopButton:Enable(false)
    self.platformCount:SetText(0)
	end
end

function PlatformsForPlatinum:OnCraftingTimer()
  self:Craft(CraftingLib.CodeEnumTradeskill.Architect, 391, {"Iron Screw", "Iron Screw", "Iron Screw"}) -- 391 is Metal Plank
end

function PlatformsForPlatinum:Craft(skillId, itemId, additives)
  CraftingLib.CraftItem(itemId) -- brings up the item's crafting grid

  local tListAdditives = CraftingLib.GetAvailableAdditives(skillId, itemId)

  for _,additive in pairs(additives) do
    for idx,item in pairs(tListAdditives) do
      if (item:GetName() == additive) then
        CraftingLib.AddAdditive(item)
        break
      end
    end
  end

  CraftingLib.CompleteCraft()
  self.platformCount:SetText(self.platformCount:GetText() + 1)
end

-----------------------------------------------------------------------------------------------
-- PlatformsForPlatinum Functions
-----------------------------------------------------------------------------------------------

function PlatformsForPlatinum:OnPlatformsForPlatinumOn()
  self.wndMain:Invoke() -- show the window
end


function PlatformsForPlatinum:OnStartButton()
  if not self.currentlyCrafting then
    self:Craft(CraftingLib.CodeEnumTradeskill.Architect, 391, {"Iron Screw", "Iron Screw", "Iron Screw"})
    Apollo.StartTimer("CraftingTimer")
    self.currentlyCrafting = true
    self.startButton:Enable(false)
    self.stopButton:Enable(true)
  end
end

function PlatformsForPlatinum:OnStopButton()
  if self.currentlyCrafting then
    Apollo.StopTimer("CraftingTimer")
    self.currentlyCrafting = false
    self.startButton:Enable(true)
    self.stopButton:Enable(false)
  end
end

function PlatformsForPlatinum:OnClose()
  self.wndMain:Close()
end


-----------------------------------------------------------------------------------------------
-- PlatformsForPlatinum Instance
-----------------------------------------------------------------------------------------------
local PlatformsForPlatinumInst = PlatformsForPlatinum:new()
PlatformsForPlatinumInst:Init()
