
uClock = AceLibrary("AceAddon-2.0"):new("AceDB-2.0", "AceEvent-2.0", "FuBarPlugin-2.0")
uClock.hasIcon = "Interface\\Icons\\INV_Misc_PocketWatch_02"
uClock.blizzardTooltip = true
uClock.cannotHideText = true

uClock:RegisterDB("uClockDB")
uClock:RegisterDefaults('profile', { twentyFour = true, showSeconds = false })


function uClock:OnEnable()
	self:ScheduleRepeatingEvent(self.UpdateDisplay, 1, self)
	self.OnMenuRequest = {
		type = 'group',
		args = {
			twentyFour = {
				name = "24 Hour Mode",
				desc = "Choose whether to have the time shown in 12-hour or 24-hour format,",
				type = "toggle", order = 1,
				get = function() return self.db.profile.twentyFour end,
				set = function() self.db.profile.twentyFour = not self.db.profile.twentyFour end,
			},
			showSeconds = {
				name = "Show Seconds",
				desc = "Choose whether to show seconds.",
				type = "toggle", order = 2,
				get = function() return self.db.profile.showSeconds end,
				set = function() self.db.profile.showSeconds = not self.db.profile.showSeconds end,
			},
		},
	}
end

function uClock:OnTextUpdate()
	self:SetText(self:GetTimeString(date("%H"), date("%M"), true))
end

function uClock:OnTooltipUpdate()
	local hour, minute = GetGameTime()

	GameTooltip:AddDoubleLine("Server Time", self:GetTimeString(hour, minute))
	GameTooltip:AddDoubleLine("Today's Date", date("%A, %B %d, %Y"))
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("|cffeda55fClick|r to toggle the Time Manager.", 0.2, 1, 0.2)
	GameTooltip:AddLine("|cffeda55fShift-Click|r to toggle the Calendar.", 0.2, 1, 0.2)
end

function uClock:OnClick(button)
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			if GroupCalendar then
				GroupCalendar.ToggleCalendarDisplay()
			else
				ToggleCalendar()
			end
		else
			ToggleTimeManager()
		end
	end
end


function uClock:GetTimeString(hour, minute, color)
	local time, pm

	if not self.db.profile.twentyFour then
		pm = floor(hour / 12) == 1
		hour = mod(hour, 12)

		if hour == 0 then hour = 12 end
	end

	time = ("%d:%02d"):format(hour, minute)

	if self.db.profile.showSeconds then
		time = time..date(":%S")
	end

	if not self.db.profile.twentyFour then
		time = time..(pm and " PM" or " AM")
	end

	if color then return "|cffffffff"..time.."|r"
	else return time end
end

