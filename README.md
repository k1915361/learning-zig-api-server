# learning-zig-api-server

Learning Zig and API server, for purpose of interacting with a database, uploading/downloading models, images, videos, database files, and interacting with another web server.

## Setting up zig

Download zig bundle from link:
https://ziglang.org/download/

Unzip and place it in a directory:  
`C:\eugene\zig-windows-x86_64-0.14.0-dev.1913+7b8fc18c6`  
`E:\env-path\zig-windows-x86_64-0.14.0-dev.1924+bdd3bc056`

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

## Running a web server

<https://cookbook.ziglang.cc/04-01-tcp-server.html>

Useful resources of image, video, media files handling (base64), handling multiple data communication (JSON), communicating data (HTTP), Database, and Text Processing (Regex, String Parsing).

5. Web Programming
5.1. HTTP Get
5.2. HTTP Post

10. Encoding
10.1. Deserialize JSON
10.2. Encode and decode base64

14. Database
14.1. SQLite
14.2. Postgres
14.3. MySQL

15. Text Processing
15.1. Regex Expressions
15.2. String Parsing

## Running an example TCP Server

```powershell
cd E:\learning-zig-api-server-main\src
zig run tcp_server_example.zig

# Open another powershell terminal
# ./test-api.ps1 - #1 script
$socket = New-Object Net.Sockets.TcpClient("127.0.0.1", 8000)
$stream = $socket.GetStream()
$writer = New-Object IO.StreamWriter($stream)
$writer.WriteLine("hello zig")
$writer.Flush()
$writer.Close()
$socket.Close()
```

## Running a HTTP Media Server

<https://www.pedaldrivenprogramming.com/2024/03/writing-a-http-server-in-zig/>  
<https://github.com/Fingel/zig-http-server/tree/main>

This example handles html and image formats png, jpg, gif.

`const self_addr = try net.Address.resolveIp("0.0.0.0", 4206);`

Windows and `net.zig`'s function `if_nametoindex` as method `resolve` for struct `Ip6Adress` is not compatible. Try other way to run a HTTP media server.

Some Zig implementations and repositories use bash scripts which is not compatible with Windows.

`net.zig:755 error std.net.if_nametoindex unimplemented for this OS`

---

<https://blog.orhun.dev/zig-bits-04/#building-an-http-client-zap>  

Downgrade Zig version from 0.14 to 0.11

`(allocator,`: `expected type 'net.Server.Connection', found 'mem.Allocator'`

`var server = http.Server.init(allocator, .{ .reuse_address = true });`

---

Another attempt at a HTTP Media Server.

`main_ std_net has no member named StreamServer.zig`

`std.net.StreamServer` `std_net has no member named StreamServer`

Zig's standard net implementation has likely changed.  
Downgrade the Zig version from 0.14 to older and more stable versions.

## Open current directory in File Explorer by command

```powershell
start .
```

## Commonly Used Commands

clear terminal  
`cls`

clear terminal and run another command  
`cls; `