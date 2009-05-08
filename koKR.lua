
local L = LibStub("AceLocale-3.0"):NewLocale("uClock", "koKR")
if not L then return end

-- time/date strings
L[" PM"] = " 오후"
L[" AM"] = " 오전"

L["%A, %B %d, %Y"] = "%Y년 %M월 %d일 %A"

-- tooltip strings
L["Today's Date"] = "오늘의 날짜"
L["Local Time"] = "지역 시간"
L["Server Time"] = "서버 시간"
L["UTC Time"] = "국제 표준시"

L["|cffeda55fClick|r to toggle the Time Manager."] = "|cffeda55f클릭|r시 시간 관리자를 토글합니다."
L["|cffeda55fShift-Click|r to toggle the Calendar."] = "|cffeda55fShift-클릭|r시 달력을 토글합니다."
L["|cffeda55fRight-Click|r for options."] = "|cffeda55f우클릭|r시 설정창을 엽니다."

-- option strings
L["Show Local Time"] = "지역 시간 보기"
L["Show Realm Time"] = "서버 시간 보기"
L["Show UTC Time"] = "국제 표준시 보기"
L["24 Hour Mode"] = "24시간제"
L["Show Seconds"] = "초단위 표시"
