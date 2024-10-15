const std = @import("std");
const assert = std.debug.assert;

const Header = struct {
    magic: u32,
    name: []const u8,
};

pub fn greet(name: []const u8) void {
    std.debug.print("Hello, {s}!\n", .{name});
}

pub fn main() void {
    greet("World");

    // //

    const msg = "hello this is dog";
    var it = std.mem.tokenizeAny(u8, msg, " ");
    while (it.next()) |item| {
        std.debug.print("{s}\n", .{item});
    }

    // //

    var buffer: [10]i32 = undefined;
    var list = List(i32){
        .items = &buffer,
        .len = 0,
    };
    list.items[0] = 1234;
    list.len += 1;

    std.debug.print("{d}\n", .{list.items.len});
    std.debug.print("{d}\n", .{list.len});

    // //
    

}

fn List(comptime T: type) type {
    return struct {
        items: []T,
        len: usize,
    };
}

test "types are values" {
    const T1 = u8;
    const T2 = bool;
    assert(T1 != T2);

    const x: T2 = true;
    assert(x);
}