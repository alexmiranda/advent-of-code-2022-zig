const std = @import("std");
const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

const Compartment = std.bit_set.IntegerBitSet(26 * 2);

fn sumPriorities(data: []const u8) usize {
    var it = std.mem.split(u8, data, "\n");
    var sum: usize = 0;
    while (it.next()) |rucksack| {
        if (rucksack.len == 0) continue;
        const middle = rucksack.len / 2;
        var first_compartment = to_set(rucksack[0..middle]);
        const second_compartment = to_set(rucksack[middle..]);
        first_compartment.setIntersection(second_compartment);
        sum += first_compartment.findFirstSet().? + 1;
    }
    return sum;
}

fn sumGroupPriorities(data: []const u8) usize {
    var it = std.mem.split(u8, data, "\n");
    var sum: usize = 0;
    var set = Compartment.initFull();
    var i: usize = 0;
    while (it.next()) |rucksack| {
        if (rucksack.len == 0) continue;
        i += 1;
        var compartment = to_set(rucksack);
        set.setIntersection(compartment);
        if (i % 3 == 0) {
            sum += set.findFirstSet().? + 1;
            set.setRangeValue(.{ .start = 0, .end = 52 }, true);
        }
    }
    return sum;
}

fn to_set(compartment: []const u8) Compartment {
    var set = Compartment.initEmpty();
    for (compartment) |item| {
        set.set(priority(item));
    }
    return set;
}

fn priority(item: u8) u8 {
    return if (item >= 'a') item - 'a' else item - 'A' + 26;
}

test "Example - part 1" {
    const answer = sumPriorities(example);
    try std.testing.expectEqual(@as(usize, 157), answer);
}

test "Input - part 1" {
    const answer = sumPriorities(input);
    try std.testing.expectEqual(@as(usize, 7848), answer);
}

test "Example - part 2" {
    const answer = sumGroupPriorities(example);
    try std.testing.expectEqual(@as(usize, 70), answer);
}

test "Input - part 2" {
    const answer = sumGroupPriorities(input);
    try std.testing.expectEqual(@as(usize, 2616), answer);
}
