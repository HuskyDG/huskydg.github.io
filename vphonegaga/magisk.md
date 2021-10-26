# Magisk on VphoneGaga

<img src="https://i.imgur.com/s67IoUZ.jpg"/>



Set up a proper minial Magisk on VphoneGaga virtual machine without patching boot image

VphoneGaga 32bit and 64bit now supported!

Good news for anyone who want to run Magisk on VMOS: Vphone have proper system and can run Magisk properly thanks to [emulator.sh](https://github.com/topjohnwu/Magisk/blob/master/scripts/emulator.sh) script by **topjohnwu**. 

### Installation

  1. Download `vmostool_magisk.zip`
  2. Import to VphoneGaga. You can find it at `/sdcard/Documents`, extract to any folder. For example here `/sdcard/Documents/vmostool_magisk`.
  3. Open Terminal app, grant superuser first by `su` command then run `sh <extracted_folder>/vphonegaga.sh`.
  
  For example run:
```
su
sh /sdcard/Documents/vmostool_magisk/vphonegaga
```
  4. Reboot the virtual machine.

     If you want to load Magisk then run this command:
```
su
magisk_root enable
```


Also reboot to make it work...

Only install Magisk Manager v8.0.0
Newer Magisk doesn't work


## Limitations 

- **Only MagiskSU works:** it can prompt Superuser request when app excute `su` binary
- **MagiskHide:** Android's kernel on this virtual machine was too old and didn't support Mount Namespace which is used by MagiskHide to hide itself by unmount /sbin/su from other app
- **MagiskModule** `/dev/tmp` issue so module failed to install
- VphoneGaga blocks Magisk from running on post-fs-data stage so if Magisk Module is installed, it won't work



## Download

Download link: https://link1s.com/MagiskVphoneGaGa
VPhoneGaGa link: https://link1s.com/VphoneGaga
