# learning-zig-api-server

Learning Zig and API server, for purpose of interacting with a database, uploading/downloading models, images, videos, database files, and interacting with another web server.

## Setting up zig

Download zig bundle from link:
https://ziglang.org/download/

Unzip and place it in a directory:
C:\eugene\zig-windows-x86_64-0.14.0-dev.1913+7b8fc18c6
E:\env-path\zig-windows-x86_64-0.14.0-dev.1924+bdd3bc056

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
cd E:\learning-zig-api-server-main\

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

## cleaning your build cache and re-building

- Delete the zig-cache directory in your project root.
- Run `zig build --fetch` to re-fetch dependencies.
- Then run `zig build` again.
- Use `zig build` and `zig build run` instead of `build-exe` command. Use the `main.zig` instead of `app.zig`.

```zig
zig build --fetch
zig build
zig build run
```

## Building and Running Zig application

This also apply to Re-Building and Re-Running Zig application

```zig
zig build run
```

## Running a Starter Server

This link provides a basic example to start with.

<https://github.com/karlseguin/http.zig/blob/master/examples/01_basic.zig#L118>

It shows how to handle get and post requests and return response of basic HTML and JSON files.

API link examples:

```s
# Querystring + text output
/hello?name=Teg

# path parameter + serialize json object
/writer/hello/Ghanima

# Path parameter + json writer
/json/hello/Duncan 

# Internal metrics
/metrics"

/form_data
```

This example uses a different heap allocator, from our `std.heap.page_allocator` to their `std.heap.GeneralPurposeAllocator`. A bit of research is to be done on its purpose and benefit.

## Open current directory in File Explorer by command

```powershell
start .
```
