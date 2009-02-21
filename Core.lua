
local dropDownMenu, db
local localTime, realmTime, displayedTime

local uClock = LibStub("AceAddon-3.0"):NewAddon("uClock", 'AceTimer-3.0')
local uClockBlock = LibStub("LibDataBroker-1.1"):NewDataObject("uClock", {
	type = "data source",
	icon = "Interface\\Icons\\INV_Misc_PocketWatch_02",

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
		tooltip:AddDoubleLine("Server Time", realmTime)
		tooltip:AddDoubleLine("Today's Date", date("%A, %B %d, %Y"))
		tooltip:AddLine(" ")
		tooltip:AddLine("|cffeda55fClick|r to toggle the Time Manager.", 0.2, 1, 0.2)
		tooltip:AddLine("|cffeda55fShift-Click|r to toggle the Calendar.", 0.2, 1, 0.2)
		tooltip:AddLine("|cffeda55fRight-Click|r for options.", 0.2, 1, 0.2)
	end,
})


function uClock:OnEnable()
	self.db = LibStub("AceDB-3.0"):New("uClockDB", { profile = { twentyFour = true, showSeconds = false, r = 1, g = 1, b = 1 }}, "Default")
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

			info.text = "Show Local Time"
			info.func = function() db.showLocal = not db.showLocal uClock:UpdateTimeStrings() end
			info.checked = function() return db.showLocal end
			UIDropDownMenu_AddButton(info, level)

			info.text = "Show Realm Time"
			info.func = function() db.showRealm = not db.showRealm uClock:UpdateTimeStrings() end
			info.checked = function() return db.showRealm end
			UIDropDownMenu_AddButton(info, level)

			wipe(info)

			info.disabled = 1
			UIDropDownMenu_AddButton(info, level)

			info.disabled = nil
			info.keepShownOnClick = 1

			info.text = "24 Hour Mode"
			info.func = function() db.twentyFour = not db.twentyFour uClock:UpdateTimeStrings() end
			info.checked = function() return db.twentyFour end
			UIDropDownMenu_AddButton(info, level)

			info.text = "Show Seconds"
			info.func = function() db.showSeconds = not db.showSeconds uClock:UpdateTimeStrings() end
			info.checked = function() return db.showSeconds end
			UIDropDownMenu_AddButton(info, level)

			info.func = nil
			info.checked = nil

			info.text = "Colour of Text"
			info.notClickable = true
			info.hasColorSwatch = true
			info.swatchFunc = function() db.r, db.g, db.b = ColorPickerFrame:GetColorRGB() uClock:UpdateTimeStrings() end
			info.cancelFunc = function(previous) db.r, db.g, db.b = previous.r, previous.g, previous.b uClock:UpdateTimeStrings() end
			info.r, info.g, info.b = db.r, db.g, db.b
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

	local lPM, sPM

	if not db.twentyFour then
		lPM = floor(lHour / 12) == 1
		lHour = mod(lHour, 12)

		sPM = floor(sHour / 12) == 1
		sHour = mod(sHour, 12)

		if lHour == 0 then lHour = 12 end
		if sHour == 0 then sHour = 12 end
	end

	localTime = ("%d:%02d"):format(lHour, lMinute)
	realmTime = ("%d:%02d"):format(sHour, sMinute)

	if db.showSeconds then
		localTime = localTime..date(":%S")
		realmTime = realmTime..date(":%S")
	end

	if not db.twentyFour then
		localTime = localTime..(lPM and " PM" or " AM")
		realmTime = realmTime..(sPM and " PM" or " AM")
	end

	if db.showLocal and db.showRealm then displayedTime = localTime.." | "..realmTime
	elseif db.showLocal then displayedTime = localTime
	elseif db.showRealm then displayedTime = realmTime
	else displayedTime = "" end

	uClockBlock.text = ("|cff%02x%02x%02x%s|r"):format(db.r*255, db.g*255, db.b*255, displayedTime)
end
