module("luci.controller.checknet", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/checknet") then
		return
	end

	entry({"admin", "network", "checknet"}, cbi("checknet"), _("Double LTE Checknet Service"), 80).dependent = false
end
