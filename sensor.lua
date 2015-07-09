--==========================Module Part======================
local moduleName = ...
local M = {}
_G[moduleName] = M


local mqtt_state = 0 -- State control
local t              -- Temperature
local h              -- Humidity
local p              -- Pressure
local count = 0      -- Interations
local sc = 0         -- default MQTT secure mode

function mqtt_do()
    count = count + 1  -- For testing number of interations before failure
    if tmr.time() > 60 then --If working > 60s, then node.dsleep
        print("No connected. GoTo node.dsleep", tmr.time())
        mqtt_state = 30
    end
    if mqtt_state < 5 then
        mqtt_state = wifi.sta.status() --State: Waiting for wifi
    elseif mqtt_state == 5 then
        mqtt_state = 25 -- Publishing...
        t = nil
        h = nil
        p = nil
        if cfg.pDHT~=nil then
            local s, t1, h1, t2, h2 = dht.read(cfg.pDHT)
            if s == dht.OK then
                t = string.format("%d.%03d", math.floor(t1),t2)
                h = string.format("%d.%03d", math.floor(h1),h2)
            end
        end
        if cfg.pSDA~=nil and cfg.pSCL~=nil then
            -- Pressure
            bmp180 = require("bmp180")
            bmp180.init(cfg.pSDA, cfg.pSCL)
            bmp180.read(1)
            if t==nil then 
                local t1 = bmp180.getTemperature() 
                t=string.format("%d.%d", t1/10,t1%10)
            end
            p = bmp180.getPressure()
            bmp180 = nil
            package.loaded["bmp180"]=nil
            _G["bmp180"]=nil
        end
        -- MQTT
        if t~=nil or h~=nil or p~=nil then
            m = mqtt.Client(cfg.ID, 120, cfg.mqUser, cfg.mqPwd)
            --print("connect to ",cfg.ID, 120, cfg.mqUser, cfg.mqPwd, cfg.mqHost , cfg.mqPort, sc)
            m:connect( cfg.mqHost , cfg.mqPort, sc, function(conn)
                print("Connected to MQTT:" .. cfg.mqHost .. ":" .. cfg.mqPort .." as " .. cfg.ID )
                mqtt_state = 20 -- Go to publish Temperature
            end)
        else
            mqtt_state = 0 -- Publishing...
        end
     elseif mqtt_state == 20 then
        mqtt_state = 25 -- Publishing...
        if t==nil then
            mqtt_state = 21
            return
        end
        m:publish(cfg.mqT..'t',t, 0, 0, function(conn)
          print("Sent messeage #"..count.."\nTopic:"..cfg.mqT..'t'.."\nTemp:"..t)
          mqtt_state = 21  --  Go to publish Humidity
        end)
     elseif mqtt_state == 21 then
        mqtt_state = 25 -- Publishing...
        if h==nil then
            mqtt_state = 22
            return
        end
        m:publish(cfg.mqT..'h',h, 0, 0, function(conn)
          print(" Sent messeage #"..count.."\nTopic:"..cfg.mqT..'h'.."\nH:"..h)
          mqtt_state = 22  -- Go to publish pressure
        end)
     elseif mqtt_state == 22 then
        mqtt_state = 25 -- Publishing...
        if p==nil then
            mqtt_state = 23
            return
        end
        m:publish(cfg.mqT..'p',p, 0, 0, function(conn)
          print(" Sent messeage #"..count.."\nTopic:"..cfg.mqT..'p'.."\nP:"..p)
          mqtt_state = 23  -- Go to publish time
        end)
     elseif mqtt_state == 23 then
          mqtt_state = 25 -- Publishing...
          m:publish(cfg.mqT..'time',tmr.time(), 0, 0, function(conn)
              print(" Sent messeage #"..count.."\nTopic:"..cfg.mqT..'time'.."\nTime:"..tmr.time())
              mqtt_state = 30  -- Go to publish vdd
          end)
     elseif mqtt_state == 25 then
        print("Publishing..."..mqtt_state)
     else
        print("node.dsleep...")
        if m~=nil then m:close() end
        tmr.stop(0)
        node.dsleep(1000000*cfg.mqRp)
     end

end

function M.doSensor()
    tmr.alarm(0, 2000, 1, function() mqtt_do() end)
end
return M
