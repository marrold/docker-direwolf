
# 📡 docker-direwolf

A fork of W2BRO's [docker-direwolf](https://github.com/w2bro/docker-direwolf)  Dire Wolf container project, with modifications to support the [Virtual Packet Environment](https://wiki.oarc.uk/virtual_packet_environment)

  

## Installation
It's assumed you'll be using docker-compose to start the containers. See `docker-compose-example.yaml` as an example

  
  
## Configuring Dire Wolf

### Generating a config with environment variables

The following Environment variables can be used to automatically generate a Dire Wolf configuration. 

**Note**: boolean style variables will be interpreted as true if set to *anything* - it doesn't have to be True/False/Yes/No (Although probably should be for readability) 

| Variable | Required | Description |
|-------------|-----------|-------------|
| `CALLSIGN` | Yes | Your callsign & SSID, example `N0CALL-10` |
| `ADEVICE` | Yes | Configures Audio Device |
| `ARATE` | No | The sound rate. Defaults to `48000` |
| `USE_GPS` | No | Enables using GPS for location | 
| `GPSD_HOST` | No | Defaults to `127.0.0.1` | 
| `LATITUDE` | Yes | Latitude for PBEACON, example `42^37.14N` |
| `LONGITUDE` | Yes | Longitude for PBEACON, example `071^20.83W` |
| `HEIGHT` | No | Antenna Height |
| `GAIN` | No | Antenna Gain |
| `POWER` | No | Output Power (Watts) |
| `COMMENT` | No | Override PBEACON default comment, do not use the `~` character |
| `SYMBOL` | No | APRS symbol for PBEACON, defaults to `igate` |
| `VIA` | No | The path to use when sending beacons. Defaults to `WIDE1-1`
| `ENABLE_IG` | No | Enables gating recieved packets to APRS-IS. Defaults to NO |
| `PASSCODE` | Yes | Passcode for igate login, [find passcode here] |
| `IGSERVER` | No | Override with the APRS server for your region, default for North America `noam.aprs2.net` |
| `IG_BEACON` | No |  Enables sending locally generated beacons to APRS-IS. Defaults to No |
| `IG_DELAY` | No | The initial delay when sending beacons to APRS-IS. Defaults to `0:30` |
| `IG_EVERY` | No | How frequently to send beacons to APRS-IS. Defaults to `60` |
| `RF_BEACON` | No | Enables sending locally generated beacons out via RF. Defaults to No |
| `RF_SLOT` | No | The slot to use when sending Beacons over RF. | 
| `RF_DELAY` | No | The initial delay when sending RF beacons. Defaults to `0:30` |
| `RF_EVERY` | No | How frequently to transmit RF beacons. Defaults to `60` |
| `DWARGS` | No | Set to add/pass any arguments to the direwolf executable, example `-t 0` for no color logs |

  
### Passing a configuration file to Dire Wolf
For more advanced setups you may wish to write your own config file and pass it to Dire Wolf rather than using the environment variable based method. To do so, mount your config file as a volume at `/etc/direwolf/direwolf-override.conf`
