-- Copyright 2016 David Thornley <david.thornley@touchstargroup.com>
-- Licensed to the public under the Apache License 2.0.
require("luci.sys")

m = Map("mgmtlanip")
m.title = translate("Mgmt LanIP Service")
m.description = translate("Mgmt LanIP Service For OpenWrt")

s = m:section(TypedSection, "service", translate("Base Setting"))
s.anonymous = true

enabled = s:option(Flag, "enabled", translate("Enable"))
enabled.default = 1
enabled.rmempty = false

second = s:option(Value, "second", translate("Cycle Second"))
second.default = 10
second.datatype = "range(3,59)"
second.rmempty = false

interface_name = s:option(Value, "interface_name", translate("Interface Name"))
interface_name.default = 'br-lan'
interface_name.rmempty = true

interface_index = s:option(Value, "interface_index", translate("Interface Index"))
interface_index.default = '0'
interface_index.rmempty = true

ipv4_address = s:option(Value, "ipv4_address", translate("IPv4 Address"))
ipv4_address.default = '192.168.111.254'
ipv4_address.rmempty = true

ipv4_netmask = s:option(Value, "ipv4_netmask", translate("IPv4 Netmask"))
ipv4_netmask.default = '255.255.255.0'
ipv4_netmask.rmempty = true

local e = luci.http.formvalue("cbi.apply")
if e then
	io.popen("/etc/init.d/mgmtlanip restart")
end

return m
