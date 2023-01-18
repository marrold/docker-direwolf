#!/bin/bash
set -e

function direwolf_begin {
	echo "cat /etc/direwolf/direwolf.conf"
	cat direwolf.conf
	echo -e "### EOF ###\n"

	echo -e "Starting Dire Wolf: direwolf $DWARGS -c direwolf.conf\n"
	
	direwolf $DWARGS -c direwolf.conf
}

if [ -f "direwolf-override.conf" ]; then
       echo "direwolf-override.conf exists, skipping config generation..."
       cp direwolf-override.conf direwolf.conf
       direwolf_begin
else
       echo -e "Couldn't find direwolf.conf, generating a new one...\n"
fi

cd /etc/direwolf

rm -f direwolf.conf

# Validate location settings
if [ -n "$USE_GPS" ] && [ -n "$ENABLE_DIGI" ]; then
		echo "Digipeating whilst using GPS Beacons is a bad idea."
		echo "Remove either USE_GPS or ENABLE_DIGI"
		exit 1
fi

if [[ -n "$RF_BEACON" ||  -n "$IG_BEACON" ]]; then
	if [ -n "$USE_GPS" ]; then
		if  [ -n "$LATITUDE" ] && [ -n "$LONGITUDE" ]; then
			echo "USE_GPS is enabled. Don't set LATITUDE or LONGITUDE"
			exit 1
		fi
	else
		if  [ -z "$LATITUDE" ] && [ -z "$LONGITUDE" ]; then
			echo "USE_GPS is not enabled. Set LATITUDE and LONGITUDE"
			exit 1
		fi
	fi
fi

# Validate iGate settings
if  [ -n "$ENABLE_IG" ]; then
	if  [ -z "$PASSCODE" ]; then
		echo "PASSCODE is required if ENABLE_IG is set"
		exit 1
	fi
else
	if  [ -n "$IG_BEACON" ]; then
		echo "ENABLE_IG is required to use IG_BEACON"
		exit 1
	fi
fi

## Basic Configuration

cat <<- EOT >> direwolf.conf
#### Base Configuration ####

MYCALL $CALLSIGN
ADEVICE $ADEVICE
ARATE $ARATE
CHANNEL 0
EOT

if [ -n "$PTT" ]; then
	echo "PTT $PTT" >> direwolf.conf
fi

if [ -n "$MODEM" ]; then
	echo "MODEM $MODEM" >> direwolf.conf
fi

echo "" >> direwolf.conf

## APRS-IS Configuration
if [ -n "$ENABLE_IG" ] && [ -n "$PASSCODE" ]; then

	cat <<- EOT >> direwolf.conf
	#### APRS-IS Configuration ####

	IGLOGIN $CALLSIGN $PASSCODE
	IGSERVER $IG_SERVER

	EOT

fi

## GPSD Configuration 
if  [ -n "$USE_GPS" ]; then
	cat <<- EOT >> direwolf.conf
	#### GPSD Configuration ####

	GPSD $GPSD_HOST

	EOT
fi

## BEACON Configuration
if [[ -n "$RF_BEACON" ||  -n "$IG_BEACON" ]]; then

	echo -e "#### Beacon Configuration ####\n" >> direwolf.conf


	if [ -z "$USE_GPS" ]; then
		TYPE="PBEACON"
		BEACON="lat=$LATITUDE long=$LONGITUDE"
	else
		TYPE="TBEACON"
	fi

	if [ -n "$POWER" ] && [ -n "$HEIGHT" ] && [ -n "$GAIN" ]; then
		if [ -n "$BEACON" ]; then
			BEACON="power=$POWER height=$HEIGHT gain=$GAIN $BEACON"
		else
			BEACON="power=$POWER height=$HEIGHT gain=$GAIN"
		fi
	fi

	if [ -n "$OVERLAY" ]; then
		BEACON="symbol=\"$SYMBOL\" overlay=$OVERLAY comment=\"$COMMENT\" $BEACON"
	else
		BEACON="symbol=\"$SYMBOL\" comment=\"$COMMENT\" $BEACON"
	fi

	if [ -n "$RF_BEACON" ]; then
		if [ -n "$RF_SLOT" ]; then
			echo "$TYPE slot=$RF_SLOT every=$RF_EVERY $BEACON via=$VIA" >> direwolf.conf
		else
			echo "$TYPE delay=$RF_DELAY every=$RF_EVERY $BEACON via=$VIA" >> direwolf.conf
		fi
	fi

	if [ -n "$IG_BEACON" ]; then
		echo -e "$TYPE sendto=IG delay=$IG_DELAY every=$IG_EVERY $BEACON" >> direwolf.conf
	fi

	echo "" >> direwolf.conf

fi

## DIGIPEATER Configuration
if [ -n "$ENABLE_DIGI" ]; then
	cat <<- EOT >> direwolf.conf
	#### Digipeater Configuration ####

	DIGIPEAT 0 0 ^WIDE[3-7]-[1-7]$ ^WIDE[12]-[12]$ TRACE
	FILTER 0 0 ! d/$CALLSIGN

	EOT
fi

direwolf $DWARGS -c direwolf.conf
