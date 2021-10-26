# VMOS and VphoneGaga
The different things between VMOS and VphoneGaga - Android virtual master on Android

This repository is for educational only! Based on my knowledge, these thing maybe not always right!

# VMOS - Fake Rootfs

**VMOS is an closed source project!!**

VMOS uses fake rootfs, that means they directly place virtual machine system files on VMOS internal data folder and use it as root directory. The other virtual machine app like F1VM, X8SB and Virtual Android (Play Store) use this method too

So they don't need or don't have **boot.img**, **system.img**, ... to mount loop as the reason above!

The disadvantage of this method is that they don't have **Selinux** rule. This is the big problem because any app can take control of system without root if Selinux is unavailable! 

You can modify system files without Root access with almost file explorer...

But many drawbacks start from this point occurs, some apps don't recognize virtual machine root directory but recognize your real system root directory instead, that why they won't work (Termux, legacy GLTools,... And also Magisk Manager)

The path to rootfs of virtual machine from your real system will be 
```
/data/data/com.vmos.pro/osimg/r/<vm_name>/
```

**VMOS is easily to be detected!**


*VMOS let its props to be visible to all apps in VMOS*

The simplest ways to detect if you are on virtual machine by running `getprop | grep 'vmprop'` on **Terminal Emulator**

VMOS uses the same `/proc` and `/dev` of you device in order to work, make virtual machine able to use your phone RAM. If you access these folders in VMOS, you are actually access this folders from your device. The fun fact that `/proc/self/root` are point to your root directory of your real device and `/proc/self/root/sdcard` is point to `/sdcard` of your device.


If you device is rooted, you can access this folder from your real system device

# VphoneGaga - Real Rootfs

**Different from VMOS, VphoneGaga is open source**

Use VphoneGaga, you will overcome those drawbacks above! VphoneGaga is safe option for you because:

Different from VMOS, they don't directly place virtual machine file on internal data folder. They load system file from image BIN disk by mounting like our real system does every time boot.

The system inside VphoneGaga have its own **Selinux** rule and **enforcing** by default so it is great and safe to run any app inside VphoneGaga unless you grant it root access...

VphoneGaga doesn't depend on `/proc` and `/dev` of your real system, so it is more independent...

But its image format is BIN, not `.img` format so it is hard to unpack this image to modify :(

You cannot access VphoneGaga files from your real system as its filesystem is actually mounted from image disk.
