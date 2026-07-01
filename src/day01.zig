const std = @import("std");

const offset: u8 = '0';

fn sumDigitsNext(comptime digits: []const u8) u32 {
    const len = digits.len;
    var total: u32 = 0;

    for (0..len) |i| {
        if (digits[i] == digits[(i + 1) % len]) {
            total += (digits[i] - offset);
        }
    }

    return total;
}

fn sumDigitsHalfway(comptime digits: []const u8) u32 {
    const len = digits.len;
    var total: u32 = 0;

    for (0..len) |i| {
        if (digits[i] == digits[(i + len / 2) % len]) {
            total += (digits[i] - offset);
        }
    }

    return total;
}

pub fn main() void {
    const input = @embedFile("./input/day01");
    const trimmed = input[0 .. input.len - 1];

    std.debug.print("{}\n", .{sumDigitsNext(trimmed)});
    std.debug.print("{}\n", .{sumDigitsHalfway(trimmed)});
}
