const std = @import("std");
const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

fn part1(str: []const u8) !u32 {
    var it = std.mem.split(u8, str, "\n");
    var sum: u32 = 0;
    var max: u32 = 0;
    while (it.next()) |line| {
        if (line.len == 0) {
            max = if (max > sum) max else sum;
            sum = 0;
            continue;
        }
        sum += try std.fmt.parseInt(u32, line, 10);
    }
    return max;
}

fn part2(str: []const u8) !u32 {
    var it = std.mem.split(u8, str, "\n");
    var sum: u32 = 0;
    var max: [3]u32 = .{ 0, 0, 0 };
    while (it.next()) |line| {
        if (line.len == 0) {
            if (sum >= max[0]) {
                max[2] = max[1];
                max[1] = max[0];
                max[0] = sum;
            } else if (sum >= max[1]) {
                max[2] = max[1];
                max[1] = sum;
            } else if (sum > max[2]) {
                max[2] = sum;
            }
            sum = 0;
            continue;
        }
        sum += try std.fmt.parseInt(u32, line, 10);
    }
    return max[0] + max[1] + max[2];
}

test "example - part 1" {
    const answer = try part1(example);
    try std.testing.expectEqual(@as(u32, 24000), answer);
}

test "input - part 1" {
    const answer = try part1(input);
    try std.testing.expectEqual(@as(u32, 71780), answer);
}

test "example - part 2" {
    const answer = try part2(example);
    try std.testing.expectEqual(@as(u32, 45000), answer);
}

test "input - part 2" {
    const answer = try part2(input);
    try std.testing.expectEqual(@as(u32, 212489), answer);
}
