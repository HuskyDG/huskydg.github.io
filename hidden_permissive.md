# Hidden SELinux Permissive

## About

- Selinux Permissive is very bad. For Magisk, it causes Magisk cannot completely hidden if you are using MagiskHide or any hiding mechanism (Shamiko). Developer didn't address this problem yet. 
- This module will patch selinux to premissive all contexts, apply patch for `untrusted_app`, `isolated_app` and enforce they. In short, it will make Selinux is enforced for normal apps but system contexts are in Permissive. 
- Download this module: [Click here](http://huskydg.github.io/safety_permissive.zip)
- In some Android x86 build (such as PrimeOS 2.x), early enforcing causes system bootloop. Use file manager and browse to `/data/adb/modules/safety_permissive`, create a file named `late` to enable late mode.

## Feature

- Fake SELinux Enforcing
- Hide SU processes

## Changelogs

### v1.1

- Add more denials for untrusted_app and isolated_app to bypass [MagiskDetector](http://github.com/vvb2060/MagiskDetector).

### v1.0

- Initial release
