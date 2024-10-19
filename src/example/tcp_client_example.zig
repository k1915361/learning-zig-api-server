// https://cookbook.ziglang.cc/04-02-tcp-client.html
// Code slightly altered to fit Windows and Zig 0.14.0:
//
// from std.process.args() to std.process.ArgIterator.initWithAllocator(allocator)
//
// client connects to server
// connects to the server: tcp_server_unused_port_example.zig
// cd E:\learning-zig-api-server-main\src\04-02
// zig run .\tcp_client_example.zig -- 60801
// the port number "60801"must match the server port number

const std = @import("std");
const net = std.net;
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = try std.process.ArgIterator.initWithAllocator(allocator);
    defer args.deinit();

    // The first (0 index) Argument is the path to the program.
    _ = args.skip();

    const port_value = args.next() orelse {
        print("expect port as command line argument\n", .{});
        return error.NoPort;
    };
    const port = try std.fmt.parseInt(u16, port_value, 10);

    const peer = try net.Address.parseIp4("127.0.0.1", port);
    // Connect to peer
    const stream = try net.tcpConnectToAddress(peer);
    defer stream.close();
    print("Connecting to {}\n", .{peer});

    // Sending data to peer
    const data = "hello zig, from tcp client.";
    var writer = stream.writer();
    const size = try writer.write(data);
    print("Sending '{s}' to peer, total written: {d} bytes\n", .{ data, size });
    // Or just using `writer.writeAll`
    // try writer.writeAll("hello zig");
}
