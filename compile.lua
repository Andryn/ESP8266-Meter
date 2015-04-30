file.remove("config.lc");
file.remove("GPIO_lib.lc");
file.remove("wifi_lib.lc");
file.remove("dht_lib.lc");
file.remove("httpd.lc");
file.remove("sensor.lc");

node.compile('config.lua');
node.compile('GPIO_lib.lua');
node.compile('wifi_lib.lua');
node.compile('dht_lib.lua');
node.compile('httpd.lua');
node.compile('sensor.lua');
