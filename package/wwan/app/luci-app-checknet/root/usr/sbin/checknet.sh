#!/bin/sh
#filename: checknet.sh

VERSION="v1.0.5-20220315"

#LOGG_STYLE="tty"
#LOGG_STYLE="file"
LOGG_STYLE="logger"
#LOGG_STYLE="tty+logger"
# RemoteLog=`uci get system.@system[0].remote_log_ip`
# if [ "$RemoteLog" != "0.0.0.0" ];then
	# LOGG_STYLE="file+logger"
# fi

LOGFILE_PATH="/tmp"
LOGFILE_NAME="checknet_log"
LOG_ENABLED=1

logg()
{
	[ $LOG_ENABLED -ne 1 ] && return 0
	if [ "$LOGG_STYLE" == "file" ];then
		echo "$*" >> ${LOGFILE_PATH}/${LOGFILE_NAME}
	elif [ "$LOGG_STYLE" == "logger" ];then
		echo "$*" | logger -s -p user.debug
	elif [ "$LOGG_STYLE" == "tty+logger" ];then
		echo "$*" > /dev/ttyS1
		echo "$*" | logger -s -p user.debug
	elif [ "$LOGG_STYLE" == "file+logger" ];then
		echo "$*" >> ${LOGFILE_PATH}/${LOGFILE_NAME}
		echo "$*" | logger -s -p user.debug
	else
		echo "$*" > /dev/ttyS1
	fi
	return 0
}

logg_notice()
{
	[ $LOG_ENABLED -ne 1 ] && return 0
	if [ "$LOGG_STYLE" == "file" ];then
		echo "$*" >> ${LOGFILE_PATH}/${LOGFILE_NAME}
	elif [ "$LOGG_STYLE" == "logger" ];then
		echo "$*" | logger -s -p user.notice
	elif [ "$LOGG_STYLE" == "tty+logger" ];then
		echo "$*" > /dev/ttyS1
		echo "$*" | logger -s -p user.notice
	elif [ "$LOGG_STYLE" == "file+logger" ];then
		echo "$*" >> ${LOGFILE_PATH}/${LOGFILE_NAME}
		echo "$*" | logger -s -p user.notice
	else
		echo "$*" > /dev/ttyS1
	fi
	return 0
}

### 

# Global Variable Definition 
ENABLED=0
MINUTE=1
LOG_ENABLED=0
BOARD_NAME="gl-ar300m16"
WAN_ZONE='wan'
LTE1_ZONE='lte1'
LTE2_ZONE='lte2'
WAN_IFNAME='eth1'
LTE1_IFNAME='wwan0'
LTE2_IFNAME='wwan1'
WAN_PING_IP='10.0.0.1'
LTE1_PING_IP='100.64.0.1'
LTE2_PING_IP='100.64.0.1'
MODEM_DEV1='cdc-wdm0'
MODEM_DEV2='cdc-wdm1'
MODEM_DIAL='quectel-CM'
DIAL_APN_CMNET='cmiotnbdtdz.zj'
DIAL_APN_CMTDS='zjcyhlw01s.njiot'
DIAL_APN_CTLTE='public.vpdn'
TTYUSB_COM='ttyUSB0'
TTYUSB_AT1='ttyUSB3'
TTYUSB_AT2='ttyUSB7'


create_checknet_config()
{
	touch /etc/config/checknet
	cat /dev/null > /etc/config/checknet
	uci -q batch <<-EOF >/dev/null
		delete checknet.@service[0]
		add checknet service
		set checknet.@service[-1].enabled='1'
		set checknet.@service[-1].minute='1'
		set checknet.@service[-1].log_enabled='0'
		set checknet.@service[-1].board_name='gl-ar300m16'
		set checknet.@service[-1].wan_zone='wan'
		set checknet.@service[-1].lte1_zone='lte1'
		set checknet.@service[-1].lte2_zone='lte2'
		set checknet.@service[-1].wan_ifname='eth1'
		set checknet.@service[-1].lte1_ifname='wwan0'
		set checknet.@service[-1].lte2_ifname='wwan1'
		set checknet.@service[-1].wan_ping_ip='10.0.0.1'
		set checknet.@service[-1].lte1_ping_ip='100.64.0.1'
		set checknet.@service[-1].lte2_ping_ip='100.64.0.1'
		set checknet.@service[-1].modem_dev1='cdc-wdm0'
		set checknet.@service[-1].modem_dev2='cdc-wdm1'
		set checknet.@service[-1].modem_dial='quectel-CM'
		set checknet.@service[-1].dial_apn_cmnet='cmiotnbdtdz.zj'
		set checknet.@service[-1].dial_apn_cmtds='zjcyhlw01s.njiot'
		set checknet.@service[-1].dial_apn_ctlte='public.vpdn'
		set checknet.@service[-1].ttyusb_com='ttyUSB0'
		set checknet.@service[-1].ttyusb_at1='ttyUSB3'
		set checknet.@service[-1].ttyusb_at2='ttyUSB7'
		commit checknet
	EOF
}

get_checknet_config()
{
	ENABLED=$( uci get checknet.@service[-1].enabled )
	MINUTE=$( uci get checknet.@service[-1].minute )
	LOG_ENABLED=$( uci get checknet.@service[-1].log_enabled )
	BOARD_NAME="$( uci get checknet.@service[-1].board_name )"
	WAN_ZONE="$( uci get checknet.@service[-1].wan_zone )"
	LTE1_ZONE="$( uci get checknet.@service[-1].lte1_zone )"
	LTE2_ZONE="$( uci get checknet.@service[-1].lte2_zone )"
	WAN_IFNAME="$( uci get checknet.@service[-1].wan_ifname )"
	LTE1_IFNAME="$( uci get checknet.@service[-1].lte1_ifname )"
	LTE2_IFNAME="$( uci get checknet.@service[-1].lte2_ifname )"
	WAN_PING_IP="$( uci get checknet.@service[-1].wan_ping_ip )"
	LTE1_PING_IP="$( uci get checknet.@service[-1].lte1_ping_ip )"
	LTE2_PING_IP="$( uci get checknet.@service[-1].lte2_ping_ip )"
	MODEM_DEV1="$( uci get checknet.@service[-1].modem_dev1 )"
	MODEM_DEV2="$( uci get checknet.@service[-1].modem_dev2 )"
	MODEM_DIAL="$( uci get checknet.@service[-1].modem_dial )"
	DIAL_APN_CMNET="$( uci get checknet.@service[-1].dial_apn_cmnet )"
	DIAL_APN_CMTDS="$( uci get checknet.@service[-1].dial_apn_cmtds )"
	DIAL_APN_CTLTE="$( uci get checknet.@service[-1].dial_apn_ctlte )"
	TTYUSB_COM="$( uci get checknet.@service[-1].ttyusb_com )"
	TTYUSB_AT1="$( uci get checknet.@service[-1].ttyusb_at1 )"
	TTYUSB_AT2="$( uci get checknet.@service[-1].ttyusb_at2 )"
}


###

zone_to_pingip()
{
	local zone
	if [ $# -ne 1 ]; then
		echo ""
		return 1
	fi
	zone=$1
	# Note: Only supports gl-ar300m16 with three WANs
	# wan => WAN_PING_IP
	# lte1 => LTE1_PING_IP
	# lte2 => LTE2_PING_IP
	[ "$( cat /tmp/sysinfo/board_name )" != "${BOARD_NAME}" ] && echo "" && return 1
	case "$zone" in  
		"$WAN_ZONE") 
			echo "$WAN_PING_IP"
			return 0
			;;
		"$LTE1_ZONE") 
			echo "$LTE1_PING_IP"
			return 0
			;;
		"$LTE2_ZONE") 
			echo "$LTE2_PING_IP"
			return 0
			;;
		*) 
			echo ""
			return 1
			;;
	esac
}

check_net_status()
{
	local zone phy ifip gateway pingip count
	if [ $# -ne 1 ]; then
		return 0
	fi
	zone=$1
	[ "$( ifstatus $zone | jsonfilter -q -e '@.up' )" != "true" ] && 
		logg "* check_net_status - $zone not up, please execute ubus interface $zone up" && return 1
	phy="$( ifstatus $zone | jsonfilter -q -e '@.l3_device' )"
	[ -z "$phy" ] && return 0
	ifip="$( ifstatus $zone | jsonfilter -q -e '@["ipv4-address"][0].address' )"
	gateway="$( ifstatus $zone | jsonfilter -q -e '@["route"][0].nexthop' )"
	pingip="$( zone_to_pingip $zone )"
	[ -z "$pingip" ] && return 0
	logg "* check_net_status - zone:${zone}, phy:${phy}, IP:${ifip}, GW:${gateway}, PINGIP:${pingip} "
	count=$( ping -4 -I $phy -c 1 -W 2 -s 56 -t 60 -q $pingip  2>/dev/null | grep -i ", 0% packet loss" | wc -l )
	if [ $count -ne 0 ]; then
		logg "* check_net_status - ping check to $pingip is OK"
		return 0
	else
		logg "* check_net_status - ping check to $pingip is NG"
		return 1
	fi
}

exec_ifup_zone()
{
	local zone
	if [ $# -ne 1 ]; then
		return 1
	fi
	zone=$1
	[ -z $zone ] && logg " exec_ifup_zone - interface $zone is null" && return 1
	if [ "$( uci get network.${zone} 2>/dev/null )" == "interface" ]; then
		logg "* exec_ifup_zone - interface $zone have exist, will ifup $zone"
		env -i ubus call network.interface.$zone up >/dev/null 2>&1 && logg "* exec_ifup_zone - ubus interface $zone up"
		sleep 3
		env -i /sbin/ifup $zone >/dev/null 2>&1 && logg "* exec_ifup_zone - ifup interface $zone up"
		sleep 3
	else
		logg "* exec_ifup_zone - interface $zone is not exist, will no ifup"
	fi
	return 0
}

fix_net_link()
{
	local zone retval
	if [ $# -ne 1 ]; then
		return 0
	fi
	zone=$1
	check_net_status $zone
	retval=$?
	if [ $retval -ne 0 ]; then
		logg "* fix_net_link - $zone network NG, will ifup $zone"
		exec_ifup_zone $zone 
	else
		logg "* fix_net_link - $zone network OK, will no ifup"
	fi
	return 0
}

sim_to_apn()
{
	local lte_at defaultapn
	if [ $# -ne 1 ]; then
		echo ""
		return 1
	fi
	lte_at=$1
	[ -c /dev/${lte_at} ] || return 1
	# Note: Only supports gl-ar300m16 with three WANs
	# cmnet => cmiotnbdtdz.zj
	# cmtds => zjcyhlw01s.njiot
	# ctlte => public.vpdn
	[ "$(cat /tmp/sysinfo/board_name | awk -F '\,' '{print $2}')" != "$BOARD_NAME" ] && echo "" && return 1
	defaultapn="$( comgt -d /dev/$lte_at -s /etc/gcom/defaultapn.gcom 2>/dev/null )"
	case "$defaultapn" in  
		"cmnet"|"CMNET") 
			echo "$DIAL_APN_CMNET"
			return 0
			;;
		"cmtds"|"CMTDS") 
			echo "$DIAL_APN_CMTDS"
			return 0
			;;
		"ctlte"|"CTLTE") 
			echo "$DIAL_APN_CTLTE"
			return 0
			;;
		*) 
			echo ""
			return 1
			;;
	esac
}

dev_to_at()
{
	local lte_dev
	if [ $# -ne 1 ]; then
		echo ""
		return 1
	fi
	lte_dev=$1
	[ -c /dev/${lte_dev} ] || return 1
	# Note: Only supports gl-ar300m16 with three WANs
	# cdc-wdm0 => ttyUSB3
	# cdc-wdm1 => ttyUSB7
	[ "$(cat /tmp/sysinfo/board_name | awk -F '\,' '{print $2}')" != "$BOARD_NAME" ] && echo "" && return 1
	case "$lte_dev" in  
		"$MODEM_DEV1") 
			echo "$TTYUSB_AT1"
			return 0
			;;
		"$MODEM_DEV2") 
			echo "$TTYUSB_AT2"
			return 0
			;;
		*) 
			echo ""
			return 1
			;;
	esac
}

zone_to_phy()
{
	local zone
	if [ $# -ne 1 ]; then
		echo ""
		return 1
	fi
	zone=$1
	# Note: Only supports gl-ar300m16 with three WANs
	# wan => eth1
	# lte1 => wwan0
	# lte2 => wwan1
	[ "$(cat /tmp/sysinfo/board_name | awk -F '\,' '{print $2}')" != "$BOARD_NAME" ] && echo "" && return 1
	case "$zone" in  
		"$WAN_ZONE") 
			echo "$WAN_IFNAME"
			return 0
			;;
		"$LTE1_ZONE") 
			echo "$LTE1_IFNAME"
			return 0
			;;
		"$LTE2_ZONE") 
			echo "$LTE2_IFNAME"
			return 0
			;;
		*) 
			echo ""
			return 1
			;;
	esac
}

phy_to_zone()
{
	local phy
	if [ $# -ne 1 ]; then
		echo ""
		return 1
	fi
	phy=$1
	# Note: Only supports gl-ar300m16 with three WANs
	# eth1 => wan
	# wwan0 => lte1
	# wwan1 => lte2
	[ "$(cat /tmp/sysinfo/board_name | awk -F '\,' '{print $2}')" != "$BOARD_NAME" ] && echo "" && return 1
	case "$phy" in  
		"$WAN_IFNAME") 
			echo "$WAN_ZONE"
			return 0
			;;
		"$LTE1_IFNAME") 
			echo "$LTE1_ZONE"
			return 0
			;;
		"$LTE2_IFNAME") 
			echo "$LTE2_ZONE"
			return 0
			;;
		*) 
			echo ""
			return 1
			;;
	esac
}

fix_modem_dial()
{
	local lte_dev lte_at dial_apn dial_tool dev_path dev_ifname proc_count zone ifip gateway 
	if [ $# -ne 1 ]; then
		return 1
	fi
	lte_dev=$1
	[ -c /dev/${lte_dev} ] || return 1
	lte_at="$( dev_to_at $lte_dev )"
	[ $? -ne 0 ] && logg "* fix_modem_dial - dev_to_at return err" && return 1
	dial_apn="$( sim_to_apn $lte_at )"
	[ $? -ne 0 ] && logg "* fix_modem_dial - sim_to_apn return err" && return 1
	dev_path="$(readlink -f /sys/class/usbmisc/$lte_dev/device/)"
	dev_ifname="$( ls "$dev_path"/net )"
	zone="$( phy_to_zone $dev_ifname )"
	dial_tool="$MODEM_DIAL"
	logg "* fix_modem_dial - lte_dev:${lte_dev}, lte_at:${lte_at}, dial_apn:${dial_apn}, dev_ifname:${dev_ifname}"
	proc_count="$( ps | grep -i "${dial_tool} -i ${dev_ifname}" | grep -v grep | wc -l )"
	if [ $proc_count -eq 0 ]; then
		logg "* fix_modem_dial - proc must be fixed, will start dial proc"
		${dial_tool} -i ${dev_ifname} -s ${dial_apn} >/dev/null 2>/dev/null & 
		sleep 1
	elif [ $proc_count -eq 1 ]; then
		ifip="$( ifstatus $zone | jsonfilter -q -e '@["ipv4-address"][0].address' )"
		gateway="$( ifstatus $zone | jsonfilter -q -e '@["route"][0].nexthop' )"
		if [ -z $ifip -a -z $gateway ]; then
			logg "* fix_modem_dial - proc get ip is null, will restart dial proc"
			ps | grep -i "${dial_tool} -i ${dev_ifname}" | grep -v grep  | awk '{print $1}' | xargs kill -s 9 2>/dev/null
			sleep 1
			${dial_tool} -i ${dev_ifname} -s ${dial_apn} >/dev/null 2>/dev/null & 
			sleep 1
		fi
		logg "* fix_modem_dial - proc no need fixed, please show dial proc status "
	else
		logg "* fix_modem_dial - proc running exception, will restart dial proc "
		ps | grep -i "${dial_tool} -i ${dev_ifname}" | grep -v grep  | awk '{print $1}' | xargs kill -s 9 2>/dev/null
		sleep 1
		${dial_tool} -i ${dev_ifname} -s ${dial_apn} >/dev/null 2>/dev/null & 
		sleep 1
	fi
	return 0
}

fix_double_dial()
{
	local lte1_dev lte2_dev
	if [ $# -ne 2 ]; then
		return 1
	fi
	lte1_dev=$1
	lte2_dev=$2
	[ -c /dev/${lte1_dev} ] && fix_modem_dial $lte1_dev
	[ -c /dev/${lte2_dev} ] && fix_modem_dial $lte2_dev
	return 0
}

check_mwan3_status()
{
	local zone
	if [ $# -ne 1 ]; then
		return 0
	fi
	zone=$1
	if [ "$( mwan3 interfaces | grep ${zone} | awk '{print $8}' )" != "active" ]; then
		logg "* check_mwan3_status - $zone not up, please execute mwan3 ifup $zone"
		return 1
	elif [ "$( mwan3 interfaces | grep ${zone} | awk '{print $4}' )" != "online" ]; then
		logg "* check_mwan3_status - $zone not online"
		return 1
	else
		logg "* check_mwan3_status - $zone is online"
		return 0
	fi
}

fix_zone_route()
{
	local zone phy gwcnt
	if [ $# -ne 1 ]; then
		return 1
	fi
	zone=$1
	phy="$( zone_to_phy ${zone} )"
	[ -z "$phy" ] && logg " fix_zone_route - $zone interface is not exist" && return 1
	gwcnt=$( route -n | grep "0.0.0.0.*0.0.0.0" | awk '{print $8}' | grep ${phy} | wc -l )
	if [ $gwcnt -eq 0 ]; then
		logg "* fix_zone_route - default gateway $phy count is 0, will ifup $zone"
		exec_ifup_zone $zone 
	elif [ $gwcnt -eq 1 ]; then
		logg "* fix_zone_route - default gateway $phy count is 1, no need fixed"
	else
		logg "* fix_zone_route - default gateway $phy count is error, will ifup $zone"
		exec_ifup_zone $zone 
	fi
}

get_signal_strength()
{
	local lte_at lte_asu lte_rssi
	if [ $# -ne 1 ]; then
		return 1
	fi
	lte_at=$1
	[ ! -c "/dev/${lte_at}" ] && return 1
	lte_asu=$(comgt -d /dev/${lte_at} sig 2>/dev/null | grep "Signal Quality: " | sed "s/Signal Quality: //" | awk -F '\,' '{print $1}')
	[ -z "$lte_asu" ] && lte_asu=0
	if [ $lte_asu -ge 99 ]; then
		lte_rssi=-113
	elif [ $lte_asu -le 0 ]; then
		lte_rssi=-113
	else
		lte_rssi=$(( -113 + lte_asu * 2 ))
	fi
	logg "* get_signal_strength - lte_at=${lte_at}, lte_asu=${lte_asu}, lte_rssi=${lte_rssi}dBm "
	return 0
}


### ( Main )
# TODO: 
#   * 
#

checknet_main()
{
	[ -f "/etc/config/checknet" ] || create_checknet_config 
	[ -f "/etc/config/checknet" ] && get_checknet_config 
	[ ${ENABLED} -ne 1 ] && logg_notice "* checknet - service disable, will be exit. " && return 0

	CURTIME="$( date +'%Y-%m-%dT%H:%M:%S%Z' )"
	logg "* checknet - $VERSION ===> StartTime: $CURTIME"

	[ -f "/etc/init.d/igmpproxy" ] && 
		/etc/init.d/igmpproxy stop >/dev/null 2>&1 && 
		logg_notice "* checknet - stop igmpproxy service"

	[ -c /dev/${TTYUSB_AT1} ] && get_signal_strength $TTYUSB_AT1 
	[ -c /dev/${TTYUSB_AT2} ] && get_signal_strength $TTYUSB_AT2 

	[ "$( uci get mwan3.${WAN_ZONE} 2>/dev/null )" == "interface" ] && check_mwan3_status $WAN_ZONE
	[ "$( uci get mwan3.${LTE1_ZONE} 2>/dev/null )" == "interface" ] && check_mwan3_status $LTE1_ZONE
	[ "$( uci get mwan3.${LTE2_ZONE} 2>/dev/null )" == "interface" ] && check_mwan3_status $LTE2_ZONE

	[ -c /dev/${MODEM_DEV1} ] && fix_modem_dial $MODEM_DEV1
	[ -c /dev/${MODEM_DEV2} ] && fix_modem_dial $MODEM_DEV2

	[ "$( uci get network.${WAN_ZONE} 2>/dev/null )" == "interface" ] &&  fix_net_link $WAN_ZONE
	[ "$( uci get network.${LTE1_ZONE} 2>/dev/null )" == "interface" ] &&  fix_net_link $LTE1_ZONE
	[ "$( uci get network.${LTE2_ZONE} 2>/dev/null )" == "interface" ] &&  fix_net_link $LTE2_ZONE

	[ "$( uci get network.${WAN_ZONE} 2>/dev/null )" == "interface" ] && fix_zone_route $WAN_ZONE 
	[ "$( uci get network.${LTE1_ZONE} 2>/dev/null )" == "interface" ] && fix_zone_route $LTE1_ZONE 
	[ "$( uci get network.${LTE2_ZONE} 2>/dev/null )" == "interface" ] && fix_zone_route $LTE2_ZONE 

	CURTIME="$( date +'%Y-%m-%dT%H:%M:%S%Z' )"
	logg "* checknet - $VERSION <=== EndTime: $CURTIME"

	return 0
}


MINUTE=1
[ $# -eq 1 ] && MINUTE=$1
while true
do
	checknet_main
	sleep $(( MINUTE * 60 ))
done

exit 0

### ( End )

