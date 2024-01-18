config = Map("speedifyunofficial")

view = config:section(NamedSection,"Setup", "config",  translate("Configuration Extras"), translate("Check the log tab for action results."))
verovd = view:option(Value, "verovd", "Version override:", "Format example: 12.8.0-10744<br>Empty to use the latest version.<br>Re-install Speedify in the configuration tab after applying.");   view.optional=false; view.rmempty = false;
dmpver = view:option(Button, "_dmpver", "List versions", "Lists previously available versions in the log tab.")
restart = view:option(Button, "_restart", "Restart Speedify", "Force restart Speedify.")
stop = view:option(Button, "_stop", "Halt Speedify", "Force stop Speedify.")
uninstall = view:option(Button, "_remove", "Uninstall Speedify", "Remove all files.")

function dmpver.write()
  luci.sys.call("echo 'Log Reset' > /tmp/speedifyunofficial.log")
  luci.sys.call("sh /usr/lib/speedifyunofficial/run.sh list-versions >> /tmp/speedifyunofficial.log")
  luci.http.redirect("/cgi-bin/luci/admin/vpn/spdconf/logs")
end

function restart.write()
  luci.sys.call("/etc/init.d/speedifyunofficial restart &")
  luci.sys.call("echo 'Done Restart' > /tmp/speedifyunofficial.log")
end

function stop.write()
  luci.sys.call("/etc/init.d/speedifyunofficial stop &")
  luci.sys.call("echo 'Done Stop' > /tmp/speedifyunofficial.log")
end

function uninstall.write()
 luci.sys.call("/etc/init.d/speedifyunofficial stop")
 luci.sys.call("rm -rf /usr/share/speedify/* /usr/share/speedifyui/* /www/spdui/*")
 luci.sys.call("echo 'Speedify was manually uninstalled...' > tee /tmp/speedifyunofficial.log")
 luci.http.redirect("/cgi-bin/luci/admin/vpn/spdconf/logs")
end

return config