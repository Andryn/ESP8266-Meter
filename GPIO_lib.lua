--==========================Module Part======================
local moduleName = ...
print('loaded',moduleName)
local M = {}
_G[moduleName] = M
--==========================

function M.initGPIO()
    gpio.mode(cfg.pIN, gpio.INPUT)
    gpio.write(cfg.pIN, gpio.HIGH)
end

function M.getConfigMode()
    print("gpio.read",gpio.read(cfg.pIN))
    if gpio.read(cfg.pIN)==gpio.LOW or cfg.SSID=='' then 
        return true
    end
    return false
end

return M
