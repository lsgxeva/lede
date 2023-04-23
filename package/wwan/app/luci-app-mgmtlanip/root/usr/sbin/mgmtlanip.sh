#!/bin/sh
#filename: mgmtlanip.sh

VERSION="v1.0.5-20220315"

logg()
{
	echo "$*" | logger -s -p user.debug
}

logg_notice()
{
	echo "$*" | logger -s -p user.notice
}

### 

# Global Variable Definition 
ENABLED=0
SECOND=10
INTERFACE_NAME='br-lan'
INTERFACE_INDEX='0'
IPV4_ADDRESS='192.168.111.254'
IPV4_NETMASK='255.255.255.0'


create_mgmtlanip_config()
{
	touch /etc/config/mgmtlanip
	cat /dev/null > /etc/config/mgmtlanip
	uci -q batch <<-EOF >/dev/null
		delete mgmtlanip.@service[0]
		add mgmtlanip service
		set mgmtlanip.@service[-1].enabled='1'
		set mgmtlanip.@service[-1].second='10'
		set mgmtlanip.@service[-1].interface_name='br-lan'
		set mgmtlanip.@service[-1].interface_index='0'
		set mgmtlanip.@service[-1].ipv4_address='192.168.111.254'
		set mgmtlanip.@service[-1].ipv4_netmask='255.255.255.0'
		commit mgmtlanip
	EOF
}

get_mgmtlanip_config()
{
	ENABLED=$( uci get mgmtlanip.@service[-1].enabled )
	SECOND=$( uci get mgmtlanip.@service[-1].second )
	INTERFACE_NAME="$( uci get mgmtlanip.@service[-1].interface_name )"
	INTERFACE_INDEX="$( uci get mgmtlanip.@service[-1].interface_index )"
	IPV4_ADDRESS="$( uci get mgmtlanip.@service[-1].ipv4_address )"
	IPV4_NETMASK="$( uci get mgmtlanip.@service[-1].ipv4_netmask )"
}

###

_fix_mgmtlanip()
{
	local lan_ifname lan_ifidx lan_ipad lan_netm lan_mask is_lan
	[ $# -ne 4 ] && return 0
	lan_ifname="$1"
	lan_ifidx="$2"
	lan_ipad="$3"
	lan_netm="$4"
	lan_mask="$( /bin/ipcalc.sh $lan_ipad $lan_netm | grep PREFIX | awk -F = '{print $2}' )"
	is_lan=0
	for ifname in "$( ip addr show | grep inet | grep -v inet6 | grep ${lan_ipad}/${lan_mask} | awk '{print $NF, $2}' | awk '{print $1}' )"
	do
		if [ "$ifname" = "${lan_ifname}:${lan_ifidx}" ]; then
			is_lan=1
		else
			[ ! -z "$ifname" ] && ip addr del ${lan_ipad}/${lan_mask} dev ${ifname} && 
				logg "* _fix_mgmtlanip - ip addr del ${lan_ipad}/${lan_mask} dev ${ifname} "
		fi
	done
	if [ $is_lan -ne 1 ]; then
		[ ! -z "$lan_ifname" ] && ip addr add ${lan_ipad}/${lan_mask} dev ${lan_ifname} label ${lan_ifname}:${lan_ifidx} && 
			logg "* _fix_mgmtlanip - ip addr add ${lan_ipad}/${lan_mask} dev ${lan_ifname} label ${lan_ifname}:${lan_ifidx} "
	fi
	return 0
}


### ( Main )
# TODO: 
#   * 
#

mgmtlanip_main()
{
	[ -f "/etc/config/mgmtlanip" ] || create_mgmtlanip_config 
	[ -f "/etc/config/mgmtlanip" ] && get_mgmtlanip_config 
	[ ${ENABLED} -ne 1 ] && logg_notice "* mgmtlanip - service disable, will be exit. " && return 0

	[ $( ubus call network.device status "{\"name\":\"$INTERFACE_NAME\"}" | jsonfilter -q -e '@.up' ) == "true" ] &&
		_fix_mgmtlanip "$INTERFACE_NAME" "$INTERFACE_INDEX" "$IPV4_ADDRESS" "$IPV4_NETMASK" 

	return 0
}


SECOND=10
[ $# -eq 1 ] && SECOND=$1
while true
do
	mgmtlanip_main
	sleep $SECOND
done

exit 0

### ( End )

