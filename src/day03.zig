const std = @import("std");
const Allocator = std.mem.Allocator;
const math = std.math;

fn updateDirection(x: i64, y: i64, dx: *i64, dy: *i64) void {
    if (@abs(x) == @abs(y)) {
        if (x > 0 and y < 0) {
            dy.* = 0;
            dx.* = -1;
        } else if (x < 0 and y < 0) {
            dy.* = 1;
            dx.* = 0;
        } else if (x < 0 and y > 0) {
            dy.* = 0;
            dx.* = 1;
        }
    }
}

fn getPosition(targetX: i64, targetY: i64) u64 {
    const depth = @max(@abs(targetX), @abs(targetY));

    if (depth == 0) {
        return 1;
    }

    const previousDepth = depth - 1;
    const size = ((previousDepth) * 2) + 1;

    var x: i64 = @intCast(previousDepth);
    var y = x;

    var position = (size * size);

    if (targetX == x and targetY == y) {
        return position;
    }

    x += 1;
    position += 1;

    var dy: i64 = -1;
    var dx: i64 = 0;

    while (targetX != x or targetY != y) {
        updateDirection(x, y, &dx, &dy);
        x += dx;
        y += dy;
        position += 1;
    }

    return position;
}

fn getCoordinates(position: u64) [2]i64 {
    var size = math.sqrt(position);

    if (size % 2 == 0) {
        size -= 1;
    }

    const depth = (size - 1) / 2;
    var offset = position - (size * size);

    var x: i64 = @intCast(depth);
    var y: i64 = x;

    if (offset != 0) {
        x += 1;
        offset -= 1;

        var dy: i64 = -1;
        var dx: i64 = 0;

        while (offset > 0) {
            updateDirection(x, y, &dx, &dy);
            x += dx;
            y += dy;
            offset -= 1;
        }
    }

    return .{ x, y };
}

fn count(position: u64, cache: *std.AutoHashMap(u64, u64)) !u64 {
    if (position == 1) {
        return 1;
    }

    if (cache.get(position)) |cached| {
        return cached;
    }

    const x, const y = getCoordinates(position);

    var total: u64 = 0;

    for ([3]i64{ -1, 0, 1 }) |i| {
        for ([3]i64{ -1, 0, 1 }) |j| {
            if (i == 0 and j == 0) {
                continue;
            }

            const other = getPosition(x + i, y + j);

            if (other < position) {
                total += try count(other, cache);
            }
        }
    }

    try cache.put(position, total);

    return total;
}

fn part2(target: u64) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var cache: std.AutoHashMap(u64, u64) = .init(allocator);
    var position: u64 = 1;

    while (true) {
        const value = try count(position, &cache);

        if (value > target) {
            return value;
        }

        position += 1;
    }
}

fn part1(position: u64) u64 {
    const x, const y = getCoordinates(position);
    return @abs(x) + @abs(y);
}

pub fn main() !void {
    const input: u64 = 289326;
    std.debug.print("{any}\n", .{part1(input)});
    std.debug.print("{any}\n", .{part2(input)});
}
