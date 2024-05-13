--/run ViragDevTool_AddData(CopyTable(ChallengesFrame),"Challenges")
local _, shared = ...
local f = shared.f
local name = "DungeonTeleports"
f = CreateFrame("Frame", name, ChallengesFrame)

local defaults = {
	isMinimal = false,
}
--Options
local panel = CreateFrame("Frame")
panel.name = "Dungeon Teleports"
InterfaceOptions_AddCategory(panel)

local title = panel:CreateFontString("ARTWORK",nil,"GameFontNormalLarge")
title:SetPoint("TOP")
title:SetText("Dungeon Teleports")

local cb = CreateFrame("CheckButton",nil,panel,"InterfaceOptionsCheckButtonTemplate")
cb:SetPoint("TOPLEFT", 20,-20)
cb.Text:SetText("Minimal")
cb:HookScript("OnClick", function()
	f.db.isMinimal = not f.db.isMinimal
end)


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
		cb:SetChecked(self.db.isMinimal)
	end
end

f:SetSize(100,100)
f:RegisterEvent("ADDON_LOADED")
f:HookScript("OnEvent",OnEvent)
f.isbuttonscreated = false
f.DTButtons = {}

function f:CreateDungeonButtons ()
	if InCombatLockdown() then return end
	if not ChallengesFrame then return end
	if not ChallengesFrame.DungeonIcons then return end
	self:SetParent(ChallengesFrame)
	self:SetPoint("CENTER")
	
	if not self.isbuttonscreated then
		for k,v in pairs(ChallengesFrame.DungeonIcons) do
			if v.mapID then
				if IsSpellKnown(self.DungeonMapToPortal[v.mapID]) then
					-- ViragDevTool_AddData(CopyTable(ChallengesFrame),"vvvvv")
					-- ViragDevTool_AddData(ChallengesFrame,"vvvvv no copy")
					-- ViragDevTool_AddData(type(ChallengesFrame),"type")
					--ChallengesFrame.DungeonIcons[k].
					local btn = CreateFrame("Button","DTButton",v,"InsecureActionButtonTemplate")
					btn.portalSpellID = self.DungeonMapToPortal[v.mapID]
					--btn.portalSpellID = 8936 --8936 Regrowth for testing
					btn:SetAttribute("type","spell")
					btn:SetAttribute("spell", btn.portalSpellID)
					btn:SetAttribute("target", "player")
					btn:RegisterForClicks("AnyUp", "AnyDown")
					btn:SetPoint("CENTER",v,"CENTER",0,0)
					btn:SetSize(v.Icon:GetWidth(false),v.Icon:GetHeight(false))
					btn:SetFrameStrata("HIGH")
					btn:SetFrameLevel(3)
					--Display Portal
					btn.tex = btn:CreateTexture()
					btn.tex:SetAllPoints()
					btn.tex:SetAtlas("ChallengeMode-Runes-Large")
					btn.tex:SetBlendMode("BLEND")
					btn.tex:SetDrawLayer("OVERLAY",7)
					
					btn:SetScript("OnEnter", function(self2,motion)
						local glowSize = 100
						if not self.db.isMinimal then 
							--[[Lines
							self2.lines = self2:CreateTexture()
							self2.lines:SetAtlas("ChallengeMode-Runes-LineGlow")
							self2.lines:SetPoint("CENTER")
							self2.lines:SetSize(self2:GetWidth()+8,self2:GetHeight()+8)
							self2.lines:SetDrawLayer("BACKGROUND")
							self2.lines:SetBlendMode("BLEND")]]
							
							--Circles
							btn.innerCircle = btn.innerCircle or btn:CreateTexture()
							btn.innerCircle:SetPoint("CENTER")
							btn.innerCircle:SetAllPoints()
							btn.innerCircle:SetAtlas("ChallengeMode-Runes-InnerCircleGlow")
							btn.innerCircle:SetDrawLayer("OVERLAY",7)
							
							--Runes
							--[[self2.topRune = self2:CreateTexture()
							self2.topRune:SetAtlas("ChallengeMode-Runes-T-Glow")
							self2.topRune:SetPoint("TOP",0,15)
							self2.topRune:SetSize(18,18)
							self2.topRune:SetDrawLayer("BACKGROUND")
							self2.topRune:SetBlendMode("ADD")
							
							self2.leftRune = self2:CreateTexture()
							self2.leftRune:SetAtlas("ChallengeMode-Runes-L-Glow")
							self2.leftRune:SetPoint("LEFT",-12,12)
							self2.leftRune:SetSize(18,18)
							self2.leftRune:SetDrawLayer("BACKGROUND")
							self2.leftRune:SetBlendMode("ADD")
							
							self2.rightRune = self2:CreateTexture()
							self2.rightRune:SetAtlas("ChallengeMode-Runes-R-Glow")
							self2.rightRune:SetPoint("RIGHT",12,12)
							self2.rightRune:SetSize(18,18)
							self2.rightRune:SetDrawLayer("BACKGROUND")
							self2.rightRune:SetBlendMode("ADD")
							
							self2.bottomLeftRune = self2:CreateTexture()
							self2.bottomLeftRune:SetAtlas("ChallengeMode-Runes-BL-Glow")
							self2.bottomLeftRune:SetPoint("BOTTOM",-23,-10)
							self2.bottomLeftRune:SetSize(18,18)
							self2.bottomLeftRune:SetDrawLayer("BACKGROUND")
							self2.bottomLeftRune:SetBlendMode("ADD")
							
							self2.bottomRightRune = self2:CreateTexture()
							self2.bottomRightRune:SetAtlas("ChallengeMode-Runes-BR-Glow")
							self2.bottomRightRune:SetPoint("BOTTOM",23,-10)
							self2.bottomRightRune:SetSize(18,18)
							self2.bottomRightRune:SetDrawLayer("BACKGROUND")
							self2.bottomRightRune:SetBlendMode("ADD")]]
							
							
							--Small
							self2.highlight = self2.highlight or self2:CreateTexture()
							self2.highlight:SetAtlas("ChallengeMode-Runes-GlowSmall")
							self2.highlight:SetPoint("CENTER")
							self2.highlight:SetSize(40,40)
							self2.highlight:SetBlendMode("ADD")
							self2.highlight:SetDrawLayer("OVERLAY",7)
							
							self2.highlight2 = self2.highlight2 or self2:CreateTexture()
							self2.highlight2:SetAtlas("ChallengeMode-Runes-GlowBurstLarge")
							self2.highlight2:SetPoint("CENTER")
							self2.highlight2:SetSize(40,40)
							self2.highlight2:SetBlendMode("BLEND")
							self2.highlight2:SetDrawLayer("OVERLAY",7)
							
							--Glow
							self2.glow = self2.glow or self2:CreateTexture()
							self2.glow:SetAtlas("BonusChest-CircleGlow")
							self2.glow:SetPoint("CENTER")
							self2.glow:SetSize(1,1)
							self2.glow:SetVertexColor(0.2745,0.7529,0.8313)
							self2.glow:SetBlendMode("ADD")
							self2.glow:SetDrawLayer("OVERLAY",7)
						end
						--Large
						self2.tex:SetAtlas("ChallengeMode-Runes-GlowLarge")
						self2.tex:SetBlendMode("ADD")
						
						
						self2.tex2 = self2.tex2 or self2:CreateTexture()
						self2.tex2:SetAtlas("ChallengeMode-Runes-GlowBurstLarge")
						self2.tex2:SetPoint("CENTER")
						self2.tex2:SetAllPoints()
						self2.tex2:SetBlendMode("BLEND")
						self2.tex2:SetDrawLayer("OVERLAY",7)
						if not self.db.isMinimal then
							self2.rotateTimer = C_Timer.NewTicker(0.03333,function(t) 
								self2.highlight:SetRotation(self2.highlight:GetRotation()+0.02)
								self2.highlight2:SetRotation(self2.highlight:GetRotation()+0.02)
								self2.tex:SetRotation(self2.tex:GetRotation()-0.01)
								self2.tex2:SetRotation(self2.tex:GetRotation()-0.01)
								self2.glow:SetSize(glowSize*math.abs(0.5*math.sin(self2.tex:GetRotation())),glowSize*math.abs(0.5*math.sin(self2.tex:GetRotation())))
							end)
						end
					end)
					btn:SetScript("OnLeave", function(self2,motion)
						if not self.db.isMinimal then
							--self2.lines:SetTexture()
							self2.innerCircle:SetTexture()
							--self2.topRune:SetTexture()
							--self2.leftRune:SetTexture()
							--self2.rightRune:SetTexture()
							--self2.bottomLeftRune:SetTexture()
							--self2.bottomRightRune:SetTexture()
							self2.highlight:SetTexture()
							self2.highlight2:SetTexture()
							self2.glow:SetTexture()
							
							if self2.rotateTimer and not self2.rotateTimer:IsCancelled() then
								self2.rotateTimer:Cancel()
							end
						end
						self2.tex2:SetTexture()
						self2.tex:SetAtlas("ChallengeMode-Runes-Large")
						self2.tex:SetBlendMode("BLEND")
						self2.tex:SetVertexColor(1,1,1)
					end)
					self.DTButtons[k] = btn
					self.isbuttonscreated = true
				end
			end
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
        [406] = 93283, -- Halls of Infusion
        [463] = 424197, -- Dawn of the Inifine: Galakrond's Fall
        [464] = 424197, -- Dawn of the Inifine: Murozond's Rise
        
    }

