const std = @import("std");
const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

const AssignmentPair = struct {
    a1: u8,
    a2: u8,
    b1: u8,
    b2: u8,

    fn from(s: []const u8) !@This() {
        const first_sep = std.mem.indexOfScalar(u8, s, '-').?;
        const a1 = try std.fmt.parseInt(u8, s[0..first_sep], 10);
        const comma = std.mem.indexOfPosLinear(u8, s, first_sep + 2, ",").?;
        const a2 = try std.fmt.parseInt(u8, s[first_sep + 1 .. comma], 10);
        const second_sep = std.mem.indexOfPosLinear(u8, s, comma + 2, "-").?;
        const b1 = try std.fmt.parseInt(u8, s[comma + 1 .. second_sep], 10);
        const b2 = try std.fmt.parseInt(u8, s[second_sep + 1 ..], 10);
        return .{
            .a1 = a1,
            .a2 = a2,
            .b1 = b1,
            .b2 = b2,
        };
    }

    fn isFullyContained(self: @This()) bool {
        return (self.a1 <= self.b1 and self.a2 >= self.b2) or
            (self.b1 <= self.a1 and self.b2 >= self.a2);
    }

    fn isOverlapping(self: @This()) bool {
        return (self.a1 >= self.b1 and self.a1 <= self.b2) or
            (self.a2 >= self.b1 and self.a2 <= self.b2) or
            (self.b1 >= self.a1 and self.b1 <= self.a2) or
            (self.b2 >= self.a1 and self.b2 <= self.a2);
    }
};

fn countFullyContained(s: []const u8) !usize {
    var counter: usize = 0;
    var it = std.mem.splitAny(u8, s, "\n");
    while (it.next()) |line| {
        if (line.len == 0) continue;
        const pair = try AssignmentPair.from(line);
        if (pair.isFullyContained()) {
            counter += 1;
        }
    }
    return counter;
}

fn countOverlapping(s: []const u8) !usize {
    var counter: usize = 0;
    var it = std.mem.splitAny(u8, s, "\n");
    while (it.next()) |line| {
        if (line.len == 0) continue;
        const pair = try AssignmentPair.from(line);
        if (pair.isOverlapping()) {
            counter += 1;
        }
    }
    return counter;
}

test "Example - part 1" {
    try std.testing.expectEqual(@as(usize, 2), try countFullyContained(example));
}

test "Input - part 1" {
    try std.testing.expectEqual(@as(usize, 477), try countFullyContained(input));
}

test "Example - part 2" {
    try std.testing.expectEqual(@as(usize, 4), try countOverlapping(example));
}

test "Input - part 2" {
    try std.testing.expectEqual(@as(usize, 830), try countOverlapping(input));
}

test "assignment pairs" {
    const pair = try AssignmentPair.from("18-20,19-21");
    try std.testing.expectEqual(@as(u8, 18), pair.a1);
    try std.testing.expectEqual(@as(u8, 20), pair.a2);
    try std.testing.expectEqual(@as(u8, 19), pair.b1);
    try std.testing.expectEqual(@as(u8, 21), pair.b2);
}
