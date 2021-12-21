# Magisk On Nox
## About
Integrate Magisk root into Nox emulator

## Requirements
- Nox Emulator with Android 64-bit
- Other emulator can install

## Download
[magisk-on-nox.zip](https://link1s.com/MagiskOnNox) 

## Installation

1. Go to emulator settings, enable Root and reboot
2. Install **Terminal Emulator** if you don't have it installed
3. Download magisk-on-nox.zip to your emulator
4. Extract it to:

 `[Internal Storage]/Download/magisk-on-nox`

*Make sure you have extracted all files from zip*

*You can replace `magisk.apk` with another `magisk.apk`*

5. Open **Terminal Emulator**, run these command:
```
su
sh /sdcard/Download/magisk-on-nox/install.sh
```

Note: `/sdcard` might be confusing but it is path to your internal storage, not your secondary external storage (microSD card slot)

6. Reboot the emulator.


## Credits
- [Magisk](https://github.com/topjohnwu/Magisk): The most famous root solution on Android
