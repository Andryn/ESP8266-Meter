# ESP8266-Meter
Meter temperature and humidity on ESP8266, DHT22 and BMP180 based  for <a href="http://www.aliexpress.com/af/ESP8266-ESP%25252d12-Board.html">ESP8266 ESP-12 Full Evaluation Board</a>.
If you not have DHT22, then comment line cfg.pDHT=1 in config.lua.
If you not have BMP180, then comment lines cfg.pSDA=4 and cfg.pSCL=2 in config.lua.

Publish data to MQTT broker.
Work on <a href="https://github.com/nodemcu/nodemcu-firmware/releases/tag/0.9.6-dev_20150704">NodeMCU 0.9.6 build 20150704</a>

## Hardware
<table>
    <tr>
      <th>NodeMCU IO index</th>
      <th>ESP-12 GPIO</th>
      <th>Connection</th>
    </tr>
    <tr>
        <td>0</td>
        <td>GPI16</td>
        <td>Connect to REST pin for node.dsleep()</td>
    </tr>
    <tr>
        <td>1</td>
        <td>GPIO5</td>
        <td>DHT22</td>
    </tr>
    <tr>
        <td>2</td>
        <td>GPIO4</td>
        <td>BMP180 SCL</td>
    </tr>
    <tr>
        <td>4</td>
        <td>GPIO2</td>
        <td>BMP180 SDA</td>
    </tr>
    <tr>
        <td>5</td>
        <td>GPIO14</td>
        <td>Input for setup mode</td>
    </tr>
    <tr>
        <td>6</td>
        <td>GPIO12</td>
        <td>RGB 4-pin LED wifi indicator, green</td>
    </tr>
    <tr>
        <td>7</td>
        <td>GPIO13</td>
        <td>RGB 4-pin LED wifi indicator, blue</td>
    </tr>
    <tr>
        <td>8</td>
        <td>GPIO15</td>
        <td>RGB 4-pin LED wifi indicator, red</td>
    </tr>
</table>
## Use
http://192.168.4.1/ - Initial manual setup (you need connect to open AP which ssid='ESP')<br/>
