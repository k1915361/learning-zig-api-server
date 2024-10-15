# learning-zig-api-server
Learning Zig and API server, for purpose of interacting with a database, uploading/downloading models, images, videos, database files, and interacting with another web server.

## Setting up zig

Download zig bundle from link:
https://ziglang.org/download/

Unzip and place it in a directory:
C:\eugene\zig-windows-x86_64-0.14.0-dev.1913+7b8fc18c6

Add the directory to Path
For Windows, "Environment Variables" > "User Variables" > "Path" > Add the zip directory

```powershell
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + "C:\eugene\zig-windows-x86_64-0.14.0-dev.1913+7b8fc18c6",
   "Machine"
)

```

## Zig - Run Hello World

```powershell
cd C:\Users\user\Documents\eugene\ku-backend

zig init

zig build test
```

## zig Basics

helloworld.zig

```zig
const std = @import("std");

pub fn greet(name: []const u8) void {
    std.debug.print("Hello, {s}!\n", .{name});
}

pub fn main() void {
    greet("World");
}
```

```powershell
zig build-exe helloworld.zig
./helloworld
# Hello, World!
```

## cleaning your build cache and re-building:
- Delete the zig-cache directory in your project root.
- Run `zig build --fetch` to re-fetch dependencies.
- Then run `zig build` again.
- Use `zig build` and `zig build run` instead of `build-exe` command. Use the `main.zig` instead of `app.zig`.


## Open current directory by command 
```powershell
start .
```