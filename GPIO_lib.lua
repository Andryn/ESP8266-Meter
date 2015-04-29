--==Module Part==
local moduleName = ...
local M = {}
_G[moduleName] = M
--===============

function M.initGPIO()
    gpio.mode(cfg.pIN, gpio.INPUT)
    gpio.write(cfg.pIN, gpio.HIGH)
end

function M.getConfigMode()
    --print("gpio.read",gpio.read(cfg.pIN))
    if gpio.read(cfg.pIN)==gpio.LOW or cfg.SSID=='' then 
        return 1
    end
    return 0
end

return M
