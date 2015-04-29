--==========================Module Part======================
local moduleName = ...
print('loaded',moduleName)
local M = {}
_G[moduleName] = M


local mqtt_state = 0 -- State control
local t              -- Temperature
local h              -- Humidity
local count = 0      -- Interations
local tm             -- Start Time

function mqtt_do()
    count = count + 1  -- For testing number of interations before failure
    if count==1 then tm=tmr.time() end
    if tmr.time()-tm>60 then --If working > 60s, then node.dsleep
        print("No connected. GoTo node.dsleep", tm, tmr.time())
        mqtt_state = 30
    end
    if mqtt_state < 5 then
        mqtt_state = wifi.sta.status() --State: Waiting for wifi
    elseif mqtt_state == 5 then
        mqtt_state = 25 -- Publishing...
        DHT= require("dht_lib")
        DHT.read22(cfg.pMTR)
        t = DHT.getTemperature()
        h = DHT.getHumidity()
        -- release module
        DHT = nil
        package.loaded["dht_lib"]=nil
        _G["dht_lib"]=nil
        -- MQTT
        if t~=nil and h~=nil then
            m = mqtt.Client(cfg.ID, 120, cfg.mqUser, cfg.mqPwd)
            m:connect( cfg.mqHost , cfg.mqPort, 0, function(conn)
                print("Connected to MQTT:" .. cfg.mqHost .. ":" .. cfg.mqPort .." as " .. cfg.ID )
                mqtt_state = 20 -- Go to publish Temperature
            end)
        else
            mqtt_state = 0 -- Publishing...
        end
     elseif mqtt_state == 20 then
          mqtt_state = 25 -- Publishing...
          m:publish(cfg.mqT..'t',t, 0, 0, function(conn)
              print(" Sent messeage #"..count.."\nTopic:"..cfg.mqT..'t'.."\nTemp:"..t)
              mqtt_state = 21  --  Go to publish Humidity
          end)
     elseif mqtt_state == 21 then
          mqtt_state = 25 -- Publishing...
          m:publish(cfg.mqT..'h',h, 0, 0, function(conn)
              print(" Sent messeage #"..count.."\nTopic:"..cfg.mqT..'h'.."\nH:"..h)
              mqtt_state = 30  -- Finished publishing - go node.dsleep
          end)
     elseif mqtt_state == 25 then
        print("Publishing..."..mqtt_state)
     else
        print("node.dsleep...")
        tmr.stop(0)
        node.dsleep(1000000*cfg.mqRp)
     end

end


function M.doSensor()
    tmr.alarm(0, 1000, 1, function() mqtt_do() end)
end
return M
