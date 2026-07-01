const std = @import("std");
const Allocator = std.mem.Allocator;

fn parseBanks(allocator: Allocator) ![]u32 {
    const input = @embedFile("./input/day06");
    const trimmed = std.mem.trim(u8, input, "\n");

    var banks = std.mem.tokenizeSequence(u8, trimmed, "\t");
    var output: std.ArrayList(u32) = .empty;

    while (banks.next()) |raw| {
        const bank = try std.fmt.parseInt(u32, raw, 10);
        try output.append(allocator, bank);
    }

    return output.items;
}

fn max(banks: []u32) [2]u32 {
    var i: u32 = 0;
    var bank = banks[i];

    for (banks[1..], 1..) |other, j| {
        if (other > bank) {
            i = @intCast(j);
            bank = other;
        }
    }

    return .{ i, bank };
}

fn hashBanks(banks: []u32) u64 {
    var hash: u64 = 5381;

    for (banks) |bank| {
        hash +%= ((hash << 5) +% hash) +% bank;
    }

    return hash;
}

fn solve(allocator: Allocator, banks: []u32) ![2]u32 {
    const len: u32 = @intCast(banks.len);
    var map: std.AutoHashMap(u64, u32) = .init(allocator);
    var steps: u32 = 0;

    while (true) {
        const hash = hashBanks(banks);

        if (map.get(hash)) |firstSteps| {
            const loopSize = steps - firstSteps;
            return .{ steps, loopSize };
        }

        try map.put(hash, steps);

        const i, var bank = max(banks);
        banks[i] = 0;
        var j = i + 1;

        while (bank > 0) {
            banks[(j % len)] += 1;
            bank -= 1;
            j += 1;
        }

        steps += 1;
    }

    return steps;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const banks = try parseBanks(allocator);
    const part1, const part2 = try solve(allocator, banks);

    std.debug.print("{}\n", .{part1});
    std.debug.print("{}\n", .{part2});
}
