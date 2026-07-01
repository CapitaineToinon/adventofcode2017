const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

fn parse(allocator: Allocator, comptime input: []const u8) ![][]u32 {
    var linesIter = std.mem.tokenizeScalar(u8, input, '\n');
    var lines: ArrayList([]u32) = .empty;

    while (linesIter.next()) |line| {
        var numbersIter = std.mem.tokenizeSequence(u8, line, "\t");
        var numbers: ArrayList(u32) = .empty;

        while (numbersIter.next()) |number| {
            const int = try std.fmt.parseInt(u32, number, 10);
            try numbers.append(allocator, int);
        }

        try lines.append(allocator, numbers.items);
    }

    return lines.items;
}

fn part1(input: [][]u32) u32 {
    var total: u32 = 0;

    for (input) |line| {
        var min: u32 = 9999;
        var max: u32 = 0;

        for (line) |number| {
            max = @max(max, number);
            min = @min(min, number);
        }

        total += (max - min);
    }

    return total;
}

fn part2(input: [][]u32) u32 {
    var total: u32 = 0;

    for (input) |line| {
        outer: for (line, 0..) |number, i| {
            for (line[i + 1 ..]) |other| {
                const max = @max(number, other);
                const min = @min(number, other);

                if (max % min == 0) {
                    total += (max / min);
                    continue :outer;
                }
            }
        }
    }

    return total;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const file = @embedFile("./input/day02");
    const input = try parse(allocator, file);

    std.debug.print("{any}\n", .{part1(input)});
    std.debug.print("{any}\n", .{part2(input)});
}
