--==========================Module Part======================
local moduleName = ...
print('loaded',moduleName)
local M = {}
_G[moduleName] = M
----------------------------Default config-------------------
if cfg==nil then 
--cfg init--
    cfg = {}
    cfg.ID=""
    cfg.pIN=5
    cfg.SSID=""
    cfg.PWD=""
    cfg.mqHost=""
    cfg.mqPort=1883
    cfg.mqUser=""
    cfg.mqPwd=""    
    cfg.pMTR=1
    cfg.mqT=""
    cfg.mqRp=60
end

--==========================Local parameters===========

function M.loadcfg()
    local jn = require "cjson"
    if file.open("cfg.json","r")==nil then return end
    cfg = jn.decode(file.readline())
    file.close()
end
function M.savecfg()
    cfg.MAC=nil
    local jn = require "cjson"
    file.open("cfg.json","w+")
    file.writeline(jn.encode(cfg))
    file.close()
end

return M
