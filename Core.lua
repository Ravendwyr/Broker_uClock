
local L = LibStub("AceLocale-3.0"):GetLocale("Broker_uClock")

local dropDownMenu, db
local localTime, realmTime, utcTime, displayedTime

local uClock = LibStub("AceAddon-3.0"):NewAddon("uClock", 'AceTimer-3.0')
local uClockBlock = LibStub("LibDataBroker-1.1"):NewDataObject("uClock", {
	type = "data source", icon = "Interface\\Icons\\INV_Misc_PocketWatch_02",

	OnClick = function(self, button)
		if button == "LeftButton" then
			if IsShiftKeyDown() then
				if GroupCalendar then GroupCalendar.ToggleCalendarDisplay()
				else ToggleCalendar() end
			else
				ToggleTimeManager()
			end
		elseif button == "RightButton" then
			GameTooltip:Hide()
			ToggleDropDownMenu(1, nil, dropDownMenu, "cursor")
		end
	end,

	OnTooltipShow = function(tooltip)
		tooltip:AddDoubleLine(L["Today's Date"], date("%A, %B %d, %Y"))
		tooltip:AddDoubleLine(L["Local Time"], localTime)
		tooltip:AddDoubleLine(L["Server Time"], realmTime)
		tooltip:AddDoubleLine(L["UTC Time"], utcTime)
		tooltip:AddLine(" ")
		tooltip:AddLine(L["|cffeda55fClick|r to toggle the Time Manager."], 0.2, 1, 0.2)
		tooltip:AddLine(L["|cffeda55fShift-Click|r to toggle the Calendar."], 0.2, 1, 0.2)
		tooltip:AddLine(L["|cffeda55fRight-Click|r for options."], 0.2, 1, 0.2)
	end,
})


function uClock:OnEnable()
	self.db = LibStub("AceDB-3.0"):New("uClockDB", { profile = { showLocal = true, showRealm = false, showUTC = false, twentyFour = true, showSeconds = false }}, "Default")
	db = self.db.profile

	dropDownMenu = CreateFrame("Frame")
	dropDownMenu.displayMode = "MENU"
	dropDownMenu.info = {}
	dropDownMenu.levelAdjust = 0
	dropDownMenu.initialize = function(self, level, value)
		if not level then return end

		local info = self.info
		wipe(info)

		if level == 1 then
			info.isTitle = 1
			info.text = "uClock"
			UIDropDownMenu_AddButton(info, level)

			info.isTitle = nil
			info.disabled = nil
			info.keepShownOnClick = 1

			info.text = L["Show Local Time"]
			info.func = function() db.showLocal = not db.showLocal uClock:UpdateTimeStrings() end
			info.checked = function() return db.showLocal end
			UIDropDownMenu_AddButton(info, level)

			info.text = L["Show Realm Time"]
			info.func = function() db.showRealm = not db.showRealm uClock:UpdateTimeStrings() end
			info.checked = function() return db.showRealm end
			UIDropDownMenu_AddButton(info, level)

			info.text = L["Show UTC Time"]
			info.func = function() db.showUTC = not db.showUTC uClock:UpdateTimeStrings() end
			info.checked = function() return db.showUTC end
			UIDropDownMenu_AddButton(info, level)

			wipe(info)

			info.disabled = 1
			UIDropDownMenu_AddButton(info, level)

			info.disabled = nil
			info.keepShownOnClick = 1

			info.text = L["24 Hour Mode"]
			info.func = function() db.twentyFour = not db.twentyFour uClock:UpdateTimeStrings() end
			info.checked = function() return db.twentyFour end
			UIDropDownMenu_AddButton(info, level)

			info.text = L["Show Seconds"]
			info.func = function() db.showSeconds = not db.showSeconds uClock:UpdateTimeStrings() end
			info.checked = function() return db.showSeconds end
			UIDropDownMenu_AddButton(info, level)

			wipe(info)

			info.disabled = 1
			UIDropDownMenu_AddButton(info, level)

			info.disabled = nil
			info.text = CLOSE
			info.func = function() if UIDROPDOWNMENU_OPEN_MENU == dropDownMenu then CloseDropDownMenus() end end
			UIDropDownMenu_AddButton(info, level)
		end
	end

	self:ScheduleRepeatingTimer("UpdateTimeStrings", 1)
end


function uClock:UpdateTimeStrings()
	local lHour, lMinute = date("%H"), date("%M")
	local sHour, sMinute = GetGameTime()
	local uHour, uMinute = date("!%H"), date("!%M")

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

	localTime = ("%d:%02d"):format(lHour, lMinute)
	realmTime = ("%d:%02d"):format(sHour, sMinute)
	utcTime   = ("%d:%02d"):format(uHour, uMinute)

	if db.showSeconds then
		localTime = localTime..date(":%S")
		realmTime = realmTime..date(":%S")
		utcTime   = utcTime .. date(":%S")
	end

	if not db.twentyFour then
		localTime = localTime..(lPM and " PM" or " AM")
		realmTime = realmTime..(sPM and " PM" or " AM")
		utcTime   = utcTime .. (uPM and " PM" or " AM")
	end

	displayedTime = ""

	if db.showLocal then displayedTime = displayedTime..localTime.." | " end
	if db.showRealm then displayedTime = displayedTime..realmTime.." | " end
	if db.showUTC then displayedTime = displayedTime..utcTime end

	displayedTime = displayedTime:gsub(" | $", "") -- remove trailing seperators

	uClockBlock.text = displayedTime
end
