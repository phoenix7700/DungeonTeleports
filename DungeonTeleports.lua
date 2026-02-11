--/run DevTool:AddData(CopyTable(ChallengesFrame),"Challenges")
local addonName, shared = ...
local f = shared.f
local name = "DungeonTeleports"
local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "0"
f = CreateFrame("Frame", name, ChallengesFrame)

local defaults = {
	hideHoverAnimation = false,
	hideKnown = false,
	useBackupPortals = true,
}

local panel = CreateFrame("Frame")
panel.name = "Dungeon Teleports"
local category, layout = Settings.RegisterCanvasLayoutCategory(panel,panel.name)
Settings.RegisterAddOnCategory(category)
shared.settingsCategory = category

local title = panel:CreateFontString("ARTWORK",nil,"GameFontNormalLarge")
title:SetPoint("TOP")
title:SetText("Dungeon Teleports "..version)

local hideHoverAnimationCheckButton = CreateFrame("CheckButton",nil,panel,"InterfaceOptionsCheckButtonTemplate")
hideHoverAnimationCheckButton:SetPoint("TOPLEFT", 20,-20)
hideHoverAnimationCheckButton.Text:SetText("Hide Hover Animation")
hideHoverAnimationCheckButton:HookScript("OnClick", function()
	f.db.hideHoverAnimation = not f.db.hideHoverAnimation
	f.isbuttonscreated = false
	f:CreateDungeonButtons()	
end)

local hideKnownCheckButton = CreateFrame("CheckButton",nil,panel,"InterfaceOptionsCheckButtonTemplate")
hideKnownCheckButton:SetPoint("TOPLEFT", 20,-60)
hideKnownCheckButton.Text:SetText("Hide Known")
hideKnownCheckButton:HookScript("OnClick", function()
	f.db.hideKnown = not f.db.hideKnown
	f.isbuttonscreated = false
	f:CreateDungeonButtons()	
end)

local useBackupPortalsCheckButton = CreateFrame("CheckButton",nil,panel,"InterfaceOptionsCheckButtonTemplate")
useBackupPortalsCheckButton:SetPoint("TOPLEFT", 20, -100)
useBackupPortalsCheckButton.Text:SetText("Use Backup Portals")
useBackupPortalsCheckButton:HookScript("OnClick", function()
	f.db.useBackupPortals = not f.db.useBackupPortals
	f.isbuttonscreated = false
	f:CreateDungeonButtons()
end)

--end Options
--Main
local function Initialize(self)
	if ChallengesFrame then
		if type(ChallengesFrame.Update) == "function" then
			hooksecurefunc(ChallengesFrame, "Update", function() self:CreateDungeonButtons() end)
		end
		self:CreateDungeonButtons()
	end
end
--
local function OnEvent(self, event, addon)
	if event == "ADDON_LOADED" then
		if addon == "Blizzard_ChallengesUI" then
			Initialize(self)
			self:UnregisterEvent("ADDON_LOADED")
		elseif addon == name then
			DungeonTeleports_SavedData = DungeonTeleports_SavedData or {}
			self.db = DungeonTeleports_SavedData
			for k,v in pairs(defaults) do
				if self.db[k] == nil then
					self.db[k] = v
				end
			end
			hideHoverAnimationCheckButton:SetChecked(self.db.hideHoverAnimation)
			hideKnownCheckButton:SetChecked(self.db.hideKnown)
			useBackupPortalsCheckButton:SetChecked(self.db.useBackupPortals)
		end
	end
end
--
local function CreateHoverAnimationTextures(frame)
		--Circles
		frame.innerCircle = frame.innerCircle or frame:CreateTexture()
		frame.innerCircle:SetPoint("CENTER")
		frame.innerCircle:SetAllPoints()
		frame.innerCircle:SetDrawLayer("OVERLAY",7)
				
		--Small
		frame.innerFrame.highlight = frame.innerFramehighlight or frame.innerFrame:CreateTexture()
		frame.innerFrame.highlight:SetPoint("CENTER")
		frame.innerFrame.highlight:SetSize(40,40)
		frame.innerFrame.highlight:SetBlendMode("ADD")
		frame.innerFrame.highlight:SetDrawLayer("OVERLAY",7)
		
		frame.innerFrame.highlight2 = frame.innerFramehighlight2 or frame.innerFrame:CreateTexture()
		frame.innerFrame.highlight2:SetPoint("CENTER")
		frame.innerFrame.highlight2:SetSize(40,40)
		frame.innerFrame.highlight2:SetBlendMode("BLEND")
		frame.innerFrame.highlight2:SetDrawLayer("OVERLAY",7)
		
		
		--Glow
		frame.glowFrame.glow = frame.glowFrame.glow or frame.glowFrame:CreateTexture()
		frame.glowFrame.glow:SetPoint("CENTER")
		frame.glowFrame.glow:SetSize(50,50)
		frame.glowFrame.glow:SetScale(1,1)
		frame.glowFrame.glow:SetVertexColor(0.2745,0.7529,0.8313)
		frame.glowFrame.glow:SetBlendMode("ADD")
		frame.glowFrame.glow:SetDrawLayer("OVERLAY",7)
		
		frame.glowFrame.glow:SetAtlas("greatVault-keyHole-glow")
		frame.innerFrame.highlight2:SetAtlas("ChallengeMode-Runes-GlowBurstLarge")
		frame.innerFrame.highlight:SetAtlas("ChallengeMode-Runes-GlowSmall")
		frame.innerCircle:SetAtlas("ChallengeMode-Runes-InnerCircleGlow")
		frame.outerFrame.outerCircleTrim:SetAtlas("ChallengeMode-Runes-GlowBurstLarge")
end
--
function f:SetupDungeonButtonFrames(button)
	button:SetAttribute("type","spell")
	button:SetAttribute("spell", button.portalSpellID)
	button:SetAttribute("target", "player")
	button:RegisterForClicks("AnyUp","AnyDown")
	button:SetPoint("CENTER",button:GetParent(),"CENTER",0,0)
	button:SetSize(button:GetParent().Icon:GetWidth(false),button:GetParent().Icon:GetHeight(false))
	button:SetFrameStrata("HIGH")
	button:SetFrameLevel(3)
	button.innerFrame:SetAllPoints()
	button.glowFrame:SetAllPoints()
	button.outerFrame:SetAllPoints()
	button.txtFrame:SetAllPoints()
	
	button.txtFrame.HighestLevel:SetPoint("TOP",button,"TOP",0,-4)
	button.txtFrame.HighestLevel:SetFontObject(SystemFont_Huge1_Outline)
	button.txtFrame.HighestLevel:SetJustifyH("Center")
	button.txtFrame.HighestLevel:SetText("")
	
	--Display Portal
	button.outerFrame.outerCircle:SetAllPoints()
	button.outerFrame.outerCircle:SetAtlas("ChallengeMode-Runes-Large")
	button.outerFrame.outerCircle:SetBlendMode("BLEND")
	button.outerFrame.outerCircle:SetDrawLayer("OVERLAY",7)
		

	button.outerFrame.outerCircleTrim:SetPoint("CENTER")
	button.outerFrame.outerCircleTrim:SetAllPoints()
	button.outerFrame.outerCircleTrim:SetBlendMode("BLEND")
	button.outerFrame.outerCircleTrim:SetDrawLayer("OVERLAY",7)
	
	--Hover
	button.outerFrame.animGroup:SetLooping("REPEAT")
	button.outerFrame.rotate1:SetDegrees(-360)
	button.outerFrame.rotate1:SetDuration(60)
	button.outerFrame.rotate1:SetSmoothing("OUT")
		
	button.innerFrame.animGroup:SetLooping("REPEAT")
	button.innerFrame.rotate1:SetDegrees(720)
	button.innerFrame.rotate1:SetDuration(60)
	button.innerFrame.rotate1:SetSmoothing("OUT")
	
	local startSize = 0.05
	local finishSize = 1.7
	button.glowFrame.animGroup:SetLooping("REPEAT")
	button.glowFrame.scale:SetOrder(1)
	button.glowFrame.scale:SetScaleFrom(startSize,startSize)
	button.glowFrame.scale:SetScaleTo(finishSize,finishSize)
	button.glowFrame.scale:SetDuration(5)
	button.glowFrame.scale:SetSmoothing("IN_OUT")
	
	button.glowFrame.scale2:SetOrder(1)
	button.glowFrame.scale2:SetDuration(5)
	button.glowFrame.scale2:SetScaleFrom(finishSize,finishSize)
	button.glowFrame.scale2:SetScaleTo(startSize,startSize)
	button.glowFrame.scale2:SetSmoothing("IN_OUT")

	CreateHoverAnimationTextures(button)
					
	button:SetScript("OnEnter", function(self2,motion)
		if not self.db.hideHoverAnimation then
			self2.glowFrame.glow:Show()
			self2.innerFrame.highlight2:Show()
			self2.innerFrame.highlight:Show()
			self2.innerCircle:Show()
			self2.outerFrame.outerCircle:Show()
			self2.outerFrame.outerCircleTrim:Show()
			self2.outerFrame.animGroup:Play()
			self2.innerFrame.animGroup:Play()
			self2.glowFrame.animGroup:Play()
		end
		if not f.db.hideKnown or not self.db.hideHoverAnimation then
			self2.outerFrame.outerCircle:SetAtlas("ChallengeMode-Runes-GlowLarge")
			self2.outerFrame.outerCircle:SetBlendMode("ADD")
			self2.outerFrame.outerCircle:SetDrawLayer("OVERLAY",7)
		end

		--Tooltip Handling
		local dungeonMapName = C_ChallengeMode.GetMapUIInfo(button.mapID)
		local mPlusMapScoreInfo,totalScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(button.mapID)
		GameTooltip:SetOwner(self2,"ANCHOR_RIGHT",-10)
		GameTooltip:AddLine(WrapTextInColorCode(dungeonMapName,"FFFFFFFF"))
		if totalScore then
			local color = f:GetDungeonTextColor(button.mapID)
			GameTooltip:AddLine("Rating: "..color:WrapTextInColorCode(tostring(totalScore)))
		end
		if mPlusMapScoreInfo then
			for _,affixInfo in pairs(mPlusMapScoreInfo) do
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine("Best Run "..affixInfo.name)
				GameTooltip:AddLine(WrapTextInColorCode("Level "..affixInfo.level,"FFFFFFFF"))
				GameTooltip:AddLine(WrapTextInColorCode(string.format("%d:%.2d",affixInfo.durationSec/60,affixInfo.durationSec%60),"FFFFFFFF"))
			end
		end
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self2,motion)
		if not self.db.hideHoverAnimation then
			self2.glowFrame.glow:Hide()
			self2.innerFrame.highlight2:Hide()
			self2.innerFrame.highlight:Hide()
			self2.innerCircle:Hide()
			self2.outerFrame.outerCircleTrim:Hide()
			self2.outerFrame.animGroup:Stop()
			self2.innerFrame.animGroup:Stop()
			self2.glowFrame.animGroup:Stop()
		end
		if not f.db.hideKnown then
			self2.outerFrame.outerCircle:SetAtlas("ChallengeMode-Runes-Large")
			self2.outerFrame.outerCircle:SetBlendMode("BLEND")
		else
			self2.outerFrame.outerCircle:Hide()
			self2.outerFrame.outerCircleTrim:Hide()
		end
		GameTooltip:Hide()
	end)
	function button:HideAllElements()
		button.glowFrame:Hide()
		button:Hide()
	end
	function button:ShowAllElements()
		button.glowFrame:Show()
		button:Show()
	end

	function button:SetButtonColor(red, green, blue)
		button.outerFrame.outerCircle:SetVertexColor(red,green,blue)
		button.outerFrame.outerCircleTrim:SetVertexColor(red,green,blue)
		
		local highlight2 = button.innerFrame.highlight2
		if highlight2 then
			button.innerFrame.highlight2:SetVertexColor(red,green,blue)
			button.innerFrame.highlight:SetVertexColor(red,green,blue)
			button.innerCircle:SetVertexColor(red,green,blue)
			button.glowFrame.glow:SetVertexColor(red,green,blue)
		end
	end

	--TESTING
	-- button:SetScript("OnClick", function(self2) 
		-- print(C_ChallengeMode.GetMapUIInfo(button.mapID),button.portalSpellID)
	-- end)
end


--
function f:UpdateDungeonButtons()
	for k,iconFrame in pairs(ChallengesFrame.DungeonIcons) do
		local portalID = self:GetPortalFromDungeonMapID(iconFrame.mapID)
		
		if self.DTButtons[k] and self.DTButtons[k].mapID == iconFrame.mapID and portalID == self.DTButtons[k].portalSpellID then
			if not IsSpellKnown(portalID) and self.DTButtons[k]:IsShown()then
				self.DTButtons[k]:HideAllElements()
			elseif IsSpellKnown(portalID) then
				self.DTButtons[k]:ShowAllElements()
				if f.db.hideKnown then
					self.DTButtons[k].outerFrame.outerCircle:Hide()
					self.DTButtons[k].outerFrame.outerCircleTrim:Hide()
				else
					self.DTButtons[k].outerFrame.outerCircle:SetAtlas("ChallengeMode-Runes-Large")
					self.DTButtons[k].outerFrame.outerCircle:SetBlendMode("BLEND")
					self.DTButtons[k]:SetButtonColor(1,1,1)
					self.DTButtons[k].glowFrame.glow:SetVertexColor(0.2745,0.7529,0.8313)
					self.DTButtons[k].outerFrame.outerCircle:Show()
				end

				if f.db.hideHoverAnimation then
					self.DTButtons[k].glowFrame.glow:Hide()
					self.DTButtons[k].innerFrame.highlight2:Hide()
					self.DTButtons[k].innerFrame.highlight:Hide()
					self.DTButtons[k].innerCircle:Hide()
					self.DTButtons[k].outerFrame.outerCircleTrim:Hide()
				end
				if self:IsUsingBackupPortal(iconFrame.mapID,self.DTButtons[k].portalSpellID) then
					if not f.db.useBackupPortals then
						self.DTButtons[k]:HideAllElements()
					end
					self.DTButtons[k]:SetButtonColor(0,1,0)
				end
			end
		elseif self.DTButtons[k] then
			self.DTButtons[k].mapID = iconFrame.mapID
			self.DTButtons[k].portalSpellID = portalID
			self.DTButtons[k]:SetAttribute("spell", portalID)
		else
			if IsSpellKnown(portalID) then
				--Create new button
				self.DTButtons[k] = self:InitializeDungeonButton(iconFrame)
			end
		end
		self.DTButtons[k].txtFrame.HighestLevel:SetText(iconFrame.HighestLevel:GetText())
		self.DTButtons[k].txtFrame.HighestLevel:SetTextColor(iconFrame.HighestLevel:GetTextColor())
		iconFrame.HighestLevel:Hide()
	end
end
--
function f:InitializeDungeonButton(parentFrame)
	local btn 
	btn = CreateFrame("Button","DTButton",parentFrame,"InsecureActionButtonTemplate")
	btn.innerFrame = CreateFrame("Frame","DTButtonInner",btn)
	btn.outerFrame = CreateFrame("Frame","DTButtonOuter",btn)
	btn.glowFrame = CreateFrame("Frame","DTButtonGlow",parentFrame)
	btn.txtFrame = CreateFrame("Frame","DTButtonText",parentFrame)
	btn.outerFrame.outerCircle = btn:CreateTexture()
	btn.outerFrame.outerCircleTrim = btn:CreateTexture()
	btn.outerFrame.animGroup = btn:CreateAnimationGroup()
	btn.outerFrame.rotate1 = btn.outerFrame.animGroup:CreateAnimation("Rotation")
	btn.innerFrame.animGroup = btn.innerFrame:CreateAnimationGroup()
	btn.innerFrame.rotate1 = btn.innerFrame.animGroup:CreateAnimation("Rotation")
	btn.glowFrame.animGroup = btn.glowFrame:CreateAnimationGroup()
	btn.glowFrame.scale = btn.glowFrame.animGroup:CreateAnimation("Scale")
	btn.glowFrame.scale2 = btn.glowFrame.animGroup:CreateAnimation("Scale")
	btn.mapID = parentFrame.mapID
	btn.txtFrame.HighestLevel = btn.txtFrame:CreateFontString("Highest Level")
	btn.txtFrame:SetFrameLevel(5)
	btn.portalSpellID = self:GetPortalFromDungeonMapID(btn.mapID)
	
	--btn.portalSpellID = 8936 --8936 Regrowth for testing
	self:SetupDungeonButtonFrames(btn)
	btn.glowFrame.glow:Hide()
	btn.innerFrame.highlight2:Hide()
	btn.innerFrame.highlight:Hide()
	btn.innerCircle:Hide()
	btn.outerFrame.outerCircleTrim:Hide()
	if f.db.hideKnown then
		btn.outerFrame.outerCircle:Hide()
		btn.outerFrame.outerCircleTrim:Hide()
	end
	return btn
end
--
function f:CreateDungeonButtons ()
	if InCombatLockdown() then return end
	if not ChallengesFrame then return end
	if not ChallengesFrame.DungeonIcons then return end
	self:SetParent(ChallengesFrame)
	self:SetPoint("CENTER")
	if not self.isbuttonscreated then
		for k,parentFrame in pairs(ChallengesFrame.DungeonIcons) do
			if not parentFrame.mapID then return end
			--if (IsSpellKnown(self:GetPortalFromDungeonMapID(parentFrame.mapID)) or UnitIsUnit("player","Ragel")) and k%4 == 0 then -- Testing
			--if parentFrame.mapID == 400 or parentFrame.mapID == 401 then --Testing
			
			if IsSpellKnown(self:GetPortalFromDungeonMapID(parentFrame.mapID)) then --RELEASE
				local btn = self.DTButtons[k]
				if not btn then
					btn = self:InitializeDungeonButton(parentFrame)
				else
					--btn already exists check if spellID is correct
					self:UpdateDungeonButtons()
				end
				self.DTButtons[k] = btn
				self.isbuttonscreated = true
			end
			--Fix default text Draw Layer
			--parentFrame.HighestLevel:SetPoint()
		end
	else
		self:UpdateDungeonButtons()
	end
	if not ChallengesFrame.WeeklyInfo.Child.AffixesContainer then return end
	for k,affix in pairs(ChallengesFrame.WeeklyInfo.Child.AffixesContainer.Affixes) do
		affix.Portrait:SetMask([[Interface\CHARACTERFRAME\TempPortraitAlphaMask]])
	end
end

--
f:SetSize(100,100)
f:RegisterEvent("ADDON_LOADED")
f:HookScript("OnEvent",OnEvent)
f.isbuttonscreated = false
f.DTButtons = {}

function f:GetPortalFromDungeonMapID (mapID) 
	if f.db.useBackupPortals then
		for _,id in ipairs(f.DungeonMapToPortal[mapID]) do
			if IsSpellKnown(id) then
				return id
			end
		end
	end	
	return f.DungeonMapToPortal[mapID][1]
end

function f:IsUsingBackupPortal (mapID,portalID)
	return portalID ~= f.DungeonMapToPortal[mapID][1]
end
function f:GetDungeonTextColor(mapID)
	local _, overAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID);
	local color;
	if(overAllScore) then
		color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overAllScore);
	end
	if(not color) then
		color = HIGHLIGHT_FONT_COLOR;
	end
	return color
end
--[[
--Get all Current MapID
for k,mapID in pairs(C_ChallengeMode.GetMapTable()) do
	print(mapID .."=".. C_ChallengeMode.GetMapUIInfo(mapID))
end
--List ALL MapID
mapID=1 
while mapID < 1000 do
	name = C_ChallengeMode.GetMapUIInfo(mapID)
	if name then
		print(mapID .."=".. name)
	end
	mapID = mapID + 1 
end
]]
f.DungeonMapToPortal = {
		-- Wrath
		[556]  = {1254555}, -- Pit of Saron
        -- Cataclysm
        [438] = {410080}, -- The Vortex Pinnacle
        [456] = {424142}, -- Throne of the Tides
		[507] = {445424}, -- Grim Batol
        
        -- Pandaria
        [2]   = {131204}, -- Temple of the Jade Serpent
        [56]  = {131205}, -- Stormstout Brewery
        [57]  = {131225}, -- Gate of the Setting Sun
        [58]  = {131206}, -- Shado-Pan Monastery
        [59]  = {131228}, -- Siege of Niuzao Temple
        [60]  = {131222}, -- Mogu'shan Palace
        [76]  = {131232}, -- Scholomance
        [77]  = {131231, 131229}, -- Scarlet Halls
        [78]  = {131229, 131231}, -- Scarlet Monastery
        
        -- Warlords of Draenor
        [161] = {159898, 159899, 159897}, -- Skyreach
        [163] = {159895}, -- Bloodmaul Slag Mines
        [164] = {159897, 159898}, -- Auchindoun
        [165] = {159899, 159898}, -- Shadowmoon Burial Grounds
        [166] = {159900, 159901, 159896}, -- Grimrail Depot
        [167] = {159902}, -- Upper Blackrock Spire
        [168] = {159901, 159900, 159896}, -- The Everbloom
        [169] = {159896, 159900, 159901}, -- Iron Docks
        
        -- Legion
        [197] = {0}, -- Eye of Azshara
        [198] = {424163, 424153}, -- Darkheart Thicket
        [199] = {424153, 424163}, -- Black Rook Hold
        [200] = {393764}, -- Halls of Valor
        [206] = {410078}, -- Neltharion's Lair
        [207] = {0}, -- Vault of the Wardens
        [208] = {0}, -- Maw of Souls
        [209] = {0}, -- The Arcway
        [210] = {393766}, -- Court of Stars
        [227] = {373262}, -- Lower Karazhan
        [233] = {0}, -- Cathedral of Eternal Night
        [234] = {373262}, -- Upper Karazhan
        [239] = {1254551}, -- Seat of the Triumvirate
        -- [] = {}, -- Violet Hold?
        
        -- Battle for Azeroth
        [244] = {424187, 467553}, -- Atal'Dazar
        [245] = {410071, 445418}, -- Freehold
        [246] = {0}, -- Tol Dagor
        [247] = {467553, 424187}, -- The MOTHERLODE!! (Alliance)
        [248] = {424167}, -- Waycrest Manor
        [249] = {0}, -- Kings' Rest
        [250] = {0}, -- Temple of Sethraliss
        [251] = {410074}, -- The Underrot
        [252] = {0}, -- Shrine of the Storm
        [353] = {445418, 410071}, -- Siege of Boralus (Alliance)
        [369] = {373274}, -- Mechagon Junkyard
        [370] = {373274}, -- Mechagon Workshop
        
        -- Shadowlands
        [375] = {354464, 354468}, -- Mists of Tirna Scithe
        [376] = {354462, 354466}, -- The Necrotic Wake
        [377] = {354468, 354464}, -- De Other Side
        [378] = {354465, 354469}, -- Halls of Atonement
        [379] = {354463, 354467}, -- Plaguefall
        [380] = {354469, 354465}, -- Sanguine Depths
        [381] = {354466, 354462}, -- Spires of Ascension
        [382] = {354467, 354463}, -- Theater of Pain
        [391] = {367416}, -- Streets of Wonder
        [392] = {367416}, -- So'leah's Gambit
        
        -- Dragonflight
        [399] = {393256, 393276}, -- Ruby Life Pools
        [400] = {393262}, -- The Nokhud Offensive
        [401] = {393279, 393267}, -- The Azure Vault
        [402] = {393273, 393283}, -- Algeth'ar Academy
        [403] = {393222}, -- Uldaman: Legacy of Tyr
        [404] = {393276, 393256}, -- Neltharus
        [405] = {393267, 393279}, -- Brackenhide Hollow
        [406] = {393283, 424197, 393273}, -- Halls of Infusion
        [463] = {424197, 393283}, -- Dawn of the Inifine: Galakrond's Fall
        [464] = {424197, 393283}, -- Dawn of the Inifine: Murozond's Rise
        
		--The War Within
		[499] = {445444, 445414}, -- Priory of the Sacred Flame
		[500] = {445443, 445440}, -- The Rookery
		[501] = {445269, 445441, 1216786}, -- The Stonevault
		[502] = {445416, 445417}, -- City of Threads
		[503] = {445417, 445416}, -- Ara-Kara, City of Echoes
		[504] = {445441, 1216786, 445269}, -- Darkflame Cleft
		[505] = {445414, 445444} , -- The Dawnbreaker
		[506] = {445440, 445443} , -- Cinderbrew Meadery
		[525] = {1216786, 445441, 445269} , -- Operation: Floodgate
		[542] = {1237215}, --Exo-Dome Al'dani
		
		--Midnight
		[557] = {1254400}, -- Windrunner Spire
		[558] = {1254572}, -- Magisters' Terrace
		[559] = {1254563}, --Nexus-Point Xenas
		[560] = {1254559}, -- Maisara Caverns

	}

	--Fix different horde and alliance teleport IDs change ID if character is Horde.
	if UnitFactionGroup("player") == "Horde" then
		f.DungeonMapToPortal[353] = {464256, 410071} -- Siege of Boralus
		f.DungeonMapToPortal[245] = {410071, 464256} -- Freehold (Different Siege Number)
		f.DungeonMapToPortal[247] = {467555, 424187} -- MOTHERLODE
		f.DungeonMapToPortal[244] = {424187, 467555} -- Atal'Dazar (Different MOTHERLODE Number)
	end

