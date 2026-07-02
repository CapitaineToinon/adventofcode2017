const std = @import("std");
const print = std.debug.print;

fn solve(input: []const u8) [2]u32 {
    var index: u32 = 0;
    return group(input, &index, 0);
}

fn group(input: []const u8, i: *u32, depth: u32) [2]u32 {
    var score: u32 = depth;
    var size: u32 = 0;

    while (i.* < input.len) {
        switch (input[i.*]) {
            '}' => {
                i.* += 1;
                break;
            },
            '{' => {
                i.* += 1;
                const s, const g = group(input, i, depth + 1);
                score += s;
                size += g;
            },
            '<' => {
                i.* += 1;
                size += garbage(input, i);
            },
            else => {
                i.* += 1;
            },
        }
    }

    return .{ score, size };
}

fn garbage(input: []const u8, i: *u32) u32 {
    var size: u32 = 0;

    while (i.* < input.len) {
        switch (input[i.*]) {
            '>' => {
                i.* += 1;
                break;
            },
            '!' => i.* += 2,
            else => {
                i.* += 1;
                size += 1;
            },
        }
    }

    return size;
}

pub fn main() !void {
    const input = @embedFile("./input/day09");
    const trimmed = std.mem.trim(u8, input, "\n");
    const score, const size = solve(trimmed);

    print("{}\n", .{score});
    print("{}\n", .{size});
}
