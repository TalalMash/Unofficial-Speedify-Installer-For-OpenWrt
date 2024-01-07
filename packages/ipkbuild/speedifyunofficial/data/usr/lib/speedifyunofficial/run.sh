#!/bin/sh  /etc/rc.common

. /lib/functions.sh

ACTION="${1:-start}"
PKGS=/tmp/spdpkgs

config_load speedifyunofficial

run_speedify (){
   if [ $(uci get speedifyunofficial.Setup.enabled) == 0 ]; then
        exit 0
   fi

   cd /usr/share/speedify || exit 1
   sh DisableRpFilter.sh
   mkdir -p logs
   nice -n -20 /usr/sbin/capsh --drop=cap_sys_nice --shell=/bin/sh -- -c './speedify -d logs &'
   sleep 2
   ./speedify_cli startupconnect on > /dev/null
   nginx -c /usr/lib/speedifyunofficial/nginx.conf 2>&1 &
}

parse_versions(){
   APT=$(config_get Setup apt)
   APT=$(echo $APT | sed -e 's/\/$//')
   echo Repository URL:$APT
   aptURL="$APT$SPDDIR"
   echo Repository Ubuntu packages URL:$aptURL
   echo Note: Duplicated version is the Speedify UI version.
   curl -o $PKGS $aptURL
   cat $PKGS | grep Version
}

parse_apt_url(){
   APT=$(config_get Setup apt)
   APT=$(echo $APT | sed -e 's/\/$//')
   echo Repository URL:$APT
   aptURL="$APT$SPDDIR"
   echo Repository Ubuntu packages URL:$aptURL
   curl -o $PKGS $aptURL

   DWVER=$(awk '/Version:/{gsub("Version: ", "");print;exit}' $PKGS)
   echo Latest Version:$DWVER

   SPDDW=$(awk '/Filename/{gsub("Filename: ", "");print;exit}' $PKGS)
   export DWURL=$APT/$SPDDW
   echo Speedify package URL:$DWURL

   UIDW=$(sed -n '/speedifyui/{nnnnnnnn;p;q}' $PKGS | awk '/Filename/{gsub("Filename: ", "");print;exit}')
   export UIDWURL=$APT/$UIDW
   echo Speedify UI package URL:$UIDWURL

   if [[ $(config_get Setup verovd) ]]; then
        echo "Version override is set!"
        DWVER=$(config_get Setup verovd)
        echo "Set to $DWVER"
        SPDDW=$(sed -n '/'"$DWVER"'/{nn;p;q}' $PKGS | awk '/Filename/{gsub("Filename: ", "");print;exit}')
        export DWURL=$APT/$SPDDW
        echo Speedify package URL:$DWURL
        UIDW=$(sed -n '/'"$DWVER"'/{nn;p;q}' $PKGS | awk '/Filename/{gsub("Filename: ", "");print;exit}' | sed 's/speedify/speedifyui/g')
        export UIDWURL=$APT/$UIDW
        echo Speedify UI package URL:$UIDWURL
   fi
}

installall(){
   if [ "$(ping -q -c1 google.com &>/dev/null && echo 0 || echo 1)" = "1" ]; then
        echo "Internet connectivity issue. Stopping installation/update"
        run_speedify &
        exit 0
   fi

   echo "Installing GNU C Library"
   echo "Removing cache if it exists at /tmp/spddw"
   rm /tmp/spddw -r
   mkdir /tmp/spddw
   cd /tmp/spddw
   wget -q -c $LIBC6
   ar x *
   tar -xf data.tar.xz -C /
   rm /tmp/spddw/* -r
   wget -q -c $LIBGCC
   ar x *
   tar -xf data.tar.xz -C /
   rm /tmp/spddw/* -r

   echo "Downloading Speedify..."
   wget -q -P /tmp/spddw/speedify/ "$DWURL"
   echo "Downloading Speedify UI..."
   wget -q -P /tmp/spddw/speedifyui/ "$UIDWURL"
   echo "Extracting Speedify..."
   cd /tmp/spddw/speedify/
   ar x *.deb
   tar -xzf data.tar.gz -C /
   mkdir -p /usr/share/speedify/logs
   echo "Extracting Speedify UI..."
   cd /tmp/spddw/speedifyui/
   ar x *.deb
   tar -xzf data.tar.gz -C /
   mkdir /www/spdui/
   ln -sf /usr/share/speedifyui/files/* /www/spdui/
   echo "Deleting installation files..."
   rm -rf /tmp/spddw
   echo "Updating OpenWrt configration and starting Speedify..."
   uci set speedifyunofficial.Setup.version=$DWVER
   uci commit
   chmod 755 /etc/init.d/speedifyunofficial
   /etc/init.d/speedifyunofficial enable
   ifdown speedify
   ifdown speedify6
   uci del network.speedify
   uci del network.speedify6
   uci commit network
   uci del_list firewall.cfg03dc81.network='speedify'
   uci del_list firewall.cfg03dc81.network='speedify6'
   uci add_list firewall.cfg03dc81.network='speedify'
   uci add_list firewall.cfg03dc81.network='speedify6'
   uci set network.speedify=interface
   uci set network.speedify.force_link='0'
   uci set network.speedify.proto='static'
   uci set network.speedify.device='connectify0'
   uci set network.speedify.ipaddr='10.202.0.2'
   uci set network.speedify.netmask='255.255.255.0'
   uci set network.speedify.gateway='10.202.0.1'
   uci add_list network.speedify.dns='10.202.0.1'
   uci add_list firewall.cfg03dc81.network='speedify'
   uci set network.speedify6=interface
   uci set network.speedify6.proto='dhcpv6'
   uci set network.speedify6.device='connectify0'
   uci set network.speedify6.reqaddress='try'
   uci set network.speedify6.reqprefix='auto'
   uci set dhcp.speedify6=dhcp
   uci set dhcp.speedify6.interface='speedify6'
   uci set dhcp.speedify6.ignore='1'
   uci set dhcp.speedify6.ra='relay'
   uci set dhcp.speedify6.dhcpv6='relay'
   uci set dhcp.speedify6.ndp='relay'
   uci set dhcp.speedify6.master='1'
   uci commit network
   uci commit firewall
   uci commit dhcp
   ifup speedify
   ifup speedify6
   echo "Speedify is now installed, user interface is at http://<routerip>/spdui/?wsPort=9331"
}


if [ $(uname -m) = "aarch64" ]; then
  ARCH=arm64
  elif [ $(uname -m) = "x86_64" ]; then
    ARCH=amd64
  else
    ARCH=armhf
fi

SPDDIR="/dists/speedify/main/binary-$ARCH/Packages"
LIBC6="http://ftp.de.debian.org/debian/pool/main/g/glibc/libc6_2.31-13+deb11u5_$ARCH.deb"
LIBGCC="https://deb.debian.org/debian/pool/main/g/gcc-8/libgcc1_8.3.0-6_$ARCH.deb"


if [ "$ACTION" = "update" ]; then
  parse_apt_url
  installall
  killall -KILL speedify
  run_speedify
else
  if [ "$ACTION" = "stopkill" ]; then
    echo "Killing Speedify"
    killall -KILL speedify
    exit 0
  fi
  if [ "$ACTION" = "list-versions" ]; then
    parse_versions
    exit 0
  fi
  echo "Starting Speedify"
  AUPD=$(config_get Setup autoupdate)
  if [ "$AUPD" = 1 ]; then
    echo "Update on boot enabled."
    echo "Checking for updates..."
    parse_apt_url
    CURRVER=$(config_get Setup version | awk -F '|' -v 'OFS=|' '{ gsub(/[^0-9]/,"",$NF); print}')
    DWVER=$(echo $DWVER | awk -F '|' -v 'OFS=|' '{ gsub(/[^0-9]/,"",$NF); print}')
    echo "Current version: $CURRVER"
    echo "Repo version: $DWVER"
    if [ "$DWVER" -gt "$CURRVER" ]; then
        installall
        killall -KILL speedify
        run_speedify
        echo "Update finished, running."
        exit 0
    else
        echo "Up to date, running."
        killall -KILL speedify
        run_speedify
        exit 0
    fi
  else
    killall -KILL speedify
    run_speedify
    echo "Running"
 fi
fi