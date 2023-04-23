#!/bin/sh
#filename: getmwan.sh

### 

get_lte_rssi()
{
	local zone rssi_lev lte_asu lte_index lte_at
	zone=$1
	rssi_lev=-113
	lte_asu=0
	[ -z "$zone" ] && echo $rssi_lev && return 1
	lte_index="${zone#*lte}"
	lte_at="$( uci get checknet.@service[0].ttyusb_at${lte_index} )"
	[ -z "$lte_index" -o -z "$lte_at" ] && echo $rssi_lev && return 1
	[ ! -c "/dev/${lte_at}" ] && echo $rssi_lev && return 1

	lte_asu=$(comgt -d /dev/${lte_at} sig 2>/dev/null | grep "Signal Quality: " | sed "s/Signal Quality: //" | awk -F '\,' '{print $1}')
	[ -z "$lte_asu" ] && lte_asu=0
	if [ $lte_asu -ge 99 ]; then
		rssi_lev=-113
	elif [ $lte_asu -le 0 ]; then
		rssi_lev=-113
	else
		rssi_lev=$(( -113 + lte_asu * 2 ))
	fi
	echo $rssi_lev
	return 0
}

get_mwan_info()
{
	local zone 
	local network_ifname mwan_ifname
	local zone_name zone_ifname zone_ping_ip
	local online_field active_field 
	local is_online is_active is_pingip rssi_lev 
	echo "$( mwan3 interfaces )" | while read line; do
		zone=""
		network_ifname=""
		mwan_ifname=""
		zone_name=""
		zone_ifname=""
		mwan_ifname=""
		online_field=""
		active_field=""
		is_online=0
		is_active=0
		is_pingip=0
		rssi_lev=0

		[ -z "$line" ] && continue
		[ $( echo $line | wc -w ) -ne 8 ] && continue
		zone="$( echo "$line" | cut -f 2 -d " " )"
		[ -z "$zone" -o ${#zone} -lt 3 ] && continue

		network_ifname="$( uci get network.${zone} 2>/dev/null )"
		[ -z "$network_ifname" -o "$network_ifname" != "interface" ] && continue
		mwan_ifname="$( uci get mwan3.${zone} 2>/dev/null )"
		[ -z "$mwan_ifname" -o "$mwan_ifname" != "interface" ] && continue
		zone_name="$( uci get checknet.@service[0].${zone}_zone 2>/dev/null )"
		zone_ifname="$( uci get checknet.@service[0].${zone}_ifname 2>/dev/null )"
		zone_ping_ip="$( uci get checknet.@service[0].${zone}_ping_ip 2>/dev/null )"
		[ -z "$zone_name" -o -z "$zone_ifname" -o -z "$zone_ping_ip" ] && continue

		online_field="$( echo "$line" | cut -f 4 -d " " )"
		[ "$online_field" == "online" ] && is_online=1
		active_field="$( echo "$line" | cut -f 8 -d " " )"
		[ "$active_field" == "active" ] && is_active=1
		[ $( ping -4 -I $zone_ifname -c 1 -W 2 -s 56 -t 60 -q $zone_ping_ip 2>/dev/null | grep -i ", 0% packet loss" | wc -l ) -ne 0 ] && is_pingip=1 
		case "$zone_ifname" in
				"eth"*)
					rssi_lev=0
					;;
				"wwan"*)
					rssi_lev=$( get_lte_rssi $zone )
					;;
				*)
					rssi_lev=-113
					;;
		esac
		echo "zone=${zone}, is_online=${is_online}, is_active=${is_active}, is_pingip=${is_pingip}, rssi_lev=${rssi_lev}"
	done
}

### ( Main )
# TODO: 
#   * 
#

get_mwan_info

exit 0

### ( End )

