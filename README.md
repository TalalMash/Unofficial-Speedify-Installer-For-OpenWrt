# Unofficial Speedify Installer for OpenWrt (experimental)

**Update: [Speedify now officially supports OpenWrt as of Q4 2024](https://support.speedify.com/article/918-openwrt)**

## Minimum Requirements

- 64 bit Intel/AMD or 64-bit ARM or 32-bit ARM hard float
- 512MB RAM
- 64MB storage
- OpenWrt 18 and higher
- Working packages and kernel module repsositories
- Internet connection
- Familiarity with OpenWrt, else checkout [SmoothWAN](https://smoothwan.com)

## Tested devices

*Officially verified:*
- Official OpenWrt PC (23.05.2)
- GL.iNet Slate AX & Flint 4.4.6 official firmware
  
*User reports:*
- GL.iNet Beryl AX 4.4.6 official firmware 
- GL.iNet Spitz AX 4.0 official firmware 
- Banana Pi BPI-R3 OpenWrt 23.05 
- Nano Pi R6S FriendlyWrt 23.05.X

## Installation

Download the `.ipk` file from the [Releases section](https://github.com/TalalMash/Unofficial-Speedify-Installer-For-OpenWrt/releases/latest) and follow the video below:

https://github.com/TalalMash/Unofficial-Speedify-Installer-For-OpenWrt/assets/96490382/0c49dea6-e07f-4db8-8813-b6786d552da9

## Known issues & Workarounds

### Generating logs
The official **Help -> Generate Logs** button in Speedify UI doesn't work.

Instead you need to:
1. Open our custom Speedify Configuration menu from the OpenWrt Menu **VPN -> Speedify**
2. Click the **Download Logs & Config** button

### Restarting Speedify

The official **Restart Speedify Service** in the Speedify UI doesn't work.

Instead you need to:
1. Open our custom Speedify Configuration menu from the OpenWrt Menu **VPN -> Speedify**
2. Click the **Reset** button
