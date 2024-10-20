// https://cookbook.ziglang.cc/10-02-base64.html

const std = @import("std");
const print = std.debug.print;
const Encoder = std.base64.standard.Encoder;
const Decoder = std.base64.standard.Decoder;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const src = "hello zig";

    // Encode
    const encoded_length = Encoder.calcSize(src.len);
    const encoded_buffer = try allocator.alloc(u8, encoded_length);
    defer allocator.free(encoded_buffer);

    _ = Encoder.encode(encoded_buffer, src);

    std.debug.print("source: {s}\n", .{src});
    std.debug.print("expected: aGVsbG8gemln\n", .{});
    std.debug.print("encoded: {s}\n", .{encoded_buffer});
    std.debug.print("same: {}\n", .{std.mem.eql(u8, "aGVsbG8gemln", encoded_buffer)});

    try std.testing.expectEqualStrings("aGVsbG8gemln", encoded_buffer);

    // Decode
    const decoded_length = try Decoder.calcSizeForSlice(encoded_buffer);
    const decoded_buffer = try allocator.alloc(u8, decoded_length);
    defer allocator.free(decoded_buffer);

    try Decoder.decode(decoded_buffer, encoded_buffer);
    try std.testing.expectEqualStrings(src, decoded_buffer);
}
