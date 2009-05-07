
local L = LibStub("AceLocale-3.0"):NewLocale("uClock", "zhCN")
if not L then return end

-- time/date strings
L[" PM"] = " 下午"
L[" AM"] = " 上午"

L["%A, %B %d, %Y"] = "%Y 年 %B 月 %d 日,%A"

L["Monday"] = "星期一"
L["Tuesday"] = "星期二"
L["Wednesday"] = "星期三"
L["Thursday"] = "星期四"
L["Friday"] = "星期五"
L["Saturday"] = "星期六"
L["Sunday"] = "星期日"

-- tooltip strings
L["Today's Date"] = "当前日期"
L["Local Time"] = "本地时间"
L["Server Time"] = "服务器时间"
L["UTC Time"] = "UTC 时间(世界标准时间)"

L["|cffeda55fClick|r to toggle the Time Manager."] = "|cffeda55f点击|r 切换时间管理器."
L["|cffeda55fShift-Click|r to toggle the Calendar."] = "|cffeda55fShift-左键|r 切换日历."
L["|cffeda55fRight-Click|r for options."] = "|cffeda55f右键|r 打开选项."

-- option strings
L["Show Local Time"] = "显示本地时间"
L["Show Realm Time"] = "显示服务器时间"
L["Show UTC Time"] = "显示 UTC 时间"
L["24 Hour Mode"] = "24 小时模式"
L["Show Seconds"] = "显示秒数"
