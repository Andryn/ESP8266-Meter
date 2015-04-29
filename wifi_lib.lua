--==========================Module Part======================
local moduleName = ...
print('loaded',moduleName)
local M = {}
_G[moduleName] = M
--==========================Local parameters===========

local function ledinit() 
    for p = 6, 8 do
        pwm.setup(p,500,50)
        pwm.start(p)
    end
end
ledinit()
local function led(r,g,b) 
    pwm.setduty(8,r) 
    pwm.setduty(6,g) 
    pwm.setduty(7,b) 
end
wifi.sleeptype(1) -- 0=NONE_SLEEP_T, 1 =LIGHT_SLEEP_T, 2 = MODEM_SLEEP_T

local wifi_ap=function()
    wifi.setmode(wifi.SOFTAP)
    local w = {ssid='ESP'}
    wifi.ap.config(w)
    local lt=0
    tmr.stop(1)
    tmr.alarm(1,1000,1,function()
        if lt==0 then
            lt=1; led(512,512,512)
        else
            lt=0; led(0,0,0)
        end
    end)
    return wifi.ap.getmac()
end

local wifi_st=function()
    wifi.setmode(wifi.STATION)
    wifi.sta.config(cfg.SSID,cfg.PWD)
    wifi.sta.connect()
    tmr.stop(1)
    tmr.alarm(1,1000,1,function()
        local s=wifi.sta.status()
        if s==0 or s==1 then led(0,0,512)
        elseif s==5 then led(0,512,0) tmr.stop(1)
        else led(512,0,0) end
    end)
    return wifi.sta.getmac()
end

--Out--
function M.wifi(ap)
    if ap then
        cfg.MAC=wifi_ap()
    else
        cfg.MAC=wifi_st()
    end
    return true
end

return M
