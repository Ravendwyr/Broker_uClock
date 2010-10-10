
-------------------
-- Locals
-------------------

local cataclysm = select(4, GetBuildInfo()) >= 40000

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("uClock")
local localTime, realmTime, utcTime, displayedTime
local locale = GetLocale()
local db


-------------------
-- Namespace
-------------------

local name, uClock = ...

LibStub("LibDataBroker-1.1"):NewDataObject(name, uClock)
LibStub("AceEvent-3.0"):Embed(uClock)
LibStub("AceTimer-3.0"):Embed(uClock)

uClock.type = "data source"
uClock.icon = "Interface\\Icons\\Spell_Holy_BorrowedTime"
uClock.text = "Loading..."


-------------------
-- Media
-------------------

local LSM = LibStub("LibSharedMedia-3.0")

LSM:Register("sound", "Blizzard: Alarm Clock 1",    "Sound\\Interface\\AlarmClockWarning1.wav")
LSM:Register("sound", "Blizzard: Alarm Clock 2",    "Sound\\Interface\\AlarmClockWarning2.wav")
LSM:Register("sound", "Blizzard: Alarm Clock 3",    "Sound\\Interface\\AlarmClockWarning3.wav")
LSM:Register("sound", "Blizzard: Bell - Alliance",  "Sound\\Doodad\\BellTollAlliance.wav")
LSM:Register("sound", "Blizzard: Bell - Horde",     "Sound\\Doodad\\BellTollHorde.wav")
LSM:Register("sound", "Blizzard: Bell - Night Elf", "Sound\\Doodad\\BellTollNightElf.wav")
LSM:Register("sound", "Blizzard: Drum Hit",         "Sound\\Doodad\\BellTollTribal.wav")
LSM:Register("sound", "Blizzard: Gong - Troll",     "Sound\\Doodad\\G_GongTroll01.wav")
LSM:Register("sound", "Blizzard: Karazhan Bell",    "Sound\\Doodad\\KharazahnBellToll.wav")
LSM:Register("sound", "Blizzard: Mellow Bells",     "Sound\\Spells\\ShaysBell.wav")


-------------------
-- Events
-------------------

function uClock:PLAYER_LOGIN()
	db = LibStub("AceDB-3.0"):New("uClockDB", { profile = {
		showLocal = true, showRealm = false, showUTC = false,
		twentyFour = true, showSeconds = false, showClock = true,
		hourlyChime = true, hourlyChimeFile = "Blizzard: Alarm Clock 3",
	}}, "Default").profile

	if not db.showClock then
		if cataclysm then
			TimeManagerClockButton:Hide()
		else
			SetCVar("showClock", "0")
			InterfaceOptionsDisplayPanelShowClock_SetFunc("0")
		end
	end

	TimeManagerClockButton:HookScript("OnShow", function() db.showClock = true end)
	TimeManagerClockButton:HookScript("OnHide", function() db.showClock = false end)

	AceConfig:RegisterOptionsTable(name, uClock.CreateConfig)
	AceConfigDialog:AddToBlizOptions(name, "Broker uClock")
	AceConfigDialog:SetDefaultSize(name, 600, 300)

	_G.SlashCmdList["UCLOCK"] = function() AceConfigDialog:Open(name) end
	_G["SLASH_UCLOCK1"] = "/uclock"
	_G["SLASH_UCLOCK2"] = "/uc"

	self:UnregisterEvent("PLAYER_LOGIN")
	self:ScheduleRepeatingTimer("UpdateTimeStrings", 1)
end


-------------------
-- Core
-------------------

function uClock:CreateDateString(message) -- workaround for date() not returning localised days/months
	if locale == "enUS" or locale == "enGB" then return message end

	local days = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" }
	local months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }

	for i = 1, 7, 1 do
		if message:find(days[i]) then
			message = message:gsub( days[i], _G["WEEKDAY_"..days[i]:upper()] )
			break
		end
	end

	for i = 1, 12, 1 do
		if message:find(months[i]) then
			message = message:gsub( months[i], _G["MONTH_"..months[i]:upper()] )
			break
		end
	end

	return message
end

function uClock:UpdateTimeStrings()
	local lHour, lMinute = date("%H"), date("%M")
	local sHour, sMinute = GetGameTime()
	local uHour, uMinute = date("!%H"), date("!%M")
	local seconds = date("%S")

	if db.hourlyChime and lMinute == "00" and seconds == "00" then -- use local time as the difference between local and realm time is minimal
		PlaySoundFile(LSM:Fetch("sound", db.hourlyChimeFile))
	end

	local lPM, sPM, uPM

	if not db.twentyFour then
		lPM = floor(lHour / 12) == 1
		lHour = mod(lHour, 12)

		sPM = floor(sHour / 12) == 1
		sHour = mod(sHour, 12)

		uPM = floor(uHour / 12) == 1
		uHour = mod(uHour, 12)

		if lHour == 0 then lHour = 12 end
		if sHour == 0 then sHour = 12 end
		if uHour == 0 then uHour = 12 end
	end

	if db.showSeconds then
		localTime = ("%d:%02d:%02d"):format(lHour, lMinute, seconds)
		realmTime = ("%d:%02d:%02d"):format(sHour, sMinute, seconds)
		utcTime   = ("%d:%02d:%02d"):format(uHour, uMinute, seconds)
	else
		localTime = ("%d:%02d"):format(lHour, lMinute)
		realmTime = ("%d:%02d"):format(sHour, sMinute)
		utcTime   = ("%d:%02d"):format(uHour, uMinute)
	end

	if not db.twentyFour then
		localTime = localTime..(lPM and L[" PM"] or L[" AM"])
		realmTime = realmTime..(sPM and L[" PM"] or L[" AM"])
		utcTime   = utcTime .. (uPM and L[" PM"] or L[" AM"])
	end

	displayedTime = ""

	if db.showLocal then displayedTime = displayedTime..localTime.." | " end
	if db.showRealm then displayedTime = displayedTime..realmTime.." | " end
	if db.showUTC then displayedTime = displayedTime..utcTime end

	displayedTime = displayedTime:gsub(" | $", "") -- remove any trailing seperators

	self.text = displayedTime
end


-------------------
-- Data Broker
-------------------

function uClock:OnClick(button)
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			if IsAddOnLoaded("GroupCalendar5") then -- Version 5
				if GroupCalendar.UI.Window:IsShown() then
					GroupCalendar.UI.Window:Hide()
				else
					GroupCalendar.UI.Window:Show()
				end
			elseif IsAddOnLoaded("GroupCalendar") then -- Version 4 or below
				GroupCalendar.ToggleCalendarDisplay()
			else
				ToggleCalendar()
			end
		else
			ToggleTimeManager()
		end
	elseif button == "RightButton" then
		GameTooltip:Hide()
		AceConfigDialog:Open(name)
	end
end

function uClock:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines()

	GameTooltip:AddDoubleLine(L["Today's Date"], uClock:CreateDateString(date(L["%A, %B %d, %Y"])))
	GameTooltip:AddDoubleLine(L["Local Time"], localTime)
	GameTooltip:AddDoubleLine(L["Server Time"], realmTime)
	GameTooltip:AddDoubleLine(L["UTC Time"], utcTime)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["|cffeda55fClick|r to toggle the Time Manager."], 0.2, 1, 0.2)
	GameTooltip:AddLine(L["|cffeda55fShift-Click|r to toggle the Calendar."], 0.2, 1, 0.2)
	GameTooltip:AddLine(L["|cffeda55fRight-Click|r for options."], 0.2, 1, 0.2)

	GameTooltip:Show()
end

uClock.OnLeave = GameTooltip_Hide


-------------------
-- Config
-------------------

function uClock:CreateConfig()
	uClock.CreateConfig = nil -- no longer needed

	return {
		name = "Broker uClock", type = "group",
		get = function(key) return db[key.arg] end,
		set = function(key, value) db[key.arg] = value uClock:UpdateTimeStrings() end,
		args = {
			header1 = { name = "Display Options", type = "header", order = 1 },

			showLocal = {
				name = L["Show Local Time"],
				type = "toggle", order = 2, arg = "showLocal",
			},
			showRealm = {
				name = L["Show Realm Time"],
				type = "toggle", order = 3, arg = "showRealm",
			},
			showUTC = {
				name = L["Show UTC Time"],
				type = "toggle", order = 4, arg = "showUTC",
			},

			header2 = { name = "Format Options", type = "header", order = 5 },

			twentyFour = {
				name = L["24 Hour Mode"],
				type = "toggle", order = 6, arg = "twentyFour",
			},
			showSeconds = {
				name = L["Show Seconds"],
				type = "toggle", order = 7, arg = "showSeconds",
			},

			header3 = { name = "Advanced Options", type = "header", order = 8 },

			hourlyChime = {
				name = "Hourly Chime",
				type = "toggle", order = 9, arg = "hourlyChime",
			},
			hourlyChimeFile = {
				name = "Chime Sound",
				type = "select", order = 10, arg = "hourlyChimeFile",
				dialogControl = "LSM30_Sound", values = AceGUIWidgetLSMlists.sound,
				disabled = function() return not db.hourlyChime end,
			},
			showClock = {
				name = _G.SHOW_CLOCK, desc = _G.OPTION_TOOLTIP_SHOW_CLOCK,
				type = "toggle", order = 11, arg = "showClock",
				set = function(_, value)
					if cataclysm then
						if value then TimeManagerClockButton:Show()
						else TimeManagerClockButton:Hide() end
					else
						SetCVar("showClock", value and "1" or "0")
						InterfaceOptionsDisplayPanelShowClock_SetFunc(value and "1" or "0")
					end
				end,
			},
		},
	}
end


-------------------
-- Load
-------------------

if IsLoggedIn() then uClock:PLAYER_LOGIN()
else uClock:RegisterEvent("PLAYER_LOGIN") end
