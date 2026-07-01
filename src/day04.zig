const std = @import("std");
const Allocator = std.mem.Allocator;

fn parsePassPhrases(allocator: Allocator) ![][][]u8 {
    const input = @embedFile("./input/day04");
    var lines = std.mem.tokenizeSequence(u8, input, "\n");
    var output: std.ArrayList([][]u8) = .empty;

    while (lines.next()) |line| {
        var words = std.mem.tokenizeSequence(u8, line, " ");
        var array: std.ArrayList([]u8) = .empty;

        while (words.next()) |word| {
            try array.append(allocator, @constCast(word));
        }

        try output.append(allocator, array.items);
    }

    return output.items;
}

fn hasNoDuplicates(passphrase: [][]u8) bool {
    for (passphrase, 0..) |word, i| {
        for (passphrase[i + 1 ..]) |other| {
            if (std.mem.eql(u8, word, other)) {
                return false;
            }
        }
    }

    return true;
}

fn hasNoAnagrams(passphrase: [][]u8) bool {
    for (passphrase) |word| {
        std.mem.sort(u8, word, {}, comptime std.sort.asc(u8));
    }

    return hasNoDuplicates(passphrase);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const passphrases = try parsePassPhrases(allocator);

    var part1: u32 = 0;
    var part2: u32 = 0;

    for (passphrases) |passphrase| {
        if (hasNoDuplicates(passphrase)) {
            part1 += 1;
        }

        if (hasNoAnagrams(passphrase)) {
            part2 += 1;
        }
    }

    std.debug.print("{}\n", .{part1});
    std.debug.print("{}\n", .{part2});
}
