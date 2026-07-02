const std = @import("std");
const Allocator = std.mem.Allocator;

const ConditionType = enum {
    Lt,
    Le,
    Eq,
    Ne,
    Ge,
    Gt,
};

const InstructionType = enum { Inc, Dec };

const Context = struct {
    registers: std.StringHashMap(i64),
    max: ?i64,
};

const Condition = struct {
    type: ConditionType,
    register: []const u8,
    value: i64,
    fn isTrue(self: *const Condition, registers: *std.StringHashMap(i64)) bool {
        const value: i64 = registers.get(self.register) orelse 0;

        return switch (self.type) {
            ConditionType.Lt => value < self.value,
            ConditionType.Le => value <= self.value,
            ConditionType.Eq => value == self.value,
            ConditionType.Ne => value != self.value,
            ConditionType.Ge => value >= self.value,
            ConditionType.Gt => value > self.value,
        };
    }
};

const Instruction = struct {
    type: InstructionType,
    destination: []const u8,
    by: i64,
    condition: Condition,
    fn execute(self: *const Instruction, registers: *std.StringHashMap(i64)) !?i64 {
        if (!self.condition.isTrue(registers)) {
            return null;
        }

        const value: i64 = registers.get(self.destination) orelse 0;

        const updated: i64 = switch (self.type) {
            InstructionType.Inc => value + self.by,
            InstructionType.Dec => value - self.by,
        };

        try registers.put(self.destination, updated);

        return updated;
    }
};

fn parseConditionType(input: []const u8) !ConditionType {
    if (std.mem.eql(u8, input, "<")) {
        return ConditionType.Lt;
    }
    if (std.mem.eql(u8, input, "<=")) {
        return ConditionType.Le;
    }
    if (std.mem.eql(u8, input, "==")) {
        return ConditionType.Eq;
    }
    if (std.mem.eql(u8, input, "!=")) {
        return ConditionType.Ne;
    }
    if (std.mem.eql(u8, input, ">=")) {
        return ConditionType.Ge;
    }
    if (std.mem.eql(u8, input, ">")) {
        return ConditionType.Gt;
    }

    return error.InvalidConditionType;
}

fn parseInstructionType(input: []const u8) !InstructionType {
    if (std.mem.eql(u8, input, "inc")) {
        return InstructionType.Inc;
    }
    if (std.mem.eql(u8, input, "dec")) {
        return InstructionType.Dec;
    }

    return error.InvalidInstructionType;
}

fn tokenizeLine(comptime n: usize, line: []const u8) ![n][]const u8 {
    var it = std.mem.tokenizeScalar(u8, line, ' ');
    var parts: [n][]const u8 = undefined;

    for (&parts) |*p| {
        p.* = it.next() orelse return error.InvalidLine;
    }

    return parts;
}

fn parseCondition(parts: [3][]const u8) !Condition {
    return Condition{
        .register = parts[0],
        .type = try parseConditionType(parts[1]),
        .value = try std.fmt.parseInt(i64, parts[2], 10),
    };
}

fn parseInstruction(parts: [7][]const u8) !Instruction {
    return Instruction{
        .destination = parts[0],
        .type = try parseInstructionType(parts[1]),
        .by = try std.fmt.parseInt(i64, parts[2], 10),
        .condition = try parseCondition(parts[4..].*),
    };
}

fn parseInstructions(allocator: Allocator) ![]Instruction {
    const input = @embedFile("./input/day08");
    const trimmed = std.mem.trim(u8, input, "\n");

    var lines = std.mem.tokenizeSequence(u8, trimmed, "\n");
    var instructions: std.ArrayList(Instruction) = .empty;

    while (lines.next()) |line| {
        const parts = try tokenizeLine(7, line);
        const instruction = try parseInstruction(parts);
        try instructions.append(allocator, instruction);
    }

    return instructions.items;
}

fn maxRegister(registers: std.StringHashMap(i64)) i64 {
    var iter = registers.valueIterator();
    var value: ?i64 = null;

    while (iter.next()) |i| {
        value = @max(value orelse 0, i.*);
    }

    return value orelse 0;
}

fn execute(allocator: Allocator, instructions: []Instruction) ![2]i64 {
    var registers: std.StringHashMap(i64) = .init(allocator);
    var part2: ?i64 = null;

    for (instructions) |i| {
        if (try i.execute(&registers)) |value| {
            part2 = @max(part2 orelse 0, value);
        }
    }

    const part1 = maxRegister(registers);

    return .{
        part1,
        part2 orelse 0,
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const instructions = try parseInstructions(allocator);
    const part1, const part2 = try execute(allocator, instructions);

    std.debug.print("{}\n", .{part1});
    std.debug.print("{}\n", .{part2});
}
