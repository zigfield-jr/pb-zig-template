# PocketBook Zig template

[Minimal app(lication)](SDK.pdf) for B288 (or B300) CPU. Includes
an [SDK 6.5](https://github.com/pocketbook/SDK_6.3.0/tree/6.5/SDK-B288/usr/arm-obreey-linux-gnueabi/sysroot/usr) subset.

## USB

Build project with release containing https://github.com/ziglang/zig/pull/25301

```
zig build
```

Copy `zig-out/applications/hello_world.app` to device folder `/applications`

Start the application.

## WLAN

Copy `zig-out/applications/netcat.app` to device folder `/applications`

Start the script, answer possible questions.

Build project with option `dest_ip`

```
zig build -Ddest_ip=192.168.???.???
```

## Debug

Work in progress.

Copy `zig-out/applications/gdbserver.app` to device folder `/applications`

Start the script, answer possible questions.

Remote debug using GDB with target `192.168.???.???:10002`

## Note

To access the **shell**, install the **pbterm** B288 or B300 release from https://github.com/leomeyer/pbterm

To find an **icon**, copy `/ebrmain/themes/Line.pbt` and use the **pbres** port
from https://github.com/chrisridd/pbtools
