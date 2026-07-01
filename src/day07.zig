const std = @import("std");
const Allocator = std.mem.Allocator;

const Attributes = struct { weight: u32, children: std.ArrayList([]const u8) };
const Node = struct { name: []const u8, attributes: Attributes };
const UniqueResult = struct { unique: usize, target: u32 };

fn parseInput(allocator: Allocator) !std.StringHashMap(Attributes) {
    const input = @embedFile("./input/day07");
    const trimmed = std.mem.trim(u8, input, "\n");

    var lines = std.mem.tokenizeSequence(u8, trimmed, "\n");
    var nodes: std.StringHashMap(Attributes) = .init(allocator);

    while (lines.next()) |line| {
        const node = try parseLine(allocator, line);
        try nodes.put(node.name, node.attributes);
    }

    return nodes;
}

fn parseNode(input: []const u8) !Node {
    const left, const right = splitOnce(u8, input, " ") orelse return error.ValueMissing;
    const number = right[1 .. right.len - 1];

    return Node{ .name = left, .attributes = Attributes{
        .weight = try std.fmt.parseInt(u32, number, 10),
        .children = .empty,
    } };
}

fn parseLine(allocator: Allocator, line: []const u8) !Node {
    if (splitOnce(u8, line, "->")) |tuple| {
        const left, const right = tuple;

        var node = try parseNode(left);
        var names = std.mem.tokenizeSequence(u8, right, ", ");

        while (names.next()) |next| {
            try node.attributes.children.append(allocator, next);
        }

        return node;
    } else {
        return try parseNode(line);
    }
}

fn splitOnce(comptime T: type, input: []const T, needle: []const T) ?[2][]const T {
    if (!std.mem.containsAtLeast(u8, input, 1, needle)) {
        return null;
    }

    var segments = std.mem.tokenizeSequence(T, input, needle);

    const left = segments.next().?;
    const right = segments.rest();
    const ltrimmed = std.mem.trim(u8, left, " ");
    const rtrimmed = std.mem.trim(u8, right, " ");

    return .{ ltrimmed, rtrimmed };
}

fn get(nodes: std.StringHashMap(Attributes), node: []const u8) !Attributes {
    return nodes.get(node) orelse return error.NodeNotFound;
}

fn size(nodes: std.StringHashMap(Attributes), node: []const u8) !u32 {
    const attr = try get(nodes, node);
    var total: u32 = 1;

    for (attr.children.items) |child| {
        total += try size(nodes, child);
    }

    return total;
}

fn treeWeight(nodes: std.StringHashMap(Attributes), node: []const u8) !u32 {
    const attr = try get(nodes, node);
    var total: u32 = attr.weight;

    for (attr.children.items) |child| {
        total += try treeWeight(nodes, child);
    }

    return total;
}

fn isDifferent(array: std.ArrayList(u32), i: usize) bool {
    for (0..array.items.len) |j| {
        if (i == j) {
            continue;
        }

        if (array.items[i] == array.items[j]) {
            return false;
        }
    }

    return true;
}

/// Given an ArrayList of at least length 3, finds which
/// value is different from all other values and returns
/// its index combined with the value it should have been
/// for all values in the array to be the same.
///
/// This assumes up to one value being different, no more.
fn findUnique(array: std.ArrayList(u32)) ?UniqueResult {
    if (array.items.len < 3) {
        return null;
    }

    for (0..array.items.len) |i| {
        if (isDifferent(array, i)) {
            return UniqueResult{
                .unique = i,
                .target = array.items[(i + 1) % array.items.len],
            };
        }
    }

    return null;
}

fn findRoot(nodes: std.StringHashMap(Attributes)) ![]const u8 {
    const count = nodes.count();
    var iter = nodes.keyIterator();

    while (iter.next()) |key| {
        if (try size(nodes, key.*) == count) {
            return key.*;
        }
    }

    return error.RootNotFound;
}

fn adjustWeight(weight: u32, children: u32, target: u32) u32 {
    const effective: u32 = weight + children;
    const diff = @max(effective, target) - @min(effective, target);

    if (effective > target) {
        return weight - diff;
    } else {
        return weight + diff;
    }
}

fn findWrongNode(allocator: Allocator, nodes: std.StringHashMap(Attributes), node: []const u8, target: ?u32) !u32 {
    const attr = try get(nodes, node);

    // compute the weight of each of my children
    // and their total
    var weights: std.ArrayList(u32) = .empty;
    var chidrenTotal: u32 = 0;

    for (attr.children.items) |child| {
        const w = try treeWeight(nodes, child);
        try weights.append(allocator, w);
        chidrenTotal += w;
    }

    // if any of my children is different from the others
    if (findUnique(weights)) |result| {
        // Then fix either that children or one of its chidlren
        // recursively.
        if (findWrongNode(allocator, nodes, attr.children.items[result.unique], result.target) catch null) |fix| {
            return fix;
        }
    }

    // otherwise, I may be the problem. If the target is not null
    if (target) |t| {
        // then I am the problem
        return adjustWeight(attr.weight, chidrenTotal, t);
    }

    // otherwise I'm the root and can't be the problem
    // but we failed to find a solution
    return error.NoInvalidNodeFound;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const nodes = try parseInput(allocator);

    const part1 = try findRoot(nodes);
    std.debug.print("{s}\n", .{part1});

    const part2 = try findWrongNode(allocator, nodes, part1, null);
    std.debug.print("{}\n", .{part2});
}
