const std = @import("std");
const input = @embedFile("input.txt");

pub fn findMarker(s: []const u8, comptime n: usize) usize {
    var set = std.bit_set.IntegerBitSet(26).initEmpty();
    var i = n;
    while (i < s.len) : (i += 1) {
        set.mask = 0;
        const received = s[i - n .. i];
        for (received) |char| {
            set.set(char - 'a');
        }
        if (set.count() == n) {
            return i;
        }
    }
    unreachable;
}

test "Example - part 1" {
    try std.testing.expectEqual(@as(usize, 7), findMarker("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 4));
    try std.testing.expectEqual(@as(usize, 5), findMarker("bvwbjplbgvbhsrlpgdmjqwftvncz", 4));
    try std.testing.expectEqual(@as(usize, 6), findMarker("nppdvjthqldpwncqszvftbrmjlhg", 4));
    try std.testing.expectEqual(@as(usize, 10), findMarker("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 4));
    try std.testing.expectEqual(@as(usize, 11), findMarker("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 4));
}

test "Input - part 1" {
    try std.testing.expectEqual(@as(usize, 1848), findMarker(input, 4));
}

test "Example - part 2" {
    try std.testing.expectEqual(@as(usize, 19), findMarker("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 14));
    try std.testing.expectEqual(@as(usize, 23), findMarker("bvwbjplbgvbhsrlpgdmjqwftvncz", 14));
    try std.testing.expectEqual(@as(usize, 23), findMarker("nppdvjthqldpwncqszvftbrmjlhg", 14));
    try std.testing.expectEqual(@as(usize, 29), findMarker("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 14));
    try std.testing.expectEqual(@as(usize, 26), findMarker("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 14));
}

test "Input - part 2" {
    try std.testing.expectEqual(@as(usize, 2308), findMarker(input, 14));
}
