config = Map("speedifyunofficial")

view = config:section(NamedSection,"Setup", "config",  translate("Speedify Configuration"), translate("Check the log tab for installation progress."))
enabled = view:option(Flag, "enabled", "Enable", "Enables Speedify on device startup."); view.optional=false; view.rmempty = false;
apt = view:option(Value, "apt", "Debian Repository URL:", "Default address last tested on Q1 2024."); view.optional=false; view.rmempty = false;
auto = view:option(Flag, "autoupdate", "Update on boot:", "Update Speedify before starting."); view.optional=false; view.rmempty = false;
upd = view:option(Button, "_update", "Trigger Install/Update", "Install Speedify or update and restart.")
rst = view:option(Button, "_reset", "Trigger Reset", "Reset and restart Speedify.")
genlog = view:option(Button, "_genlog", "Download Logs & Config", "Downloads Speedify log files and OpenWRT configuration/log files.")

function upd.write()
  luci.sys.call("echo 'Log Reset & Speedify Update/Install' > /tmp/speedifyunofficialig.log && sh /usr/lib/speedifyunofficial/run.sh update >> /tmp/speedifyunofficialig.log &")
  luci.http.redirect("/cgi-bin/luci/admin/vpn/spdconf/logs")
end

function rst.write()
  luci.sys.call("echo 'Log & Speedify Reset' > /tmp/speedifyunofficialig.log && killall -KILL speedify && rm -rf /usr/share/speedify/logs/* && sh /usr/lib/speedifyunofficial/run.sh >> /tmp/speedifyunofficialig.log &")
  luci.http.redirect("/cgi-bin/luci/admin/vpn/spdconf/logs")
end

function genlog.write()
  luci.sys.call("logread -F /tmp/logreadfile")
  luci.sys.call("dmesg >> /tmp/kmsgfile")
  luci.sys.call("tar -czf /tmp/spdlogs.tar.gz /usr/share/speedify/logs/* /etc/config/* /tmp/logreadfile /tmp/kmsgfile")
  luci.sys.call("ln -s /tmp/spdlogs.tar.gz /www/spdlogs.tar.gz")
  luci.http.redirect("/spdlogs.tar.gz")
end

function config.on_commit(self)
    luci.sys.exec("sh -c 'sleep 2 && /etc/init.d/speedifyunofficial restart' &")
end

return config