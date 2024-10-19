// https://cookbook.ziglang.cc/10-01-json.html

const std = @import("std");
const json = std.json;
const testing = std.testing;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Deserialize JSON
    const json_str =
        \\{
        \\  "userid": 103609,
        \\  "verified": true,
        \\  "access_privileges": [
        \\    "user",
        \\    "admin"
        \\  ]
        \\}
    ;
    const T = struct { userid: i32, verified: bool, access_privileges: [][]u8 };
    const parsed = try json.parseFromSlice(T, allocator, json_str, .{});
    defer parsed.deinit();

    std.debug.print("json:\n{s}\n\n", .{json_str});

    var value = parsed.value;

    try testing.expect(value.userid == 103609);
    try testing.expect(value.verified);
    try testing.expectEqualStrings("user", value.access_privileges[0]);
    try testing.expectEqualStrings("admin", value.access_privileges[1]);

    // Serialize JSON
    value.verified = false;
    const new_json_str = try json.stringifyAlloc(allocator, value, .{ .whitespace = .indent_2 });
    defer allocator.free(new_json_str);

    std.debug.print("deserialized json:\n{any}\n\n", .{value});
    std.debug.print("new json:\n{s}\n", .{new_json_str});

    try testing.expectEqualStrings(
        \\{
        \\  "userid": 103609,
        \\  "verified": false,
        \\  "access_privileges": [
        \\    "user",
        \\    "admin"
        \\  ]
        \\}
    ,
        new_json_str,
    );
}
