-- Copyright 2016 David Thornley <david.thornley@touchstargroup.com>
-- Licensed to the public under the Apache License 2.0.
require("luci.sys")

m = Map("checknet")
m.title = translate("Double LTE Checknet Service")
m.description = translate("Double LTE Checknet Service For OpenWrt")

s = m:section(TypedSection, "service", translate("Base Setting"))
s.anonymous = true

enabled = s:option(Flag, "enabled", translate("Enable"))
enabled.default = 0
enabled.rmempty = false

minute = s:option(Value, "minute", translate("Cycle Minute"))
minute.default = 10
minute.datatype = "range(3,59)"
minute.rmempty = false

log_enabled = s:option(Flag, "log_enabled", translate("Log Enable"))
log_enabled.default = 0
log_enabled.rmempty = false

board_name = s:option(Value, "board_name", translate("Board Name"))
board_name.default = 'gl-ar300m16'
board_name.rmempty = true

public_dnsip = s:option(Value, "public_dnsip", translate("Public DNS IP"))
public_dnsip.default = '114.114.114.114'
public_dnsip.rmempty = true

wan_count = s:option(Value, "wan_count", translate("Wan Link Count"))
wan_count.default = 3
wan_count.rmempty = false

wan_zone = s:option(Value, "wan_zone", translate("Wan Firewall Zone Name"))
wan_zone.default = 'wan'
wan_zone.rmempty = true

lte1_zone = s:option(Value, "lte1_zone", translate("LTE1 Firewall Zone Name"))
lte1_zone.default = 'lte1'
lte1_zone.rmempty = true

lte2_zone = s:option(Value, "lte2_zone", translate("LTE2 Firewall Zone Name"))
lte2_zone.default = 'lte2'
lte2_zone.rmempty = true

wan_ifname = s:option(Value, "wan_ifname", translate("Wan Interface Name"))
wan_ifname.default = 'eth1'
wan_ifname.rmempty = true

lte1_ifname = s:option(Value, "lte1_ifname", translate("LTE1 Interface Name"))
lte1_ifname.default = 'wwan0'
lte1_ifname.rmempty = true

lte2_ifname = s:option(Value, "lte2_ifname", translate("LTE2 Interface Name"))
lte2_ifname.default = 'wwan1'
lte2_ifname.rmempty = true

modem_dev1 = s:option(Value, "modem_dev1", translate("LTE1 Modem Device Name"))
modem_dev1.default = 'cdc-wdm0'
modem_dev1.rmempty = true

modem_dev2 = s:option(Value, "modem_dev2", translate("LTE2 Modem Device Name"))
modem_dev2.default = 'cdc-wdm1'
modem_dev2.rmempty = true

modem_dial = s:option(Value, "modem_dial", translate("LTE Modem Dial Tool"))
modem_dial:value("quectel-CM", "quectel-CM")
modem_dial.default = 'quectel-CM'
modem_dial.rmempty = true

dial_apn_cmnet = s:option(Value, "dial_apn_cmnet", translate("China Mobile Dial APN"))
dial_apn_cmnet:value("", translate("-- Please choose --"))
dial_apn_cmnet:value("cmnet", "cmnet")
dial_apn_cmnet:value("cmiot", "cmiot")
dial_apn_cmnet:value("cmiotnbdtdz.zj", "cmiotnbdtdz.zj")
dial_apn_cmnet.default = 'cmiotnbdtdz.zj'
dial_apn_cmnet.rmempty = true

dial_apn_cmtds = s:option(Value, "dial_apn_cmtds", translate("China Unicom Dial APN"))
dial_apn_cmtds:value("", translate("-- Please choose --"))
dial_apn_cmtds:value("3gnet ", "3gnet")
dial_apn_cmtds:value("cmtds", "cmtds")
dial_apn_cmtds:value("zjcyhlw01s.njiot", "zjcyhlw01s.njiot")
dial_apn_cmtds.default = 'zjcyhlw01s.njiot'
dial_apn_cmtds.rmempty = true

dial_apn_ctlte = s:option(Value, "dial_apn_ctlte", translate("China Telecom Dial APN"))
dial_apn_ctlte:value("", translate("-- Please choose --"))
dial_apn_ctlte:value("ctlte", "ctlte")
dial_apn_ctlte:value("ctnet", "ctnet")
dial_apn_ctlte:value("public.vpdn", "public.vpdn")
dial_apn_ctlte.default = 'public.vpdn'
dial_apn_ctlte.rmempty = true

ttyusb_count = s:option(Value, "ttyusb_count", translate("ttyUSB Device Count"))
ttyusb_count.default = 9
ttyusb_count.rmempty = true

ttyusb_com = s:option(Value, "ttyusb_com", translate("Uart COM ttyUSB Device"))
ttyusb_com.default = 'ttyUSB0'
ttyusb_com.rmempty = true

ttyusb_at1 = s:option(Value, "ttyusb_at1", translate("LTE1 AT ttyUSB Device"))
ttyusb_at1.default = 'ttyUSB3'
ttyusb_at1.rmempty = true

ttyusb_at2 = s:option(Value, "ttyusb_at2", translate("LTE2 AT ttyUSB Device"))
ttyusb_at2.default = 'ttyUSB7'
ttyusb_at2.rmempty = true

local e = luci.http.formvalue("cbi.apply")
if e then
	io.popen("/etc/init.d/checknet restart")
end

return m
