module("luci.controller.speedifyunofficial.spdconf", package.seeall)

local fs = require "nixio.fs"
local sys = require "luci.sys"
local template = require "luci.template"
local i18n = require "luci.i18n"


function index()
     local e = entry({"admin", "vpn", "spdconf"}, firstchild(), _("Speedify"), 60)
     e.acl_depends = { "speedifyunofficial" }
     e.dependent = false

     entry({"admin", "vpn", "spdconf", "config"}, cbi("speedifyunofficial/spdconf"), _("Configuration"), 1)
     entry({"admin", "vpn", "spdconf", "logs"}, call("spdconflog"), _("View Log"), 2)
     entry({"admin", "vpn", "spdconf", "options"}, cbi("speedifyunofficial/options"), _("Options"), 4)
end

function spdconflog()
    local logfile = fs.readfile("/tmp/speedifyunofficial.log") or ""
    template.render("speedifyunofficial/file_viewer",
        {title = i18n.translate("Install/Service Script Log"), content = logfile})
end