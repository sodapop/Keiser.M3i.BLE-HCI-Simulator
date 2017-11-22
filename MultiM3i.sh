#! /bin/bash
# --------------------------------------------------------
# Script simulates a group of Keiser M3i bike using HCI.
# --------------------------------------------------------
# This tool is designed to test against a large group of 
# signals at an unrealistic interval.
# --------------------------------------------------------



RATE="A0 00" # 100ms

MAJOR="06"
MINOR="24"
DATATYPE="00"
RPM="00 00"
HR="00 00"
POWER="00 00"
KCAL="00 00"
MINUTES="00"
SECS="00"
TRIP="00 00"
GEAR="01"

HCICOUNT=3;


DECPOWER=0

MAXBIKES=36;


function init {
	COUNTER=0
	while [ $COUNTER -lt $HCICOUNT ]; do
		HCIDEVICE="hci$COUNTER";
		hciconfig $HCIDEVICE down > /dev/null;
		hciconfig $HCIDEVICE up > /dev/null;
		hcitool -i $HCIDEVICE cmd 0x08 0x000A 00 > /dev/null;
		hcitool -i $HCIDEVICE cmd 0x08 0x0006 $RATE  $RATE  03  00  00  00 00 00 00 00 00 07 00 > /dev/null;
		hcitool -i $HCIDEVICE cmd 0x08 0x0008 1C 03 09 4D 33 02 01 04 14 FF 02 01 $MAJOR $MINOR $DATATYPE $BIKEID $RPM $HR $POWER $KCAL $MINUTES $SECS $TRIP $GEAR > /dev/null;
		hcitool -i $HCIDEVICE cmd 0x08 0x000A 01 > /dev/null;
		let COUNTER=COUNTER+1;
	done
}

function set_broadcast {
	COUNTER=0
	while [ $COUNTER -lt $MAXBIKES ]; do
		sleep .15
		
		if [ $((COUNTER%2)) -eq 0 ]; then
			HCIDEVICE="hci1";
		else
			HCIDEVICE="hci2";
		fi

		#HCIDEVICE="hci$COUNTER";
		#HCIDVICE="hci1";
		
		BIKEID="$COUNTER";


		BIKEID_hex=`printf "%02X" $COUNTER`;

		#To generate in the range: {0,..,9}
		GEAR=$(( $RANDOM % 10 ));
		GEAR_hex=`printf "%02X" $GEAR`;


		#To generate in the range: {90,..,90+100}
		POWER=$(( $RANDOM % 100 + 90 ));		
		POWER_hex=`printf "%04X" $POWER`;
		#echo $POWER_hex;
		POWER_hex=`printf $POWER_hex | sed 's/../& /g'`;
		#echo "POWER: "$POWER " - " $POWER_hex;

		powerArray=($POWER_hex);
		#echo ${powerArray[0]};
		#echo ${powerArray[1]};

		RPM=$(( $RANDOM % 100 + 60 ));
		RPM_hex=`printf "%04X" $RPM`;
		RPM_hex=`printf $RPM_hex | sed 's/../& /g'`;
		#echo $RPM_hex;

		rpmArray=($RPM_hex);
		#echo ${rpmArray[0]};
		#echo ${rpmArray[1]};


		hcitool -i $HCIDEVICE cmd 0x08 0x0008 1C 03 09 4D 33 02 01 04 14 FF 02 01 $MAJOR $MINOR $DATATYPE $BIKEID_hex ${rpmArray[1]} ${rpmArray[0]} $HR ${powerArray[1]} ${powerArray[0]} $KCAL $MINUTES $SECS $TRIP $GEAR_hex > /dev/null;

	
		echo $HCIDEVICE "Bike:"$BIKEID $BIKEID_hex " gear:"$GEAR $GEAR_hex " power:"$POWER"W" $POWER_hex " RPM:"$RPM $RPM_hex ;

		let COUNTER=COUNTER+1;
	done
}


function run {
    init
    while true; do
        	sleep .2
        	set_broadcast
    done
}

run;
