# GeekTool

<img src="https://i.imgur.com/aGDKH2R.png" width="120px"/> 

**Another based-TerminalEmulator app with various features for modding virtual machine of VMOS Pro**

*Material design app icon suggest by @ro6kie* 

Goal: This app makes installing vmostool easier!

## Installation


Download from [MEGA Link](http://link1s.com/W2GN7) 



You just need to download and install **GeekTool** into virtual machine of VMOS Pro.




## What can GeekTool script do?
### Support Custom ROM
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

A Framework to modify app/system behaviour without modifying the *.apk*

Need root access to install but using it no need root access

### **Busybox**

Busybox with various program for many apps

### **Advanced wipe**

Wipe all your data with only few seconds.

### **VMOS Props Config**

Patch read-only system properties set by VMOS Pro, these properties start with `ro.` cannot be changed even root user

### **Install modifications** 

Alternative Recovery zip for VMOS Pro (with limitations)

Introduce a new way to modify system, modify `/system` at boot instead of modify it directly!

Toolflash = TWRP on VMOS Pro

[Read "modification.md"](https://github.com/HuskyDG/VMOSPro_RootXposed_Terminal/blob/main/modification.md)

### **Mount real storage**

Mount to manage your files on real system

### **Init script support**

Can execute your shell script every boot time

### **SD Card Tool**

Using microSD to expand your virtual machine memory

The mountpoint path is:

***microSD card*** > **Android** > **data** > **data** > **com.vmos.pro** > **files** > **expand**

### **Dual space**

Open new userspace so you can have two space on one virtual machine


### **Google Services** 

Enable to use apps need Google Services core

### Backup data

Backup apps and data, then you can import it to another virtual machine

