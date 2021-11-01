# GeekTool

## About

<img src="https://i.imgur.com/aGDKH2R.png" width="120px"/> 

**Another based-TerminalEmulator app with various features for modding virtual machine of VMOS Pro**

*Material design app icon suggest by @ro6kie* 

Goal: This app makes installing vmostool easier!

## Installation


1. Download from [MEGA Link](http://link1s.com/W2GN7) 

2. Import apk and install **GeekTool** into virtual machine of VMOS Pro.




## What can GeekTool script do?
### Custom ROM Fix

• If an user install backup ROM with **Import local ROM** option, VMOS Pro doesn't restore any symlinks and applets point to `toybox`, `toolbox`,... It will also break the structure of system and some apps cannot work properly (Root checker said *Root is not properly installed* even grant it root access), in that case, **GeekTool will solve broken structure** in pre-init stage before the init stage start and system booting process
• No matter user install custom ROM via **Import local ROM** or **Rec the VM** option, **GeekTool** will make sure that your ROM doesn't miss any applets of `toybox` or `toolbox`
### **Superuser**
Old but gold, a good solution for ROOT, currently VMOS uses `su` binary from Koushikdutta, it is open source and can be embeded on any AOSP ROM.

[koush/Superuser](https://github.com/koush/Superuser): Why another Superuser?
 
We provide a native way to let any apps can login root user through `su` command.
The path we usually place `su` file is `/system/xbin`.

However, VMOS Pro doesn't let non-premium users have root access on official ROM, if it detected `su` binary in `/system`, then `su` binary will be deleted every boot and crash the **Superuser** app. GeekTool install `su` in `/sbin` directory instead to ensure `su` will not be removed.
GeekTool also can bypass **Superuser** crash problem by hiding the `com.koushikdutta.superuser` package of app, so you can continue keep Superuser app for managing ROOT permission.

How `su` work is letting apps run a new process in root shell launched by `daemonsu`, `su` cannot work if there are no daemon process.

### **Shizuku**

A new way to get special access of system (root,adb)

### **Xposed Framework**

Xposed is a framework for modules that can change the behavior of the system and apps without touching any APKs. That's great because it means that modules can work for different versions and even ROMs without any changes (as long as the original code was not changed too much). It's also easy to undo. As all changes are done in the memory, you just need to deactivate the module and reboot to get your original system back. There are many other advantages, but here is just one more: Multiple modules can do changes to the same part of the system or app. With modified APKs, you to decide for one. No way to combine them, unless the author builds multiple APKs with different combinations.

Need root access to install but using it no need root access

### **Busybox**

Busybox with various program for many apps and manu program!

### **Advanced wipe**

Wipe all your data with only few seconds.

### **VMOS Props Config**

Patch read-only system properties (start with `ro.`)  set by VMOS Pro, these props can only set once and cannot be changed with `setprop` even with root user.

If you get bootloop after changing any prop through `/tool_files/system.prop`, you can disable it, read FAQ bellow!


### **Install modifications** 

Alternative Recovery zip for VMOS Pro (with limitations)

Introduce a new way to modify system, modify `/system` at boot instead of modify it directly!

[For more information, read here!](https://github.com/HuskyDG/VMOSPro_RootXposed_Terminal/blob/main/modification.md)

### **Mount real storage**

You files on your real system can be access from virtual machine VMOS Pro through `/local_disk` path. You need to grant **Storage** permission to VMOS Pro app. 

### **Init script support**

Can execute your shell script every boot time.

### **SD Card Tool**

Using microSD to expand your virtual machine memory

The folder to place files on your devices will be:

***microSD card*** > **Android** > **data** > **data** > **com.vmos.pro** > **files** > **expand**

And it will be used as `/sdcard` and `/mnt/asec` in VMOS Pro


### **Dual space**

Open new userspace so you can have two space on one virtual machine


### **Google Services** 

Enable to use apps need Google Services core and easily remove if unwanted

### Backup data

Backup apps and data as VMOS flashable ZIP, then you can import it to another virtual machine.


## FAQ

### Bootloop cause by Xposed modules or edit some property data

**Only work with VMOSTool v1.26+**


1. Turn off virtual machine
2. On your real system, create a file at 

`/sdcard/vmospro/tool_config.prop` 

   with content:

```
# Disable load /tool_files/system.prop
DISABLE_PROPS=false
# Disable Xposed Framework
DISABLE_XPOSED=false
```
3. Turn on virtual machine, now it will boot with no **Xposed Framework** and disable loading `system.prop`
4. Delete `/sdcard/vmospro/tool_config.prop` to make Xposed works normally


For safety, please only modify `/tool_files/system.prop` instead of `/system/build.prop`. The properties in `system.prop` will override or merge with `build.prop` every boot.

