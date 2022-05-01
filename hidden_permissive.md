# Hidden SELinux Permissive

## About

- Selinux Permissive is very bad. For Magisk, it causes Magisk cannot completely hidden if you are using MagiskHide or any hiding mechanism (Shamiko). Developer didn't address this problem yet. 
- This module will patch selinux to premissive all contexts, apply some denials for `untrusted_app`, `isolated_app` and enforce they. In short, it will make Selinux is enforced for normal apps but system contexts are in Permissive. 
- Download this module: [Click here](http://huskydg.github.io/safety_permissive.zip)

## Feature

- Fake SELinux Enforcing
- Hide SU processes

## Changelogs

### v1.2

- Change SELinux mode to Enforcing after boot completed on Android 10+ to avoid breaking system.

### v1.1

- Add more denials for untrusted_app and isolated_app to bypass [MagiskDetector](http://github.com/vvb2060/MagiskDetector).

### v1.0

- Initial release
