--/run ViragDevTool_AddData(CopyTable(ChallengesFrame),"Challenges")
local _, shared = ...
local f = shared.f
local name = "DungeonTeleports"
f = CreateFrame("Frame", name, ChallengesFrame)


local defaults = {
	isMinimal = false,
	hideKnown = true,
}
--Options
local panel = CreateFrame("Frame")
panel.name = "Dungeon Teleports"
InterfaceOptions_AddCategory(panel)

local title = panel:CreateFontString("ARTWORK",nil,"GameFontNormalLarge")
title:SetPoint("TOP")
title:SetText("Dungeon Teleports")

local isMinimalCheckButton = CreateFrame("CheckButton",nil,panel,"InterfaceOptionsCheckButtonTemplate")
isMinimalCheckButton:SetPoint("TOPLEFT", 20,-20)
isMinimalCheckButton.Text:SetText("Hide Hover Animation")
isMinimalCheckButton:HookScript("OnClick", function()
	f.db.isMinimal = not f.db.isMinimal
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


local function OnEvent(self, event, addon)
	if addon == "Blizzard_ChallengesUI" then
		Initialize(self)
		self:UnregisterEvent("ADDON_LOADED")
	elseif addon == name then
		DTDB = DTDB or {}
		self.db = DTDB
		for k,v in pairs(defaults) do
			if self.db[k] == nil then
				self.db[k] = v
			end
		end
		isMinimalCheckButton:SetChecked(self.db.isMinimal)
		hideKnownCheckButton:SetChecked(self.db.hideKnown)
	end
end

f:SetSize(100,100)
f:RegisterEvent("ADDON_LOADED")
f:HookScript("OnEvent",OnEvent)
f.isbuttonscreated = false
f.DTButtons = {}

local function isMinimalCreateTextures(frame)
	local glowSize = 100
	if not f.db.isMinimal then 
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
	end
end

local function calculatescore (scoreInfo)
	local total = 0
	
	for k,v in pairs(scoreInfo) do
		total = total + v.score
	end
	local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(total)
	return color:WrapTextInColorCode(tostring(total))
end

function f:ClearDungeonButtons()
	for k,dungeon in pairs(self.DTButtons) do
		if dungeon.tex then dungeon.tex:SetTexture() end
		if dungeon.tex2 then dungeon.tex2:SetTexture() end
		if dungeon.tex then dungeon.tex:SetTexture() end
	end
end

function f:CreateDungeonButtons ()
	if InCombatLockdown() then return end
	if not ChallengesFrame then return end
	if not ChallengesFrame.DungeonIcons then return end
	self:SetParent(ChallengesFrame)
	self:SetPoint("CENTER")
	
	if not self.isbuttonscreated then
		for k,parentFrame in pairs(ChallengesFrame.DungeonIcons) do
			if not parentFrame.mapID then return end
			if not IsSpellKnown(self.DungeonMapToPortal[parentFrame.mapID]) --[[and not UnitIsUnit("player","Ragel")]] then return end
			local btn = self.DTButtons[k]
			if not btn then
				btn = CreateFrame("Button","DTButton",parentFrame,"InsecureActionButtonTemplate")
				btn.innerFrame = btn.innerFrame or CreateFrame("Frame","DTButtonInnerCircle",parentFrame)
				btn.glowFrame = btn.flowFrame or CreateFrame("Frame","DTButtonGlow",parentFrame)
				btn.tex = btn:CreateTexture()
				btn.tex2 = btn:CreateTexture()
				btn.animGroup = btn:CreateAnimationGroup()
				btn.rotate1 = btn.animGroup:CreateAnimation("Rotation")
				btn.innerFrame.animGroup = btn.innerFrame:CreateAnimationGroup()
				btn.innerFrame.rotate1 = btn.innerFrame.animGroup:CreateAnimation("Rotation")
				btn.glowFrame.animGroup = btn.glowFrame:CreateAnimationGroup()
				btn.glowFrame.scale = btn.glowFrame.animGroup:CreateAnimation("Scale")
				btn.glowFrame.scale2 = btn.glowFrame.animGroup:CreateAnimation("Scale")
			end
			--btn.portalSpellID = 8936 --8936 Regrowth for testing
			btn.portalSpellID = self.DungeonMapToPortal[parentFrame.mapID]
			btn:SetAttribute("type","spell")
			btn:SetAttribute("spell", btn.portalSpellID)
			btn:SetAttribute("target", "player")
			btn:RegisterForClicks("AnyUp", "AnyDown")
			btn:SetPoint("CENTER",parentFrame,"CENTER",0,0)
			btn:SetSize(parentFrame.Icon:GetWidth(false),parentFrame.Icon:GetHeight(false))
			btn:SetFrameStrata("HIGH")
			btn:SetFrameLevel(3)
			btn.innerFrame:SetAllPoints()
			btn.glowFrame:SetAllPoints()
			btn.tex:SetAllPoints()
			
			--Display Portal
			btn.tex:SetAtlas("ChallengeMode-Runes-Large")
			btn.tex:SetBlendMode("BLEND")
			btn.tex:SetDrawLayer("OVERLAY",7)
				
			--Large					
			btn.tex2:SetPoint("CENTER")
			btn.tex2:SetAllPoints()
			btn.tex2:SetBlendMode("BLEND")
			btn.tex2:SetDrawLayer("OVERLAY",7)
			
			btn.animGroup:SetLooping("REPEAT")
			btn.rotate1:SetDegrees(360)
			btn.rotate1:SetDuration(60)
			btn.rotate1:SetSmoothing("OUT")
				
			btn.innerFrame.animGroup:SetLooping("REPEAT")
			btn.innerFrame.rotate1:SetDegrees(-360)
			btn.innerFrame.rotate1:SetDuration(60)
			btn.innerFrame.rotate1:SetSmoothing("OUT")
			
			local startSize = 0.05
			local finishSize = 1.7
			btn.glowFrame.animGroup:SetLooping("REPEAT")
			btn.glowFrame.scale:SetOrder(1)
			btn.glowFrame.scale:SetScaleFrom(startSize,startSize)
			btn.glowFrame.scale:SetScaleTo(finishSize,finishSize)
			btn.glowFrame.scale:SetDuration(5)
			btn.glowFrame.scale:SetSmoothing("IN_OUT")
			
			btn.glowFrame.scale2:SetOrder(1)
			btn.glowFrame.scale2:SetDuration(5)
			btn.glowFrame.scale2:SetScaleFrom(finishSize,finishSize)
			btn.glowFrame.scale2:SetScaleTo(startSize,startSize)
			btn.glowFrame.scale2:SetSmoothing("IN_OUT")

								
			btn:SetScript("OnEnter", function(self2,motion)
				if not self.db.isMinimal then
					if not self2.innerCircle then
						isMinimalCreateTextures(self2)
					end
					self2.glowFrame.glow:SetAtlas("greatVault-keyHole-glow")
					self2.innerFrame.highlight2:SetAtlas("ChallengeMode-Runes-GlowBurstLarge")
					self2.innerFrame.highlight:SetAtlas("ChallengeMode-Runes-GlowSmall")
					self2.innerCircle:SetAtlas("ChallengeMode-Runes-InnerCircleGlow")
					self2.tex2:SetAtlas("ChallengeMode-Runes-GlowBurstLarge")
					self2.animGroup:Play()
					self2.innerFrame.animGroup:Play()
					self2.glowFrame.animGroup:Play()
				end
				if not f.db.hideKnown or not self.db.isMinimal then
					self2.tex:SetAtlas("ChallengeMode-Runes-GlowLarge")
					self2.tex:SetBlendMode("ADD")
					self2.tex:SetDrawLayer("OVERLAY",7)
				end
				--Tooltip Handling
				local dungeonMapName = C_ChallengeMode.GetMapUIInfo(parentFrame.mapID)
				local mPlusMapScoreInfo = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(parentFrame.mapID)
				local totalScore = calculatescore(mPlusMapScoreInfo)
				GameTooltip:SetOwner(self2,"ANCHOR_RIGHT",-10)
				GameTooltip:AddLine(WrapTextInColorCode(dungeonMapName,"FFFFFFFF"))
				GameTooltip:AddLine("Rating: ".. totalScore)
				local isFirstPass = true
				for _,affixInfo in pairs(mPlusMapScoreInfo) do
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine("Best "..affixInfo.name)
					GameTooltip:AddLine(WrapTextInColorCode("Level "..affixInfo.level,"FFFFFFFF"))
					GameTooltip:AddLine(WrapTextInColorCode(string.format("%d:%.2d",affixInfo.durationSec/60,affixInfo.durationSec%60),"FFFFFFFF"))
				end
				GameTooltip:Show()
			end)
			btn:SetScript("OnLeave", function(self2,motion)
				if not self.db.isMinimal then
					self2.glowFrame.glow:SetTexture()
					self2.innerFrame.highlight2:SetTexture()
					self2.innerFrame.highlight:SetTexture()
					self2.innerCircle:SetTexture()
					self2.tex2:SetTexture()
					self2.animGroup:Stop()
					self2.innerFrame.animGroup:Stop()
					self2.glowFrame.animGroup:Stop()
				end
				if not f.db.hideKnown then
					self2.tex:SetAtlas("ChallengeMode-Runes-Large")
					self2.tex:SetBlendMode("BLEND")
				else
					self2.tex:SetTexture()
					self2.tex2:SetTexture()
				end
				GameTooltip:Hide()
			end)
			if f.db.hideKnown then
				btn.tex:SetTexture()
				btn.tex2:SetTexture()
			end
			self.DTButtons[k] = btn
			self.isbuttonscreated = true
		
		end
	end
end


f.DungeonMapToPortal = {
        -- Cataclysm
        [438] = 410080, -- The Vortex Pinnacle
        [456] = 424142, -- Throne of the Tides
        
        -- Pandaria
        [2]   = 131204, -- Temple of the Jade Serpent
        [56]  = 131205, -- Stormstout Brewery
        [57]  = 131225, -- Gate of the Setting Sun
        [58]  = 131206, -- Shado-Pan Monastery
        [59]  = 131228, -- Siege of Niuzao Temple
        [60]  = 131222, -- Mogu'shan Palace
        [76]  = 131232, -- Scholomance
        [77]  = 131231, -- Scarlet Halls
        [78]  = 131229, -- Scarlet Monastery
        
        -- Warlords of Draenor
        [161] = 159898, -- Skyreach
        [163] = 159895, -- Bloodmaul Slag Mines
        [164] = 159897, -- Auchindoun
        [165] = 159899, -- Shadowmoon Burial Grounds
        [166] = 159900, -- Grimrail Depot
        [167] = 159902, -- Upper Blackrock Spire
        [168] = 159901, -- The Everbloom
        [169] = 159896, -- Iron Docks
        
        -- Legion
        [197] = 0, -- Eye of Azshara
        [198] = 424163, -- Darkheart Thicket
        [199] = 424153, -- Black Rook Hold
        [200] = 393764, -- Halls of Valor
        [206] = 410078, -- Neltharion's Lair
        [207] = 0, -- Vault of the Wardens
        [208] = 0, -- Maw of Souls
        [209] = 0, -- The Arcway
        [210] = 393766, -- Court of Stars
        [227] = 373262, -- Lower Karazhan
        [233] = 0, -- Cathedral of Eternal Night
        [234] = 373262, -- Upper Karazhan
        [239] = 0, -- Seat of the Triumvirate
        -- [] = {}, -- Violet Hold?
        
        -- Battle for Azeroth
        [244] = 424187, -- Atal'Dazar
        [245] = 410071, -- Freehold
        [246] = 0, -- Tol Dagor
        [247] = 0, -- The MOTHERLODE!!
        [248] = 424167, -- Waycrest Manor
        [249] = 0, -- Kings' Rest
        [250] = 0, -- Temple of Sethraliss
        [251] = 410074, -- The Underrot
        [252] = 0, -- Shrine of the Storm
        [353] = 0, -- Siege of Boralus
        [369] = 373274, -- Mechagon Junkyard
        [370] = 373274, -- Mechagon Workshop
        
        
        -- Shadowlands
        [375] = 354464, -- Mists of Tirna Scithe
        [376] = 354462, -- The Necrotic Wake
        [377] = 354468, -- De Other Side
        [378] = 354465, -- Halls of Atonement
        [379] = 354463, -- Plaguefall
        [380] = 354469, -- Sanguine Depths
        [381] = 354466, -- Spires of Ascension
        [382] = 354467, -- Theater of Pain
        [391] = 367416, -- Streets of Wonder
        [392] = 367416, -- So'leah's Gambit
        
        -- Dragonflight
        [399] = 393256, -- Ruby Life Pools
        [400] = 393262, -- The Nokhud Offensive
        [401] = 393279, -- The Azure Vault
        [402] = 393273, -- Algeth'ar Academy
        [403] = 393222, -- Uldaman: Legacy of Tyr
        [404] = 393276, -- Neltharus
        [405] = 393267, -- Brackenhide Hollow
        [406] = 393283, -- Halls of Infusion
        [463] = 424197, -- Dawn of the Inifine: Galakrond's Fall
        [464] = 424197, -- Dawn of the Inifine: Murozond's Rise
        
    }

