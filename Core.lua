
local L = LibStub("AceLocale-3.0"):GetLocale("uClock")

local db
local localTime, realmTime, utcTime, displayedTime
local locale = GetLocale()

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
			InterfaceOptionsFrame_OpenToCategory("Broker uClock")
		end
	end,

	OnTooltipShow = function(tooltip)
		tooltip:AddDoubleLine(L["Today's Date"], uClock:CreateDateString(date(L["%A, %B %d, %Y"])))
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

	LibStub("AceConfig-3.0"):RegisterOptionsTable("uClock", {
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
		},
	})

	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("uClock", "Broker uClock")

	_G.SlashCmdList["UCLOCK"] = function() InterfaceOptionsFrame_OpenToCategory("Broker uClock") end
	_G["SLASH_UCLOCK1"] = "/uclock"
	_G["SLASH_UCLOCK2"] = "/uc"

	self:ScheduleRepeatingTimer("UpdateTimeStrings", 1)
end


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
		localTime = localTime..(lPM and L[" PM"] or L[" AM"])
		realmTime = realmTime..(sPM and L[" PM"] or L[" AM"])
		utcTime   = utcTime .. (uPM and L[" PM"] or L[" AM"])
	end

	displayedTime = ""

	if db.showLocal then displayedTime = displayedTime..localTime.." | " end
	if db.showRealm then displayedTime = displayedTime..realmTime.." | " end
	if db.showUTC then displayedTime = displayedTime..utcTime end

	displayedTime = displayedTime:gsub(" | $", "") -- remove trailing seperator

	uClockBlock.text = displayedTime
end
