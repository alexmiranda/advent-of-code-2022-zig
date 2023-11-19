const std = @import("std");
const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

const Hand = enum {
    rock,
    paper,
    scissor,

    fn from_u8(character: u8) ?@This() {
        const val = if (character >= 'X') character - 'X' else character - 'A';
        inline for (@typeInfo(Hand).Enum.fields, 0..) |field, i| {
            if (i == val) return @field(Hand, field.name);
        }
        return null;
    }

    fn score(self: @This()) u32 {
        return @intFromEnum(self) + 1;
    }
};

const Result = enum {
    win,
    draw,
    lose,

    fn from_u8(character: u8) ?@This() {
        return switch (character) {
            'X' => .lose,
            'Y' => .draw,
            'Z' => .win,
            else => null,
        };
    }

    fn choose_hand(self: @This(), opponent_hand: Hand) Hand {
        return switch (self) {
            .win => switch (opponent_hand) {
                .rock => .paper,
                .paper => .scissor,
                .scissor => .rock,
            },
            .draw => opponent_hand,
            .lose => Result.win.choose_hand(Result.win.choose_hand(opponent_hand)),
        };
    }
};

fn totalScore(str: []const u8) u32 {
    var it = std.mem.splitAny(u8, str, "\n");
    var total_score: u32 = 0;
    while (it.next()) |line| {
        if (line.len == 0) continue;
        const opponent_hand = Hand.from_u8(line[0]).?;
        const my_hand = Hand.from_u8(line[2]).?;
        const round_score = roundScore(opponent_hand, my_hand);
        total_score += round_score;
    }
    return total_score;
}

fn totalScoreRevised(str: []const u8) u32 {
    var it = std.mem.splitAny(u8, str, "\n");
    var total_score: u32 = 0;
    while (it.next()) |line| {
        if (line.len == 0) continue;
        const opponent_hand = Hand.from_u8(line[0]).?;
        const expected_result = Result.from_u8(line[2]).?;
        const my_hand = expected_result.choose_hand(opponent_hand);
        const round_score = roundScore(opponent_hand, my_hand);
        total_score += round_score;
    }
    return total_score;
}

fn roundScore(opponent_hand: Hand, my_hand: Hand) u32 {
    return switch (opponent_hand) {
        .rock => switch (my_hand) {
            .rock => @as(u32, 3),
            .paper => @as(u32, 6),
            .scissor => @as(u32, 0),
        },
        .paper => switch (my_hand) {
            .rock => @as(u32, 0),
            .paper => @as(u32, 3),
            .scissor => @as(u32, 6),
        },
        .scissor => switch (my_hand) {
            .rock => @as(u32, 6),
            .paper => @as(u32, 0),
            .scissor => @as(u32, 3),
        },
    } + my_hand.score();
}

test "Example - part 1" {
    const answer = totalScore(example);
    try std.testing.expectEqual(@as(u32, 15), answer);
}

test "Input - part 1" {
    const answer = totalScore(input);
    try std.testing.expectEqual(@as(u32, 17189), answer);
}

test "Example - part 2" {
    const answer = totalScoreRevised(example);
    try std.testing.expectEqual(@as(u32, 12), answer);
}

test "Input - part 2" {
    const answer = totalScoreRevised(input);
    try std.testing.expectEqual(@as(u32, 13490), answer);
}
