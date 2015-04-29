--==========================Module Part======================
local moduleName = ...
print('loaded',moduleName)
local M = {}
_G[moduleName] = M

local function connect (conn, data)
    conn:on ('receive',
        function (cn, req_data)
            local method, url, vars
            _, _, method, url, vars = string.find(req_data, "([A-Z]+) /([^?]*)%??(.*) HTTP")
            local f
            if url~='' and url~='set' then
                cn:send("HTTP/1.1 404 file not found\r\n\r\n")
                cn:close()
                return
            end
            f='setup.htm'
            if url=='set' then
                vars="&"..vars.."&"
                vars = string.gsub(vars, '%%2F', '\/')
                for i,v in pairs(cfg) do 
                    if string.find(vars, "&"..i.."=") then
                        cfg[i]=string.match(vars, ".-&"..i.."=(.-)&.-")
                    end
                end
                --Save Config
                C=require("config")
                C.savecfg()
                C=nil
                package.loaded["config"]=nil
                _G["config"]=nil                
                if string.find(vars, "&RST=1&") then
                    tmr.alarm(0,2000,0,function()
                        node.dsleep(1000000)
                    end)
                end
                f='redirect.htm'
            end
            file.open(f,"r")
            while true do
                local ln=file.readline()
                if ln == nil then break end
                for i,v in pairs(cfg) do
                    ln = string.gsub(ln, '$'..i, v)
                end
                cn:send(ln)
            end
            file.close()
            cn:close()
        end)
end

-- Create the httpd server
function M.doHTTP()
    local svr = net.createServer(net.TCP, 30)
    svr:listen (80, connect)
end
return M
