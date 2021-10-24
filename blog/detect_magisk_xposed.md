# Detect Magisk and Xposed

Post by canyie

Translated to English


Not long ago, developers Rikka & vvb2060 launched an environmental detection application Momo , which smashed various anti-detection methods that people have always trusted. Below I will analyze this may be the strongest environmental detection application in history through some of the open source code.


## Anti-Magisk Hide
First analyze the principle of Magisk Hide:

```
static void new_zygote(int pid) {
    struct stat st;
    if (read_ns(pid, &st))
        return;

    auto it = zygote_map.find(pid);
    if (it != zygote_map.end()) {
        // Update namespace info
        it->second = st;
        return;
    }

    LOGD("proc_monitor: ptrace zygote PID=[%d]\n", pid);
    zygote_map[pid] = st;

    xptrace(PTRACE_ATTACH, pid);

    waitpid(pid, nullptr, __WALL | __WNOTHREAD);
    xptrace(PTRACE_SETOPTIONS, pid, nullptr,
            PTRACE_O_TRACEFORK | PTRACE_O_TRACEVFORK | PTRACE_O_TRACEEXIT);
    xptrace(PTRACE_CONT, pid);
}

void proc_monitor() {
    // 省略...

    // First try find existing zygotes
    check_zygote();

    for (int status;;) {
        const int pid = waitpid(-1, &status, __WALL | __WNOTHREAD);
        if (pid < 0) {
            // 省略...
        }

        if (!WIFSTOPPED(status) /* Ignore if not ptrace-stop */)
            DETACH_AND_CONT;

        int event = WEVENT(status);
        int signal = WSTOPSIG(status);

        if (signal == SIGTRAP && event) {
            unsigned long msg;
            xptrace(PTRACE_GETEVENTMSG, pid, nullptr, &msg);
            if (zygote_map.count(pid)) {
                // Zygote event
                switch (event) {
                    case PTRACE_EVENT_FORK:
                    case PTRACE_EVENT_VFORK:
                        PTRACE_LOG("zygote forked: [%lu]\n", msg);
                        attaches[msg] = true;
                        break;
                    // ...
                }
            } else {
                switch (event) {
                    case PTRACE_EVENT_CLONE:
                        PTRACE_LOG("create new threads: [%lu]\n", msg);
                        if (attaches[pid] && check_pid(pid)) // 这里就会实际hide magisk
                            continue;
                        break;
                    // ...
                }
            }
            xptrace(PTRACE_CONT, pid);
        } else if (signal == SIGSTOP) {
            if (!attaches[pid]) {
                // Double check if this is actually a process
                attaches[pid] = is_process(pid);
            }
            if (attaches[pid]) {
                // This is a process, continue monitoring
                PTRACE_LOG("SIGSTOP from child\n");
                xptrace(PTRACE_SETOPTIONS, pid, nullptr,
                        PTRACE_O_TRACECLONE | PTRACE_O_TRACEEXEC | PTRACE_O_TRACEEXIT);
                xptrace(PTRACE_CONT, pid);
            } // ...
        } // ...
    }
}
```



It can be seen that magisk hide traces all zygotes through the ptrace mechanism, and cat `/proc/<pid>/status` can also be confirmed by seeing the TracerPid. When the first thread of the child process is created, it is actually hidden.

```
static bool check_pid(int pid) {
    char path[128];
    char cmdline[1024];
    struct stat st;

    sprintf(path, "/proc/%d/cmdline", pid);
    if (auto f = open_file(path, "re")) {
        fgets(cmdline, sizeof(cmdline), f.get());
    } else {
        // Process died unexpectedly, ignore
        detach_pid(pid);
        return true;
    }
    
    if (cmdline == "zygote"sv || cmdline == "zygote32"sv || cmdline == "zygote64"sv ||
        cmdline == "usap32"sv || cmdline == "usap64"sv)
        return false;

    // 通过uid和进程名判断是否需要hide
    if (!is_hide_target(uid, cmdline))
        goto not_target;

    // 如果命名空间未分离，进行unmount会影响到zygote从而影响到而后启动的所有进程，跳过
    read_ns(pid, &st);
    for (auto &zit : zygote_map) {
        if (zit.second.st_ino == st.st_ino &&
            zit.second.st_dev == st.st_dev) {
            // ns not separated, abort
            LOGW("proc_monitor: skip [%s] PID=[%d] UID=[%d]\n", cmdline, pid, uid);
            goto not_target;
        }
    }

    // Detach but the process should still remain stopped
    // The hide daemon will resume the process after hiding it
    LOGI("proc_monitor: [%s] PID=[%d] UID=[%d]\n", cmdline, pid, uid);
    detach_pid(pid, SIGSTOP);
    hide_daemon(pid);
    return true;

not_target:
    PTRACE_LOG("[%s] is not our target\n", cmdline);
    detach_pid(pid);
    return true;
}
```

`hide_daemon` will fork a new process, setns to the namespace of the target process, and then uninstall everything that has been modified by magisk. Note that there is an if judgment in it. If the namespace is not separated, unmounting will affect zygote and thus all the processes that are started later, then skip it directly. That's Magisk Hide's first question.

In the introduction to the implementation details of MagiskDetector, it is stated that there are two situations that meet:

One is that the read storage space op of the application appops is ignored, and the other is that the process is an isolated process.

The isolated process here refers to `android:isolatedProcess="true"` the service. Moreover, there is also a (private) interesting (goods) thing on Android 10 called App Zygote. There is almost no description for this thing. The only document is ZygotePreload , which feels more like a backdoor opened by Google to Chrome. Ahem, off topic, this thing runs in a separate process and doesn't separate namespaces.

There are currently two known solutions to this problem. The first is Magisk Lite , which directly unmount zygote process instead of applying it, but this method will destroy many existing modules; the other is to use code injection to forcibly separate namespaces , the typical solution is **Riru-Unshare**.

Ok, this question is over, the next one~~

In the above judgment code, the read process name part is `/proc/<pid>/cmdline` judged by reading; in fact, the length of the content of this file is limited! This means that when the configured process name is too long, the process name read by Magisk will not match, thus skipping the process! This is the rationale for [Issue#3997](https://github.com/topjohnwu/magisk/issues/3997)  . Magisk has made a temporary fix for this: if the prefix matches, it is directly considered to be the target process to hide.

Is it finished? No. The next problem is when adding the process to the database:


```

static int add_list(const char *pkg, const char *proc) {
    if (proc[0] == '\0')
        proc = pkg;

    if (!validate(pkg) || !validate(proc))
        return HIDE_INVALID_PKG;
    
    // ...
}

static bool validate(const char *s) {
    if (strcmp(s, ISOLATED_MAGIC) == 0)
        return true;
    bool dot = false;
    for (char c; (c = *s); ++s) {
        if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ||
            (c >= '0' && c <= '9') || c == '_' || c == ':') {
            continue;
        }
        if (c == '.') {
            dot = true;
            continue;
        }
        return false;
    }
    return dot;
}
```
The package name and process name will be checked here. If it contains illegal characters or no dots, it is considered to be an invalid process. Android has strict regulations on package names, and android:process also regulations on process names through configuration. It seems that it can't be a demon? However the problem does occur: [Issue#4176](https://github.com/topjohnwu/magisk/issues/4176) .

After inspection, the application uses an isolated process to check Magisk, but the difference is that its service class name contains illegal characters (Java does not limit class names), and Android 10+, the system will append the class name to the name of the isolated process ( https://t.me/vvb2060Channel/441), causing the check to fail. The solution is also very simple, just modify this validate.

Detect the modification of init.rc:
Random only works if it cannot be traversed. If it can be traversed, statistical methods can be used to find exactly what is different each time.

This sentence looks a bit confusing, just look at the Magisk source code. [init/rootdir.cpp](https://github.com/topjohnwu/Magisk/blob/master/native/jni/init/rootdir.cpp):

```
// Inject Magisk rc scripts 
char pfd_svc[ 16 ], ls_svc[ 16 ], bc_svc[ 16 ]; 
gen_rand_str(pfd_svc, sizeof (pfd_svc)); 
gen_rand_str(ls_svc, sizeof (ls_svc)); 
gen_rand_str(bc_svc, sizeof (bc_svc) ); 
LOGD( "Inject magisk services: [%s] [%s] [%s]\n" , pfd_svc, ls_svc, bc_svc); 
fprintf (rc, MAGISK_RC, tmp_dir, pfd_svc, ls_svc, bc_svc);
```

Magisk will inject three of its own services into `init.rc` at startup to receive events such as post-fs-data; the names of these three services are randomized, and init will actually go to the system properties. Add `init.svc.<service name>` property like this, with a value of running or stopped, to tell other processes the status of the service. MagiskDetector takes advantage of this mechanism, traverses the system properties to record all service names, and then knows whether any service names have changed after the user restarts.

## Detect SELinux rules
[magiskpolicy/rules.cpp](https://github.com/topjohnwu/Magisk/blob/master/native/jni/magiskpolicy/rules.cpp)

```
// Allow these processes to access MagiskSU
const char *clients[] { "init", "shell", "appdomain", "zygote" };
for (auto type : clients) {
    if (!exists(type))
        continue;
    allow(type, SEPOL_PROC_DOMAIN, "unix_stream_socket", "connectto");
    allow(type, SEPOL_PROC_DOMAIN, "unix_stream_socket", "getopt");

    // Allow termios ioctl
    const char *pts[] { "devpts", "untrusted_app_devpts" };
    for (auto pts_type : pts) {
        allow(type, pts_type, "chr_file", "ioctl");
        if (db->policyvers >= POLICYDB_VERSION_XPERMS_IOCTL)
            allowxperm(type, pts_type, "chr_file", "0x5400-0x54FF");
    }
}
```

Since Magisk allows some ioctls, it will be detected. As a workaround, update to Android 8+ & Magisk 21+ and Magisk will automatically use the new rules.

At the same time, it's not just Magisk's own pot, the wrong use of SELinux may also cause Magisk to be easily detected. Example:
```
type(SEPOL_PROC_DOMAIN, "domain" ); 
type(SEPOL_FILE_TYPE, "file_type" );

```

Two magisk own domains have been added, which seems to be no problem. However, if the user sets selinux to permissive mode, the app can proceed `selinux_check_access()` (the interface corresponding to the java layer is `SELinux.checkSELinuxAccess()`), and if it is allowed, it means that this domain exists. => Magisk installed.

Not only the permissive mode, if you add `allow appdomain xxx relabelfrom` such rules and don't have them `deny appdomain magisk_file relabelto`, the app may chcon the context of a file magisk_file, and then by trying to manipulate the file to determine whether it is rejected, you can test whether there is this domain in the system. .

SELinux is an important part of Android's security mechanism, and it is strongly discouraged to set it to permissive mode or ignore neverallow to add rules at will.

### Off topic: Detecting magiskd
Although MagiskDetector does not use this method, it is a bit interesting, so I can talk about it.
Before Android 7, `/proc` was no limit, and anyone could traverse to get the process list; in 7, it was added hidepid=2, but not all manufacturers kept up; for these devices, just scan to see if there is magiskda process called Make sure there is no magisk.

## Xposed
### Detect Xposed
The original Xposed framework added its own classes to the bootclasspath, which made it easy for anyone to find them. After that, everyone chose to isolate the classloader, making detection less easy; however, as long as it exists in memory, it can be found. The principle of XposedDetector is very simple. Through an internal interface of art (VisitRoots), find all ClassLoaders in the heap, and then try them one by one. At present, lsp, edxp, dreamland, etc. are only loaded in the target application to prevent accidental injury. Of course it's okay to hook this function, but we don't want to play this cat-and-mouse game, we can only ensure that the environment of the non-target application is not modified.

## Anti-Xposed Hook
The method of XposedDetector is that through the above method, all classes in the current process can be found. According to this method, disableHooksyou sHookedMethodCallbackscan find XposedBridge and change the and .

In fact, there are many other methods:
in addition to the original xposed and edxposed before 0.5, other frameworks basically ignore the isolation process directly, and can put important things in the isolation process.

A method through Xposed hook will eventually come to this method:

```
public static XC_MethodHook.Unhook hookMethod(Member hookMethod, XC_MethodHook callback) {
    // ...
    else if (hookMethod.getDeclaringClass().isInterface()) {
		throw new IllegalArgumentException("Cannot hook interfaces: " + hookMethod.toString());
	}
}
```

This check is problematic after Android 7, because Android 7 supports a Java 8 feature called interface default method. The interface can no longer only "talk empty words", but can also have its own method body, and as long as the implementation class is not rewritten, the declaring class of the method is the interface, and Xposed will throw an exception when hooking.

The basic principle of Xposed and various implementations is to do something with `entry_point_from_quick_compiled_code_` member, you can directly modify this member or you can inline hook; and there is a "universal entry" in art: interpretation execution entry, by setting the method entry to interpretation execution can make Xposed The hook is invalid, but not for Frida's modified interpreter.


Blog content is under the Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) license

The permalink to this article is: https://blog.canyie.top/2021/05/01/anti-magisk-xposed/

