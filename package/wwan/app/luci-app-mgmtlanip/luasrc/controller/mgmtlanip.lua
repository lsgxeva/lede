module("luci.controller.mgmtlanip", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/mgmtlanip") then
		return
	end

	entry({"admin", "network", "mgmtlanip"}, cbi("mgmtlanip"), _("Mgmt LanIP Service"), 80).dependent = false
end
