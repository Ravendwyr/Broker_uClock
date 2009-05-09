
local L = LibStub("AceLocale-3.0"):NewLocale("uClock", "zhTW")
if not L then return end

-- time/date strings
L[" PM"] = " 下午"
L[" AM"] = " 上午"

L["%A, %B %d, %Y"] = "%Y年 %B %d日,%A"

-- tooltip strings
L["Today's Date"] = "當前時間"
L["Local Time"] = "本地時間"
L["Server Time"] = "伺服器時間"
L["UTC Time"] = "UTC 時間(世界標準時間)"

L["|cffeda55fClick|r to toggle the Time Manager."] = "|cffeda55f點擊|r 切換時間管理器."
L["|cffeda55fShift-Click|r to toggle the Calendar."] = "|cffeda55fShift-左鍵|r 切換日曆."
L["|cffeda55fRight-Click|r for options."] = "|cffeda55f右鍵|r 打開選項."

-- option strings
L["Show Local Time"] = "顯示本地時間"
L["Show Realm Time"] = "顯示伺服器時間"
L["Show UTC Time"] = "顯示 UTC 時間"
L["24 Hour Mode"] = "24 小時模式"
L["Show Seconds"] = "顯示秒數"
