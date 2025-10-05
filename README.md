# PocketBook Zig template

[Minimal app(lication)](SDK.pdf) for B288 (or B300) CPU.

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

To add missing **API functions**, replace the included **SDK**
subset https://github.com/pocketbook-free/SDK_481/tree/5.12/arm-obreey-linux-gnueabi/sysroot/usr/local

To list all **icons**, copy `/ebrmain/themes/Line.pbt` from the device and use the **pbres** port
from https://github.com/chrisridd/pbtools
