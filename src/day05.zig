const std = @import("std");
const Allocator = std.mem.Allocator;

fn parseJumps(allocator: Allocator) ![]i32 {
    const input = @embedFile("./input/day05");

    var lines = std.mem.tokenizeSequence(u8, input, "\n");
    var output: std.ArrayList(i32) = .empty;

    while (lines.next()) |line| {
        const num = try std.fmt.parseInt(i32, line, 10);
        try output.append(allocator, num);
    }

    return output.items;
}

fn execute(jumps: []i32, process: fn (offset: i32) i32) u32 {
    var data = jumps;
    var index: i32 = 0;
    var steps: u32 = 0;

    while (index >= 0 and index < jumps.len) {
        const offset = data[@intCast(index)];
        data[@intCast(index)] += process(offset);

        index += offset;
        steps += 1;
    }

    return steps;
}

fn part1(_: i32) i32 {
    return 1;
}

fn part2(offset: i32) i32 {
    return if (offset >= 3) -1 else 1;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const first = try parseJumps(allocator);
    const second = try allocator.alloc(i32, first.len);
    @memcpy(second, first);

    std.debug.print("{}\n", .{execute(first, part1)});
    std.debug.print("{}\n", .{execute(second, part2)});
}
